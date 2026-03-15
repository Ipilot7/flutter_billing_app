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

## Settings Environments

Settings are split into:

- `config/settings/base.py`
- `config/settings/dev.py`
- `config/settings/prod.py`
- `config/settings/__init__.py` (entrypoint selector)

Environment variables:

- `DJANGO_ENV=dev|prod` (default: `dev`)
- `DJANGO_DEBUG=1|0|true|false`
- `DJANGO_ALLOWED_HOSTS=host1,host2`
- `DJANGO_CORS_ALLOW_ALL=1|0`
- `DB_NAME` (SQLite file in dev, PostgreSQL database in prod)
- `DB_USER` (prod)
- `DB_PASSWORD` (prod)
- `DB_HOST` (prod)
- `DB_PORT` (prod, default `5432`)

Loading order:

- OS/shell environment variables (highest priority)
- `backend/.env`
- `backend/.env.example` (fallback if `.env` is absent)

Examples:

```bash
# Development
set DJANGO_ENV=dev
set DJANGO_DEBUG=1
set DB_NAME=db.sqlite3

# Production
set DJANGO_ENV=prod
set DJANGO_DEBUG=0
set DB_NAME=deeppos
set DB_USER=postgres
set DB_PASSWORD=your_password
set DB_HOST=127.0.0.1
set DB_PORT=5432
```

Database policy:

- `dev` -> SQLite (`django.db.backends.sqlite3`)
- `prod` -> PostgreSQL (`django.db.backends.postgresql`)

## API Endpoints

- `GET /health/`
- `POST /api/v1/auth/register/platform/`
- `POST /api/v1/auth/register/cash-register/`
- `POST /api/v1/auth/login/cashier-terminal/`
- `POST /api/v1/token/`
- `POST /api/v1/token/refresh/`
- `POST /api/v1/sync/push/`
- `GET /api/v1/sync/pull/?since=<iso_datetime>`
- `GET/POST /api/v1/organizations/`
- `GET/POST /api/v1/stores/`
- `GET/POST /api/v1/terminals/`
- `GET/POST /api/v1/products/`
- `GET/POST /api/v1/sales/`
- `GET/POST /api/v1/shifts/`
- `GET/POST /api/v1/sync-operations/`

Docs:

- Swagger v1: `/api/v1/docs/`
- ReDoc v1: `/api/v1/redoc/`

Backward compatibility aliases without version are still available (`/api/...`).

## Sync Contract (v1)

### Push

`POST /api/v1/sync/push/`

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

`GET /api/v1/sync/pull/?since=2026-03-13T10:00:00Z`

Returns changed `products`, `categories`, `shifts`, and `sales` after cursor time.

## Registration Flows

### Platform Registration

`POST /api/v1/auth/register/platform/`

Creates organization, first store, and owner account. Returns JWT `access` and `refresh` tokens.

### Cash Register Registration

`POST /api/v1/auth/register/cash-register/`

Requires authenticated `owner` or `manager`. Creates a terminal and cashier user for the selected store.

### Cashier Terminal Login

`POST /api/v1/auth/login/cashier-terminal/`

Quick cashier login for POS terminal using `device_id` + `cashier_pin`. Returns JWT tokens and terminal context.

Security behavior:

- After 5 failed PIN attempts on one `device_id` (within 5 minutes), endpoint is temporarily locked.
- Locked attempts return `429 Too Many Requests` for 15 minutes.

## Sales Contract (v1)

### Create Sale With Items

`POST /api/v1/sales/`

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
