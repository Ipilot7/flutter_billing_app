from decimal import Decimal

from django.db import transaction
from rest_framework import serializers

from catalog.models import Product
from .models import Shift, Sale, SaleItem


class ShiftSerializer(serializers.ModelSerializer):
    class Meta:
        model = Shift
        fields = '__all__'
        read_only_fields = ['organization', 'store', 'opened_by', 'closed_by', 'opened_at', 'closed_at']


class SaleItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = SaleItem
        fields = '__all__'


class SaleSerializer(serializers.ModelSerializer):
    items = SaleItemSerializer(many=True, read_only=True)

    class Meta:
        model = Sale
        fields = '__all__'
        read_only_fields = ['organization', 'store', 'terminal', 'created_by', 'created_at']


class SaleCreateItemInputSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    quantity = serializers.DecimalField(max_digits=12, decimal_places=3)
    price = serializers.DecimalField(max_digits=12, decimal_places=2, required=False)
    discount = serializers.DecimalField(max_digits=12, decimal_places=2, required=False, default=Decimal('0.00'))


class SaleCreateSerializer(serializers.ModelSerializer):
    items = SaleCreateItemInputSerializer(many=True)

    class Meta:
        model = Sale
        fields = ['id', 'shift', 'receipt_number', 'payment_type', 'items']

    def validate_items(self, items):
        if not items:
            raise serializers.ValidationError('Sale must contain at least one item.')
        for item in items:
            if item['quantity'] <= 0:
                raise serializers.ValidationError('Item quantity must be greater than zero.')
            if item.get('discount', Decimal('0.00')) < 0:
                raise serializers.ValidationError('Item discount cannot be negative.')
        return items

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        shift = validated_data.pop('shift')

        organization = validated_data.pop('organization', shift.organization)
        store = validated_data.pop('store', shift.store)
        terminal = validated_data.pop('terminal', shift.terminal)
        created_by = validated_data.pop('created_by', None)

        product_ids = [item['product_id'] for item in items_data]

        with transaction.atomic():
            products = {
                p.id: p
                for p in Product.objects.select_for_update().filter(
                    id__in=product_ids,
                    organization=organization,
                    is_active=True,
                )
            }

            if len(products) != len(set(product_ids)):
                raise serializers.ValidationError('One or more products are missing or inactive.')

            subtotal = Decimal('0.00')
            discount_total = Decimal('0.00')
            prepared_items = []

            for item in items_data:
                product = products[item['product_id']]
                quantity = item['quantity']
                unit_price = item.get('price', product.price)
                discount = item.get('discount', Decimal('0.00'))
                line_total = (unit_price * quantity) - discount

                if line_total < 0:
                    raise serializers.ValidationError('Line total cannot be negative.')

                new_stock = product.stock - quantity

                subtotal += unit_price * quantity
                discount_total += discount
                prepared_items.append((product, quantity, unit_price, discount, line_total))

            sale = Sale.objects.create(
                organization=organization,
                store=store,
                terminal=terminal,
                shift=shift,
                created_by=created_by,
                subtotal=subtotal,
                discount_total=discount_total,
                total=subtotal - discount_total,
                **validated_data,
            )

            for product, quantity, unit_price, discount, line_total in prepared_items:
                product.stock = product.stock - quantity
                product.save(update_fields=['stock', 'updated_at'])

                SaleItem.objects.create(
                    sale=sale,
                    product=product,
                    product_name=product.name,
                    quantity=quantity,
                    price=unit_price,
                    discount=discount,
                    line_total=line_total,
                )

        return sale
