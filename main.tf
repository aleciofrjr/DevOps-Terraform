terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }

}

provider "aws" {
    shared_credentials_file = "~/.aws/credentials"
    profile = "Nginx-Server"
    region = "us-west-2"
}

# Criando a Instância EC2
resource "aws_instance" "ubuntu_server" {
    ami             = var.image_name
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.my-key.key_name
    security_groups = ["${aws_security_group.allow_ssh.name}"]

    tags = {
        Name = var.instance_name
    }
    
    connection {
        type    = "ssh"
        user    = "ubuntu"
        host    = self.public_ip
    }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install nginx -y",
            "sudo systemctl start nginx",
            "sudo apt install dstat -y",
            "sudo apt install npm jq -y",
            "sudo npm install -g csvtojson -y"
        ]
    }
    provisioner "file" {
        source      = "script_monitor.sh"
        destination = "script_monitor.sh"
    }
    
# Copiando arquivo DSTAT que foi efetuado a correção para execução da ferramenta!!
# OBS: Foi necessário fetuar a copia manual com SCP devido a permissões que não consegui resolver!
#    provisioner "file" {
#        source      = "/usr/bin/dstat"
#        destination = "/usr/bin/dstat"
#    }

# Executando script_monitor
#    provisioner "remote-exec" {
#        inline = [
#            "~/.script_monitor.sh"
#        ]
#    }
}

# Recurso para Chaves de segurança
resource "aws_key_pair" "my-key" {
    key_name    = "my-key"
    public_key  = "${file("~/.ssh/id_rsa.pub")}"
}

# Recurso para security_groups
resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"

# Liberando portas de acesso 22
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# Liberando porta de acesso 80
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# Liberando portas de saída
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
