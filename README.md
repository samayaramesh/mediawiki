Mediawiki Installation on AWS using Terraform & Ansible
------------------------------------------------------- 

Pre-Requisites: 
---------------------------
1. Terraform is installed and the PATH is set. 
	
	If not, download the setup using the instructions in the link below: 
	https://www.terraform.io/intro/getting-started/install.html
	1. Download the zip file
	2. unzip the file
	3. move the file to /usr/local/bin/
	4. check using "terraform --version" command
	
2. AWS Secret variables are set: 
	```
	AWS_ACCESS_KEY_ID='****'
	
	AWS_SECRET_ACCESS_KEY='***'
	```
3. Python 2.7+ and Ansible 2.x is installed
	
   Step 1 — Installing Ansible
   ```
   sudo yum install epel-release
   sudo yum install ansible
   ```
   Step 2 — Configuring Ansible Hosts
   
   Below are the reference to configure Dynamic Inventory in Ansible for AWS (/etc/ansible/hosts will not be used in AWS since the instances are dynamic)
   
   https://devopscube.com/setup-ansible-aws-dynamic-inventory/#:~:text=Dynamic%20inventory%20is%20an%20ansible,was%20just%20a%20Python%20file.
   
   https://medium.com/@rakeshguha15/how-to-use-ansible-aws-ec2-plugin-to-create-dynamic-inventory-7098553d160
   
   Step 3 - Configuring Dynamic Inventory
   
   1. Create an inventory directory under /opt/ansible/inventory/
   
   2. Create a file aws_ec2.yaml or aws_ec2.yml 
   
   3. Add below lines for dynamic inventory to the file (example)
   
```   ---
plugin: aws_ec2

regions: ap-south-1

aws_access_key: ***********************

aws_secret_key: ***********************************

keyed_groups:
 
 - key: tags
 
   prefix: tag
 
 - prefix: instance_type
 
   key: instance_type
  
 - key: placement.region
  
   prefix: aws_region

groups:
  
  web:
  
    tags:
    
      kind: web
  
  db:
  
    tags:
    
      kind: db
```
---
   4. Update the inventory path and enable the plugin /etc/ansible.ansible.cfg
```   
   inventory      = /opt/ansible/inventory/aws_ec2.yaml
   
   [Inventory]
   
   enable_plugins = aws_ec2
```   
   5. Use the plugin while running the ansible playbook as shown below
```   
   [centos@ip-172-31-10-226 inventory]$ ansible-inventory --graph
   
@all:

  |--@aws_ec2:
  |  |--ec2-15-207-254-128.ap-south-1.compute.amazonaws.com
  |  |--ec2-52-66-124-223.ap-south-1.compute.amazonaws.com
  |  |--ip-172-31-24-182.ap-south-1.compute.internal
  |--@aws_region_ap_south_1:
  |  |--ec2-15-207-254-128.ap-south-1.compute.amazonaws.com
  |  |--ec2-52-66-124-223.ap-south-1.compute.amazonaws.com
  |  |--ip-172-31-24-182.ap-south-1.compute.internal
  |--@instance_type_m4_large:
  |  |--ip-172-31-24-182.ap-south-1.compute.internal
  |--@instance_type_t2_micro:
  |  |--ec2-15-207-254-128.ap-south-1.compute.amazonaws.com
  |--@instance_type_t2_nano:
  |  |--ec2-52-66-124-223.ap-south-1.compute.amazonaws.com
  |--@tag_Name_Automation_apac:
  |  |--ec2-15-207-254-128.ap-south-1.compute.amazonaws.com
  |--@tag_Name_Rakesh_Test1:
  |  |--ec2-52-66-124-223.ap-south-1.compute.amazonaws.com
  |--@ungrouped:
```
----------
   6. Update hosts entry (based on the region) inside ansible yaml file as below
   ---
#This playbook deploys the mediawiki 
```
- name: Media Wiki Database and WebServer
  hosts: aws_region_ap_south_1    /// Here the grouping is based on the region
  become: yes 
``` 
   7. Run ansible playbook inside terraform as below 
```  
  provisioner "remote-exec" {
    inline = ["sudo yum install python -y"]
	connection {
		type        = ssh
		private_key = file(var.private_key)
		user        = var.ansible_user
  }
}
  provisioner "local-exec" {
    command = ansible-playbook site.yml -u ${var.ansible_user} --private-key ${var.private_key} -i tag_Name_web
  }
  provisioner "local-exec" {
    command = ansible-playbook site.yml -u ${var.ansible_user} --private-key ${var.private_key} -i tag_Name_db  
  }
  lifecycle {
    create_before_destroy = true
  }
}
---------
```
   
AWS Resources
--------------
 - Terraform that does the following:
 	- 1 VPC
 	- 3 Subnets  
 	- 1 Keypair 
 	- 3 EC2 Instances - 2 Web and 1 DB
 	- 1 Elastic Load Balancer
	- Launch Confguration
	- Autoscaling
	- Provisioner (Used to run ansible playbook)
   
 - Ansible Playbook that performs the following: 
    - Dynamically fetches your resources based on the tags you defined in the terraform IaC. 
    - Performs the Installation of the MySQL Database
    - Creates the Database and Users and other Validations. 
    - Encrypts the passwords into a vault. 
    - Role that installs Apache HTTPD, PHP from third-party repositories (remi, epel)
    - Configures the webserver
    - Makes it ready for the Launch on the browser. 

Steps to setup
---------------
1. Clone and switch the directory to the Repository. 

2. Navigate to the folder: 

    ```cd terraform```

3. Initialize the working directory.:

    ```terraform init```
	
4. Create a plan and save it to the local file tfplan: 

	```terraform plan -out=tfplan```
	
5. Apply the plan stored in the file tfplan.
	
	```terraform apply -input=false tfplan -auto-approve```
	
6. Below output autogenerated
   1. Instance IDs with public IP
   2. Private key to login to the instance created 
   3. ELB DNS Name
	
7. Open the Browser and check the URL with mediawiki page
