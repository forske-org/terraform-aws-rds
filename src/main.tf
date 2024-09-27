provider "aws" {
    region = var.region
    shared_credentials_files = ["<location_of_aws_credentials_file>"]
    shared_config_files = ["<location_of_aws_config_file>"]
}

data "aws_availability_zones" "available" {}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "2.77.0"

    name = var.application
    cidr = "10.0.0.0/16"
    azs = data.aws_availability_zones.available.names
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    enable_dns_hostnames = true
    enable_dns_support = true
}

resource "random_password" "password" {
    length = 32
    special = false
}

resource "aws_db_subnet_group" "rds" {
    name = "${var.application}_rds_subnet_group"
    subnet_ids = module.vpc.public_subnets

    tags = {
        Name = var.application
    }
}

resource "aws_security_group" "rds" {
    name = "${var.application}_rds"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.application}_rds"
    }
}

resource "aws_db_parameter_group" "rds" {
    name = "${var.application}_rds"
    family = "mysql8.0"

    parameter {
        name = "character_set_server"
        value = "utf8"
    }

    parameter {
        name = "character_set_client"
        value = "utf8"
    }
}

resource "aws_db_instance" "rds" {
    allocated_storage = 5
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "8.0.39"
    instance_class = "db.t3.micro"
    identifier = var.application
    username = "${var.application}_admin"
    password = random_password.password.result
    db_subnet_group_name = aws_db_subnet_group.rds.name
    db_name = var.application
    vpc_security_group_ids = [aws_security_group.rds.id]
    skip_final_snapshot = true
    multi_az = false
    publicly_accessible = true
}
