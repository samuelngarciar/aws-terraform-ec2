# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "project_name" {
  type        = string
  description = "Name of the example project."

  default     = "newinstance"
}

variable "ttl" {
  type        = string
  description = "Value for TTL tag."

  default     = "1"
}
