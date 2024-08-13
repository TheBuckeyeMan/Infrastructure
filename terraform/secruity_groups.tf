resource "aws_security_group" "security_group"{
    name = "http_security_group"
    description = "ALLOW ATTP Traffic"
    vpc_id = aws_vpc.vpc.id
    ingress = {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "http_security_group"
    }
}