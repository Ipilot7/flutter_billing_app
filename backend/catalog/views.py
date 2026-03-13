from rest_framework import permissions, viewsets

from .models import Category, Product
from .serializers import CategorySerializer, ProductSerializer


class CategoryViewSet(viewsets.ModelViewSet):
	queryset = Category.objects.all().order_by('id')
	serializer_class = CategorySerializer
	permission_classes = [permissions.IsAuthenticated]


class ProductViewSet(viewsets.ModelViewSet):
	queryset = Product.objects.all().order_by('id')
	serializer_class = ProductSerializer
	permission_classes = [permissions.IsAuthenticated]
