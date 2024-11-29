#!/bin/bash

# Atualiza os pacotes disponíveis
apt-get update -y

# Instala os pacotes necessários
apt-get install -y ca-certificates curl gnupg

# Configuração do Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Inicia o Docker e adiciona permissões ao usuário
systemctl start Docker
usermod -aG docker ubuntu
systemctl enable docker


# Instalação do EFS dentro da EC2
apt-get install -y git binutils rustc cargo pkg-config libssl-dev gettext
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
apt-get install -y ./build/amazon-efs-utils*deb

# Criar ponto de montagem do EFS
mkdir -p /efs
mount -t efs -o tls fs-xxxxxxxx:/ /efs

# Espera o arquivo docker-compose.yaml aparecer
while [ ! -f /efs/docker-compose.yaml ]; do
    sleep 1
done

# Subir o contêiner do WordPress
cd /efs
docker-compose up -d
