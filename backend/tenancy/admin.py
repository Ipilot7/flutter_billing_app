from django.contrib import admin

from .models import Organization, Store, Terminal


class TerminalInline(admin.TabularInline):
	model = Terminal
	extra = 0
	fields = ('name', 'device_id', 'is_active', 'last_seen_at', 'created_at')
	readonly_fields = ('created_at',)


@admin.register(Organization)
class OrganizationAdmin(admin.ModelAdmin):
	list_display = ('name', 'subscription_status', 'subscription_expires_at', 'created_at')
	list_filter = ('subscription_status', 'created_at')
	search_fields = ('name',)
	ordering = ('name',)


@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
	list_display = ('name', 'organization', 'timezone', 'is_active', 'created_at')
	list_filter = ('is_active', 'timezone', 'organization')
	search_fields = ('name', 'organization__name', 'address')
	ordering = ('organization__name', 'name')
	inlines = [TerminalInline]


@admin.register(Terminal)
class TerminalAdmin(admin.ModelAdmin):
	list_display = ('name', 'store', 'device_id', 'is_active', 'last_seen_at', 'created_at')
	list_filter = ('is_active', 'store__organization', 'store')
	search_fields = ('name', 'device_id', 'store__name', 'store__organization__name')
	ordering = ('store__organization__name', 'store__name', 'name')
