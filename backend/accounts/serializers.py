from rest_framework import serializers

from .models import User
from tenancy.models import Organization, Store, Terminal


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'role',
            'organization',
            'store',
            'is_active',
        ]


class PlatformRegistrationSerializer(serializers.Serializer):
    organization_name = serializers.CharField(max_length=255)
    store_name = serializers.CharField(max_length=255)
    timezone = serializers.CharField(max_length=64, required=False, default='UTC')
    address = serializers.CharField(max_length=500, required=False, allow_blank=True)

    owner_username = serializers.CharField(max_length=150)
    owner_password = serializers.CharField(min_length=8, write_only=True)
    owner_email = serializers.EmailField(required=False, allow_blank=True)
    owner_first_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    owner_last_name = serializers.CharField(max_length=150, required=False, allow_blank=True)

    def validate_owner_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError('Username already exists.')
        return value

    def create(self, validated_data):
        organization = Organization.objects.create(
            name=validated_data['organization_name'],
        )
        store = Store.objects.create(
            organization=organization,
            name=validated_data['store_name'],
            timezone=validated_data.get('timezone', 'UTC'),
            address=validated_data.get('address', ''),
        )
        owner = User.objects.create_user(
            username=validated_data['owner_username'],
            password=validated_data['owner_password'],
            email=validated_data.get('owner_email', ''),
            first_name=validated_data.get('owner_first_name', ''),
            last_name=validated_data.get('owner_last_name', ''),
            role='owner',
            organization=organization,
            store=store,
        )
        return {
            'organization': organization,
            'store': store,
            'owner': owner,
        }


class CashRegisterRegistrationSerializer(serializers.Serializer):
    store_id = serializers.IntegerField()
    terminal_name = serializers.CharField(max_length=100)
    device_id = serializers.CharField(max_length=255)

    cashier_username = serializers.CharField(max_length=150)
    cashier_password = serializers.CharField(min_length=8, write_only=True)
    cashier_pin = serializers.CharField(max_length=10, required=False, allow_blank=True)
    cashier_first_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    cashier_last_name = serializers.CharField(max_length=150, required=False, allow_blank=True)

    def validate(self, attrs):
        request = self.context['request']
        user = request.user

        if user.role not in ('owner', 'manager'):
            raise serializers.ValidationError('Only owner or manager can register a cash register.')

        try:
            store = Store.objects.get(id=attrs['store_id'])
        except Store.DoesNotExist as exc:
            raise serializers.ValidationError('Invalid store_id.') from exc

        if user.organization_id and store.organization_id != user.organization_id:
            raise serializers.ValidationError('Store is outside your organization.')

        if Terminal.objects.filter(device_id=attrs['device_id']).exists():
            raise serializers.ValidationError('device_id already exists.')

        if User.objects.filter(username=attrs['cashier_username']).exists():
            raise serializers.ValidationError('cashier_username already exists.')

        attrs['store'] = store
        return attrs

    def create(self, validated_data):
        request = self.context['request']
        store = validated_data['store']

        terminal = Terminal.objects.create(
            store=store,
            name=validated_data['terminal_name'],
            device_id=validated_data['device_id'],
        )

        cashier = User.objects.create_user(
            username=validated_data['cashier_username'],
            password=validated_data['cashier_password'],
            first_name=validated_data.get('cashier_first_name', ''),
            last_name=validated_data.get('cashier_last_name', ''),
            role='cashier',
            organization=store.organization,
            store=store,
        )
        cashier_pin = validated_data.get('cashier_pin', '')
        if cashier_pin:
            cashier.set_pin(cashier_pin)
            cashier.save(update_fields=['pin_code'])

        return {
            'terminal': terminal,
            'cashier': cashier,
            'created_by': request.user,
        }


class CashierTerminalLoginSerializer(serializers.Serializer):
    device_id = serializers.CharField(max_length=255)
    cashier_pin = serializers.CharField(max_length=10)

    def validate(self, attrs):
        device_id = attrs['device_id']
        cashier_pin = attrs['cashier_pin']

        try:
            terminal = Terminal.objects.select_related('store', 'store__organization').get(
                device_id=device_id,
                is_active=True,
            )
        except Terminal.DoesNotExist as exc:
            raise serializers.ValidationError('Terminal not found or inactive.') from exc

        cashiers = User.objects.filter(
            role='cashier',
            store=terminal.store,
            is_active=True,
        )

        matched_cashiers = [cashier for cashier in cashiers if cashier.check_pin(cashier_pin)]

        if not matched_cashiers:
            raise serializers.ValidationError('Invalid cashier PIN for this terminal.')

        if len(matched_cashiers) > 1:
            raise serializers.ValidationError(
                'Multiple cashiers share this PIN. Use unique cashier PINs per store.'
            )

        attrs['terminal'] = terminal
        attrs['cashier'] = matched_cashiers[0]
        return attrs


class TokenPairSerializer(serializers.Serializer):
    refresh = serializers.CharField()
    access = serializers.CharField()


class OrganizationInfoSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    name = serializers.CharField()


class StoreInfoSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    name = serializers.CharField()
    organization_id = serializers.IntegerField(required=False)


class TerminalInfoSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    name = serializers.CharField()
    device_id = serializers.CharField()
    store_id = serializers.IntegerField()


class PlatformRegistrationResponseSerializer(serializers.Serializer):
    user = UserSerializer()
    organization = OrganizationInfoSerializer()
    store = StoreInfoSerializer()
    tokens = TokenPairSerializer()


class CashRegisterRegistrationResponseSerializer(serializers.Serializer):
    terminal = TerminalInfoSerializer()
    cashier = UserSerializer()


class CashierTerminalLoginResponseSerializer(serializers.Serializer):
    user = UserSerializer()
    terminal = TerminalInfoSerializer()
    store = StoreInfoSerializer()
    tokens = TokenPairSerializer()
