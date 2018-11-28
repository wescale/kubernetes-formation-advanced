#!/bin/bash

curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

wget -O helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-rc.4-linux-amd64.tar.gz
tar -xf helm.tar.gz
chmod +x linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm

wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq


echo "export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops" >> /home/ec2-user/.bashrc

sudo yum install git

# ansible

sudo amazon-linux-extras install -y ansible2

wget https://raw.github.com/ansible/ansible/devel/contrib/inventory/ec2.py
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo mv ec2.py /etc/ansible/
sudo mv ec2.ini /etc/ansible/

sudo chmod a+x /etc/ansible/ec2.py

python get-pip.py --user  >> /dev/null 2>&1
pip install boto --user  >> /dev/null 2>&1
pip install --upgrade awscli --user  >> /dev/null 2>&1
rm get-pip.py  >> /dev/null 2>&1

sudo sed -i.bak "s/destination_variable = public_dns_name/destination_variable = private_dns_name/g" /etc/ansible/ec2.ini
sudo sed -i.bak "s/vpc_destination_variable = ip_address/vpc_destination_variable = private_ip_address/g" /etc/ansible/ec2.ini
sudo sed -i.bak "s/#elasticache = False/elasticache = False/g" /etc/ansible/ec2.ini
sudo sed -i.bak "s/#rds = False/rds = False/g" /etc/ansible/ec2.ini

# docker

sudo yum install -y docker  >> /dev/null 2>&1
sudo usermod -aG docker ec2-user  >> /dev/null 2>&1
sudo systemctl start docker  >> /dev/null 2>&1

## test
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user  >> /var/log/pip-install.log
pip install boto --user  >> /var/log/pip-install.log
pip install --upgrade awscli --user  >> /var/log/pip-install.log
rm get-pip.py  >> /dev/null 2>&1

wget https://files.pythonhosted.org/packages/source/m/mitogen/mitogen-0.2.3.tar.gz
tar -xvf mitogen-0.2.3.tar.gz  >> /dev/null 2>&1
sudo mv mitogen-0.2.3 /etc/ansible/

sudo rm /etc/ansible/ansible.cfg

sudo touch /etc/ansible/ansible.cfg
sudo chown ec2-user:ec2-user /etc/ansible/ansible.cfg

echo "[defaults]" >> /etc/ansible/ansible.cfg
echo "strategy_plugins = /etc/ansible/mitogen-0.2.3/ansible_mitogen/plugins/strategy" >> /etc/ansible/ansible.cfg
echo "strategy = mitogen_linear" >> /etc/ansible/ansible.cfg
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
echo "[inventory]" >> /etc/ansible/ansible.cfg
echo "[privilege_escalation]" >> /etc/ansible/ansible.cfg
echo "[paramiko_connection]" >> /etc/ansible/ansible.cfg
echo "[ssh_connection]" >> /etc/ansible/ansible.cfg
echo "[diff]" >> /etc/ansible/ansible.cfg

sudo chmod a+w /etc/ssh/ssh_config

echo "Host *.formation-kubernetes.wescale" >> /etc/ssh/ssh_config
echo "  StrictHostKeyChecking no" >> /etc/ssh/ssh_config

sudo systemctl restart sshd

sudo chmod a-w /etc/ssh/ssh_config

