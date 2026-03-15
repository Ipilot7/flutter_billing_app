"""Development settings."""

from .base import *


DEBUG = env_bool("DJANGO_DEBUG", True)
ALLOWED_HOSTS = env_list("DJANGO_ALLOWED_HOSTS", "*")

DATABASES = {
	"default": {
		"ENGINE": "django.db.backends.sqlite3",
		"NAME": os.getenv("DB_NAME", BASE_DIR / "db.sqlite3"),
	}
}
