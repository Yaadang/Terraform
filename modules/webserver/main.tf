resource "aws_default_security_group" "myapp-sg"{
    vpc_id = var.vpc-id
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.myip]
    }
    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-SG"
    }

}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

}

resource "aws_instance" "myapp-server"{
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet-id
    vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = "Docker-Server"

    user_data = file("./modules/webserver/entryscript.sh")
    tags = {
        Name = "${var.env_prefix}-server"
    }
    
}