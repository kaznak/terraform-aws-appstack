
# WebApp Environment

An AWS cloud environment for web applications.
This code is an example to deploy WordPress sites.

# Architecture

![Architecture Overview](./docs/imgs/architecture.png)

Some of legacy or wild web applications is not thread-safe, and then they are not suitable for a scale-out environment.
The unsafety mainly comes from their local file handling.
Placing those code into an EFS and share the file system ease this trouble.
However, problems may still occur depending on the style of file locking.

# Directory tree

+ bin/ : Utility tools
+ cloud-res/ : Cloud resources(terraform codes)
+ server-res/ : Server configuration files
+ docs/ : Documents

# Prerequirements

+ awscli
	+ aws-mfa, if you use switch role mechanisms.
+ domains on Route53

# Configuration

Add the names of profiles used in the environment into the following file:

+ ./aws-profiles.lst

Edit the following two files mainly:

+ 00.terraform.tf
+ 20.locals.tf

# Deployment
## 1. EFS deployment

~~~
pushd cloud-res
terraform apply -target=aws_efs_file_system.main
# type yes to deploy
popd
~~~

## 2. Update user_data

~~~
terraform state show aws_efs_file_system.main
~~~

Note down the value of ``dns_name''.

Edit the following two files:

+ 32.user-data.maintenance.full.sh
+ 32.user-data.service.full.sh

Substitute the ``dns_name'' value to the endpoint variable of the above files:

~~~
# !TODO! EFS endpoint must be placed.
endpoint=fs-c0000000.efs.ap-northeast-1.amazonaws.com
~~~

## 3. AMI creation for the maintenance server

~~~
pushd cloud-res
mv 33.ec2.maintenance-ami.tf{.off,}
terraform apply  -target=aws_instance.maintenance-ami
# type yes to deploy
# and wait decent time for deploying and installing finish
# check /var/log/user-data.log
terraform apply -target=aws_ami_from_instance.maintenance-ami
# type yes to deploy
terraform state rm aws_ami_from_instance.maintenance-ami
terraform destroy -target=aws_instance.maintenance-ami
# type yes to deploy
mv 33.ec2.maintenance-ami.tf{,.off}
popd
~~~

## 4. AMI creation for the service server

~~~
pushd cloud-res
mv 33.ec2.service-ami.tf{.off,}
terraform apply  -target=aws_instance.service-ami
# type yes to deploy
# and wait decent time for deploying and installing finish
# check /var/log/user-data.log
terraform apply -target=aws_ami_from_instance.service-ami
# type yes to deploy
terraform state rm aws_ami_from_instance.service-ami
terraform destroy -target=aws_instance.service-ami
# type yes to deploy
mv 33.ec2.service-ami.tf{,.off}
popd
~~~

## 5. Main resource deployment

~~~
pushd cloud-res
terraform apply
# type yes to deploy
popd
~~~
