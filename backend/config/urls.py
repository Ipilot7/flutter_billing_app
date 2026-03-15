"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

from .health import health_check

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health'),
    # Versioned API documentation
    path('api/v1/schema/', SpectacularAPIView.as_view(), name='schema-v1'),
    path('api/v1/docs/', SpectacularSwaggerView.as_view(url_name='schema-v1'), name='swagger-ui-v1'),
    path('api/v1/redoc/', SpectacularRedocView.as_view(url_name='schema-v1'), name='redoc-v1'),
    # Versioned API entry points
    path('api/v1/', include('config.api_v1_urls')),
    path('api/v2/', include('config.api_v2_urls')),
    # Backward-compatible docs aliases
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    # Backward-compatible aliases without version segment
    path('api/', include('config.api_legacy_urls')),
]
