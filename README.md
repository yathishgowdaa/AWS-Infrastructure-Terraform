# AWS-Infrastructure-Terraform
A Basic infrastructure is provisioned on AWS cloud using Terraform to automate the build.


During the creation of VPC I had to add 2 public subnets and 2 private subnets because of 2 reason

Extra public subnet is added because the creation of loadbalancer requires requires 2 subnets in 2 AZ's for HA. But even if 2 public subnets are created I have made sure the code pulls the desired subnet i.e [10.1.1.0/24] cidr range as per our requirement and that the loadbalancer is provisioned there.

Extra private subnet is added because during the creation of mysql db instance it requires a db subnet group name for it to provision the resource in the desired subnet. If not provided the resource will be provisioned in the default vpc. But as we wanted the rds instance in private subnet I had to spin up an extra private subnet. 

Have opened up the ports in the rds security group ingress rule and added the security group of the autoscaling group to allow incoming traffic from the web server so that is how I have established connection between servers and db instance. If we want to acces the db then we need to use the db endpoint and put that in the application code to let the application talk to db.

If the future deployments needs Loadsbalancer's DNS name we can fetch it from the attributes returned by the module. In this example I have declared a output variable that returns the DNS name of the loadbalancer this value can either be used to simply print the value in the console and paste in the browser or used in AWS Route53 service to create a custom DNS and hosted zone to route the traffic to the loadbalacer.

To get the code to the production we have to make sure the architecture complies with the companies security policies. All the firewalls, ports and cidrs should follow networking best practices listed by the cyber security. Certificates should be used to securly pass the information and end to end encrytion. The server and the database should be load tested to check if it can handle the incomimg traffic. Passwords and other sensitive information must be stored in secrets manager and these values should be pulled by API call. Terraform structure should be written in following the Env specific tree structure so the variable values will be supplied from tfvars file specific to the Env being provisioned. 

Code can still be refactored to follow the terraform best practices 

I have created the modules but it can still be properly refcatored to follow the terraform module tree structure

S3 resource can be provisioned to store the state files in the remote backend and dynamo db can be used to state lock the file to avoid multiple people making changes to infrastructure

To Implement CI/CD for this setup we would require the following 

Download the plugin on Jenkins 
Install terraform on Jenkins box
If Jenkins is hosted on ec2 machine then we can assign a role to Jenkins to execute the jobs and also fetch the secrets if we have from the secrets manager 
Else we can use cloudless plugin to store the aws creds in the Jenkins 
We can connect GitHub repo where we have our code saved using the web hooks 

Once We have all the setup complete, write a Jenkins file with the stages and the commands that has to be executed within the stages 

We can have pipelines set up for every Env for ex dev, test, prod. The first the pipeline will check for changes in the branch and  the pipeline is triggered and it will fetch the code from that branch and then run terraform init, terraform validate and then run terraform plan if the plan is successful then it would also run terraform apply after terraform plan and provision the resources on AWS Env specific to the workapace and Env mentioned. Once the resources are deployed in dev we can check if everything is working as expected and test. Once the team is satisfied with the dev and testing we can change the Env and workspace and build another trigger with the PR but this time it would pause after terraform plan stage it would check if would master branch if not then the build would exit and wait for the PR to be approved and merged to the master branch. Once approved the build resumes and creates the resources in prod Env. This way we can we can completely automate the infrastructure build end to end.

We can also include terratest and tflint for auto test templates and linting the tf files.
