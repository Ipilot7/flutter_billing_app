from django.core.cache import cache
from django.db import transaction
from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import permissions, status, viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User
from .serializers import (
	CashRegisterRegistrationSerializer,
	CashRegisterRegistrationResponseSerializer,
	CashierTerminalLoginSerializer,
	CashierTerminalLoginResponseSerializer,
	PlatformRegistrationSerializer,
	PlatformRegistrationResponseSerializer,
	UserSerializer,
)


class UserViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = User.objects.all().order_by('id')
	serializer_class = UserSerializer
	permission_classes = [permissions.IsAuthenticated]


class PlatformRegistrationView(APIView):
	permission_classes = [permissions.AllowAny]
	serializer_class = PlatformRegistrationSerializer

	@extend_schema(
		request=PlatformRegistrationSerializer,
		responses={201: PlatformRegistrationResponseSerializer},
	)
	@transaction.atomic
	def post(self, request):
		serializer = PlatformRegistrationSerializer(data=request.data)
		serializer.is_valid(raise_exception=True)
		result = serializer.save()

		owner = result['owner']
		refresh = RefreshToken.for_user(owner)

		return Response(
			{
				'user': UserSerializer(owner).data,
				'organization': {
					'id': result['organization'].id,
					'name': result['organization'].name,
				},
				'store': {
					'id': result['store'].id,
					'name': result['store'].name,
				},
				'tokens': {
					'refresh': str(refresh),
					'access': str(refresh.access_token),
				},
			},
			status=status.HTTP_201_CREATED,
		)


class CashRegisterRegistrationView(APIView):
	permission_classes = [permissions.IsAuthenticated]
	serializer_class = CashRegisterRegistrationSerializer

	@extend_schema(
		request=CashRegisterRegistrationSerializer,
		responses={201: CashRegisterRegistrationResponseSerializer},
	)
	@transaction.atomic
	def post(self, request):
		serializer = CashRegisterRegistrationSerializer(
			data=request.data,
			context={'request': request},
		)
		serializer.is_valid(raise_exception=True)
		result = serializer.save()

		return Response(
			{
				'terminal': {
					'id': result['terminal'].id,
					'name': result['terminal'].name,
					'device_id': result['terminal'].device_id,
					'store_id': result['terminal'].store_id,
				},
				'cashier': UserSerializer(result['cashier']).data,
			},
			status=status.HTTP_201_CREATED,
		)


class CashierTerminalLoginView(APIView):
	permission_classes = [permissions.AllowAny]
	serializer_class = CashierTerminalLoginSerializer
	MAX_FAILED_ATTEMPTS = 5
	FAILED_WINDOW_SECONDS = 300
	LOCK_SECONDS = 900

	@extend_schema(
		request=CashierTerminalLoginSerializer,
		responses={200: CashierTerminalLoginResponseSerializer},
	)
	def post(self, request):
		device_id = str(request.data.get('device_id', '')).strip()
		failed_key = f'cashier_login:failed:{device_id}'
		lock_key = f'cashier_login:lock:{device_id}'

		if device_id and cache.get(lock_key):
			return Response(
				{'detail': 'Too many failed attempts. Try again later.'},
				status=status.HTTP_429_TOO_MANY_REQUESTS,
			)

		serializer = CashierTerminalLoginSerializer(data=request.data)
		try:
			serializer.is_valid(raise_exception=True)
		except ValidationError:
			if device_id:
				failed_attempts = int(cache.get(failed_key, 0)) + 1
				cache.set(failed_key, failed_attempts, self.FAILED_WINDOW_SECONDS)
				if failed_attempts >= self.MAX_FAILED_ATTEMPTS:
					cache.set(lock_key, 1, self.LOCK_SECONDS)
			raise

		terminal = serializer.validated_data['terminal']
		cashier = serializer.validated_data['cashier']

		if device_id:
			cache.delete(failed_key)
			cache.delete(lock_key)

		terminal.last_seen_at = timezone.now()
		terminal.save(update_fields=['last_seen_at'])

		refresh = RefreshToken.for_user(cashier)

		return Response(
			{
				'user': UserSerializer(cashier).data,
				'terminal': {
					'id': terminal.id,
					'name': terminal.name,
					'device_id': terminal.device_id,
					'store_id': terminal.store_id,
				},
				'store': {
					'id': terminal.store.id,
					'name': terminal.store.name,
					'organization_id': terminal.store.organization_id,
				},
				'tokens': {
					'refresh': str(refresh),
					'access': str(refresh.access_token),
				},
			},
			status=status.HTTP_200_OK,
		)
