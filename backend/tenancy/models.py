from django.db import models


class Organization(models.Model):
	SUBSCRIPTION_CHOICES = [
		('trial', 'Trial'),
		('active', 'Active'),
		('past_due', 'Past Due'),
		('canceled', 'Canceled'),
	]

	name = models.CharField(max_length=255)
	subscription_status = models.CharField(
		max_length=20, choices=SUBSCRIPTION_CHOICES, default='trial'
	)
	subscription_expires_at = models.DateTimeField(null=True, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	def __str__(self) -> str:
		return self.name


class Store(models.Model):
	organization = models.ForeignKey(
		Organization, on_delete=models.CASCADE, related_name='stores'
	)
	name = models.CharField(max_length=255)
	timezone = models.CharField(max_length=64, default='UTC')
	address = models.CharField(max_length=500, blank=True)
	is_active = models.BooleanField(default=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	def __str__(self) -> str:
		return f"{self.organization.name} / {self.name}"


class Terminal(models.Model):
	store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name='terminals')
	name = models.CharField(max_length=100)
	device_id = models.CharField(max_length=255, unique=True)
	is_active = models.BooleanField(default=True)
	last_seen_at = models.DateTimeField(null=True, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)

	def __str__(self) -> str:
		return f"{self.store.name} / {self.name}"
