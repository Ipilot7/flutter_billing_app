from rest_framework import serializers

from .models import SyncOperation


class SyncOperationSerializer(serializers.ModelSerializer):
    class Meta:
        model = SyncOperation
        fields = '__all__'
