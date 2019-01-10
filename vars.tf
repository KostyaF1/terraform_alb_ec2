# AWS Account creds.
variable "access_key" {}

variable "secret_key" {}


variable "tag_name" {
  description = "Tag name"
  type = "string"
  default = "task9"
}

variable "domain_name" {
  description = "Domain name"
  type = "string"
  default = "task9.ml"
}

variable "key_name" {
  description = "SSH pub key name"
  type = "string"
  default = "id_rsa"
}

variable "regions" {
  description = "map of regions"
  type = "map"
  default = {"Europe"= "eu-central-1", "US"= "us-west-1"}
}

variable "instance_type" {
  description = "instance type name"
  type = "string"
  default = "t2.micro"
}

variable "cidr" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = ["10.192.10.0/24", "10.192.20.0/24"]
}

variable "file_path" {
  description = "Path to file on local machine"
  type = "string"
  default = "/home/kostiantyn/DevOps/chi_intern/task9/static/"
}

variable "remote_static_file_path" {
  description = "Path to file on remote machine"
  type = "string"
  default = "/home/ubuntu/"
}

variable "remote_conf_file_path_nginx" {
  description = "Path to file on remote machine"
  type = "string"
  default = "/etc/nginx/sites-enabled/"
}

variable "static_file_name" {
  description = "Local html file that need to upload to s3"
  type = "string"
  default = "index.html"
}

variable "conf_file_name" {
  description = "Local Configuration file for nginx server"
  type = "string"
  default = "task9.ml.conf"
}

variable "template_path" {
  description = "Local path of terraform templates"
  type = "string"
  default = "/home/kostiantyn/DevOps/chi_intern/task9/templates/"
}

variable "key_path" {
  description = "Path to private SSH key on local machine"
  type = "string"
  default = "/home/kostiantyn/.ssh/"
}
