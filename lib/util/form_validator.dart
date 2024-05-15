class FormValidator {
  static final FormValidator _validator =  FormValidator._internal();
  factory FormValidator() {
    return _validator;
  }
  FormValidator._internal();

  bool isTextEmpty(String value) {
    return value.isEmpty ? true : false;
  }

  bool isNotValidEmail(String value) {
    String pattern =
        r'^(([^<;>;()[\]\\.,;:\s@\"]+(\.[^<;>;()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp =  RegExp(pattern);
    return regExp.hasMatch(value) ? false : true;
  }
}
