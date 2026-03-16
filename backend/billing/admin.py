from django.contrib import admin

from .models import SubscriptionEvent


@admin.register(SubscriptionEvent)
class SubscriptionEventAdmin(admin.ModelAdmin):
	list_display = (
		'id',
		'organization',
		'provider',
		'event_type',
		'created_at',
		'processed_at',
	)
	list_filter = ('provider', 'organization', 'created_at', 'processed_at')
	search_fields = ('event_type', 'organization__name')
	readonly_fields = ('created_at',)
	ordering = ('-created_at',)
