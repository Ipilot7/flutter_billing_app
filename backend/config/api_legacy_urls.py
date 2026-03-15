from django.urls import include, path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from accounts.views import (
    CashierTerminalLoginView,
    CashRegisterRegistrationView,
    PlatformRegistrationView,
)
from syncx.views import SyncPullView, SyncPushView

from .api import router

urlpatterns = [
    path('auth/register/platform/', PlatformRegistrationView.as_view(), name='platform_register'),
    path('auth/register/cash-register/', CashRegisterRegistrationView.as_view(), name='cash_register_register'),
    path('auth/login/cashier-terminal/', CashierTerminalLoginView.as_view(), name='cashier_terminal_login'),
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('sync/push/', SyncPushView.as_view(), name='sync_push'),
    path('sync/pull/', SyncPullView.as_view(), name='sync_pull'),
    path('', include(router.urls)),
]
