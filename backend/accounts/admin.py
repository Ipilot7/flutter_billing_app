from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .models import User


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
	list_display = (
		'username',
		'email',
		'role',
		'organization',
		'store',
		'is_active',
		'is_staff',
	)
	list_filter = ('role', 'is_active', 'is_staff', 'is_superuser', 'organization')
	search_fields = ('username', 'first_name', 'last_name', 'email')
	ordering = ('username',)

	fieldsets = DjangoUserAdmin.fieldsets + (
		(
			'POS Access',
			{
				'fields': ('role', 'organization', 'store', 'pin_code'),
			},
		),
	)

	add_fieldsets = DjangoUserAdmin.add_fieldsets + (
		(
			'POS Access',
			{
				'fields': ('role', 'organization', 'store', 'pin_code'),
			},
		),
	)
