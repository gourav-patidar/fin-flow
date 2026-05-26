import 'package:flutter/material.dart';

import '../../core/constants/radii.dart';

/// The 8 canonical transaction categories from `CLAUDE.md` section 7. The
/// string keys are what the Transaction model stores; resolution to icon +
/// gradient happens here so screens never duplicate the mapping.
enum TransactionCategory {
  foodAndDining('Food & Dining'),
  groceries('Groceries'),
  transport('Transport'),
  billsAndUtilities('Bills & Utilities'),
  shopping('Shopping'),
  entertainment('Entertainment'),
  health('Health'),
  investments('Investments');

  const TransactionCategory(this.label);
  final String label;

  static TransactionCategory? tryParse(String value) {
    for (final TransactionCategory c in TransactionCategory.values) {
      if (c.label == value) return c;
    }
    return null;
  }
}

class _CategoryStyle {
  const _CategoryStyle(this.icon, this.gradient);
  final IconData icon;
  final List<Color> gradient;
}

// TODO(asset): swap Material icons for branded SVG glyphs once finalized.
const Map<TransactionCategory, _CategoryStyle> _styles =
    <TransactionCategory, _CategoryStyle>{
  TransactionCategory.foodAndDining: _CategoryStyle(
    Icons.restaurant_rounded,
    <Color>[Color(0xFFFF7E5C), Color(0xFFFF5C5C)],
  ),
  TransactionCategory.groceries: _CategoryStyle(
    Icons.shopping_basket_rounded,
    <Color>[Color(0xFF00D4AA), Color(0xFF00A085)],
  ),
  TransactionCategory.transport: _CategoryStyle(
    Icons.directions_car_rounded,
    <Color>[Color(0xFF4FACFE), Color(0xFF2E7BCF)],
  ),
  TransactionCategory.billsAndUtilities: _CategoryStyle(
    Icons.flash_on_rounded,
    <Color>[Color(0xFFFFB547), Color(0xFFFF8C42)],
  ),
  TransactionCategory.shopping: _CategoryStyle(
    Icons.shopping_bag_rounded,
    <Color>[Color(0xFFEC4899), Color(0xFFC026D3)],
  ),
  TransactionCategory.entertainment: _CategoryStyle(
    Icons.movie_rounded,
    <Color>[Color(0xFF7B6EF6), Color(0xFF5B4FE0)],
  ),
  TransactionCategory.health: _CategoryStyle(
    Icons.favorite_rounded,
    <Color>[Color(0xFFEF4444), Color(0xFFB91C1C)],
  ),
  TransactionCategory.investments: _CategoryStyle(
    Icons.trending_up_rounded,
    <Color>[Color(0xFF14B8A6), Color(0xFF0F766E)],
  ),
};

/// A 40×40 rounded square with a category gradient + white glyph. Used in
/// transaction tiles, filter chips, and category pickers.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.category,
    this.size = 40,
    super.key,
  });

  final TransactionCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final _CategoryStyle style = _styles[category]!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.icon),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.gradient,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2EFFFFFF), // inset highlight approximation
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Icon(
        style.icon,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
