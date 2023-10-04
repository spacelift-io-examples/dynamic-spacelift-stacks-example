# Create a stack for each path after filtering out ignore_paths
resource "spacelift_stack" "dynamic_stacks" {
  for_each = local.stacks_clean_folders_filtered

  name              = "${local.stack_name_prefix} : ${upper(var.aws_account)} : ${each.key}"
  description       = "${each.key} ${local.description_suffix}"
  administrative    = contains(local.administrative_paths, each.key)
  autodeploy        = true
  project_root      = each.key
  repository        = var.repository_name
  branch            = var.branch_name
  terraform_version = var.terraform_version

  labels = concat(local.stack_labels, local.push_policy_labels, [
    "folder:Infra/AWS-Account/${var.aws_account}",
    "terraform",
    var.repository_name,
  ])
  space_id     = var.space_id
  runner_image = "ghcr.io/vimn-public/spacelift-runner-terraform:main"
#  before_init = [
#    "before_init",
#  ]
}

# Triggers the stack after creation
resource "spacelift_run" "this" {
  for_each = local.stacks_clean_folders_filtered

  stack_id = spacelift_stack.dynamic_stacks[each.key].id
}

#context is tidy related with the integration
resource "spacelift_context_attachment" "default" {
  stack_id   = spacelift_stack.dynamic_stacks.id
  context_id = var.context_id
  priority   = 0
}

resource "spacelift_aws_integration_attachment" "default" {
  stack_id       = spacelift_stack.dynamic_stacks.id
  integration_id = var.cloud_integration_id
  read           = true
  write          = true
}

# Create the ignore changes outside root policy from file
resource "spacelift_policy" "ignore_changes_outside_root_policy" {
  name = "Ignore changes outside root."
  body = file("${path.module}/policies/ignore-changes-outside-root.rego")
  type = "GIT_PUSH"
}

# Attach the ignore changes outside root policy to each stack
resource "spacelift_policy_attachment" "ignore_changes_outside_root_attachment" {
  for_each = local.stacks_clean_folders_filtered

  policy_id = spacelift_policy.ignore_changes_outside_root_policy.id
  stack_id  = spacelift_stack.dynamic_stacks[each.key].id
}
