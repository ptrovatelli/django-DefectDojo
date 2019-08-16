#!/bin/bash

sudo python3 -m pip install selenium --user

python3 tests/Product_type_unit_test.py

exec python tests/Product_unit_test.py