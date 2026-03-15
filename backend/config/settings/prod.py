"""Production settings."""

from .base import *


DEBUG = env_bool("DJANGO_DEBUG", False)
ALLOWED_HOSTS = env_list("DJANGO_ALLOWED_HOSTS", "")

DATABASES = {
	"default": {
		"ENGINE": "django.db.backends.postgresql",
		"NAME": os.getenv("DB_NAME", "deeppos"),
		"USER": os.getenv("DB_USER", "postgres"),
		"PASSWORD": os.getenv("DB_PASSWORD", ""),
		"HOST": os.getenv("DB_HOST", "127.0.0.1"),
		"PORT": os.getenv("DB_PORT", "5432"),
	}
}

SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
SECURE_HSTS_SECONDS = 31536000 if not DEBUG else 0
SECURE_HSTS_INCLUDE_SUBDOMAINS = not DEBUG
SECURE_HSTS_PRELOAD = not DEBUG
SECURE_SSL_REDIRECT = env_bool("DJANGO_SECURE_SSL_REDIRECT", not DEBUG)
