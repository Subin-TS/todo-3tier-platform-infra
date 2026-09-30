resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-rds-sg"
  description = "Security group for ${var.name} RDS MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  deletion_protection   = false
  skip_final_snapshot   = true
  publicly_accessible   = false
  multi_az              = false

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  backup_retention_period = 1

  tags = {
    Name = "${var.name}-mysql"
  }
}
