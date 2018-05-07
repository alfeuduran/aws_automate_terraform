data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "aws-dev-telend-sg" {
  name                   = "aws-dev-telend-sg"
  vpc_id                 = "${var.vpc_id}"
  revoke_rules_on_delete = "true"

  ingress {
    protocol    = "${var.protocol}"
    from_port   = "${var.from_port}"
    to_port     = "${var.to_port}"
    cidr_blocks = ["${split(",", var.range)}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "aws_dev_talend" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key-par-name}"
  vpc_security_group_ids = ["${aws_security_group.aws-dev-telend-sg.id}"]

  tags {
    Nome        = "jornada Comercial"
    Projeto     = "Jornada Comercial"
    Environment = "DEV"
    Owner       = "gsbetl@natura.net"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"

      #key_file = "~/.ssh/my-key.pem"
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install default-jre",
      "sudo apt-get install default-jdk",
      "www.talend.com/download/thankyou/big-data/",
    ]
  }
}
