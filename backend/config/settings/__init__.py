"""Environment-aware Django settings package.

Use DJANGO_ENV=dev|prod (default: dev).
Use DJANGO_DEBUG=true|false to control DEBUG in each environment.
"""

import os
from pathlib import Path

from dotenv import load_dotenv


_BASE_DIR = Path(__file__).resolve().parents[2]
_dotenv_path = _BASE_DIR / '.env'
_dotenv_example_path = _BASE_DIR / '.env.example'

# Shell environment variables still have priority (override=False).
if _dotenv_path.exists():
    load_dotenv(_dotenv_path, override=False)
elif _dotenv_example_path.exists():
    load_dotenv(_dotenv_example_path, override=False)


DJANGO_ENV = os.getenv("DJANGO_ENV", "dev").strip().lower()

if DJANGO_ENV in {"prod", "production"}:
    from .prod import *  # noqa: F401,F403
else:
    from .dev import *  # noqa: F401,F403
