from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient

from accounts.models import User
from catalog.models import Product
from sales.models import Shift, Sale
from tenancy.models import Organization, Store, Terminal


class TestSalesApi(TestCase):
	def setUp(self):
		self.client = APIClient()

		self.organization = Organization.objects.create(name='Org 1')
		self.store = Store.objects.create(organization=self.organization, name='Store 1')
		self.terminal = Terminal.objects.create(
			store=self.store,
			name='Cash 1',
			device_id='sale-device-1',
		)
		self.cashier = User.objects.create_user(
			username='cashier1',
			password='pass12345',
			role='cashier',
			organization=self.organization,
			store=self.store,
		)
		self.product = Product.objects.create(
			organization=self.organization,
			name='Milk',
			sku='SKU-MILK',
			barcode='100200',
			price='60.00',
			cost='40.00',
			stock='10.000',
			min_stock='1.000',
		)
		self.client.force_authenticate(self.cashier)

	def test_open_shift_creates_org_scoped_shift(self):
		payload = {
			'terminal': self.terminal.id,
			'start_balance': '100.00',
			'status': 'open',
		}
		response = self.client.post(reverse('shifts-list'), payload, format='json')

		self.assertEqual(response.status_code, 201)
		shift = Shift.objects.first()
		self.assertIsNotNone(shift)
		self.assertEqual(shift.organization_id, self.organization.id)
		self.assertEqual(shift.store_id, self.store.id)
		self.assertEqual(shift.opened_by_id, self.cashier.id)

	def test_cannot_create_sale_with_closed_shift(self):
		shift = Shift.objects.create(
			organization=self.organization,
			store=self.store,
			terminal=self.terminal,
			opened_by=self.cashier,
			start_balance='100.00',
			status='closed',
		)

		payload = {
			'shift': shift.id,
			'receipt_number': 'R-5001',
			'payment_type': 'cash',
			'items': [
				{
					'product_id': self.product.id,
					'quantity': '1.000',
					'price': '60.00',
					'discount': '0.00',
				}
			],
		}

		response = self.client.post(reverse('sales-list'), payload, format='json')
		self.assertEqual(response.status_code, 400)
		self.assertEqual(Sale.objects.count(), 0)

	def test_create_sale_with_open_shift(self):
		shift = Shift.objects.create(
			organization=self.organization,
			store=self.store,
			terminal=self.terminal,
			opened_by=self.cashier,
			start_balance='100.00',
			status='open',
		)

		payload = {
			'shift': shift.id,
			'receipt_number': 'R-5002',
			'payment_type': 'cash',
			'items': [
				{
					'product_id': self.product.id,
					'quantity': '2.000',
					'price': '60.00',
					'discount': '0.00',
				}
			],
		}

		response = self.client.post(reverse('sales-list'), payload, format='json')
		self.assertEqual(response.status_code, 201)
		sale = Sale.objects.first()
		self.assertIsNotNone(sale)
		self.assertEqual(sale.organization_id, self.organization.id)
		self.assertEqual(sale.store_id, self.store.id)
		self.assertEqual(sale.terminal_id, self.terminal.id)
		self.assertEqual(sale.created_by_id, self.cashier.id)
		self.product.refresh_from_db()
		self.assertEqual(str(self.product.stock), '8.000')

	def test_create_sale_fails_when_insufficient_stock(self):
		shift = Shift.objects.create(
			organization=self.organization,
			store=self.store,
			terminal=self.terminal,
			opened_by=self.cashier,
			start_balance='100.00',
			status='open',
		)

		payload = {
			'shift': shift.id,
			'receipt_number': 'R-5003',
			'payment_type': 'cash',
			'items': [
				{
					'product_id': self.product.id,
					'quantity': '999.000',
					'price': '60.00',
					'discount': '0.00',
				}
			],
		}

		response = self.client.post(reverse('sales-list'), payload, format='json')
		self.assertEqual(response.status_code, 400)
		self.assertEqual(Sale.objects.count(), 0)


class TestFirstSaleSmoke(TestCase):
	def setUp(self):
		self.client = APIClient()

	def test_first_sale_full_flow(self):
		register_response = self.client.post(
			reverse('platform_register'),
			{
				'organization_name': 'Smoke Org',
				'store_name': 'Smoke Store',
				'owner_username': 'smoke-owner',
				'owner_password': 'pass12345',
			},
			format='json',
		)
		self.assertEqual(register_response.status_code, 201)
		owner_access = register_response.data['tokens']['access']
		store_id = register_response.data['store']['id']

		self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {owner_access}')
		register_cash_response = self.client.post(
			reverse('cash_register_register'),
			{
				'store_id': store_id,
				'terminal_name': 'Smoke Cash',
				'device_id': 'smoke-device-1',
				'cashier_username': 'smoke-cashier',
				'cashier_password': 'pass12345',
				'cashier_pin': '1234',
			},
			format='json',
		)
		self.assertEqual(register_cash_response.status_code, 201)

		product_response = self.client.post(
			reverse('products-list'),
			{
				'organization': register_response.data['organization']['id'],
				'name': 'Smoke Product',
				'sku': 'SMOKE-1',
				'barcode': 'SMOKE-BC-1',
				'price': '75.00',
				'cost': '50.00',
				'stock': '5.000',
				'min_stock': '1.000',
				'is_active': True,
			},
			format='json',
		)
		self.assertEqual(product_response.status_code, 201)
		product_id = product_response.data['id']

		self.client.credentials()
		cashier_login_response = self.client.post(
			reverse('cashier_terminal_login'),
			{'device_id': 'smoke-device-1', 'cashier_pin': '1234'},
			format='json',
		)
		self.assertEqual(cashier_login_response.status_code, 200)
		cashier_access = cashier_login_response.data['tokens']['access']

		self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {cashier_access}')
		open_shift_response = self.client.post(
			reverse('shifts-list'),
			{
				'terminal': register_cash_response.data['terminal']['id'],
				'start_balance': '100.00',
				'status': 'open',
			},
			format='json',
		)
		self.assertEqual(open_shift_response.status_code, 201)
		shift_id = open_shift_response.data['id']

		create_sale_response = self.client.post(
			reverse('sales-list'),
			{
				'shift': shift_id,
				'receipt_number': 'SMOKE-R-1',
				'payment_type': 'cash',
				'items': [
					{
						'product_id': product_id,
						'quantity': '2.000',
						'price': '75.00',
						'discount': '0.00',
					}
				],
			},
			format='json',
		)
		self.assertEqual(create_sale_response.status_code, 201)
		self.assertEqual(create_sale_response.data['total'], '150.00')
		self.assertEqual(len(create_sale_response.data['items']), 1)

		remaining_stock_response = self.client.get(reverse('products-list'))
		self.assertEqual(remaining_stock_response.status_code, 200)
		matched = [p for p in remaining_stock_response.data if p['id'] == product_id]
		self.assertEqual(len(matched), 1)
		self.assertEqual(matched[0]['stock'], '3.000')
