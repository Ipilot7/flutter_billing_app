from django.core.cache import cache
from django.db import transaction
from django.utils import timezone
from datetime import timedelta
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


class LogoutView(APIView):
	permission_classes = [permissions.AllowAny]

	def post(self, request):
		"""
		Stateless logout — clients must discard tokens locally.
		Without token_blacklist enabled, JWTs expire naturally.
		"""
		return Response({'detail': 'Logged out successfully.'}, status=status.HTTP_200_OK)


class UserViewSet(viewsets.ReadOnlyModelViewSet):
	queryset = User.objects.all().order_by('id')
	serializer_class = UserSerializer
	permission_classes = [permissions.IsAuthenticated]


class CurrentUserView(APIView):
	permission_classes = [permissions.IsAuthenticated]

	@extend_schema(responses={200: UserSerializer})
	def get(self, request):
		return Response(UserSerializer(request.user).data, status=status.HTTP_200_OK)


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
	MAX_FAILED_ATTEMPTS = 10
	FAILED_WINDOW_SECONDS = 300
	LOCK_SECONDS = 300

	@extend_schema(
		request=CashierTerminalLoginSerializer,
		responses={200: CashierTerminalLoginResponseSerializer},
	)
	def post(self, request):
		device_id = str(request.data.get('device_id', '')).strip()
		failed_key = f'cashier_login:failed:{device_id}'
		lock_key = f'cashier_login:lock:{device_id}'
		lock_until_key = f'cashier_login:lock_until:{device_id}'

		if device_id and cache.get(lock_key):
			lock_until_epoch = cache.get(lock_until_key)
			now_epoch = int(timezone.now().timestamp())
			retry_after = self.LOCK_SECONDS
			if lock_until_epoch is not None:
				try:
					retry_after = max(1, int(lock_until_epoch) - now_epoch)
				except (TypeError, ValueError):
					retry_after = self.LOCK_SECONDS

			return Response(
				{
					'detail': 'Too many failed attempts. Try again later.',
					'retry_after_seconds': retry_after,
				},
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
					lock_until = timezone.now() + timedelta(seconds=self.LOCK_SECONDS)
					lock_until_epoch = int(lock_until.timestamp())
					cache.set(lock_key, 1, self.LOCK_SECONDS)
					cache.set(lock_until_key, lock_until_epoch, self.LOCK_SECONDS)
					return Response(
						{
							'detail': 'Too many failed attempts. Try again later.',
							'retry_after_seconds': self.LOCK_SECONDS,
						},
						status=status.HTTP_429_TOO_MANY_REQUESTS,
					)
			raise

		terminal = serializer.validated_data['terminal']
		cashier = serializer.validated_data['cashier']

		if device_id:
			cache.delete(failed_key)
			cache.delete(lock_key)
			cache.delete(lock_until_key)

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
