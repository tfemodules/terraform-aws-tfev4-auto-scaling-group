# TFEv4 Auto Scaling Group - EC2 Instance

A Terraform configuration to build an Auto Scaling Group which brings up EC2 instance with TFEv4 installed. The TFE installation will be in external services mode using AWS S3 and AWS PostgreSQL RDS.

## Description

The Terraform configuration provisions:

- An AWS role which allows the created EC2 instance full access to S3 resources

- Security group which allows network traffic from the EC2 instance according to the TFE [documentation](https://www.terraform.io/docs/enterprise/before-installing/network-requirements.html).

- Auto Scaling Group which will bring up a single EC2 instance and register it in provided target groups.

- Launch Configuration for the EC2 instance which is based on the specified AMI. The user data will be set to:
  
  - create an `/ect/replicated.conf` file based on the input variables.
  - create an `/opt/tfe-installer/settings.conf` file based on the input variables.
  - Run the replicated installation script according to the TFE [documentation](https://www.terraform.io/docs/enterprise/install/automating-the-installer.html) using the created settings files.

## Requirements

* Terraform `>= 0.13`
* AWS provider `~> 3.0`

## Input Variables

The available input variables for the module are described in the table below.

| Variable | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| vpc_id | `string` | | Id of the VPC in which to deploy the TFE instance. |
| subnets_ids | `list(string)` | | List of subnet ids in which to create TFE instance. |
| ingress_cidrs_http | `list(string)` | `["0.0.0.0/0"]` | CIDRs from which HTTP/HTTPS ingress traffic to the TFE instance is allowed. |
| ingress_cidrs_replicated_dashboard | `list(string)` | `["0.0.0.0/0"]` | CIDRs from which ingress traffic to the TFE instance is allowed. |
| ingress_cidrs_ssh | `list(string)` | `["0.0.0.0/0"]` | CIDRs from which ingress traffic to the TFE instance is allowed. |
| ami_id | `string` | | The AMI Id to use for the TFE instance. |
| key_name | `string` | | Name of the AWS key pair to use for the TFE instance. |
| common_tags | `map(string)` | `{}` | Tags to apply to all resources. |
| instance_type | `string` | `m5a.large` | The AWS instance type to use. |
| name_prefix | `string` | `"tfev4-"` | Name prefix to use when creating names for resources. |
| root_block_device_size | `number` | `50` | The size of the root block device volume in gigabytes. |
| associate_public_ip_address | `bool` | `false` | Wether to associate public ip address with the instance. Should be false except if bringing a standalone instance for testing. |
| target_groups_arns | `list(string)` | | List of target group arns in which to register the auto scaling group instances. |
| health_check_type | `string` | `"ELB"` | Sets the healthcheck type for the auto scaling group. Accepted values ELB, EC2. |
| asg_lifecycle_hook_default_result | `string` | `"ABANDON"` | Sets the default action for the Auto Scaling group initial lifecycle hook. Can be ABANDON or CONTINUE. |
| replicated_password | `string` | | Password to set for the replicated console. |
| tfe_hostname | `string` | | Hostname which will be used to access the tfe instance. |
| tfe_enc_password | `string` | | Encryption password to be used by TFE. |
| tfe_release_sequence | `number` | | The release sequence corresponding to the TFE version which should be installed. |
| installation_assets_s3_bucket_name | `string` | | The name of the S3 bucket containing the installation assets - ssl certificate, ssl certificate key and tfe license. |
| tfe_license_s3_path | `string` | | S3 Path to the TFE license .rli file. |
| tfe_cert_s3_path | `string` | | S3 Path to the file containing the certificate chain which should be presented by the TFE. |
| tfe_privkey_s3_path | `string` | | S3 Path to the file containing the private key for the certificate which should be presented by the TFE. |
| tfe_ca_bundle | `string` | "``" | The additional CA certificates to add to TFE. Value needs to be a string with new line characters replaced with literal \n. |
| tfe_pg_address | `string` | | Address of the PostGRE data base to be used by TFE. Must contain hostname and optionally a port. |
| tfe_pg_dbname | `string` | | Name of the PostGRE data base to be used by TFE. |
| tfe_pg_user | `string` | | Username tfe will use to access the PostGRE data base. |
| tfe_pg_password | `string` | | Password tfe will use to access the PostGRE data base. |
| tfe_s3_bucket | `string` | | Name of the S3 bucket tfe will use for object storage. |
| tfe_s3_region | `string` | | AWS region of the S3 bucket tfe will use for object storage. |

## Outputs

The outputs defined for the module are described in the table below.

| Output | Type | Description |
| -------- | ---- | ----------- |
| tfe_asg_name | `string` | The name of the TFE Auto Scaling group. |
