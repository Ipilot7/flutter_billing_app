from django.db import models


class SyncOperation(models.Model):
	STATUS_CHOICES = [
		('pending', 'Pending'),
		('applied', 'Applied'),
		('failed', 'Failed'),
	]

	operation_id = models.UUIDField(unique=True)
	terminal = models.ForeignKey(
		'tenancy.Terminal', on_delete=models.CASCADE, related_name='sync_operations'
	)
	entity_type = models.CharField(max_length=100)
	entity_id = models.CharField(max_length=100)
	payload = models.JSONField(default=dict)
	status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
	error = models.TextField(blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	processed_at = models.DateTimeField(null=True, blank=True)
