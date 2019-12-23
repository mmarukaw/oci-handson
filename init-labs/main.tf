// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

variable "base_compartment_id" {}
variable "lab_count" {}
variable lab_regions {
  type = list(string)
}


# Groups
resource "oci_identity_group" "lab_groups" {
  count          = "${var.lab_count}"
  name           = "group-${var.lab_regions[count.index % length(var.lab_regions)]}-${floor(count.index / length(var.lab_regions)) + 1}"
  description    = "Hands on lab group for ${var.lab_regions[count.index % length(var.lab_regions)]}-${floor(count.index / length(var.lab_regions)) + 1}"
  compartment_id = "${var.tenancy_ocid}"
}

# Users
resource "oci_identity_user" "lab_users" {
  count          = "${var.lab_count}"
  name           = "user-${var.lab_regions[count.index % length(var.lab_regions)]}-${floor(count.index / length(var.lab_regions)) + 1}"
  description    = "Hands on lab user for ${var.lab_regions[count.index % length(var.lab_regions)]}-${floor(count.index / length(var.lab_regions)) + 1}"
  compartment_id = "${var.tenancy_ocid}"
}

output "lab_users" {
  value = {
    for user in oci_identity_user.lab_users:
      user.id => user.name
  }
}

# User group membership
resource "oci_identity_user_group_membership" "lab_user_group_memberships" {
  depends_on     = [oci_identity_user.lab_users, oci_identity_group.lab_groups]
  count          = "${var.lab_count}"
  group_id       = "${oci_identity_group.lab_groups[count.index].id}"
  user_id        = "${oci_identity_user.lab_users[count.index].id}"
}

# Passwords
resource "oci_identity_ui_password" "lab_passwords" {
  depends_on     = [oci_identity_user.lab_users]
  count          = "${var.lab_count}"
  user_id        = "${oci_identity_user.lab_users[count.index].id}"
} 

output "lab_passwords" {
  value = {
    for password in oci_identity_ui_password.lab_passwords:
      password.user_id => password.password
  }
}

# Compatments
resource "oci_identity_compartment" "lab_compartments" {
  count          = "${var.lab_count}"
  name           = "${var.lab_regions[count.index % length(var.lab_regions)]}-${floor(count.index / length(var.lab_regions)) + 1}"
  description    = "Hands on lab compartment for ${var.lab_regions[count.index % length(var.lab_regions)]}-${floor(count.index / length(var.lab_regions)) + 1}"
  compartment_id = "${var.base_compartment_id}"
  enable_delete  = false // true will cause this compartment to be deleted when running `terrafrom destroy`
}

# Policies
resource "oci_identity_policy" "lab_policies" {
  depends_on     = [oci_identity_compartment.lab_compartments, oci_identity_group.lab_groups]
  count          = floor((var.lab_count - 1) / 50) + 1
  name           = "lab_policy_${count.index}"
  description    = "Hands on lab policy ${count.index}"
  compartment_id = "${var.base_compartment_id}"

  statements   = [for i in range(((count.index) * 50), min(((count.index + 1) * 50), var.lab_count)) : "Allow group group-${var.lab_regions[i % length(var.lab_regions)]}-${floor(i / length(var.lab_regions)) + 1} to manage all-resources in compartment ${var.lab_regions[i % length(var.lab_regions)]}-${floor(i / length(var.lab_regions)) + 1} where all{request.region='${var.lab_regions[i % length(var.lab_regions)]}', request.permission != 'COMPARTMENT_CREATE', request.permission != 'TAG_NAMESPACE_CREATE'}"]
}

