variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the VPC"
  type        = string
}

variable "pub_subnet_cidr" {
  description = "CIDR of public subnet"
  type        = list(string)
}

variable "subnet_az" {
  description = "AZ for public subnet"
  type        = list(string)
}

variable "pri_subnet_cidr" {
  description = "CIDR of private subnet"
  type        = list(string)
}

variable "pub_subnet_name" {
  description = "Name tag of the pub subnet name"
  type        = list(string)
}

variable "pri_subnet_name" {
  description = "Name tag of the pri subnet name"
  type        = list(string)
}

variable "public_rt_name" {
  description = "Name tag of the public rt name"
  type        = string
}

variable "private_rt_name" {
  description = "Name tag of the private rt name"
  type        = string
}

variable "igw_name" {
  description = "Name tag of the igw_name"
  type        = string
}

#--------------------------target group- salary

variable "salary_lb_tg_name" {
    type        = string
    default     = "salary-api-tg"
    }

variable "salary_lb_tg_port" {
    type = number 
}

variable "salary_lb_tg_protocol" {
    type = string
    default = "HTTP" 
}

variable "salary_lb_tg_target_type" {
    type = string
    default = "instance" 
}

variable "salary_lb_tg_target_healthcheck_path" {
    type = string
    default = "/actuator/*" 
}

#-------------------------target group- attendance

variable "attendance_lb_tg_name" {
    type        = string
    default     = "attendance-api-tg"
    }

variable "attendance_lb_tg_port" {
    type = number 
}

variable "attendance_lb_tg_protocol" {
    type = string
    default = "HTTP" 
}

variable "attendance_lb_tg_target_type" {
    type = string
    default = "instance" 
}

variable "attendance_lb_tg_target_healthcheck_path" {
    type = string
    default = "/api/v1/attendance*" 
}

#-------------------------target group- employee

variable "employee_lb_tg_name" {
    type        = string
    default     = "employee-api-tg"
    }

variable "employee_lb_tg_port" {
    type = number 
}

variable "employee_lb_tg_protocol" {
    type = string
    default = "HTTP" 
}

variable "employee_lb_tg_target_type" {
    type = string
    default = "instance" 
}

variable "employee_lb_tg_target_healthcheck_path" {
    type = string
    default = "/api/v1/employee*" 
}

#----------------alb-sg

variable "alb_sg_name" {
    type   = string
}

variable "sg_ingress_protocol_tcp" {
  type = string
  default = "tcp"
}

variable "sg_egress_protocol" {
  type = string
  default = "-1"
}

variable "alb_sg_ingress_cidr" {
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

variable "sg_egress_cidr" {
    type        = list(string)
    default     = ["0.0.0.0/0"]
}


#---------------------------ALB


variable "alb_name" {
    type   = string
}

variable "alb_internal_facing" {
    type   = bool
    default = false
}

variable "alb_type" {
    type = string
    default= "application"
}

variable "alb_enable_deletion_protection" {
    type = bool
    default = "false"
}


#------------------Listener rule
variable "listener_port" {
    type = number
    default= 80
}

variable "listener_protocol" {
    type = string
    default = "HTTP"
}

#------------------------listener path-----attendance

variable "attendance_listener_path" {
    type = list(string)
    default = ["/api/v1/attendance/*"]
}

#------------------listener path-----salary
variable "salary_listener_path" {
    type = list(string)
    default = ["/actuator/*"]
}

variable "employee_listener_path" {
    type = list(string)
    default = ["/api/v1/employee/*"]
}


variable "salary_tg_id" {
    type = string
    default = ""
}

# variable "s3_bucket_name" {
#     type = string
#     default = "s3-bucket-for-tf-state"
# }

variable "env_name" {
    type = string
    default = "dev"
}

#-------------------openvpn SG

variable "openvpn_sg_name" {
    type   = string
}

variable "sg_ingress_protocol_udp" {
  type = string
  default = "udp"
}

variable "openvpn_sg_ingress_cidr" {
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

#----------------------dev-app-NACL

variable "dev_aap_nacl" {
    type        = string
    default     = "dev-app-NACL"
}

variable "dev_openvpn_subnet_cidr" {
    type        = string
    default     = "10.0.3.0/24"
}

variable "nacl_ingress_protocol_tcp" {
    type        = string
    default     = "tcp"
}

variable "nacl_egress_protocol_tcp" {
    type        = string
    default     = "tcp"
}

variable "nacl_ingress_protocol_udp" {
    type        = string
    default     = "udp"
}

variable "public_subnet2_cidr" {
    type        = string
    default     = "10.0.8.0/24"
}

variable "dev_private_subnet_cidr_db" {
    type        = string
    default     = "10.0.6.0/24"
}

variable "dev_private_subnet_cidr_middleware" {
    type        = string
    default     = "10.0.5.0/24"
}

#--------------------------dev-redis-NACL
variable "dev_middleware_nacl" {
    type        = string
    default     = "dev-middleware-NACL"
}

variable "dev_private_subnet_cidr_app" {
    type        = string
    default     = "10.0.4.0/24"
}

variable "dev_db_nacl" {
    type        = string
    default     = "dev-db-NACL"
}
