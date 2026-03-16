import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';

/// Reusable dropdown for selecting a product category.
/// Used in both AddProductPage and EditProductPage.
class CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        return DropdownButtonFormField<String>(
          initialValue: selectedCategoryId,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text(l.selectCategory),
          items: state.categories
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
