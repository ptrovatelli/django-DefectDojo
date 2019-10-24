#!/usr/bin/env bash
# Run travis tests (including the ones with selenium)

umask 0002
cd /app

#if [ "${DD_ADMIN_USER}" = "" ]; then
#	echo "Please set DD_ADMIN_USER in the environment"
#	exit 1
#fi
#if [ "${DD_ADMIN_PASSWORD}" = "" ]; then
#	echo "Please set DD_ADMIN_PASSWORD in the environment"
#	exit 1
#fi

hasError="false"

## this is from travis "unittest-script.sh"
#echo "Running Product type unit tests"
#if python3 tests/Product_type_unit_test.py ; then
#    echo "Success: Product type unit tests passed"
#else
#    echo "Error: Product type unittest failed."; hasError="true"
#fi
#
#if [ $hasError = "true" ]; then
#	echo "ERROR: At least one error found. Check previous logs"
#else
#	echo "All tests are OK"
#fi

# tunnel localhost:8888 to 0.0.0.0:8889 for chrome remote debugging (chrome won't accept remote connexions)
nohup socat tcp-listen:8889,fork tcp:localhost:8888 &

#echo "End of tests. Leaving the container up"
echo "Enter the container with : docker exec -it django-defectdojo_travis_1 bash"
echo "Then: DD_ADMIN_PASSWORD=xxx"
echo "Run a test with: python3 tests/dedupe_unit_test.py"
tail -f /dev/null
