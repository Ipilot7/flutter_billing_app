from rest_framework.permissions import BasePermission


class IsPosStaff(BasePermission):
    """Allows only POS staff roles to access sales/shift endpoints."""

    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False
        return user.role in ('owner', 'manager', 'cashier')
