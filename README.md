# Terraform to spin AWS Resources

Create infrasture for a complete production application.

List of AWS Infrasturcture created in AWS.
1) VPC
2) Subnet (Public and Private)
3) Route Tables for public and private subnet
4) Internet Gateway
5) NAT Gateway
6) Elastic IP
7) Route table association
8) Security Groups
9) Key Pair
10) AWS instances
11) S3 Bucket
12) ALB (Application Load Balancer)

Files used:
1) connection.tf -> provider details are defined
2) variable.tf -> where all the necessary variables are defined
3) userdata.sh -> shell script for installing webserver
4) resources.tf -> where all the necessary resources are defined

