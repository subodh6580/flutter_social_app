import 'package:flutter_contacts/contact.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/components/contact_tile.dart';
import '../../controllers/chat_and_call/conatcts_controller.dart';

class ContactList extends StatefulWidget {
  final Function(List<Contact>) selectedContactsHandler;

  const ContactList({Key? key, required this.selectedContactsHandler})
      : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final ContactsController contactsController = ContactsController();

  @override
  void initState() {
    // TODO: implement initState
    contactsController.loadContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ThemeIconWidget(
                    ThemeIcon.close,
                    size: 20,
                  ).ripple(() {
                    Navigator.of(context).pop();
                  }),
                  Heading5Text(
                    sendString.tr,
                    weight: TextWeight.medium,

                  ).ripple(() {
                    Navigator.of(context).pop();
                    widget.selectedContactsHandler(
                        contactsController.selectedContacts);
                  }),
                ],
              ).hp(DesignConstants.horizontalPadding),
              Positioned(
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Obx(() => Heading6Text(
                          '${shareContactsString.tr} ${contactsController.selectedContacts.length}/${contactsController.contacts.length}',
                      weight: TextWeight.medium,
                        ))
                  ],
                ),
              )
            ],
          ),
          divider().tP16,
          Expanded(
            child: GetBuilder<ContactsController>(
                init: contactsController,
                builder: (ctx) {
                  return ListView.separated(
                      padding:
                           EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 25),
                      itemCount: contactsController.contacts.length,
                      itemBuilder: (ctx, index) {
                        Contact contact = contactsController.contacts[index];
                        return ContactTile(
                          contact: contact,
                          isSelected: contactsController.selectedContacts
                              .contains(contact),
                        ).ripple(() {
                          contactsController.selectUnSelectContact(contact);
                        });
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          height: 20,
                        );
                      });
                }),
          )
        ],
      ),
    );
  }
}
