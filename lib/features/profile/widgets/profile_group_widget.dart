import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/color_resources.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class ProfileGroupWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ProfileGroupWidget({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> validChildren = children.where((child) => child is! SizedBox || (child.width != 0 && child.height != 0)).toList();

    if (validChildren.isEmpty) return const SizedBox();

    List<Widget> dividedChildren = [];
    for (int i = 0; i < validChildren.length; i++) {
      dividedChildren.add(validChildren[i]);
      if (i < validChildren.length - 1) {
        dividedChildren.add(Divider(
          height: 1,
          thickness: 1,
          indent: 64,
          endIndent: 16,
          color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: Dimensions.paddingSizeSmall,
            top: Dimensions.paddingSizeLarge,
          ),
          child: Text(
            title.toUpperCase(),
            style: outfitBold(
              fontSize: Dimensions.fontSizeSmall,
              letterSpacing: 0.8,
              color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x121B211D),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: dividedChildren,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileGroupItemWidget extends StatelessWidget {
  final IconData? icon;
  final String? iconImage;
  final String title;
  final String? subtitle;
  final String? valueText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Color? iconColor;

  const ProfileGroupItemWidget({
    super.key,
    this.icon,
    this.iconImage,
    required this.title,
    this.subtitle,
    this.valueText,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.iconColor,
  }) : assert(icon != null || iconImage != null, 'Either icon or iconImage must be provided');

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? (isDark ? const Color(0x33E84D4F) : ColorResources.softBlush)
                      : (isDark ? ColorResources.nightSurfaceRaised : const Color(0xFFF7FAF7)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDestructive
                        ? ColorResources.alertRed.withValues(alpha: 0.3)
                        : (isDark ? ColorResources.nightStructuralLine : ColorResources.structuralLine),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: iconImage != null
                    ? Image.asset(
                        iconImage!,
                        height: 18,
                        width: 18,
                        color: isDestructive
                            ? ColorResources.alertRed
                            : (iconColor ?? (isDark ? ColorResources.nightInk : ColorResources.inkCharcoal)),
                      )
                    : Icon(
                        icon,
                        size: 18,
                        color: isDestructive
                            ? ColorResources.alertRed
                            : (iconColor ?? (isDark ? ColorResources.nightInk : ColorResources.inkCharcoal)),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: outfitMedium(
                        fontSize: 14,
                        color: isDestructive
                            ? ColorResources.alertRed
                            : (isDark ? ColorResources.nightInk : ColorResources.inkCharcoal),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else ...[
                if (valueText != null) ...[
                  Text(
                    valueText!,
                    style: jetBrainsMonoMedium(
                      fontSize: 12,
                      color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? ColorResources.nightMuted : ColorResources.mutedOliveGrey,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
