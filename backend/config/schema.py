from drf_spectacular.openapi import AutoSchema


class GroupedAutoSchema(AutoSchema):
    """Assign stable Swagger tags by API prefix for grouped documentation."""

    TAGS_BY_PREFIX = {
        "auth": "Authentication",
        "token": "Authentication",
        "users": "Accounts",
        "organizations": "Tenancy",
        "stores": "Tenancy",
        "terminals": "Tenancy",
        "categories": "Catalog",
        "products": "Catalog",
        "shifts": "Sales",
        "sales": "Sales",
        "sale-items": "Sales",
        "sync": "Synchronization",
        "sync-operations": "Synchronization",
        "subscription-events": "Billing",
    }

    def get_tags(self):
        path = self.path.strip("/")
        segments = path.split("/") if path else []

        if segments and segments[0] == "api":
            segments = segments[1:]

        if segments and segments[0].startswith("v") and segments[0][1:].isdigit():
            segments = segments[1:]

        if segments and segments[0] == "api":
            segments = segments[1:]

        first_segment = segments[0] if segments else ""
        tag = self.TAGS_BY_PREFIX.get(first_segment, "Other")
        return [tag]
