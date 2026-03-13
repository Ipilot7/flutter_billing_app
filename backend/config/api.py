from rest_framework.routers import DefaultRouter

from accounts.views import UserViewSet
from billing.views import SubscriptionEventViewSet
from catalog.views import CategoryViewSet, ProductViewSet
from sales.views import SaleItemViewSet, SaleViewSet, ShiftViewSet
from syncx.views import SyncOperationViewSet
from tenancy.views import OrganizationViewSet, StoreViewSet, TerminalViewSet

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='users')
router.register(r'organizations', OrganizationViewSet, basename='organizations')
router.register(r'stores', StoreViewSet, basename='stores')
router.register(r'terminals', TerminalViewSet, basename='terminals')
router.register(r'categories', CategoryViewSet, basename='categories')
router.register(r'products', ProductViewSet, basename='products')
router.register(r'shifts', ShiftViewSet, basename='shifts')
router.register(r'sales', SaleViewSet, basename='sales')
router.register(r'sale-items', SaleItemViewSet, basename='sale-items')
router.register(r'sync-operations', SyncOperationViewSet, basename='sync-operations')
router.register(r'subscription-events', SubscriptionEventViewSet, basename='subscription-events')
