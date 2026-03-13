# POS Backend (Django)

Backend scaffold for multi-cashier POS synchronization, authorization, and subscription billing.

## Included

- Django + DRF + JWT auth
- CORS enabled for mobile/web clients
- POS domain apps:
  - `accounts` (custom user with roles)
  - `tenancy` (organization/store/terminal)
  - `catalog` (categories/products)
  - `sales` (shifts/sales/sale items)
  - `syncx` (offline sync operation log)
  - `billing` (subscription webhook events)

## Quick Start

```bash
cd backend
.venv\\Scripts\\activate
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

## API Endpoints

- `GET /health/`
- `POST /api/auth/register/platform/`
- `POST /api/auth/register/cash-register/`
- `POST /api/auth/login/cashier-terminal/`
- `POST /api/token/`
- `POST /api/token/refresh/`
- `POST /api/sync/push/`
- `GET /api/sync/pull/?since=<iso_datetime>`
- `GET/POST /api/organizations/`
- `GET/POST /api/stores/`
- `GET/POST /api/terminals/`
- `GET/POST /api/products/`
- `GET/POST /api/sales/`
- `GET/POST /api/shifts/`
- `GET/POST /api/sync-operations/`

## Sync Contract (v1)

### Push

`POST /api/sync/push/`

```json
{
  "terminal_id": 1,
  "operations": [
    {
      "operation_id": "e3e4b69c-ec6d-44a8-8f3b-0db47efac0a1",
      "entity_type": "sale.create",
      "entity_id": "local-sale-123",
      "payload": {"shift_id": 1, "items": []}
    }
  ]
}
```

Response includes `applied`, `duplicates`, and `failed` lists.

Supported `entity_type` values:

- `product.upsert`
- `sale.create`
- `sale.return`

### Pull

`GET /api/sync/pull/?since=2026-03-13T10:00:00Z`

Returns changed `products`, `categories`, `shifts`, and `sales` after cursor time.

## Registration Flows

### Platform Registration

`POST /api/auth/register/platform/`

Creates organization, first store, and owner account. Returns JWT `access` and `refresh` tokens.

### Cash Register Registration

`POST /api/auth/register/cash-register/`

Requires authenticated `owner` or `manager`. Creates a terminal and cashier user for the selected store.

### Cashier Terminal Login

`POST /api/auth/login/cashier-terminal/`

Quick cashier login for POS terminal using `device_id` + `cashier_pin`. Returns JWT tokens and terminal context.

Security behavior:

- After 5 failed PIN attempts on one `device_id` (within 5 minutes), endpoint is temporarily locked.
- Locked attempts return `429 Too Many Requests` for 15 minutes.

## Sales Contract (v1)

### Create Sale With Items

`POST /api/sales/`

```json
{
  "shift": 1,
  "receipt_number": "R-1001",
  "payment_type": "cash",
  "items": [
    {
      "product_id": 10,
      "quantity": "2.000",
      "price": "75.00",
      "discount": "0.00"
    }
  ]
}
```

Server behavior:

- Validates shift is open and in user scope.
- Calculates `subtotal`, `discount_total`, `total` on server.
- Creates `Sale` + `SaleItem` records in one transaction.
- Deducts product stock atomically (`select_for_update`).

Common error responses:

- `400 Cannot create sale with closed shift.`
- `400 One or more products are missing or inactive.`
- `400 Insufficient stock for product id=<id>.`

## Notes

- For production, switch to Postgres and add idempotency checks on `syncx.SyncOperation.operation_id` handling.
- Add role-based permissions per endpoint before go-live.
