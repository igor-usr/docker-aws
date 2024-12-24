#!/bin/bash

# atualiza sistema
sudo yum update -y

# instala o docker
sudo yum install -y docker
 
# inicia e habilita o serviço do docker
sudo systemctl start docker
sudo systemctl enable docker
 
# dá permissões de administrador para os usuários docker e ec2-user
sudo usermod -aG docker ec2-user
newgrp docker

# download do docker compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
 
# altera permissões de execução do docker-compose
sudo chmod +x /usr/local/bin/docker-compose
 
# cria diretório app
sudo mkdir /app

# cria e edita o arquivo docker-compose.yml dentro do diretório /app
cat <<EOF > /app/compose.yml

services: 
  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: "" # endereço do RDS
      WORDPRESS_DB_USER: "" # usuário do banco de dados
      WORDPRESS_DB_PASSWORD: "" # senha do banco de dados
      WORDPRESS_DB_NAME: "" # nome do banco de dados no RDS
    volumes:
      - /mnt/efs:/var/www/html
EOF
# criar diretório /mnt/efs
sudo mkdir -p /mnt/efs

# definir DNS do EFS onde estão as duas últimas chaves
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <>:/ /mnt/efs

# executa o arquivo docker-compose.yml
docker-compose -f /app/compose.yml up -d
