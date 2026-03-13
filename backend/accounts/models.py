from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.hashers import check_password, make_password


class User(AbstractUser):
	ROLE_CHOICES = [
		('owner', 'Owner'),
		('manager', 'Manager'),
		('cashier', 'Cashier'),
	]

	organization = models.ForeignKey(
		'tenancy.Organization',
		null=True,
		blank=True,
		on_delete=models.SET_NULL,
		related_name='users',
	)
	store = models.ForeignKey(
		'tenancy.Store',
		null=True,
		blank=True,
		on_delete=models.SET_NULL,
		related_name='users',
	)
	role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='cashier')
	pin_code = models.CharField(max_length=128, blank=True)

	def set_pin(self, raw_pin: str) -> None:
		self.pin_code = make_password(raw_pin)

	def check_pin(self, raw_pin: str) -> bool:
		if not self.pin_code:
			return False
		return check_password(raw_pin, self.pin_code)

	def __str__(self) -> str:
		return self.username
