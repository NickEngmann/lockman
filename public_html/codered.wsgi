import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, '/var/www/kirmani.io/api/codered/public_html')

from codered import app as application
