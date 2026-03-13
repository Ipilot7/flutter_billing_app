from django.utils import timezone
from django.utils.dateparse import parse_datetime
from rest_framework import permissions, status, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView

from catalog.models import Category, Product
from catalog.serializers import CategorySerializer, ProductSerializer
from sales.models import Sale, Shift
from sales.serializers import SaleSerializer, ShiftSerializer
from tenancy.models import Terminal
from .handlers import apply_operation
from .models import SyncOperation
from .serializers import SyncOperationSerializer


class SyncOperationViewSet(viewsets.ModelViewSet):
	queryset = SyncOperation.objects.all().order_by('-created_at')
	serializer_class = SyncOperationSerializer
	permission_classes = [permissions.IsAuthenticated]


class SyncPushView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def post(self, request):
		terminal_id = request.data.get('terminal_id')
		operations = request.data.get('operations', [])

		if not terminal_id:
			return Response(
				{'detail': 'terminal_id is required'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		if not isinstance(operations, list):
			return Response(
				{'detail': 'operations must be a list'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		applied = []
		duplicates = []
		failed = []

		try:
			terminal = Terminal.objects.get(id=terminal_id)
		except Terminal.DoesNotExist:
			return Response(
				{'detail': 'Invalid terminal_id'},
				status=status.HTTP_400_BAD_REQUEST,
			)

		for operation in operations:
			try:
				operation_id = operation['operation_id']
				entity_type = operation.get('entity_type', 'unknown')
				entity_id = str(operation.get('entity_id', ''))
				payload = operation.get('payload', {})

				sync_op, created = SyncOperation.objects.get_or_create(
					operation_id=operation_id,
					defaults={
						'terminal_id': terminal_id,
						'entity_type': entity_type,
						'entity_id': entity_id,
						'payload': payload,
						'status': 'applied',
						'processed_at': timezone.now(),
					},
				)

				if created:
					try:
						result = apply_operation(
							entity_type=entity_type,
							terminal=terminal,
							payload=payload,
							user=request.user,
						)
						sync_op.status = 'applied'
						sync_op.payload = {**payload, '_result': result}
						sync_op.processed_at = timezone.now()
						sync_op.save(update_fields=['status', 'payload', 'processed_at'])
					except Exception as apply_exc:
						sync_op.status = 'failed'
						sync_op.error = str(apply_exc)
						sync_op.processed_at = timezone.now()
						sync_op.save(update_fields=['status', 'error', 'processed_at'])
						failed.append({'operation': operation, 'error': str(apply_exc)})
						continue

					applied.append(operation_id)
				else:
					duplicates.append(operation_id)
			except Exception as exc:
				failed.append({'operation': operation, 'error': str(exc)})

		return Response(
			{
				'applied': applied,
				'duplicates': duplicates,
				'failed': failed,
				'server_time': timezone.now().isoformat(),
			},
			status=status.HTTP_200_OK,
		)


class SyncPullView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	def get(self, request):
		since_raw = request.query_params.get('since')
		since = parse_datetime(since_raw) if since_raw else None

		user_org_id = getattr(request.user, 'organization_id', None)
		org_id = user_org_id or request.query_params.get('organization_id')

		product_qs = Product.objects.all()
		category_qs = Category.objects.all()
		shift_qs = Shift.objects.all()
		sale_qs = Sale.objects.all()

		if org_id:
			product_qs = product_qs.filter(organization_id=org_id)
			category_qs = category_qs.filter(organization_id=org_id)
			shift_qs = shift_qs.filter(organization_id=org_id)
			sale_qs = sale_qs.filter(organization_id=org_id)

		if since:
			product_qs = product_qs.filter(updated_at__gt=since)
			category_qs = category_qs.filter(created_at__gt=since)
			shift_qs = shift_qs.filter(opened_at__gt=since)
			sale_qs = sale_qs.filter(created_at__gt=since)

		products = ProductSerializer(product_qs.order_by('id'), many=True).data
		categories = CategorySerializer(category_qs.order_by('id'), many=True).data
		shifts = ShiftSerializer(shift_qs.order_by('id'), many=True).data
		sales = SaleSerializer(sale_qs.order_by('id'), many=True).data

		return Response(
			{
				'server_time': timezone.now().isoformat(),
				'next_cursor': timezone.now().isoformat(),
				'data': {
					'products': products,
					'categories': categories,
					'shifts': shifts,
					'sales': sales,
				},
			},
			status=status.HTTP_200_OK,
		)
