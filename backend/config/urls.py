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
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from accounts.views import (
    CashierTerminalLoginView,
    CashRegisterRegistrationView,
    PlatformRegistrationView,
)

from .api import router
from .health import health_check
from syncx.views import SyncPullView, SyncPushView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health'),
    path('api/auth/register/platform/', PlatformRegistrationView.as_view(), name='platform_register'),
    path('api/auth/register/cash-register/', CashRegisterRegistrationView.as_view(), name='cash_register_register'),
    path('api/auth/login/cashier-terminal/', CashierTerminalLoginView.as_view(), name='cashier_terminal_login'),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/sync/push/', SyncPushView.as_view(), name='sync_push'),
    path('api/sync/pull/', SyncPullView.as_view(), name='sync_pull'),
    path('api/', include(router.urls)),
]
