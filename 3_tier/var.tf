variable "location" {}
variable "rg" {}

# Network details
variable "vnetcidr" {}
variable "websubnetcidr" {}
variable "appsubnetcidr" {}
variable "dbsubnetcidr" {}

# Credential to be given during run time 
variable "passwordos" {}
variable "passworddb" {}