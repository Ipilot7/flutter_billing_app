from django.db import models


class SubscriptionEvent(models.Model):
	PROVIDER_CHOICES = [('stripe', 'Stripe'), ('store', 'Store Billing')]

	organization = models.ForeignKey(
		'tenancy.Organization', on_delete=models.CASCADE, related_name='subscription_events'
	)
	provider = models.CharField(max_length=20, choices=PROVIDER_CHOICES)
	event_type = models.CharField(max_length=120)
	raw_payload = models.JSONField(default=dict)
	created_at = models.DateTimeField(auto_now_add=True)
	processed_at = models.DateTimeField(null=True, blank=True)
