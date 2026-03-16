from decimal import Decimal

from django.db import transaction

from catalog.models import Category, Product
from sales.models import Sale, SaleItem, Shift


def _to_decimal(value, default='0'):
    if value is None:
        value = default
    return Decimal(str(value))


def apply_product_upsert(*, terminal, payload):
    barcode = payload.get('barcode')
    if not barcode:
        raise ValueError('product.upsert requires barcode')

    category = None
    category_backend_id = payload.get('category_backend_id')
    category_name = payload.get('category_name')

    if category_backend_id is not None:
        category = Category.objects.filter(
            id=category_backend_id,
            organization=terminal.store.organization,
        ).first()
    elif category_name:
        cleaned_name = str(category_name).strip()
        if cleaned_name:
            category, _ = Category.objects.get_or_create(
                organization=terminal.store.organization,
                name=cleaned_name,
            )

    defaults = {
        'name': payload.get('name', 'Unnamed Product'),
        'sku': payload.get('sku', ''),
        'category': category,
        'price': _to_decimal(payload.get('price', '0')),
        'cost': _to_decimal(payload.get('cost', '0')),
        'stock': _to_decimal(payload.get('stock', '0')),
        'min_stock': _to_decimal(payload.get('min_stock', '0')),
        'is_active': payload.get('is_active', True),
        'organization': terminal.store.organization,
    }

    product, _ = Product.objects.update_or_create(
        organization=terminal.store.organization,
        barcode=barcode,
        defaults=defaults,
    )
    return {'product_id': product.id, 'barcode': product.barcode}


def apply_category_upsert(*, terminal, payload):
    name = str(payload.get('name', '')).strip()
    if not name:
        raise ValueError('category.upsert requires name')

    organization = terminal.store.organization
    backend_id = payload.get('backend_id')

    category = None
    if backend_id is not None:
        category = Category.objects.filter(
            id=backend_id,
            organization=organization,
        ).first()

    if category is None:
        category, _ = Category.objects.get_or_create(
            organization=organization,
            name=name,
        )
    elif category.name != name:
        category.name = name
        category.save(update_fields=['name'])

    return {'category_id': category.id, 'name': category.name}


def apply_sale_create(*, terminal, payload, user):
    items_payload = payload.get('items', [])
    if not items_payload:
        raise ValueError('sale.create requires at least one item')

    shift_id = payload.get('shift_id')
    if not shift_id:
        raise ValueError('sale.create requires shift_id')

    # Validate shift exists and is open
    shift = Shift.objects.filter(
        id=shift_id,
        organization=terminal.store.organization,
        store=terminal.store,
        terminal=terminal,
    ).first()
    
    if shift is None:
        raise ValueError('Shift not found or does not belong to this terminal')
    
    if shift.status != 'open':
        raise ValueError('Shift is not open. Cannot create sale.')

    with transaction.atomic():
        sale = Sale.objects.create(
            organization=terminal.store.organization,
            store=terminal.store,
            terminal=terminal,
            shift_id=shift_id,
            created_by=user,
            receipt_number=payload['receipt_number'],
            payment_type=payload.get('payment_type', 'cash'),
            subtotal=_to_decimal(payload.get('subtotal', '0')),
            discount_total=_to_decimal(payload.get('discount_total', '0')),
            total=_to_decimal(payload.get('total', '0')),
        )

        for item in items_payload:
            product = None
            product_id = item.get('product_id')
            barcode = item.get('barcode')

            if product_id:
                product = Product.objects.filter(
                    id=product_id,
                    organization=terminal.store.organization,
                ).first()
            elif barcode:
                product = Product.objects.filter(
                    barcode=barcode,
                    organization=terminal.store.organization,
                ).first()

            if product is None:
                raise ValueError(f"Product not found for item: {item}")

            quantity = _to_decimal(item.get('quantity', '0'))
            if quantity <= 0:
                raise ValueError('Item quantity must be > 0')

            new_stock = product.stock - quantity

            product.stock = new_stock
            product.save(update_fields=['stock', 'updated_at'])

            price = _to_decimal(item.get('price', product.price))
            discount = _to_decimal(item.get('discount', '0'))
            line_total = _to_decimal(item.get('line_total', price * quantity - discount))

            SaleItem.objects.create(
                sale=sale,
                product=product,
                product_name=item.get('product_name', product.name),
                quantity=quantity,
                price=price,
                discount=discount,
                line_total=line_total,
            )

    return {'sale_id': sale.id, 'receipt_number': sale.receipt_number}


def apply_sale_return(*, terminal, payload, user):
    parent_sale_id = payload.get('parent_sale_id')
    if not parent_sale_id:
        raise ValueError('sale.return requires parent_sale_id')

    with transaction.atomic():
        parent = Sale.objects.select_for_update().filter(
            id=parent_sale_id,
            organization=terminal.store.organization,
        ).first()
        if parent is None:
            raise ValueError('Parent sale not found')

        if parent.is_return:
            raise ValueError('Cannot return a return sale')

        if Sale.objects.filter(parent_sale=parent, is_return=True).exists():
            raise ValueError('This sale has already been returned')

        shift_id = payload.get('shift_id')
        if not shift_id:
            raise ValueError('sale.return requires shift_id')

        # Validate shift exists and is open
        shift = Shift.objects.filter(
            id=shift_id,
            organization=terminal.store.organization,
            store=terminal.store,
            terminal=terminal,
        ).first()
        
        if shift is None:
            raise ValueError('Shift not found or does not belong to this terminal')
        
        if shift.status != 'open':
            raise ValueError('Shift is not open. Cannot create return.')

        ret = Sale.objects.create(
            organization=terminal.store.organization,
            store=terminal.store,
            terminal=terminal,
            shift_id=shift_id,
            created_by=user,
            receipt_number=payload.get('receipt_number', f"{parent.receipt_number}-R"),
            payment_type=parent.payment_type,
            subtotal=parent.subtotal,
            discount_total=parent.discount_total,
            total=-(parent.total),
            is_return=True,
            parent_sale=parent,
        )

        for item in parent.items.select_related('product').all():
            product = item.product
            product.stock = product.stock + item.quantity
            product.save(update_fields=['stock', 'updated_at'])

            SaleItem.objects.create(
                sale=ret,
                product=product,
                product_name=item.product_name,
                quantity=item.quantity,
                price=item.price,
                discount=item.discount,
                line_total=-(item.line_total),
            )

    return {'return_sale_id': ret.id, 'parent_sale_id': parent.id}


HANDLERS = {
    'category.upsert': apply_category_upsert,
    'product.upsert': apply_product_upsert,
    'sale.create': apply_sale_create,
    'sale.return': apply_sale_return,
}


def apply_operation(*, entity_type, terminal, payload, user):
    handler = HANDLERS.get(entity_type)
    if not handler:
        raise ValueError(f'Unsupported entity_type: {entity_type}')

    if entity_type.startswith('sale.'):
        return handler(terminal=terminal, payload=payload, user=user)
    return handler(terminal=terminal, payload=payload)
