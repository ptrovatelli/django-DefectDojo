#!/bin/bash
sudo apt-get install gdebi && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo gdebi google-chrome-stable_current_amd64.deb -n

LATEST_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$LATEST_VERSION/chromedriver_linux64.zip && \
    sudo unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    sudo chmod 777 /usr/local/bin/chromedriver;

python3 -m pip install selenium --user || sudo python3 -m pip install selenium --user || exit 1 

python3 tests/Product_type_unit_test.py || echo 'Error: Product type unittest failed.'; exit 1

python3 tests/Product_unit_test.py || echo "Error: Product unittest failed"; exit 1

exec echo "All Test Ran Successfully" 
