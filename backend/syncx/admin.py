from django.contrib import admin

from .models import SyncOperation


@admin.register(SyncOperation)
class SyncOperationAdmin(admin.ModelAdmin):
	list_display = (
		'operation_id',
		'terminal',
		'entity_type',
		'entity_id',
		'status',
		'created_at',
		'processed_at',
	)
	list_filter = ('status', 'entity_type', 'terminal__store__organization', 'terminal')
	search_fields = (
		'operation_id',
		'entity_type',
		'entity_id',
		'terminal__name',
		'terminal__device_id',
	)
	readonly_fields = ('created_at', 'processed_at')
	ordering = ('-created_at',)
