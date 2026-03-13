from rest_framework import permissions, viewsets

from .models import SubscriptionEvent
from .serializers import SubscriptionEventSerializer


class SubscriptionEventViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = SubscriptionEvent.objects.all().order_by('-created_at')
	serializer_class = SubscriptionEventSerializer
	permission_classes = [permissions.IsAuthenticated]
