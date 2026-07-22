import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_palette.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/pressable_scale.dart';

class TutorialCategoryData {
  const TutorialCategoryData({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    this.iconScale = 1,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final double iconScale;
}

class TutorialCategoryPage extends StatefulWidget {
  const TutorialCategoryPage({
    required this.categories,
    this.onSearchChanged,
    this.onCategoryTap,
    this.topPadding = AppSpacing.xl,
    this.bottomPadding = AppSpacing.xxl,
    super.key,
  });

  final List<TutorialCategoryData> categories;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onCategoryTap;
  final double topPadding;
  final double bottomPadding;

  factory TutorialCategoryPage.demo({
    ValueChanged<String>? onSearchChanged,
    ValueChanged<String>? onCategoryTap,
    double topPadding = AppSpacing.xl,
    double bottomPadding = AppSpacing.xxl,
    Key? key,
  }) {
    return TutorialCategoryPage(
      key: key,
      categories: _demoCategories,
      onSearchChanged: onSearchChanged,
      onCategoryTap: onCategoryTap,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );
  }

  static const List<TutorialCategoryData> _demoCategories = [
    TutorialCategoryData(
      id: 'arts',
      title: 'Arts',
      icon: Icons.palette_outlined,
      accentColor: Color(0xFF8C64E8),
      iconScale: 1.10,
    ),
    TutorialCategoryData(
      id: 'biology',
      title: 'Biology & Life Sciences',
      icon: Icons.biotech_outlined,
      accentColor: Color(0xFF2CA4F2),
      iconScale: 0.88,
    ),
    TutorialCategoryData(
      id: 'business',
      title: 'Business & Management',
      icon: Icons.wb_incandescent_outlined,
      accentColor: Color(0xFFFFC314),
      iconScale: 0.98,
    ),
    TutorialCategoryData(
      id: 'chemistry',
      title: 'Chemistry',
      icon: Icons.science_outlined,
      accentColor: Color(0xFF27A8F2),
      iconScale: 1.00,
    ),
    TutorialCategoryData(
      id: 'ai',
      title: 'CS: Artificial Intelligence',
      icon: Icons.psychology_alt_outlined,
      accentColor: Color(0xFF607BB5),
      iconScale: 0.94,
    ),
    TutorialCategoryData(
      id: 'software',
      title: 'CS: Software Engineering',
      icon: Icons.account_tree_outlined,
      accentColor: Color(0xFF6C87BE),
      iconScale: 0.92,
    ),
    TutorialCategoryData(
      id: 'security',
      title: 'CS: Systems & Security',
      icon: Icons.lock_outline_rounded,
      accentColor: Color(0xFF5E81BF),
      iconScale: 0.96,
    ),
    TutorialCategoryData(
      id: 'theory',
      title: 'CS: Theory',
      icon: Icons.hub_outlined,
      accentColor: Color(0xFF6984BC),
      iconScale: 0.90,
    ),
    TutorialCategoryData(
      id: 'economics',
      title: 'Economics & Finance',
      icon: Icons.show_chart_rounded,
      accentColor: Color(0xFF1E9AE9),
      iconScale: 0.90,
    ),
  ];

  @override
  State<TutorialCategoryPage> createState() => _TutorialCategoryPageState();
}

class _TutorialCategoryPageState extends State<TutorialCategoryPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>()!;

    return AnimatedPageWrapper(
      child: Material(
        color: palette.pageBackground,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                widget.topPadding,
                AppSpacing.lg,
                widget.bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TutorialSearchField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TutorialCategoryGrid(
                      categories: widget.categories,
                      onCategoryTap: widget.onCategoryTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TutorialCategoryGrid extends StatelessWidget {
  const TutorialCategoryGrid({
    required this.categories,
    this.onCategoryTap,
    super.key,
  });

  final List<TutorialCategoryData> categories;
  final ValueChanged<String>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.xl,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return TutorialCategoryTile(
          category: category,
          onTap: onCategoryTap == null
              ? null
              : () => onCategoryTap!(category.id),
        );
      },
    );
  }
}

class TutorialCategoryTile extends StatelessWidget {
  const TutorialCategoryTile({
    required this.category,
    this.onTap,
    super.key,
  });

  final TutorialCategoryData category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressableScale(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Ink(
                decoration: BoxDecoration(
                  color: category.accentColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: category.accentColor.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.scale(
                    scale: category.iconScale,
                    child: _CategoryTileIcon(icon: category.icon),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 42,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.extension<AppThemePalette>()!.primaryText,
                    fontSize: 16,
                    height: 1.14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTileIcon extends StatelessWidget {
  const _CategoryTileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

class _TutorialSearchField extends StatelessWidget {
  const _TutorialSearchField({
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemePalette>()!;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.searchBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 22,
            color: palette.secondaryText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: palette.primaryText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: palette.primaryText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
