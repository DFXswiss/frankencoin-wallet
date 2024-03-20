import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final void Function()? action;

  const OptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.leadingImagePath,
    this.action,
  });

  final String title;
  final String description;
  final String leadingImagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(5, 8, 23, 1)),
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: action,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(leadingImagePath, width: 40),
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
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                              color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            description,
                            style: const TextStyle(
                                fontFamily: 'Lato', color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
