provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-rp-states"
    key    = "jayasuryamodel/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "greenyield_sg"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 80
    to_port     = 80
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "GreenYield" {
  ami                    = "ami-066784287e358dad1"  # Update with your desired AMI ID
  instance_type          = "t2.micro"
  key_name               = "jaya"  # Update with your key pair name
  security_groups        = [aws_security_group.instance_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3-pip git
              git clone https://github.com/Jayasurya5454/GreenYield.git
              cd GreenYield
              pip3 install -r requirements.txt
              nohup python3 app.py > app.log 2>&1 &
              EOF

  tags = {
    Name = "greenyield-instance"
  }
}

output "public_ip" {
  value = aws_instance.GreenYield.public_ip
}
