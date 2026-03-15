from django.db.models import ProtectedError
from rest_framework import permissions, status, viewsets
from rest_framework.response import Response

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

	def destroy(self, request, *args, **kwargs):
		terminal = self.get_object()
		try:
			terminal.delete()
			return Response(status=status.HTTP_204_NO_CONTENT)
		except ProtectedError:
			# Keep historical sales/shift data consistent: fallback to soft delete.
			if terminal.is_active:
				terminal.is_active = False
				terminal.save(update_fields=['is_active'])

			return Response(
				{
					'detail': 'Terminal has related sales history. It was deactivated instead of deleted.',
					'soft_deleted': True,
					'terminal_id': terminal.id,
				},
				status=status.HTTP_200_OK,
			)
