#!/bin/bash

python3 -m pip install selenium

python3 tests/Product_type_unit_test.py

exec python tests/Product_unit_test.py