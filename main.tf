# Create a stack for each path after filtering out ignore_paths
resource "spacelift_stack" "dynamic_stacks" {
  for_each = local.stacks_clean_folders_filtered

  name              = each.key
  administrative    = contains(local.administrative_paths, each.key)
  autodeploy        = true
  project_root      = each.key
  repository        = "dynamic-spacelift-stacks-example"
  branch            = "main"
  terraform_version = "1.2.3"

  labels = [
    "dynamic"
  ]

  github_enterprise {
    namespace = "spacelift-io-examples"
  }
}

# Triggers the stack after creation
resource "spacelift_run" "this" {
  for_each = local.stacks_clean_folders_filtered

  stack_id = spacelift_stack.dynamic_stacks[each.key].id
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
