# terraform-sample-ecs-project
This is a sample terraform project used to create an ECS fargate service

I use the [official VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to set up a VPC.

I then use a [module I created](https://registry.terraform.io/modules/leroykayanda/ecsModule/aws/latest) to set up an ECS fargate service.

I use a local backend. The resources are created in eu-west-2 (London).

Steps to run:

1. clone the repo.

    git clone https://github.com/leroykayanda/terraform-sample-ecs-project.git
    
    cd terraform-sample-ecs-project

2. These variables need to be initialized with the appropriate values in terraform.auto.tfvars

    certificate_arn: 
    an acm cert for the ALB HTTPS listener

    zone_id: 
    for the R53 hosted zone where the ALB alias will be created in  

    domain_name: 
    alias which will map to ALB DNS name 
       
    sns_topic: 
    the module sets up various alarms. This is the ARN for the SNS topic            

3. Initialize terraform, plan and apply

    terraform init
    terraform plan
    terraform apply

