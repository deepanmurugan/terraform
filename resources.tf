/*Resource to create VPC (Virtual Private Cloud)
|- VPC is associated to any region like london,france, us etc
|- From VPC you can create subnets and other resources
*/
resource "aws_vpc" "terraform_vpc" {
	cidr_block = "${var.vpc_cidr_block}"
	enable_dns_hostnames = "true"
	enable_dns_support = "true"
	tags {
		Name = "terraform_vpc_example"
		Env = "Prod"
	}
}

/* List of availability zones used to create subnets
|- in different az's for public and private subnet
*/
data aws_availability_zones aws_az {
}

/* Create no_of_public_subnet (defined in variables.tf )
|- in the VPC using round robin method in different az
*/
resource "aws_subnet" "terraform_subnet" {
	count = "${var.no_of_public_subnet}"
	cidr_block = "${cidrsubnet( var.vpc_cidr_block, var.in_subnets_max, count.index )}"
	availability_zone = "${element( data.aws_availability_zones.aws_az.names, count.index )}"
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	map_public_ip_on_launch = true
	tags {
                Name = "Public_Subnet_${count.index}"
		Env = "Prod"
        }
}

/* Create no_of_private_subnet (defined in variables.tf)
|- in the VPC using round robin method in different az
*/
resource "aws_subnet" "terraform_subnet_2" {
	count = "${var.no_of_private_subnet}"
        cidr_block = "${cidrsubnet( var.vpc_cidr_block, var.in_subnets_max, var.no_of_public_subnet+count.index )}"
        availability_zone = "${element( data.aws_availability_zones.aws_az.names, var.no_of_public_subnet+count.index )}"
        vpc_id = "${aws_vpc.terraform_vpc.id}"
	map_public_ip_on_launch = false
        tags {
                Name = "Private_Subnet_${count.index}"
		Env = "Prod"
        }
}

/* Create an internet gateway for instances in public subnet to talk to the internet */
resource "aws_internet_gateway" "terraform_igw" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	tags {
		Name = "Terraform_IGW"
	}
}

/* Create NAT Gateway for instances in private subnet to reach internet
|- NAT needs an eip (Elastic IP) through which it makes internet connection
|- NAT Gateway prevents internet to make incoming traffic to the hosts 
|- and make sure only hosts can make internet connection
*/
resource "aws_nat_gateway" "terraform_nat" {
	allocation_id = "${element( aws_eip.terraform_eip.*.id, count.index )}"
	subnet_id = "${element( aws_subnet.terraform_subnet_2.*.id, count.index )}"
	depends_on = [ "aws_internet_gateway.terraform_igw" ]
	tags {
		Name = "Terraform_NAT"
		Env = "Prod"
	}
}

/* Create an eip (Elastic IP) for NAT gateway to use */
resource "aws_eip" "terraform_eip" {
	vpc = true
	depends_on = [ "aws_internet_gateway.terraform_igw" ]
	tags {
		Name = "Terraform EIP"
		Env = "Prod"
	}
}

/* Create route table for public subnet
|- Add a route in it to send incoming traffic to pulbic using internet gateway
*/
resource "aws_route_table" "terraform_route" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	route {
    		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.terraform_igw.id}"
	}
	tags {
		Name = "Terraform_Public_RT"
	}
}

/* Create route table for private subnet
|- Add a route in it to send incoming traffic to pulbic using NAT gateway
*/
resource "aws_route_table" "terraform_route_2" {
        vpc_id = "${aws_vpc.terraform_vpc.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_nat_gateway.terraform_nat.id}"
        }
        tags {
                Name = "Terraform_Private_RT"
        }
}

/* Associate the public subnet to the public route table */
resource "aws_route_table_association" "terraform_route-association" {
	count = "${var.no_of_public_subnet}"
	subnet_id = "${element ( aws_subnet.terraform_subnet.*.id, count.index )}"
	route_table_id = "${aws_route_table.terraform_route.id}"
}

/* Associate the private subnet to the private route table */
resource "aws_route_table_association" "terraform_route-association_2" {
        count = "${var.no_of_private_subnet}"
        subnet_id = "${element ( aws_subnet.terraform_subnet_2.*.id, count.index )}"
        route_table_id = "${aws_route_table.terraform_route_2.id}"
}

/* Create a security group for webserver inside the public subnet.
|- Allow HTTP traffic on port 80 only from ALB (Application Load Balancer) security group
|- By this way we can make sure all the traffic should only come from ALB
|- Allow SSH traffic on port 22 only from the instances inside VPC cidr range
|- Allow all outbound traffic without restrictions
*/
resource "aws_security_group" "webserver_sg" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
	ingress {
		from_port = "22"
		to_port = "22"
		protocol = "tcp"
		cidr_blocks = ["${var.vpc_cidr_block}"]
	}
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                security_groups = ["${aws_security_group.alb_sg.id}"]
        }
	egress {
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

/* Create a security group for Application Load Balancer
|- Allow HTTP traffic on port 80 from the internet
|- Allow HTTPS traffic on port 443 from the internet
|- Allow all outbound traffic without restrictions
*/
resource "aws_security_group" "alb_sg" {
	vpc_id = "${aws_vpc.terraform_vpc.id}"
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "443"
                to_port = "443"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

/* Create aws key pair to use while launching aws ec2-instances
|- Use your public key value in the public_key attribute
*/
resource "aws_key_pair" "deployer" {
	key_name   = "nvirginia"
	public_key = "ssh-rsa c5x6bvwxgle25Qhq5ebLPPu5x/PCpoAJp6OLtDspt9/orTg4MRzG0TwcXMzOkw4TY3dDHxx7z3p3vyd6JMQ1+Vgn9xL29FzHLxafXdg8HLgBwEbJFtJ/aoVYhl9pEK0OvczX4ph2wzyp2idQldCOyNVm11uLePNsBAKQ4af0Y89R7auAhdnsFAED9yMVXh68j7cTPsTcqnyjzmmJuUpNMy0RaWOMZ4ZY5mwCskHHUJ+9Vq4IbCuzkOXLFei5nsd8VXbnVGeysG7mYujIaLquZ+khgurTEz/N0V0cI0q82Kcj0j/hCc+uZJhLFAfYB/iNkTz7h"
}

/* User data script file incase if you want to use userdata while launching ec2-instances
|- Used the contents of file userdata.sh in the instance launch directly
|- If you have multiple lines of code just mention user_data = "${file("userdata.sh")}"
*/
data template_file "user-data"
{
    template = "${file("userdata.sh")}"
}

/* Launch ec2-instances in the public subnet, one instance per subnet
|- associate_public_ip_address will set the public ip and dns for the instances
|- Use user_data script while lauching instances
|- Wait till the internet gateway is created and route table is associated
*/
resource "aws_instance" "terraform_instance" {
        ami = "${var.ami_value}"
        count = "${var.no_of_public_subnet}"
        instance_type = "${var.instance_type}"
        subnet_id = "${element( aws_subnet.terraform_subnet.*.id, count.index)}"
        key_name = "${aws_key_pair.deployer.id}"
        associate_public_ip_address = "true"
        vpc_security_group_ids = ["${aws_security_group.webserver_sg.*.id}"]
	user_data = <<EOF
		#!/bin/bash
		sudo yum install -y httpd
		sleep 30
		sudo service httpd start
		sleep 10
		sudo chkconfig httpd on
		sudo chmod 777 -R /var/www/html/
		echo 'This is my webpage - modified' > /var/www/html/index.html
		EOF
	depends_on = [ "aws_internet_gateway.terraform_igw", "aws_route_table_association.terraform_route-association" ]
        tags {
                Name = "webserver-ec2-${count.index}"
        }
}

/* Launch instances in the private subnet, one instance each subnet */
resource "aws_instance" "terraform_instance_2" {
        ami = "${var.ami_value}"
        count = "${var.no_of_private_subnet}"
        instance_type = "${var.instance_type}"
        subnet_id = "${element( aws_subnet.terraform_subnet_2.*.id, count.index)}"
        key_name = "${aws_key_pair.deployer.id}"
        associate_public_ip_address = "false"
        vpc_security_group_ids = ["${aws_security_group.webserver_sg.*.id}"]
        user_data = "${file("userdata.sh")}"
        tags {
                Name = "appserver-ec2-${count.index}"
        }
}

/* Fetch service account details */
data "aws_elb_service_account" "main" {
}

/* Create S3 bucket for ALB logs and attach a policy for service account to provide put object access */
resource "aws_s3_bucket" "alb_s3" {
	bucket = "myalbtestbucketnew"
	acl = "private"
	force_destroy = "true"
	policy = <<POLICY
	{
	  "Id": "Policy",
	  "Version": "2012-10-17",
	  "Statement": [
		{
	      	"Action": [
		"s3:PutObject"
      		],
      		"Effect": "Allow",
      		"Resource": "arn:aws:s3:::myalbtestbucketnew/*",
      		"Principal": {
        		"AWS": [
          		"${data.aws_elb_service_account.main.arn}"
        		]
      		}
    		}
  	]
	}
	POLICY
}

/* Create a ALB (Application Load Balancer) on both public subnets for High Availability
|- Interal = false makes the ALB as public
*/
resource "aws_lb" "app_load_balancer" {
	name = "WebappALB"
	internal = "false"
	load_balancer_type = "application"
	security_groups = ["${aws_security_group.alb_sg.id}"]
	subnets = ["${aws_subnet.terraform_subnet.*.id}"]
	
	access_logs {
		bucket = "${aws_s3_bucket.alb_s3.bucket}"
		prefix = "alb_logs"
		enabled = "true"
	}

	tags {
		Name = "Prod_alb"
	}
	depends_on = ["aws_s3_bucket.alb_s3"]
}

/* Create ALB listener for HTTP traffic on port 80 and route traffic to target group
|- Target group has instances launched in public subnet
*/
resource "aws_lb_listener" "alb_listener" {
	load_balancer_arn = "${aws_lb.app_load_balancer.arn}"
	port = 80
	protocol = "HTTP"
	
	default_action {
		target_group_arn = "${aws_lb_target_group.instance_tg.arn}"
		type = "forward"
	}
}

/* Create target group for HTTP traffic on port 80 */
resource "aws_lb_target_group" "instance_tg" {
	name = "albTG"
	port = 80
	protocol = "HTTP"
	vpc_id = "${aws_vpc.terraform_vpc.id}"
}

/* Create ALB Target group attachment
|- Attach instances in public subnet on target group
*/
resource "aws_lb_target_group_attachment" "alb_attachment" {
	count = "${var.no_of_public_subnet}"
	target_group_arn = "${aws_lb_target_group.instance_tg.arn}"
	target_id = "${element( aws_instance.terraform_instance.*.id, count.index )}"
}

/* Create listener rule and add a new rule based on application needs
|- Add target group based on your application requirements
*/
resource "aws_lb_listener_rule" "alb_rules" {
	listener_arn = "${aws_lb_listener.alb_listener.arn}"
	priority = 100
	
	action {
		type = "forward"
		target_group_arn = "${aws_lb_target_group.instance_tg.arn}"
	}

	condition {
		field = "path-pattern"
		values = ["/app"]
	}
}
