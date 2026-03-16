from django.contrib import admin

from .models import Shift, Sale, SaleItem


class SaleItemInline(admin.TabularInline):
	model = SaleItem
	extra = 0
	readonly_fields = ('product_name', 'quantity', 'price', 'discount', 'line_total')
	fields = ('product', 'product_name', 'quantity', 'price', 'discount', 'line_total')


@admin.register(Shift)
class ShiftAdmin(admin.ModelAdmin):
	list_display = (
		'id',
		'organization',
		'store',
		'terminal',
		'status',
		'start_balance',
		'end_balance',
		'opened_at',
		'closed_at',
	)
	list_filter = ('status', 'organization', 'store', 'terminal')
	search_fields = (
		'id',
		'store__name',
		'terminal__name',
		'opened_by__username',
		'closed_by__username',
	)
	ordering = ('-opened_at',)


@admin.register(Sale)
class SaleAdmin(admin.ModelAdmin):
	list_display = (
		'id',
		'organization',
		'store',
		'terminal',
		'receipt_number',
		'payment_type',
		'total',
		'is_return',
		'created_at',
	)
	list_filter = ('payment_type', 'is_return', 'organization', 'store', 'terminal')
	search_fields = ('id', 'receipt_number', 'created_by__username', 'store__name')
	ordering = ('-created_at',)
	inlines = [SaleItemInline]


@admin.register(SaleItem)
class SaleItemAdmin(admin.ModelAdmin):
	list_display = ('id', 'sale', 'product', 'product_name', 'quantity', 'price', 'line_total')
	list_filter = ('sale__store', 'sale__terminal')
	search_fields = ('sale__receipt_number', 'product_name', 'product__barcode')
	ordering = ('-id',)
