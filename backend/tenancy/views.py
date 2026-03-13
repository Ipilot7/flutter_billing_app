from rest_framework import permissions, viewsets

from .models import Organization, Store, Terminal
from .serializers import OrganizationSerializer, StoreSerializer, TerminalSerializer


class OrganizationViewSet(viewsets.ModelViewSet):
	queryset = Organization.objects.all().order_by('id')
	serializer_class = OrganizationSerializer
	permission_classes = [permissions.IsAuthenticated]


class StoreViewSet(viewsets.ModelViewSet):
	queryset = Store.objects.all().order_by('id')
	serializer_class = StoreSerializer
	permission_classes = [permissions.IsAuthenticated]


class TerminalViewSet(viewsets.ModelViewSet):
	queryset = Terminal.objects.all().order_by('id')
	serializer_class = TerminalSerializer
	permission_classes = [permissions.IsAuthenticated]
