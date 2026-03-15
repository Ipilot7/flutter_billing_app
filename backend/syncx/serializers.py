from rest_framework import serializers

from .models import SyncOperation


class SyncOperationSerializer(serializers.ModelSerializer):
    class Meta:
        model = SyncOperation
        fields = '__all__'


class SyncPushOperationSerializer(serializers.Serializer):
    operation_id = serializers.CharField()
    entity_type = serializers.CharField()
    entity_id = serializers.CharField(required=False, allow_blank=True)
    payload = serializers.DictField(required=False)


class SyncPushRequestSerializer(serializers.Serializer):
    terminal_id = serializers.IntegerField()
    operations = SyncPushOperationSerializer(many=True)


class SyncPushErrorItemSerializer(serializers.Serializer):
    operation = serializers.DictField()
    error = serializers.CharField()


class SyncPushResponseSerializer(serializers.Serializer):
    applied = serializers.ListField(child=serializers.CharField())
    duplicates = serializers.ListField(child=serializers.CharField())
    failed = SyncPushErrorItemSerializer(many=True)
    server_time = serializers.DateTimeField()


class SyncPullDataSerializer(serializers.Serializer):
    products = serializers.ListField(child=serializers.DictField())
    categories = serializers.ListField(child=serializers.DictField())
    shifts = serializers.ListField(child=serializers.DictField())
    sales = serializers.ListField(child=serializers.DictField())


class SyncPullResponseSerializer(serializers.Serializer):
    server_time = serializers.DateTimeField()
    next_cursor = serializers.DateTimeField()
    data = SyncPullDataSerializer()
