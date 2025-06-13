packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "vpc_id" {}
variable "subnet_id" {}
variable "security_group_id" {}

source "amazon-ebs" "devsecops" {
  region                     = "ap-northeast-2"
  source_ami                 = "ami-05377cf8cfef186c2" # Amazon Linux 2023
  instance_type              = "t3.micro"
  ssh_username               = "ec2-user"
  ssh_interface              = "public_ip"
  associate_public_ip_address = true
  temporary_key_pair_type    = "ed25519"
  pause_before_connecting    = "10s"
  ssh_timeout                = "5m"

  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id

  encrypted         = true
  encrypt_boot      = true

  ami_name          = "devsecops-ami-{{timestamp}}"
  ami_description   = "Pre-hardened AMI for DevSecOps (Amazon Linux 2023)"

  tags = {
    Name           = "devsecops-ami"
    Team           = "Security"
    Environment    = "Baseline"
    BuildDate      = "{{timestamp}}"
  }

  run_tags = {
    Name = "packer-builder"
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

build {
  sources = ["source.amazon-ebs.devsecops"]

  provisioner "shell" {
    inline = [
      "echo '[packer-init] Starting hardened baseline setup...'",

      # Remove insecure packages
      "sudo dnf remove -y telnet ftp rsh || true",

      # Disable root password login temporarily
      "sudo passwd -l root",

      # Block unused ports at boot level (iptables or ufw not default in AL2023)
      "sudo firewall-offline-cmd --add-port=22/tcp",
      "sudo systemctl enable firewalld",

      # Touch hardened flag
      "sudo touch /etc/hardened-by-packer"
    ]
  }

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
    extra_arguments = [
      "--ssh-extra-args=-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
    ]
  }
}
