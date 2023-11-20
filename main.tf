provider "aws" {
  region = data.terraform_remote_state.admnet.outputs.region_name

  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

provider "vault" {}

data "terraform_remote_state" "admin" {
  backend = "remote"

config = {
    organization = "testsam1"
    workspaces   = {
      name = "hashicorp-vault-admin"
    }
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
}




data "terraform_remote_state" "admnet" {
  backend = "remote"

config = {
    organization = "testsam1"
    workspaces   = {
      name = "aws-terraform-network"
    }
  }
}



data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}



resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"  
  #user_data    = file("userdata.tpl")
  subnet_id     = data.terraform_remote_state.admnet.outputs.subnet_id
  #vpc_security_group_ids = [aws_security_group.ec2.id]
  
  tags = {
    Name  = "${var.project_name}-instance"
    TTL   = var.ttl
    Owner = "${var.project_name}-guide"
  }
}
