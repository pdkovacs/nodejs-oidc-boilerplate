include "root" {
  path = find_in_parent_folders()
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy"]

    arguments = [
      "-var-file=../common.tfvars",
    ]
  }
}

dependencies {
  paths = ["../ecs"]
}
