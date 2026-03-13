import uuid
from datetime import timedelta

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APIClient

from catalog.models import Product
from sales.models import Shift, Sale, SaleItem
from syncx.models import SyncOperation
from tenancy.models import Organization, Store, Terminal


class TestSyncApi(TestCase):
	def setUp(self):
		self.client = APIClient()

		self.org = Organization.objects.create(name='Acme Store')
		self.store = Store.objects.create(organization=self.org, name='Main Store')
		self.terminal = Terminal.objects.create(
			store=self.store,
			name='Cash 1',
			device_id='device-001',
		)

		self.user = get_user_model().objects.create_user(
			username='owner',
			password='pass1234',
			role='owner',
			organization=self.org,
			store=self.store,
		)
		self.client.force_authenticate(self.user)

		self.shift = Shift.objects.create(
			organization=self.org,
			store=self.store,
			terminal=self.terminal,
			opened_by=self.user,
			start_balance='0.00',
			status='open',
		)

	def test_sync_push_is_idempotent(self):
		operation_id = str(uuid.uuid4())
		payload = {
			'terminal_id': self.terminal.id,
			'operations': [
				{
					'operation_id': operation_id,
					'entity_type': 'product.upsert',
					'entity_id': 'local-product-1',
					'payload': {
						'barcode': 'IDEM-001',
						'name': 'Idempotent Product',
						'price': '10.00',
					},
				}
			],
		}

		first = self.client.post(reverse('sync_push'), payload, format='json')
		self.assertEqual(first.status_code, 200)
		self.assertEqual(first.data['applied'], [operation_id])
		self.assertEqual(first.data['duplicates'], [])

		second = self.client.post(reverse('sync_push'), payload, format='json')
		self.assertEqual(second.status_code, 200)
		self.assertEqual(second.data['applied'], [])
		self.assertEqual(second.data['duplicates'], [operation_id])

		self.assertEqual(SyncOperation.objects.count(), 1)

	def test_sync_pull_returns_changes_after_cursor(self):
		old_time = timezone.now() - timedelta(days=1)

		product = Product.objects.create(
			organization=self.org,
			name='Milk',
			sku='SKU-1',
			barcode='123456',
			price='100.00',
			cost='80.00',
			stock='10.000',
			min_stock='2.000',
		)
		product.updated_at = timezone.now()
		product.save(update_fields=['updated_at'])

		response = self.client.get(
			reverse('sync_pull'),
			{'since': old_time.isoformat()},
			format='json',
		)

		self.assertEqual(response.status_code, 200)
		self.assertIn('data', response.data)
		self.assertIn('products', response.data['data'])
		self.assertEqual(len(response.data['data']['products']), 1)
		self.assertEqual(response.data['data']['products'][0]['id'], product.id)

	def test_sync_push_applies_product_upsert(self):
		operation_id = str(uuid.uuid4())
		payload = {
			'terminal_id': self.terminal.id,
			'operations': [
				{
					'operation_id': operation_id,
					'entity_type': 'product.upsert',
					'entity_id': 'prod-local-1',
					'payload': {
						'barcode': '998877',
						'name': 'Sugar',
						'price': '60.00',
						'cost': '50.00',
						'stock': '12.000',
					},
				}
			],
		}

		response = self.client.post(reverse('sync_push'), payload, format='json')
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data['applied'], [operation_id])

		product = Product.objects.filter(
			organization=self.org,
			barcode='998877',
		).first()
		self.assertIsNotNone(product)
		self.assertEqual(product.name, 'Sugar')

	def test_sync_push_applies_sale_create_and_deducts_stock(self):
		product = Product.objects.create(
			organization=self.org,
			name='Rice',
			sku='SKU-RICE',
			barcode='111222',
			price='100.00',
			cost='70.00',
			stock='10.000',
			min_stock='1.000',
		)

		operation_id = str(uuid.uuid4())
		payload = {
			'terminal_id': self.terminal.id,
			'operations': [
				{
					'operation_id': operation_id,
					'entity_type': 'sale.create',
					'entity_id': 'sale-local-1',
					'payload': {
						'shift_id': self.shift.id,
						'receipt_number': 'R-1001',
						'payment_type': 'cash',
						'subtotal': '200.00',
						'discount_total': '0.00',
						'total': '200.00',
						'items': [
							{
								'product_id': product.id,
								'product_name': product.name,
								'quantity': '2.000',
								'price': '100.00',
								'discount': '0.00',
								'line_total': '200.00',
							}
						],
					},
				}
			],
		}

		response = self.client.post(reverse('sync_push'), payload, format='json')
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data['failed'], [])

		sale = Sale.objects.filter(receipt_number='R-1001').first()
		self.assertIsNotNone(sale)
		product.refresh_from_db()
		self.assertEqual(str(product.stock), '8.000')

	def test_sync_push_applies_sale_return_and_blocks_duplicate_return(self):
		product = Product.objects.create(
			organization=self.org,
			name='Tea',
			sku='SKU-TEA',
			barcode='333444',
			price='50.00',
			cost='30.00',
			stock='8.000',
			min_stock='1.000',
		)

		parent_sale = Sale.objects.create(
			organization=self.org,
			store=self.store,
			terminal=self.terminal,
			shift=self.shift,
			created_by=self.user,
			receipt_number='R-2001',
			payment_type='cash',
			subtotal='100.00',
			discount_total='0.00',
			total='100.00',
		)
		SaleItem.objects.create(
			sale=parent_sale,
			product=product,
			product_name=product.name,
			quantity='2.000',
			price='50.00',
			discount='0.00',
			line_total='100.00',
		)

		operation_id = str(uuid.uuid4())
		payload = {
			'terminal_id': self.terminal.id,
			'operations': [
				{
					'operation_id': operation_id,
					'entity_type': 'sale.return',
					'entity_id': 'return-local-1',
					'payload': {
						'parent_sale_id': parent_sale.id,
						'shift_id': self.shift.id,
						'receipt_number': 'R-2001-R',
					},
				}
			],
		}

		first = self.client.post(reverse('sync_push'), payload, format='json')
		self.assertEqual(first.status_code, 200)
		self.assertEqual(first.data['failed'], [])
		self.assertEqual(first.data['applied'], [operation_id])

		return_sale = Sale.objects.filter(parent_sale=parent_sale, is_return=True).first()
		self.assertIsNotNone(return_sale)
		self.assertEqual(str(return_sale.total), '-100.00')

		product.refresh_from_db()
		self.assertEqual(str(product.stock), '10.000')

		duplicate_return_payload = {
			'terminal_id': self.terminal.id,
			'operations': [
				{
					'operation_id': str(uuid.uuid4()),
					'entity_type': 'sale.return',
					'entity_id': 'return-local-2',
					'payload': {
						'parent_sale_id': parent_sale.id,
						'shift_id': self.shift.id,
					},
				}
			],
		}

		second = self.client.post(reverse('sync_push'), duplicate_return_payload, format='json')
		self.assertEqual(second.status_code, 200)
		self.assertEqual(len(second.data['failed']), 1)
		self.assertIn('already been returned', second.data['failed'][0]['error'])

		product.refresh_from_db()
		self.assertEqual(str(product.stock), '10.000')
