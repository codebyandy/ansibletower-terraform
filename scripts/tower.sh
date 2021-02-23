yum install -y nano wget
wget https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-3.7.4-1.tar.gz
tar -zxf ansible-tower-setup-3.7.4-1.tar.gz
sed -i "s/admin_password=''/admin_password='hashidemo'/g" ansible-tower-setup-3.7.4-1/inventory
sed -i "s/pg_password=''/pg_password='hashidemo'/g" ansible-tower-setup-3.7.4-1/inventory
cd ansible-tower-setup-3.7.4-1
./setup.sh
