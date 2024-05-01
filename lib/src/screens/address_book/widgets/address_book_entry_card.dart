import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/src/colors.dart';
import 'package:jazzicon/jazzicon.dart';

class AddressBookEntryCard extends StatelessWidget {
  final String title;
  final String address;
  final Color backgroundColor;
  final void Function()? onTap;
  final void Function()? onDelete;

  const AddressBookEntryCard({
    super.key,
    required this.title,
    required this.address,
    this.onTap,
    this.onDelete,
    this.backgroundColor = const Color.fromRGBO(15, 23, 42, 1),
  });

  Widget get leadingImage =>
      Jazzicon.getIconWidget(Jazzicon.getJazziconData(20, address: address),
          size: 40);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leadingImage,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Lato',
                                color: Colors.white),
                          ),
                          Text(
                            address,
                            style: const TextStyle(
                                fontFamily: 'Lato', color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: FrankencoinColors.frRed,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
