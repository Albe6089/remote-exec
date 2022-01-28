
A default VPC was used for this deployment in us-west-2
you will need to update the vpc_id in variable.tf

Also if you will like to run this application in a different region
update the region in variable.tf

FYI: create the ubuntu instance first >> need to work on this so it can be automated
    when the instance gets created copy your public ip and it with what's in the inventory.ini file
    Deploy the application for the second time everything should work
    
To run the deployment run:
terraform apply or 
terraform apply -auto-approve if you don't want to type yes at the prompt

Ansible:
With one click >> terraform apply -auto-approve

Ansiable with steps:
To ping the host run:
ansible bastion -m ping -i  inventory.ini
To check the syntax of the playbook run:
ansible-playbook user_add.yml -i inventory.ini --syntax-check
To run a check on the playbook run this command:
ansible-playbook user_add.yml -i inventory.ini --check                    
To run the ansiable playbook run this command:
ansible-playbook user_add.yml -i inventory.ini --become
