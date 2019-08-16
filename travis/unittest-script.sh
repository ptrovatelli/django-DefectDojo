#!/bin/bash
sudo apt-get install -y gdebi && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo gdebi google-chrome-stable_current_amd64.deb -n

LATEST_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$LATEST_VERSION/chromedriver_linux64.zip && \
    sudo unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    sudo chmod 777 /usr/local/bin/chromedriver;

python3 -m pip install selenium --user || sudo python3 -m pip install selenium --user || exit 1 

CONTAINER_NAME=django-defectdojo_initializer_1
echo "export DD_ADMIN_USER=admin" >> ~/.profile && \
    container_id=(`docker ps -a --filter name=${CONTAINER_NAME}.* | awk 'FNR == 2 {print $1}'`) && \
    docker logs $container_id 2>&1 | grep "Admin password:"| cut -c17- | (read passwordss; echo "export DD_ADMIN_PASSWORD=$passwordss" >> ~/.profile) && \
    source ~/.profile

echo "Running Product type unit tests"
python3 tests/Product_type_unit_test.py || echo 'Error: Product type unittest failed.'

echo "Running Product unit tests"
python3 tests/Product_unit_test.py || echo "Error: Product unittest failed"

echo "Running Endpoint unit tests"
python3 tests/Endpoint_unit_test.py || echo "Error: Endpoint unittest failed"

echo "Running Engagement unit tests"
python3 tests/Engagement_unit_test.py || echo "Error: Engagement unittest failed"

echo "Running Environment unit tests"
python3 tests/Environment_unit_test.py || echo "Error: Environment unittest failed"

echo "Running Finding unit tests"
python3 tests/Finding_unit_test.py || echo "Error: Finding unittest failed"

echo "Running Test unit tests"
python3 tests/Test_unit_test.py || echo "Error: Test unittest failed"

echo "Running User unit tests"
python3 tests/User_unit_test.py || echo "Error: User unittest failed"

echo "Running Dedupe unit tests"
python3 tests/dedupe_unit_test.py || echo "Error: Dedupe unittest failed"

echo "Running Ibm Appscan unit test"
python3 tests/ibm_appscan_test.py || echo "Error: Ibm AppScan unittest failed"

echo "Running Zap unit test"
python3 tests/zap.py || echo "Error: Zap unittest failed"

echo "Running Smoke unit test"
python3 tests/smoke_test.py || echo "Error: Smoke unittest failed"

exec echo "All Test Ran Successfully"
