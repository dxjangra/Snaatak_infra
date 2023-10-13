resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "my_public_subnet" {
  count  = length(var.pub_subnet_cidr)
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block        = element(var.pub_subnet_cidr , count.index)
  availability_zone = element(var.subnet_az ,count.index)
  tags = {
    Name = element(var.pub_subnet_name ,count.index)
  }
}

resource "aws_subnet" "my_private_subnet" {

  count  = length(var.pri_subnet_cidr)
  cidr_block = var.pri_subnet_cidr[count.index]
  vpc_id                  = aws_vpc.my_vpc.id

  availability_zone = element(var.subnet_az ,count.index)

  tags = {
    Name = element(var.pri_subnet_name ,count.index)
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "public_routeTable" {
  vpc_id =  aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
Name = var.public_rt_name
}
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(var.pub_subnet_cidr)
  subnet_id      = element(aws_subnet.my_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_routeTable.id
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(var.pri_subnet_cidr)
  subnet_id      = element(aws_subnet.my_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_routeTable.id
}

resource "aws_route_table" "private_routeTable" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id 
    # gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = { 
Name = var.private_rt_name
}
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_gateway.id
    subnet_id = aws_subnet.my_public_subnet[0].id

}

resource "aws_alb_target_group" "salary_lb_tg" {
  name        = var.salary_lb_tg_name
  port        = var.salary_lb_tg_port
  protocol    = var.salary_lb_tg_protocol
  vpc_id      = aws_vpc.my_vpc.id
  target_type = var.salary_lb_tg_target_type

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.salary_lb_tg_protocol
    matcher             = "200"
    timeout             = "5"
    path                = var.salary_lb_tg_target_healthcheck_path
    unhealthy_threshold = "2"
  }
  # depends_on = [aws_lb.my_lb]
}

resource "aws_alb_target_group" "attendance_lb_tg" {
  name        = var.attendance_lb_tg_name
  port        = var.attendance_lb_tg_port
  protocol    = var.attendance_lb_tg_protocol
  vpc_id      = aws_vpc.my_vpc.id
  target_type = var.attendance_lb_tg_target_type

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.attendance_lb_tg_protocol
    matcher             = "200"
    timeout             = "5"
    path                = var.attendance_lb_tg_target_healthcheck_path
    unhealthy_threshold = "2"
  }
  # depends_on = [aws_lb.my_lb]
}

resource "aws_alb_target_group" "employee_lb_tg" {
  name        = var.employee_lb_tg_name
  port        = var.employee_lb_tg_port
  protocol    = var.employee_lb_tg_protocol
  vpc_id      = aws_vpc.my_vpc.id
  target_type = var.employee_lb_tg_target_type

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = var.employee_lb_tg_protocol
    matcher             = "200"
    timeout             = "5"
    path                = var.employee_lb_tg_target_healthcheck_path
    unhealthy_threshold = "2"
  }
  # depends_on = [aws_lb.my_lb]
}

resource "aws_security_group" "alb-sg" {
  name   = var.alb_sg_name
  vpc_id = aws_vpc.my_vpc.id
  description = "Allow inbound traffic from port 80 to ALB"
 
  ingress {
   protocol         = var.sg_ingress_protocol_tcp
   from_port        = 80
   to_port          = 80
   cidr_blocks      = var.alb_sg_ingress_cidr
  }
 
  egress {
   protocol         = var.sg_egress_protocol
   from_port        = 0
   to_port          = 0
   cidr_blocks      = var.sg_egress_cidr
  }
}


resource "aws_lb" "my_lb" {
  name               = var.alb_name
  internal           = var.alb_internal_facing
  load_balancer_type = var.alb_type
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = aws_subnet.my_public_subnet[*].id
  enable_deletion_protection = var.alb_enable_deletion_protection
}

#---------------Adding Listener to ALB
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_lb.my_lb.id
  port              = var.listener_port
  protocol          = var.listener_protocol

 default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.employee_lb_tg.arn
  }

}

#--------------  path based Listener rules---------- attendance

resource "aws_lb_listener_rule" "attendance_path" {
  listener_arn = aws_alb_listener.listener_http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.attendance_lb_tg.arn
  }

  condition {
    path_pattern {
      values = var.attendance_listener_path
    }
  }
}
#--------------  path based Listener rules---------- salary

resource "aws_lb_listener_rule" "salary_path" {
  listener_arn = aws_alb_listener.listener_http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.salary_lb_tg.arn
  }

  condition {
    path_pattern {
      values = var.salary_listener_path
    }
  }
}

#--------------  path based Listener rules---------- employee

resource "aws_lb_listener_rule" "employee_path" {
  listener_arn = aws_alb_listener.listener_http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.employee_lb_tg.arn
  }

  condition {
    path_pattern {
      values = var.employee_listener_path
    }
  }
}

#--------------------openVPN SG
resource "aws_security_group" "openvpn-sg" {
  name        = var.openvpn_sg_name
  description = "Allow inbound traffic for OpenVPN"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = var.sg_ingress_protocol_tcp
    cidr_blocks = var.openvpn_sg_ingress_cidr
  }

  # Ingress rule for OpenVPN (port 1194 - UDP)
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = var.sg_ingress_protocol_udp
    cidr_blocks = var.openvpn_sg_ingress_cidr
  }

  egress {
   protocol         = var.sg_egress_protocol
   from_port        = 0
   to_port          = 0
   cidr_blocks      = var.sg_egress_cidr
  }
}

#--------------------dev-app-NACL
resource "aws_network_acl" "dev-app-NACL" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.my_private_subnet[0].id]

  # allow ingress port 22
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 100
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port 1194 
  ingress {
    protocol   = var.nacl_ingress_protocol_udp
    rule_no    = 110
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 1194
    to_port    = 1194
  }
  
  # allow ingress port 8080 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 120
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 8080
    to_port    = 8080
  }
  
   # allow ingress port 8080 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 130
    action     = "allow"
    cidr_block = var.public_subnet2_cidr
    from_port  = 8080
    to_port    = 8080
  }
  # allow ingress ephemeral 1024-65535
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024 
    to_port    = 65535
  }
  
#outbound dev-app-NACL

 egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 100
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 1024 
    to_port    = 65535
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80 
    to_port    = 80
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 120
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_db
    from_port  = 9042 
    to_port    = 9042
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 130
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_db
    from_port  = 5432 
    to_port    = 5432
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 140
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_middleware
    from_port  = 6379 
    to_port    = 6379
  }

  tags = {
    Name = var.dev_aap_nacl
    Environment = var.env_name
}
}

resource "aws_network_acl" "dev-middleware-NACL" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.my_private_subnet[1].id]

  # allow ingress port 22
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 100
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress ephemeral 1024-65535
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024 
    to_port    = 65535
  }
  # allow ingress port 1194 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 120
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 1194
    to_port    = 1194
  }
  
  # allow ingress port 6379 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 130
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 6379
    to_port    = 6379
  }
  
#outbound dev-middleware-NACL

 egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 100
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 1024 
    to_port    = 65535
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80 
    to_port    = 80
  }
  
  egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443 
    to_port    = 443
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 130
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 8080 
    to_port    = 8080
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 140
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 1024 
    to_port    = 65535
  }
  

  tags = {
    Name = var.dev_middleware_nacl
    Environment = var.env_name
}
}

resource "aws_network_acl" "dev-db-NACL" {
  vpc_id = aws_vpc.my_vpc.id
  subnet_ids = [aws_subnet.my_private_subnet[2].id]

  # allow ingress port 22
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 100
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 22
    to_port    = 22
  }
  
    # allow ingress port 1194 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 110
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 1194
    to_port    = 1194
  }
  
  # allow ingress port 9042 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 120
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 9042
    to_port    = 9042
  }
  
  # allow ingress port 5432 
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 130
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 5432
    to_port    = 5432
  }
  
  # allow ingress ephemeral 1024-65535
  ingress {
    protocol   = var.nacl_ingress_protocol_tcp
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024 
    to_port    = 65535
  }
#outbound dev-middleware-NACL

 egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 100
    action     = "allow"
    cidr_block = var.dev_openvpn_subnet_cidr
    from_port  = 1024 
    to_port    = 65535
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80 
    to_port    = 80
  }
  
  egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443 
    to_port    = 443
  }
  
  egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 130
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 1024 
    to_port    = 65535
  }
  
   egress {
    protocol   = var.nacl_egress_protocol_tcp
    rule_no    = 140
    action     = "allow"
    cidr_block = var.dev_private_subnet_cidr_app
    from_port  = 8080 
    to_port    = 8080
  } 

  tags = {
    Name = var.dev_db_nacl
    Environment = var.env_name
}

}
