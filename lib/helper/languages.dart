import 'package:foap/helper/language_resource_string.dart';
import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': LanguageStrings.ar,
        'en': LanguageStrings.en,
        'tr': LanguageStrings.tr,
        'hi': LanguageStrings.hi,
        'ru': LanguageStrings.ru,
        'es': LanguageStrings.es,
        'fr': LanguageStrings.fr,
        'pt': LanguageStrings.pt,
      };
}
