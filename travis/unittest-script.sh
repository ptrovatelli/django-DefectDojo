#!/bin/bash

# This sets default permission of 775 to all files created with this script
umask 0002

cp ./dojo/settings/settings.dist.py ./dojo/settings/settings.py && \
    source ./docker/setEnv.sh dev && \
    docker-compose up -d

echo "Waiting for services to start"
# wait for services to become available
sleep 50

alias pythnExec=""

## Installing Google Chrome browser
sudo apt-get install -y gdebi && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo gdebi google-chrome-stable_current_amd64.deb -n

## Installing Chromium Driver and Selenium for test automation
LATEST_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$LATEST_VERSION/chromedriver_linux64.zip && \
    sudo unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    sudo chmod 777 /usr/local/bin/chromedriver;

python -m pip install virtualenv --user || exit 1

# activate python3 virtual environment
virtualenv --python=python3 ~/dojo-venv && \
    source ~/dojo-venv/bin/activate

pip install selenium requests || exit 1 

# Exporting Username and password to env for access by automation scripts
CONTAINER_NAME=django-defectdojo_initializer_1
echo "export DD_ADMIN_USER=admin" >> ~/.profile && \
    container_id=(`docker ps -a --filter name=${CONTAINER_NAME}.* | awk 'FNR == 2 {print $1}'`) && \
    docker logs $container_id 2>&1 | grep "Admin password:"| cut -c17- | (read passwordss; echo "export DD_ADMIN_PASSWORD=$passwordss" >> ~/.profile) && \
    source ~/.profile

# All available Unittest Scripts are activated below
# If successful, A success message is printed and the script continues
# If any script is unsuccessful a failure message is printed and the test script
# Exits with status code of 1

echo "Running Product type unit tests"
if docker exec -it ${CONTAINER_NAME}.* python tests/Product_type_unit_test.py ; then
    echo "Success: Product type unit tests passed"
else
    echo "Error: Product type unittest failed."; exit 1
fi

# echo "Running Product unit tests"
# if pythnExec tests/Product_unit_test.py ; then 
#     echo "Success: Product unit tests passed"
# else
#     echo "Error: Product unit tests failed"; exit 1
# fi

echo "Running Endpoint unit tests"
if pythnExec tests/Endpoint_unit_test.py ; then
    echo "Success: Endpoint unit tests passed"
else
    echo "Error: Endpoint unit tests failed"; exit 1
fi

echo "Running Engagement unit tests"
if pythnExec tests/Engagement_unit_test.py ; then
    echo "Success: Engagement unit tests passed"
else
    echo "Error: Engagement unittest failed"; exit 1
fi

echo "Running Environment unit tests"
if pythnExec tests/Environment_unit_test.py ; then 
    echo "Success: Environment unit tests passed"
else
    echo "Error: Environment unittest failed"; exit 1
fi

echo "Running Finding unit tests"
if pythnExec tests/Finding_unit_test.py ; then
    echo "Success: Finding unit tests passed"
else
    echo "Error: Finding unittest failed"; exit 1
fi

echo "Running Test unit tests"
if pythnExec tests/Test_unit_test.py ; then
    echo "Success: Test unit tests passed"
else
    echo "Error: Test unittest failed"; exit 1
fi

echo "Running User unit tests"
if pythnExec tests/User_unit_test.py ; then
    echo "Success: User unit tests passed"
else
    echo "Error: User unittest failed"; exit 1
fi

echo "Running Ibm Appscan unit test"
if pythnExec tests/ibm_appscan_test.py ; then
    echo "Success: Ibm AppScan unit tests passed"
else
    echo "Error: Ibm AppScan unittest failed"; exit 1
fi

echo "Running Smoke unit test"
if pythnExec tests/smoke_test.py ; then
    echo "Success: Smoke unit tests passed"
else
    echo "Error: Smoke unittest failed"; exit 1
fi

echo "Running Check Status test"
if pythnExec tests/check_status.py ; then
    echo "Success: check status tests passed"
else
    echo "Error: Check status tests failed"; exit 1
fi

# The below tests are commented out because they are still an unstable work in progress
## Once Ready they can be uncommented.

# echo "Running Import Scanner unit test"
# if pythnExec tests/Import_scanner_unit_test.py ; then
#     echo "Success: Import Scanner unit tests passed" 
# else
#     echo "Error: Import Scanner unit tests failed"; exit 1
# fi

# echo "Running Check Status UI unit test"
# if pythnExec tests/check_status_ui.py ; then
#     echo "Success: Check Status UI unit tests passed"
# else
#     echo "Error: Check Status UI test failed"; exit 1
# fi

# echo "Running Zap unit test"
# if pythnExec tests/zap.py ; then
#     echo "Success: zap unit tests passed"
# else
#     echo "Error: Zap unittest failed"; exit 1
# fi

# echo "Running Dedupe unit tests"
# if pythnExec tests/dedupe_unit_test.py ; then
#     echo "Success: Dedupe unit tests passed"
# else
#     echo "Error: Dedupe unittest failed"; exit 1
# fi

exec echo "Done Running all configured unittests."
