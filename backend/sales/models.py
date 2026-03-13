from django.db import models


class Shift(models.Model):
	STATUS_CHOICES = [('open', 'Open'), ('closed', 'Closed')]

	organization = models.ForeignKey(
		'tenancy.Organization', on_delete=models.CASCADE, related_name='shifts'
	)
	store = models.ForeignKey('tenancy.Store', on_delete=models.CASCADE, related_name='shifts')
	terminal = models.ForeignKey(
		'tenancy.Terminal', on_delete=models.CASCADE, related_name='shifts'
	)
	opened_by = models.ForeignKey(
		'accounts.User', on_delete=models.PROTECT, related_name='opened_shifts'
	)
	closed_by = models.ForeignKey(
		'accounts.User', null=True, blank=True, on_delete=models.PROTECT, related_name='closed_shifts'
	)
	start_balance = models.DecimalField(max_digits=12, decimal_places=2)
	end_balance = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
	status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='open')
	opened_at = models.DateTimeField(auto_now_add=True)
	closed_at = models.DateTimeField(null=True, blank=True)


class Sale(models.Model):
	PAYMENT_CHOICES = [('cash', 'Cash'), ('card', 'Card'), ('terminal', 'Terminal')]

	organization = models.ForeignKey(
		'tenancy.Organization', on_delete=models.CASCADE, related_name='sales'
	)
	store = models.ForeignKey('tenancy.Store', on_delete=models.CASCADE, related_name='sales')
	terminal = models.ForeignKey(
		'tenancy.Terminal', on_delete=models.CASCADE, related_name='sales'
	)
	shift = models.ForeignKey(Shift, on_delete=models.PROTECT, related_name='sales')
	created_by = models.ForeignKey(
		'accounts.User', on_delete=models.PROTECT, related_name='sales'
	)
	receipt_number = models.CharField(max_length=50)
	payment_type = models.CharField(max_length=20, choices=PAYMENT_CHOICES)
	subtotal = models.DecimalField(max_digits=12, decimal_places=2)
	discount_total = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	total = models.DecimalField(max_digits=12, decimal_places=2)
	is_return = models.BooleanField(default=False)
	parent_sale = models.ForeignKey(
		'self', null=True, blank=True, on_delete=models.SET_NULL, related_name='returns'
	)
	created_at = models.DateTimeField(auto_now_add=True)

	class Meta:
		unique_together = ('store', 'receipt_number')


class SaleItem(models.Model):
	sale = models.ForeignKey(Sale, on_delete=models.CASCADE, related_name='items')
	product = models.ForeignKey('catalog.Product', on_delete=models.PROTECT)
	product_name = models.CharField(max_length=200)
	quantity = models.DecimalField(max_digits=12, decimal_places=3)
	price = models.DecimalField(max_digits=12, decimal_places=2)
	discount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	line_total = models.DecimalField(max_digits=12, decimal_places=2)
