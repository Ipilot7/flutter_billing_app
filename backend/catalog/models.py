from django.db import models


class Category(models.Model):
	organization = models.ForeignKey(
		'tenancy.Organization', on_delete=models.CASCADE, related_name='categories'
	)
	name = models.CharField(max_length=120)
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		unique_together = ('organization', 'name')

	def __str__(self) -> str:
		return self.name


class Product(models.Model):
	organization = models.ForeignKey(
		'tenancy.Organization', on_delete=models.CASCADE, related_name='products'
	)
	category = models.ForeignKey(
		Category, null=True, blank=True, on_delete=models.SET_NULL, related_name='products'
	)
	name = models.CharField(max_length=200)
	sku = models.CharField(max_length=80, blank=True)
	barcode = models.CharField(max_length=120, db_index=True)
	price = models.DecimalField(max_digits=12, decimal_places=2)
	cost = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	stock = models.DecimalField(max_digits=12, decimal_places=3, default=0)
	min_stock = models.DecimalField(max_digits=12, decimal_places=3, default=0)
	is_active = models.BooleanField(default=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		unique_together = ('organization', 'barcode')

	def __str__(self) -> str:
		return self.name
