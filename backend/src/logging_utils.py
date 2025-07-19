# logging_utils.py : logging structuré pour Redriva
import logging
import os
from logging.handlers import RotatingFileHandler

LOG_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "logs")
os.makedirs(LOG_DIR, exist_ok=True)
LOG_FILE = os.path.join(LOG_DIR, "redriva.log")

formatter = logging.Formatter(
    fmt='%(asctime)s %(levelname)s %(name)s %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

handler = RotatingFileHandler(LOG_FILE, maxBytes=2*1024*1024, backupCount=3)
handler.setFormatter(formatter)

logger = logging.getLogger("redriva")
logger.setLevel(logging.INFO)
if not logger.hasHandlers():
    logger.addHandler(handler)

# Export du logger comme 'log' pour compatibilité
log = logger

def log_info(msg):
    logger.info(msg)

def log_error(msg):
    logger.error(msg)

def log_access(endpoint, user=None):
    logger.info(f"ACCESS endpoint={endpoint} user={user}")
