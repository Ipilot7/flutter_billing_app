from rest_framework import permissions, viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from .models import Shift, Sale, SaleItem
from .serializers import (
	SaleCreateSerializer,
	ShiftSerializer,
	SaleSerializer,
	SaleItemSerializer,
)
from .permissions import IsPosStaff


class ShiftViewSet(viewsets.ModelViewSet):
	queryset = Shift.objects.all().order_by('-opened_at')
	serializer_class = ShiftSerializer
	permission_classes = [permissions.IsAuthenticated, IsPosStaff]

	def get_queryset(self):
		qs = super().get_queryset()
		user = self.request.user
		if user.organization_id:
			qs = qs.filter(organization_id=user.organization_id)
		if user.role == 'cashier' and user.store_id:
			qs = qs.filter(store_id=user.store_id)
		return qs

	def perform_create(self, serializer):
		user = self.request.user
		terminal = serializer.validated_data['terminal']

		if user.organization_id and terminal.store.organization_id != user.organization_id:
			raise ValidationError('Terminal is outside your organization.')

		if user.role == 'cashier' and user.store_id != terminal.store_id:
			raise ValidationError('Cashier can open shift only for own store terminal.')

		has_open_shift = Shift.objects.filter(
			terminal=terminal,
			status='open',
		).exists()
		if has_open_shift:
			raise ValidationError('Terminal already has an open shift.')

		serializer.save(
			organization=terminal.store.organization,
			store=terminal.store,
			opened_by=user,
		)


class SaleViewSet(viewsets.ModelViewSet):
	queryset = Sale.objects.all().order_by('-created_at')
	serializer_class = SaleSerializer
	permission_classes = [permissions.IsAuthenticated, IsPosStaff]

	def get_serializer_class(self):
		if self.action == 'create':
			return SaleCreateSerializer
		return SaleSerializer

	def get_queryset(self):
		qs = super().get_queryset()
		user = self.request.user
		if user.organization_id:
			qs = qs.filter(organization_id=user.organization_id)
		if user.role == 'cashier' and user.store_id:
			qs = qs.filter(store_id=user.store_id)
		return qs

	def perform_create(self, serializer):
		user = self.request.user
		shift = serializer.validated_data['shift']

		if shift.status != 'open':
			raise ValidationError('Cannot create sale with closed shift.')

		if user.organization_id and shift.organization_id != user.organization_id:
			raise ValidationError('Shift is outside your organization.')

		if user.role == 'cashier' and user.store_id != shift.store_id:
			raise ValidationError('Cashier can create sale only for own store.')

		serializer.save(
			organization=shift.organization,
			store=shift.store,
			terminal=shift.terminal,
			created_by=user,
		)

	def create(self, request, *args, **kwargs):
		write_serializer = self.get_serializer(data=request.data)
		write_serializer.is_valid(raise_exception=True)
		self.perform_create(write_serializer)
		read_serializer = SaleSerializer(write_serializer.instance, context=self.get_serializer_context())
		headers = self.get_success_headers(read_serializer.data)
		return Response(read_serializer.data, status=201, headers=headers)


class SaleItemViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = SaleItem.objects.all().order_by('id')
	serializer_class = SaleItemSerializer
	permission_classes = [permissions.IsAuthenticated, IsPosStaff]

	def get_queryset(self):
		qs = super().get_queryset()
		user = self.request.user
		if user.organization_id:
			qs = qs.filter(sale__organization_id=user.organization_id)
		if user.role == 'cashier' and user.store_id:
			qs = qs.filter(sale__store_id=user.store_id)
		return qs
