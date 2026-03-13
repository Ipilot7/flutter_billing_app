from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient

from accounts.models import User
from tenancy.models import Organization, Store, Terminal


class TestRegistrationApi(TestCase):
	def setUp(self):
		self.client = APIClient()

	def test_platform_registration_creates_owner_org_store_and_tokens(self):
		payload = {
			'organization_name': 'Acme POS',
			'store_name': 'Main Branch',
			'timezone': 'UTC',
			'address': 'Some Street',
			'owner_username': 'owner1',
			'owner_password': 'pass12345',
			'owner_email': 'owner@example.com',
			'owner_first_name': 'Owner',
			'owner_last_name': 'One',
		}

		response = self.client.post(reverse('platform_register'), payload, format='json')
		self.assertEqual(response.status_code, 201)
		self.assertIn('tokens', response.data)
		self.assertIn('access', response.data['tokens'])
		self.assertIn('refresh', response.data['tokens'])

		self.assertEqual(Organization.objects.count(), 1)
		self.assertEqual(Store.objects.count(), 1)
		owner = User.objects.filter(username='owner1').first()
		self.assertIsNotNone(owner)
		self.assertEqual(owner.role, 'owner')
		self.assertIsNotNone(owner.organization_id)
		self.assertIsNotNone(owner.store_id)

	def test_cash_register_registration_requires_auth(self):
		payload = {
			'store_id': 1,
			'terminal_name': 'Cash 1',
			'device_id': 'device-123',
			'cashier_username': 'cashier1',
			'cashier_password': 'pass12345',
		}

		response = self.client.post(reverse('cash_register_register'), payload, format='json')
		self.assertEqual(response.status_code, 401)

	def test_cash_register_registration_creates_terminal_and_cashier(self):
		organization = Organization.objects.create(name='Acme')
		store = Store.objects.create(organization=organization, name='Store 1')
		owner = User.objects.create_user(
			username='owner2',
			password='pass12345',
			role='owner',
			organization=organization,
			store=store,
		)
		self.client.force_authenticate(owner)

		payload = {
			'store_id': store.id,
			'terminal_name': 'Cash 1',
			'device_id': 'device-xyz',
			'cashier_username': 'cashier2',
			'cashier_password': 'pass12345',
			'cashier_pin': '1234',
			'cashier_first_name': 'Cash',
			'cashier_last_name': 'Two',
		}

		response = self.client.post(reverse('cash_register_register'), payload, format='json')
		self.assertEqual(response.status_code, 201)

		terminal = Terminal.objects.filter(device_id='device-xyz').first()
		self.assertIsNotNone(terminal)
		self.assertEqual(terminal.store_id, store.id)

		cashier = User.objects.filter(username='cashier2').first()
		self.assertIsNotNone(cashier)
		self.assertEqual(cashier.role, 'cashier')
		self.assertEqual(cashier.organization_id, organization.id)
		self.assertEqual(cashier.store_id, store.id)

	def test_cashier_terminal_login_returns_tokens(self):
		organization = Organization.objects.create(name='Acme')
		store = Store.objects.create(organization=organization, name='Store 1')
		terminal = Terminal.objects.create(
			store=store,
			name='Cash 1',
			device_id='device-login-1',
		)
		cashier = User.objects.create_user(
			username='cashier-login',
			password='pass12345',
			role='cashier',
			organization=organization,
			store=store,
		)
		cashier.set_pin('4321')
		cashier.save(update_fields=['pin_code'])

		payload = {
			'device_id': terminal.device_id,
			'cashier_pin': '4321',
		}

		response = self.client.post(reverse('cashier_terminal_login'), payload, format='json')
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data['user']['id'], cashier.id)
		self.assertIn('tokens', response.data)
		self.assertIn('access', response.data['tokens'])
		self.assertIn('refresh', response.data['tokens'])

		terminal.refresh_from_db()
		self.assertIsNotNone(terminal.last_seen_at)

	def test_cashier_terminal_login_rejects_invalid_pin(self):
		organization = Organization.objects.create(name='Acme')
		store = Store.objects.create(organization=organization, name='Store 1')
		Terminal.objects.create(
			store=store,
			name='Cash 1',
			device_id='device-login-2',
		)
		cashier = User.objects.create_user(
			username='cashier-login-2',
			password='pass12345',
			role='cashier',
			organization=organization,
			store=store,
		)
		cashier.set_pin('9999')
		cashier.save(update_fields=['pin_code'])

		payload = {
			'device_id': 'device-login-2',
			'cashier_pin': '0000',
		}

		response = self.client.post(reverse('cashier_terminal_login'), payload, format='json')
		self.assertEqual(response.status_code, 400)

	def test_cashier_terminal_login_locks_after_many_failed_attempts(self):
		organization = Organization.objects.create(name='Acme')
		store = Store.objects.create(organization=organization, name='Store 1')
		Terminal.objects.create(
			store=store,
			name='Cash 1',
			device_id='device-lock-1',
		)
		cashier = User.objects.create_user(
			username='cashier-lock',
			password='pass12345',
			role='cashier',
			organization=organization,
			store=store,
		)
		cashier.set_pin('4321')
		cashier.save(update_fields=['pin_code'])

		for _ in range(5):
			response = self.client.post(
				reverse('cashier_terminal_login'),
				{'device_id': 'device-lock-1', 'cashier_pin': '0000'},
				format='json',
			)
			self.assertEqual(response.status_code, 400)

		locked_response = self.client.post(
			reverse('cashier_terminal_login'),
			{'device_id': 'device-lock-1', 'cashier_pin': '4321'},
			format='json',
		)
		self.assertEqual(locked_response.status_code, 429)
