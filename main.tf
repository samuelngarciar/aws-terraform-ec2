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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"  
  user_data              = file("userdata.tpl")
  subnet_id        = data.terraform_remote_state.admnet.outputs.subnet_id
  
  tags = {
    Name  = "${var.project_name}-instance"
    TTL   = var.ttl
    Owner = "${var.project_name}-guide"
  }
}

resource "aws_security_group" "main" {
   name       = "main"
   description = "Example security group"

   ingress {
     from_port  = 80
     to_port    = 80
     protocol   = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     from_port  = 22
     to_port    = 22
     protocol   = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port  = 0
     to_port    = 0
     protocol   = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
 }
