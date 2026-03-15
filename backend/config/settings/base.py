"""Base Django settings shared by all environments."""

import os
from datetime import timedelta
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent.parent


def env_bool(name: str, default: bool) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def env_list(name: str, default: str) -> list[str]:
    value = os.getenv(name, default)
    return [item.strip() for item in value.split(",") if item.strip()]


SECRET_KEY = os.getenv(
    "DJANGO_SECRET_KEY",
    "dev-pos-secret-key-change-this-to-a-long-random-value-32chars-min",
)

DEBUG = False
ALLOWED_HOSTS = env_list("DJANGO_ALLOWED_HOSTS", "*")


INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "drf_spectacular",
    "corsheaders",
    "accounts",
    "tenancy",
    "catalog",
    "sales",
    "syncx",
    "billing",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"
ASGI_APPLICATION = "config.asgi.application"

# Database is selected per environment in dev.py/prod.py.
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
AUTH_USER_MODEL = "accounts.User"

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_SCHEMA_CLASS": "config.schema.GroupedAutoSchema",
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": False,
}

SPECTACULAR_SETTINGS = {
    "TITLE": "DeepPOS Backend API",
    "DESCRIPTION": "OpenAPI schema for DeepPOS backend.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "TAGS": [
        {"name": "Authentication", "description": "Owner/cashier auth and JWT operations."},
        {"name": "Accounts", "description": "User/account management."},
        {"name": "Tenancy", "description": "Organizations, stores and terminals."},
        {"name": "Catalog", "description": "Products and categories."},
        {"name": "Sales", "description": "Shifts, sales and sale items."},
        {"name": "Synchronization", "description": "Push/pull and sync operations."},
        {"name": "Billing", "description": "Billing/subscription events."},
        {"name": "Other", "description": "Unclassified endpoints."},
    ],
}

CORS_ALLOW_ALL_ORIGINS = env_bool("DJANGO_CORS_ALLOW_ALL", True)
