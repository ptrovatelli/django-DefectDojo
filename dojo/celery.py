
import os
from celery import Celery
from django.conf import settings
import socket
from socket import error as socket_error

# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dojo.settings.settings')

app = Celery('dojo')

# Using a string here means the worker will not have to
# pickle the object when using Windows.
app.config_from_object('django.conf:settings', namespace='CELERY')

app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)

print('coucou celery')
def _check_ptvsd_port_not_in_use(port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('127.0.0.1', port))
    except socket_error as se:
        return False

    return True


ptvsd_port = 3001
if os.environ.get("DD_DEBUG") == "on" and _check_ptvsd_port_not_in_use(ptvsd_port):
    try:
        # enable remote debugging
        import ptvsd
        ptvsd.enable_attach(address=('0.0.0.0', ptvsd_port))
        print("ptvsd listening on port " + ptvsd_port)
    except Exception as e:
        print("Generic exception caught with DD_DEBUG on. Passing.")



@app.task(bind=True)
def debug_task(self):
    print(('Request: {0!r}'.format(self.request)))
