from django.contrib import admin

from .models import Category, Product


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
	list_display = ('name', 'organization', 'created_at')
	list_filter = ('organization', 'created_at')
	search_fields = ('name', 'organization__name')
	ordering = ('organization__name', 'name')


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
	list_display = (
		'name',
		'organization',
		'category',
		'barcode',
		'price',
		'stock',
		'is_active',
		'updated_at',
	)
	list_filter = ('is_active', 'organization', 'category')
	search_fields = ('name', 'barcode', 'sku', 'organization__name')
	ordering = ('organization__name', 'name')
