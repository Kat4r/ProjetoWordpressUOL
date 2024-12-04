#!/bin/bash

# Atualiza os pacotes disponíveis
apt-get update -y

# Instala os pacotes necessários
apt-get install -y ca-certificates curl gnupg

# Cria o diretório para as chaves GPG, se não existir
mkdir -p /etc/apt/keyrings

# Baixa a chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Adiciona o repositório do Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Atualiza novamente os pacotes para incluir o novo repositório
apt-get update -y

# Instala o Docker e seus componentes
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Inicia o serviço Docker e troca suas permissões
systemctl start docker
sudo usermod -aG docker ubuntu
systemctl enable docker

# Testa a instalação do Docker e registra no log
docker --version >> /var/log/user-data.log 2>&1
docker compose version >> /var/log/user-data.log 2>&1


# Instalação do EFS dentro da EC2
apt-get update
apt-get -y install git binutils rustc cargo pkg-config libssl-dev gettext
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
apt-get -y install ./build/amazon-efs-utils*deb

# Criar ponto de montagem do EFS
#sudo mkdir -p /efs

# Montar o EFS usando o EFS Mount Helper com TLS
#sudo mount -t efs -o tls fs-xxxxxxxxxx:/ /efs

# Acessar o armazenamento EFS
#cd /efs

# Cria uma pasta para os arquivos do wordpress
mkdir -p /wp

# Acessa a pasta recém criada
cd /wp

cat << EOF > docker-compose.yaml
services:

  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: <seu-rds>
      WORDPRESS_DB_USER: <seu-usuário>
      WORDPRESS_DB_PASSWORD: <sua-senha>
      WORDPRESS_DB_NAME: <nome-do-banco>
    volumes:
      - /wordpress:/var/www/html
EOF

# Iniciar o docker compose
docker compose up -d





