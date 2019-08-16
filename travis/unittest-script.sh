#!/bin/bash

wget https://chromedriver.storage.googleapis.com/763809.68/chromedriver_linux64.zip && \
    sudo unzip chromedriver_linux64.zip -d /usr/local/bin/

python3 -m pip install selenium --user || sudo python3 -m pip install selenium --user || exit 1 

python3 tests/Product_type_unit_test.py || echo 'Error: Product type unittest failed.'; exit 1

python tests/Product_unit_test.py || echo "Error: Product unittest failed"; exit 1

exec echo "All Test Ran Successfully" 
