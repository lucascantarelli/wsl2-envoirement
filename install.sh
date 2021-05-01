#!/bin/bash
echo "Atualizando repositórios..."
if ! apt-get update
then
    echo "Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/sources.list"
    exit 1
fi
if ! apt-get upgrade -y
then
    echo "Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/sources.list"
    exit 1
fi
echo "Atualização feita com sucesso"
echo "Atualizando pacotes já instalados..."
if ! apt-get dist-upgrade -y
then
	if ! dpkg --configure -a
	then
		echo "Não foi possível atualizar pacotes. Rode Manualmente o comando \"dpkg --configure -a\""
		exit 1
	fi
fi
clear
echo "Script de Configuração do Docker"
echo "Instalando os Pacotes Nescessarios para o Sistema."
if ! apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common  \
	-y
then
	echo "Não Foi Possivel Instalar os Pacotes a Seguir: apt-transport-https \ ca-certificates \ curl \ gnupg-agent \ software-properties-common"
	exit 1
fi
sleep(2)
clear
echo "Script de Configuração do Docker"
echo "Adicionando Chave GPG Oficial do Docker...."
if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
then
	echo "Houve um Erro ao Tentar Adicionar a Chave GPG do Docker."
	exit 1
fi
clear
echo "Chave Adicionada !"

echo "Verificação da Assinatura Digital: 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
if ! apt-key fingerprint 0EBFCD88
then
	echo "Erro ao Verificar a Assinatura Digital."
	exit 1
fi
echo "Assinatura Digital OK."

echo "Adicionando Repositorio  x86_64 / amd64"
if ! add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) \
	stable"
then
	echo "Não Foi Possivel Adicionar o Repositorio do Docker."
	exit 1
fi
echo "Repositorio Adicionando com Sucesso."
sleep(2)
clear
echo "Script de Configuração do Docker"
echo "Atualizando repositórios..."
if ! apt-get update
then
    echo "Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/sources.list"
    exit 1
fi
echo "Atualização feita com sucesso"

echo "Instalando os Pacotes: docker-ce docker-ce-cli containerd.io"
if ! apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y
then
	echo "Erro na Instalação dos Pacotes: apt-get install docker-ce docker-ce-cli containerd.io"
	exit 1
fi
clear
echo "Script de Configuração do Docker"
echo "Docker Instalado com Sucesso, os seguintes pacotes foram adicionados: docker-ce docker-ce-cli containerd.io"
sleep(2)
clear
echo "Script de Configuração do Docker"
echo "Instalando os Pacotes: Python"
if ! apt-get install -y python3-pip build-essential libssl-dev libffi-dev python-dev python3-venv
then
	echo "Erro na Instalação dos Pacotes: apt-get install docker-ce docker-ce-cli containerd.io"
	exit 1
fi
clear
echo "Script de Configuração do Docker"
echo "Python Instalado com Sucesso, os seguintes pacotes foram adicionados: python3-pip build-essential libssl-dev libffi-dev python-dev python3-venv"
sleep(2)
clear
echo "Script de Configuração do Docker"
if ! sudo systemctl enable docker.service
then
	echo "Não foi possivel adicionar na Inicialização"
fi
if ! sudo chmod -R 777 /var/run/docker.sock
then
	echo "Permissão Negada !"
fi
if ! sudo service docker start
then
	echo "Não foi possivel iniciar o docker"
fi
clear
if ! sudo service docker status
then
	echo "Docker Não Iniciado !"
fi


sudo docker swarm init
docker node inspect self --format '{{ .Status.Addr  }}'