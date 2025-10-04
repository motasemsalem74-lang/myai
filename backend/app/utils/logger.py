"""
إعداد Logger
Logger Configuration
"""

import logging
import sys
from pathlib import Path
from datetime import datetime

def setup_logger(name: str) -> logging.Logger:
    """إعداد logger مع تنسيق مخصص"""
    
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    
    # Console Handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    
    # تنسيق الرسائل
    formatter = logging.Formatter(
        '%(asctime)s | %(levelname)-8s | %(name)s | %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    console_handler.setFormatter(formatter)
    
    if not logger.handlers:
        logger.addHandler(console_handler)
    
    return logger
