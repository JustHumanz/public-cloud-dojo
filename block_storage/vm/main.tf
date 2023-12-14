terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

variable "cache_dev_size" {
        description = "Size of cache device"
        default = 36
}

variable "backing_dev_size" {
        description = "Size of backing device"
        default = 1000
}

locals {
  bcache_setup = templatefile("${path.module}/bcache.sh", {
    cache_size = "${var.cache_dev_size}"
    back_size = "${var.backing_dev_size}"
  })
}


resource "aws_instance" "bcache" {
  ami = "ami-0fe8bec493a81c7da"
  instance_type = "t3.medium"
  key_name = "humanz"
  user_data = local.bcache_setup #"${file("bcache.sh")}"
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    iops = 16000
    throughput = 1000
    delete_on_termination = true
    volume_size = var.cache_dev_size
    volume_type = "gp3"
  }


  ebs_block_device {
    device_name = "/dev/sdc"
    delete_on_termination = true
    volume_size = var.backing_dev_size
    volume_type = "st1"
  }


}
