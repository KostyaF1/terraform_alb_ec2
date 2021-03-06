data "aws_availability_zones" "available" {}

data "template_file" "init" {
  template = "${file("${var.template_path}init.tpl")}"

  vars {
    conf_file_name = "${var.conf_file_name}"
    remote_conf_file_path_nginx = "${var.remote_conf_file_path_nginx}"
    remote_static_file_path = "${var.remote_static_file_path}"
    remote_tmp_path_nginx = "${var.remote_tmp_path_nginx}"
  }
}

data "aws_subnet_ids" "task9_subnets" {
  depends_on = ["aws_subnet.task9_subnet"]
  vpc_id = "${aws_vpc.task9_vpc.id}"
}

data "aws_ami" "nat_ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["ami-ubuntu-16.04*"]
  }
}


# Templates
data "template_file" "task9_ec2_policy" {
  template = "${file("${var.template_path}task9_ec2_policy.json.tpl")}"

  vars {
    ec2_addresses = "${aws_instance.task9_instance.*.public_ip[count.index]}"
    s3_resource = "${aws_s3_bucket.task9_s3.arn}"
    elb_resource = "${aws_lb.task9-lb.arn}"
  }
}

data "template_file" "task9_s3_policy" {
  template = "${file("${var.template_path}s3_policy.json.tpl")}"
  vars {
    ec2_addresses = "${element(aws_instance.task9_instance.*.private_ip, count.index)}"
    s3_resource = "${aws_s3_bucket.task9_s3.arn}"
  }
}

data "template_file" "task9_ec2_role" {
  template = "${file("${var.template_path}task9_ec2_role.json.tpl")}"

}

data "template_file" "task9_nginx_conf" {
  template = "${file("${var.template_path}task9_ml.conf.tpl")}"
  vars {
    remote_static_file_path = "${var.remote_static_file_path}"
  }
}