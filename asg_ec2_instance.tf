locals {
  tfe_settings = { for k, v in var.tfe_settings : k => { "value" = v } }
}

resource "aws_launch_configuration" "tfe" {
  name_prefix                 = "${var.name_prefix}v${var.replicated_tfe_release_sequence}-"
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
      tfe_hostname         = var.replicated_tls_bootstrap_hostname
      replicated_password  = var.replicated_password
      tfe_release_sequence = var.replicated_tfe_release_sequence
    }))
    tfe_settings_b64content = base64gzip(jsonencode(local.tfe_settings))
    install_wrapper_b64content = base64gzip(templatefile("${path.module}/templates/install_wrap.sh.tmpl", {
      replicated_install_args = join(" ", var.replicated_install_args)
    }))
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
  name                      = "${var.name_prefix}tfe-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
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