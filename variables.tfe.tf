variable "replicated_password" {
  type        = string
  description = "Password to set for the replicated console."
}

variable "tfe_hostname" {
  type        = string
  description = "Hostname which will be used to access the tfe instance."
}

variable "tfe_release_sequence" {
  type        = number
  description = "The release sequence corresponding to the TFE version which should be installed."
}

variable "tfe_settings" {
  type        = map(string)
  description = "Key/Value pairs to generate the TFE settings file as described on https://www.terraform.io/docs/enterprise/install/automating-the-installer.html#available-settings ."
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