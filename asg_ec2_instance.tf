resource "aws_launch_configuration" "tfe" {
  name_prefix                 = "${var.name_prefix}v${var.tfe_release_sequence}-"
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.tfe_instance.name
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  security_groups             = [aws_security_group.tfe_instance.id]
  root_block_device {
    volume_size = var.root_block_device_size
  }
  user_data_base64 = base64encode(templatefile("${path.module}/templates/cloud-init.tmpl", {
    replicated_conf_b64content = base64gzip(templatefile("${path.module}/templates/replicated.conf.tmpl", {
      tfe_hostname         = var.tfe_hostname
      replicated_password  = var.replicated_password
      tfe_release_sequence = var.tfe_release_sequence
    }))
    tfe_settings_b64content = base64gzip(templatefile("${path.module}/templates/settings.json.tmpl", {
      tfe_enc_password = var.tfe_enc_password
      tfe_hostname     = var.tfe_hostname
      tfe_pg_dbname    = var.tfe_pg_dbname
      tfe_pg_address   = var.tfe_pg_address
      tfe_pg_password  = var.tfe_pg_password
      tfe_pg_user      = var.tfe_pg_user
      tfe_s3_bucket    = var.tfe_s3_bucket
      tfe_s3_region    = var.tfe_s3_region
      tfe_ca_bundle    = var.tfe_ca_bundle
    }))
    install_wrapper_b64content = base64gzip(templatefile("${path.module}/templates/install_wrap.sh.tmpl", {}))
    download_assets_b64content = base64gzip(templatefile("${path.module}/templates/download_assets.sh.tmpl", {
      tfe_cert_s3_path    = var.tfe_cert_s3_path
      tfe_privkey_s3_path = var.tfe_privkey_s3_path
      tfe_license_s3_path = var.tfe_license_s3_path
    }))
  }))
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tfe" {
  name                      = local.asg_name
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 1800
  health_check_type         = var.health_check_type
  launch_configuration      = aws_launch_configuration.tfe.name
  vpc_zone_identifier       = var.subnets_ids
  target_group_arns         = var.target_groups_arns
  wait_for_capacity_timeout = 0 # installing / starting tfe can take ~30-40 mins so no point terraform waiting for capacity.
  dynamic "tag" {
    for_each = merge({ Name = "${var.name_prefix}instance" }, var.common_tags)
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  timeouts {
    delete = "30m"
  }
}