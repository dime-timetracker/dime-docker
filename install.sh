#!/bin/bash

echo "Checking prerequisites..."
tools=( git docker docker-compose npm )
for tool in "${tools[@]}"; do
  if ! type "$tool" > /dev/null; then
    echo -e "\e[0;31m - $tool \e[m"
  else
    echo -e "\e[0;32m + $tool \e[m"
  fi
done

if [ ! -e ".git" ]; then
  echo "Fetching sources..."
  git clone --recursive git://github.com/dime-timetracker/dime-docker.git dime || exit 1
  cd dime
else
  if [ -e ".installed" ]; then
    echo 'Dime already installed.'
    exit 1
  fi
fi

fqn=$(host -TtA $(hostname -s)2>/dev/null|grep "has address"|awk '{print $1}');
if [[ "${fqn}" == ""  ]]; then
  fqn=$(hostname -s);
fi

echo "Initialize Docker"
docker-compose up -d

echo "Setup Frontend"
frontendConfig="frontend/src/parameters.js"
echo "Using ${fqn} as server name. Please adjust $frontendConfig manually, if that is not correct."
cp $frontendConfig.template $frontendConfig
echo "env.baseUrl = \"$fqn:8100\"" >> $frontendConfig
cd frontend; npm install; npm run build
cd ..

echo "Setup Server"
serverConfig="server/config/parameters.php"
sed -r "s/'host' => '.*'/'host' => 'db'/" $serverConfig.dist > $serverConfig

curl -s https://getcomposer.org/installer > server/composer-setup.php
docker exec -it dime_api_1 php -r "if (hash_file('SHA384', 'composer-setup.php') !== 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer corrupt'; unlink('composer-setup.php');  } echo PHP_EOL;"
docker exec -it dime_api_1 php composer-setup.php
rm composer-setup.php
docker exec -it dime_api_1 php composer.phar install
docker exec -it dime_api_1 php console.php dime:install

touch .installed

echo ""
echo "Done. Dime is now running at http://$fqn:8100/"
