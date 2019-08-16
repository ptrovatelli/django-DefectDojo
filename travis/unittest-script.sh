#!/bin/bash

docker exec -it django-defectdojo_uwsgi_1 /bin/bash

python tests/Product_type_unit_test.py

exec python tests/Product_unit_test.py