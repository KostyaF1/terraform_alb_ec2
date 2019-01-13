provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.regions["Europe"]}"
}

resource "aws_vpc" "task9_vpc" {
  cidr_block       = "10.192.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.tag_name}-vpc"
  }
}

resource "aws_internet_gateway" "task9_internet_gateway" {
  vpc_id = "${aws_vpc.task9_vpc.id}"

  tags = {
    Name = "${var.tag_name}-ig"
  }
}

resource "aws_subnet" "task9_subnet" {
  count = 2
  cidr_block = "${element(var.cidr, count.index)}"
  vpc_id = "${aws_vpc.task9_vpc.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.tag_name}-subnet"
  }
}

resource "aws_route_table" "task9_route_table" {
  count = 2
  vpc_id = "${aws_vpc.task9_vpc.id}"
  tags = {
    Name = "${var.tag_name}-rt"
  }
}

resource "aws_route" "task9_route" {
  count = 2
  route_table_id = "${element(aws_route_table.task9_route_table.*.id, count.index)}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.task9_internet_gateway.id}"
}

resource "aws_route_table_association" "task9_rta" {
  count = 2
  subnet_id      = "${element(data.aws_subnet_ids.task9_subnets.ids, count.index)}"
  route_table_id = "${element(aws_route_table.task9_route_table.*.id, count.index)}"
}

resource "aws_instance" "task9_instance" {
  count = 2
  ami           = "${data.aws_ami.nat_ami.id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  subnet_id = "${element(aws_subnet.task9_subnet.*.id, count.index)}"
  security_groups = ["${aws_security_group.task9_sg.id}"]
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.task9_ec2_profile.name}"
  user_data = "${data.template_file.init.rendered}"
  tags = {
    Name = "${var.tag_name}-ec2"
  }
}

resource "aws_iam_policy" "task9_ec2_policy" {
  name = "task9EC2Policy"
  policy = "${data.template_file.task9_ec2_policy.rendered}"
}

resource "aws_iam_role" "tak9_ec2_role" {
  name = "Tak9EC2Role"
  path = "/"
  assume_role_policy = "${data.template_file.task9_ec2_role.rendered}"
}

resource "aws_iam_role_policy_attachment" "task9_policy_att" {
  policy_arn = "${aws_iam_policy.task9_ec2_policy.arn}"
  role = "${aws_iam_role.tak9_ec2_role.name}"
}

resource "aws_iam_instance_profile" "task9_ec2_profile" {
  name = "Task9EC2Profile"
  role = "${aws_iam_role.tak9_ec2_role.name}"
}

resource "aws_security_group" "task9_sg" {
  name        = "${var.tag_name}-sg"
  description = "EC2 Security Group"
  vpc_id = "${aws_vpc.task9_vpc.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_name}-sg"
  }
}

resource "aws_lb" "task9-lb" {
  name               = "task9-lb"
  load_balancer_type = "application"

  subnets = ["${data.aws_subnet_ids.task9_subnets.ids}"]
  security_groups = ["${aws_security_group.task9_lb_sg.id}"]

  tags = {
    Name = "${var.tag_name}-elb"
  }
}

resource "aws_lb_listener" "task9_lb_listener" {
  load_balancer_arn = "${aws_lb.task9-lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.task9_lb_target_group.arn}"
  }
}

resource "aws_lb_target_group" "task9_lb_target_group" {
  name     = "task9-lb-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.task9_vpc.id}"
}

resource "aws_lb_target_group_attachment" "task9_lb_target_group_attachment" {
  count = 2
  target_group_arn = "${aws_lb_target_group.task9_lb_target_group.arn}"
  target_id        = "${element(aws_instance.task9_instance.*.id, count.index)}"
  port             = 8080
}

resource "aws_security_group" "task9_lb_sg" {
  name        = "${var.tag_name}-lbsg"
  description = "ELB Security Group"
  vpc_id = "${aws_vpc.task9_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_name}-elbsg"
  }
}

resource "aws_s3_bucket" "task9_s3" {
  bucket = "s3-website-${var.domain_name}"
  acl    = "private"

  tags = {
    Name = "${var.tag_name}"
  }
}

resource "aws_s3_bucket_policy" "tak9_s3_policy" {
  bucket = "${aws_s3_bucket.task9_s3.id}"
  policy = "${data.template_file.task9_s3_policy.rendered}"
}

resource "aws_s3_bucket_object" "html_object" {
  bucket = "${aws_s3_bucket.task9_s3.bucket}"
  key    = "${var.static_file_name}"
  source = "${var.file_path}${var.static_file_name}"
  etag   = "${md5(file("/${var.file_path}${var.static_file_name}"))}"
}

resource "null_resource" "task9_cluster" {
  count = 2
  connection {
    host = "${element(aws_instance.task9_instance.*.public_ip, count.index)}"
    user = "ubuntu"
    private_key = "${file("${var.key_path}${var.key_name}")}"

  }

  provisioner "file" {
    destination = "${ var.remote_tmp_path_nginx }${var.conf_file_name}"
    source = "${var.conf_file_path}${var.conf_file_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm ${ var.remote_conf_file_path_nginx }default",
      "sudo mv ${ var.remote_tmp_path_nginx }${var.conf_file_name} ${ var.remote_conf_file_path_nginx }${var.conf_file_name}",
      "sudo systemctl restart nginx",
      "sleep 10",
      "aws s3 cp s3://${aws_s3_bucket.task9_s3.bucket}/${var.static_file_name} ${var.remote_static_file_path}${var.static_file_name}"
    ]
  }
  depends_on = ["aws_iam_role_policy_attachment.task9_policy_att"]
}



