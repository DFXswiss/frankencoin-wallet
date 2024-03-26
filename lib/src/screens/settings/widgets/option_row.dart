import 'package:flutter/material.dart';

class OptionRow extends StatelessWidget {
  final String name;
  final Widget? leading;
  final String? suffix;
  final void Function(BuildContext context)? onTap;
  final bool canEdit;

  const OptionRow({
    super.key,
    required this.name,
    this.leading,
    this.suffix,
    this.onTap,
    this.canEdit = false,
  });

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
            if (leading != null) leading!,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (suffix != null) ...[
              Text(
                suffix!,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Lato',
                  color: Colors.grey,
                ),
              )
            ] else
              Icon(
                canEdit ? Icons.edit : Icons.keyboard_arrow_right,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
