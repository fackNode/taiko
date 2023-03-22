#!/bin/bash

curl -s "https://nodes.fackblock.com/api/logo.sh" | sh && sleep 2

fmt=`tput setaf 45`
end="\e[0m\n"
err="\e[31m"
scss="\e[32m"

echo -e "${fmt}\nSetting up dependencies / Устанавливаем необходимые зависимости${end}" && sleep 1
                cd $HOME
                sudo apt update
                sudo apt install curl ca-certificates curl gnupg lsb-release jq -y < "/dev/null"
if ! docker --version; then
                . /etc/*-release
                rm /usr/share/keyrings/docker-archive-keyring.gpg
                sudo wget -qO- "https://download.docker.com/linux/ubuntu/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt update
                sudo apt install docker-ce docker-ce-cli containerd.io -y
fi

if ! docker-compose --version; then
                docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
                sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
                sudo chmod +x /usr/bin/docker-compose
                . $HOME/.bash_profile
fi

echo -e "${fmt}\nInstalling node files / Устанавливаем файлы ноды${end}" && sleep 1
                rm -rf simple-taiko-node
                git clone https://github.com/taikoxyz/simple-taiko-node.git
#                 wget -P $HOME/simple-taiko-node https://raw.githubusercontent.com/fackNode/taiko/main/.env
                cd simple-taiko-node
                cp .env.sample .env
                sed -i 's|L1_ENDPOINT_HTTP=.*|L1_ENDPOINT_HTTP='"$HTTPSendpoint"'|' .env
                sed -i 's|L1_ENDPOINT_WS=.*|L1_ENDPOINT_WS='"$WSSendpoint"'|' .env
                sed -i 's|L1_PROVER_PRIVATE_KEY=.*|L1_PROVER_PRIVATE_KEY='"$TAIKO_PRIVATE_KEY"'|' .env
                sed -i 's/ENABLE_PROVER=.*/ENABLE_PROVER=true/' .env

                docker-compose up -d

if docker ps -a | grep -q 'simple-taiko-node-grafana-1' &&  docker ps -a | grep -q 'simple-taiko-node-prometheus-1' &&  docker ps -a | grep -q 'simple-taiko-node-taiko_client_prover_relayer-1' &&  docker ps -a | grep -q 'simple-taiko-node-taiko_client_driver-1' &&  docker ps -a | grep -q 'simple-taiko-node-l2_execution_engine-1' &&  docker ps -a | grep -q 'simple-taiko-node-zkevm-chain-prover-rpcd-1'; then
              echo -e "${fmt}\nNode installed correctly / Нода установлена корректно${end}" && sleep 1
else
              echo -e "${err}\nNode installed incorrectly / Нода установлена некорректно${end}" && sleep 1
fi
