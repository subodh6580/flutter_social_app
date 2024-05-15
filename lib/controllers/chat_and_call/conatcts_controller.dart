import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactsController extends GetxController {
  RxList<Contact> contacts = <Contact>[].obs;
  RxList<Contact> selectedContacts = <Contact>[].obs;

  loadContacts() async {
    if (await FlutterContacts.requestPermission()) {
      // Get all contacts (fully fetched)
      contacts.value = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      update();
    }
  }

  selectUnSelectContact(Contact contact) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
    update();
  }
}
