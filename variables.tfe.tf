variable "replicated_password" {
  type        = string
  description = "Password to set for the replicated console."
}

variable "replicated_tls_bootstrap_hostname" {
  type        = string
  description = "Hostname which will be used to access the tfe instance."
}

variable "replicated_tfe_release_sequence" {
  type        = number
  description = "The release sequence corresponding to the TFE version which should be installed."
}

variable "replicated_install_args" {
  type        = list(string)
  description = "Replicated installer script arguments as defined on https://help.replicated.com/docs/native/customer-installations/installing-via-script/#flags . Must not contain the `private-address` and `public-address` flags."
  default     = ["no-proxy"]
}

variable "tfe_settings" {
  type        = map(string)
  description = "Key/Value pairs to generate the TFE settings file as described on https://www.terraform.io/docs/enterprise/install/automating-the-installer.html#available-settings . The user is responsible to provide all required values that make sense for the type of installation."
}

variable "installation_assets_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket containing the installation assets - ssl certificate, ssl certificate key and tfe license."
}

variable "tfe_license_s3_path" {
  type        = string
  description = "S3 Path to the TFE license .rli file."
}

variable "tfe_cert_s3_path" {
  type        = string
  description = "S3 Path to the file containing the certificate chain which should be presented by the TFE."
}

variable "tfe_privkey_s3_path" {
  type        = string
  description = "S3 Path to the file containing the private key for the certificate which should be presented by the TFE."
}