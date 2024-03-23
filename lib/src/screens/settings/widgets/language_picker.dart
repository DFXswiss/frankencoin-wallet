import 'package:flutter/material.dart';
import 'package:frankencoin_wallet/generated/i18n.dart';
import 'package:frankencoin_wallet/src/core/language.dart';
import 'package:frankencoin_wallet/src/widgets/alert_background.dart';

class LanguagePicker extends StatelessWidget {
  final List<Language> availableLanguages;
  final Language selectedLanguage;

  const LanguagePicker({
    super.key,
    required this.availableLanguages,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              S.of(context).settings_language,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          ...availableLanguages.map((language) {
            return Column(children: [
              const Divider(),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(language);
                },
                child: Row(
                  children: [
                    Image.asset(
                      language.imagePath,
                      width: 40,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          language.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                    ),
                    if (language == selectedLanguage)
                      const Icon(Icons.check_circle)
                  ],
                ),
              ),
            ]);
          }),
        ],
      ),
    );
  }
}
