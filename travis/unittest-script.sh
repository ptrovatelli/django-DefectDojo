#!/bin/bash
sudo apt-get install -y gdebi && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo gdebi google-chrome-stable_current_amd64.deb -n

LATEST_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$LATEST_VERSION/chromedriver_linux64.zip && \
    sudo unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    sudo chmod 777 /usr/local/bin/chromedriver;

python3 -m pip install selenium --user || sudo python3 -m pip install selenium --user || exit 1 

docker-compose build

cp dojo/settings/settings.dist.py dojo/settings/settings.py && \
    docker/setEnv.sh dev && \
    docker-compose up -d

echo "export DD_ADMIN_USER='admin'" >> ~/.bashrc && \
    container_id=(`docker ps -a --filter "name=django-defectdojo_initializer_1" | awk 'FNR == 2 {print $1}'`) && \
    docker logs $container_id 2>&1 | grep "Admin password:"| cut -c17- | (read -d '' passwordss; echo "export DD_ADMIN_PASSWORD=$passwordss}" >> ~/.bashrc && \  
    source ~/.bashrc
 
python3 tests/Product_type_unit_test.py || echo 'Error: Product type unittest failed.'; exit 1

python3 tests/Product_unit_test.py || echo "Error: Product unittest failed"; exit 1

exec echo "All Test Ran Successfully" 
