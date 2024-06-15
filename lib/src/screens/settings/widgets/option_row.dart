import 'package:flutter/material.dart';

class OptionRow extends StatelessWidget {
  final String name;
  final String? subtitle;
  final Widget? leading;
  final String? suffix;
  final void Function(BuildContext context)? onTap;
  final bool canEdit;
  final OptionRowType type;
  final Color suffixIconColor;

  const OptionRow({
    super.key,
    required this.name,
    required this.type,
    this.leading,
    this.suffix,
    this.subtitle,
    this.onTap,
    this.canEdit = true,
    this.suffixIconColor = Colors.white,
  });

  Widget? get _suffixIcon {
    if (suffix != null) {
      return Text(
        suffix!,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Lato',
          color: Colors.grey,
        ),
      );
    }
    if (!canEdit) return Icon(Icons.lock, color: suffixIconColor);
    switch (type) {
      case OptionRowType.edit:
        return Icon(Icons.edit, color: suffixIconColor);
      case OptionRowType.navigate:
        return Icon(Icons.keyboard_arrow_right, color: suffixIconColor);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap?.call(context) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // color: const Color.fromRGBO(5, 8, 23, 1),
        ),
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lato',
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lato',
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _suffixIcon
          ].nonNulls.toList(),
        ),
      ),
    );
  }
}

enum OptionRowType {
  edit,
  navigate,
  info;
}
