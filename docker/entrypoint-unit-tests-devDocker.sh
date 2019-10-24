#!/bin/sh
# Run available unittests with a simple setup

cd /app
# Unset the database URL so that we can force the DD_TEST_DATABASE_NAME (see django "DATABASES" configuration in settings.dist.py)
unset DD_DATABASE_URL

python3 manage.py makemigrations dojo
python3 manage.py migrate

python3 manage.py test dojo.unittests --keepdb

echo "End of tests. Leaving the container up"
echo "Enter the container with : docker exec -it django-defectdojo_uwsgi_1 bash"
echo "Run a test with: python manage.py test dojo.unittests.test_dependency_check_parser.TestDependencyCheckParser.test_parse_without_file_has_no_findings --keepdb"
tail -f /dev/null
