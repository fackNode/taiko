#!/bin/bash

fmt=`tput setaf 45`
end="\e[0m\n"
err="\e[31m"
scss="\e[32m"

echo -e "${fmt}\nSetting up dependencies / Устанавливаем необходимые зависимости${end}" && sleep 1

cd $HOME
sudo apt update
sudo apt install curl ca-certificates curl gnupg lsb-release jq -y < "/dev/null"
                
if ! command -v docker &> /dev/null && ! command -v docker-compose &> /dev/null; then
  sudo wget https://raw.githubusercontent.com/fackNode/requirements/main/docker.sh && chmod +x docker.sh && ./docker.sh
fi

echo -e "${fmt}\nInstalling node files / Устанавливаем файлы ноды${end}" && sleep 1

rm -rf simple-taiko-node
git clone https://github.com/taikoxyz/simple-taiko-node.git
cd simple-taiko-node
cp .env.sample .env

sed -i 's|L1_ENDPOINT_HTTP=.*|L1_ENDPOINT_HTTP='"$HTTPSendpoint"'|' .env
sed -i 's|L1_ENDPOINT_WS=.*|L1_ENDPOINT_WS='"$WSSendpoint"'|' .env
sed -i 's|L1_PROVER_PRIVATE_KEY=.*|L1_PROVER_PRIVATE_KEY='"$TAIKO_PRIVATE_KEY"'|' .env
sed -i 's/ENABLE_PROVER=.*/ENABLE_PROVER=true/' .env
sed -i 's/ENABLE_PROPOSER=.*/ENABLE_PROPOSER=true/' .env
sed -i 's|L1_PROPOSER_PRIVATE_KEY=.*|L1_PROPOSER_PRIVATE_KEY='"$TAIKO_PRIVATE_KEY"'|' .env
sed -i 's|L2_SUGGESTED_FEE_RECIPIENT=.*|L2_SUGGESTED_FEE_RECIPIENT='"$metamask_address"'|' .env

docker-compose up -d

if docker ps -a | grep -q 'simple-taiko-node-grafana-1' &&  docker ps -a | grep -q 'simple-taiko-node-prometheus-1' &&  docker ps -a | grep -q 'simple-taiko-node-taiko_client_prover_relayer-1' &&  docker ps -a | grep -q 'simple-taiko-node-taiko_client_driver-1' &&  docker ps -a | grep -q 'simple-taiko-node-l2_execution_engine-1' &&  docker ps -a | grep -q 'simple-taiko-node-zkevm-chain-prover-rpcd-1'; then
  echo -e "${fmt}\nNode installed correctly / Нода установлена корректно${end}" && sleep 1
else
  echo -e "${err}\nNode installed incorrectly / Нода установлена некорректно${end}" && sleep 1
fi

rm $HOME/docker.sh
