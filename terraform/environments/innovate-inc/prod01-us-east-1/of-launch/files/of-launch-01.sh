MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"
--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
#of-launch bootstrap: Ansible and the AWS CLI, the shared roles bundle and this host's playbook from S3, then the latest CodeDeploy revision.
set -e

sudo apt-get update -y
cd /home/ubuntu

sudo apt-get install python3 python3-pip unzip -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt install ansible zip jq -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws s3 cp s3://${ANSIBLE_BUCKET}/ansible/infrastructure-ansible.tar.gz $(pwd)
tar xvf infrastructure-ansible.tar.gz; mv ansible .ansible; cd .ansible
aws s3 cp s3://${ANSIBLE_BUCKET}/playbooks/${PLAYBOOK_NAME} $(pwd)

sudo ansible-playbook --connection=local ${PLAYBOOK_NAME}

LATEST_REVISION=$(aws deploy list-application-revisions \
  --application-name "${CODEDEPLOY_APP}" \
  --sort-by registerTime \
  --sort-order descending \
  --region ${AWS_REGION} \
  --query "revisions[0]" \
  --output json)

if [ -n "$LATEST_REVISION" ] && [ "$LATEST_REVISION" != "null" ]; then
  aws deploy create-deployment \
    --application-name "${CODEDEPLOY_APP}" \
    --deployment-group-name "${DEPLOYMENT_GROUP}" \
    --revision "$LATEST_REVISION" \
    --description "user_data: auto-deploy after bootstrap" \
    --region ${AWS_REGION}
fi
--//--
