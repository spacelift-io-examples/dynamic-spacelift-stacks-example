locals {
  # The paths of folders to create administrative stacks for
  administrative_paths = [
    "topLevel-1"
  ]
  # Any folders to ignore and not create stacks for
  ignore_paths = ["main.tf"]
  # Raw list of paths
  stack_paths_raw = fileset(path.module, "**/main.tf")
  # List of folders without file ending (e.g. without /main.tf ending)
  stacks_clean_folders = [for file_path in local.stack_paths_raw : replace("${file_path}", "/main.tf", "")]
  # List of folder paths excluding the list of ignore paths
  stacks_clean_folders_filtered = setsubtract(local.stacks_clean_folders, toset(local.ignore_paths))
}
