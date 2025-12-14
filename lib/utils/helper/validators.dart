import 'package:aiSeaSafe/utils/constants/string_constant.dart';
import 'package:flutter/services.dart';

class ValueValidators {
  ValueValidators._();

  static bool isEmailValid(String? email) {
    if (email == null || email.isEmpty) return false;
    Pattern pattern = r'^(([a-z0-9]+(\.[a-z0-9]+)*)|(\".+\"))@(([a-z0-9]+(\.[a-z0-9]+)+)|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))$';
    RegExp regExp = RegExp(pattern.toString());
    return regExp.hasMatch(email);
  }

  static bool isPasswordValid(String? password) {
    Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern.toString());
    return password != null ? regExp.hasMatch(password) : false;
  }

  static bool isNameValid(String? name) {
    Pattern pattern = r'^[a-zA-Z ]{2,35}$';
    RegExp regExp = RegExp(pattern.toString());
    return name != null ? regExp.hasMatch(name) : false;
  }

  static bool containsDigits(String name) {
    return RegExp(r'\d').hasMatch(name);
  }

  static bool containsSpecialCharacters(String name) {
    return RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]').hasMatch(name);
  }

  static bool isEmpty({required String value}) {
    return value.isEmpty;
  }

  static bool containsDigits1(String val) {
    return RegExp(r'\d').hasMatch(val);
  }

  static String? nameValidation({
    required String name,
    required String val,
  }) {
    val = val.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (val.isEmpty) {
      return 'Please enter your $name';
    } else if (containsDigits1(val)) {
      return '$name ${StringConst.errorNoDigitsAllowed}';
    } else if (RegExp(r'[^a-zA-Z0-9\- ]').hasMatch(val)) {
      return '$name ${StringConst.errorNoSpecialCharacters}';
    } else if (val.length > 35) {
      return '$name ${StringConst.errorNoMoreThan35Characters}';
    }

    return null;
  }

  static String? otpValidator(String? otp) {
    if (otp == null || otp.isEmpty) {
      return StringConst.emptyOtp;
    } else if (otp.length < 6) {
      return StringConst.otpLength;
    }
    return null;
  }

  static String? emailValidator(String? email) {
    if (email != null && email.isNotEmpty) {
      if (isEmailValid(email)) {
        return null;
      } else {
        return StringConst.errorInvalidEmail;
      }
    } else {
      return StringConst.emptyEmail;
    }
  }

  static String? passwordValidator(String? password, {bool isStrong = true}) {
    if (password != null && password.isNotEmpty) {
      if (isStrong) {
        if (isPasswordValid(password)) {
          return null;
        } else {
          return StringConst.errorInvalidPassword;
        }
      } else {
        return null;
      }
    } else {
      return StringConst.emptyPassword;
    }
  }

  static String? conformPasswordValidator(String? password, String? confirmPassword, {bool isStrong = true}) {
    if (confirmPassword != null && confirmPassword.isNotEmpty) {
      if (isPasswordValid(password)) {
        if (confirmPassword == password) {
          return null;
        } else {
          return StringConst.passwordsDoNotMatchError;
        }
      } else {
        return StringConst.errorInvalidPassword;
      }
    } else {
      return StringConst.emptyConfirmPassword;
    }
  }

  static String? firstNameValidator(String? firstName) {
    if (firstName != null && firstName.isNotEmpty) {
      if (isNameValid(firstName)) {
        if (firstName.length <= 35) {
          return null;
        } else {
          return StringConst.errorInvalidLengthFirstName;
        }
      } else if (containsDigits(firstName)) {
        return 'First name ${StringConst.errorNoDigitsAllowed}';
      } else if (containsSpecialCharacters(firstName)) {
        return 'First name ${StringConst.errorNoSpecialCharacters}';
      } else {
        return StringConst.errorEnterAtLeastTwoCharacter;
      }
    } else {
      return StringConst.emptyFirstName;
    }
  }

  static String? lastNameValidator(String? lastName) {
    if (lastName != null && lastName.isNotEmpty) {
      if (isNameValid(lastName)) {
        if (lastName.length <= 35) {
          return null;
        } else {
          return StringConst.errorInvalidLengthLastName;
        }
      } else if (containsDigits(lastName)) {
        return 'Last name ${StringConst.errorNoDigitsAllowed}';
      } else if (containsSpecialCharacters(lastName)) {
        return 'Last name ${StringConst.errorNoSpecialCharacters}';
      } else {
        return StringConst.errorEnterAtLeastTwoCharacter;
      }
    } else {
      return StringConst.emptyLastName;
    }
  }

  static String? emptyVehicleValidator(String? value) {
    if (isEmpty(value: value ?? '')) {
      return StringConst.emptyVehicleType;
    } else {
      return null;
    }
  }

  static String? nameValidator(String? name) {
    if (name != null && name.isNotEmpty) {
      if (isNameValid(name)) {
        if (name.length <= 35) {
          return null;
        } else {
          return StringConst.errorInvalidLengthFirstName;
        }
      } else if (containsDigits(name)) {
        return 'Vessel name ${StringConst.errorNoDigitsAllowed}';
      } else if (containsSpecialCharacters(name)) {
        return 'Vessel name ${StringConst.errorNoSpecialCharacters}';
      } else {
        return StringConst.errorEnterAtLeastTwoCharacter;
      }
    } else {
      return StringConst.emptyVesselName;
    }
  }

  static String? emergencyPhoneValidator(String? phone, String? name, int phoneLength, String countryName) {
    // if ((phone == null || phone.isEmpty) && (name == null || name.isEmpty)) {
    //   // both empty → no error
    //   return null;
    // }
    if (phone == null || phone.isEmpty) {
      return "Phone number cannot be empty";
    }
    // reuse your existing phone validation
    return emptyPhoneNumberValidator(value: phone, phoneNumberLength: phoneLength, countryName: countryName);
  }

  static String? emptyPhoneNumberValidator({required String value, required num phoneNumberLength, required String countryName}) {
    if (value.isEmpty) {
      return 'Phone number cannot be empty';
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter only numbers for the phone number';
    } else if (value.length != phoneNumberLength) {
      return 'Please enter $phoneNumberLength digits for $countryName';
    } else if (RegExp(r'^0+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    } else {
      return null;
    }
  }

  static String? captainNameValidator(String? name) {
    if (name != null && name.isNotEmpty) {
      if (isNameValid(name)) {
        if (name.length <= 35) {
          return null;
        } else {
          return StringConst.errorInvalidLengthFirstName;
        }
      } else if (containsDigits(name)) {
        return 'Captain name ${StringConst.errorNoDigitsAllowed}';
      } else if (containsSpecialCharacters(name)) {
        return 'Captain name ${StringConst.errorNoSpecialCharacters}';
      } else {
        return StringConst.errorEnterAtLeastTwoCharacter;
      }
    } else {
      return StringConst.emptyVesselName;
    }
  }

  static String? simpleSelectValidator({required String name, required String val}) {
    if (val
        .trim()
        .isEmpty) {
      return 'Please select $name';
    }
    return null;
  }

  static String? vesselIdValidator(String? id) {
    if (id == null || id.isEmpty) {
      return "Vessel ID cannot be empty";
    }

    final imoRegex = RegExp(r"^IMO\s\d{7}$");
    final mmsiRegex = RegExp(r"^\d{9}$");
    final callSignRegex = RegExp(r"^[A-Z0-9]{3,7}$");

    if (imoRegex.hasMatch(id)) {
      return null; // Valid IMO
    } else if (mmsiRegex.hasMatch(id)) {
      return null; // Valid MMSI
    } else if (callSignRegex.hasMatch(id)) {
      return null; // Valid Call Sign
    } else {
      return "Invalid vessel identifier. Use 'IMO 1234567', '123456789' (MMSI), or 'CALL123'";
    }
  }

  static String? subjectValidator(String? subject) {
    if (subject != null && subject.isNotEmpty) {
      return null;
    } else {
      return StringConst.emptySubject;
    }
  }

  static String? descriptionValidator(String? description) {
    if (description != null && description.isNotEmpty) {
      return null;
    } else {
      return StringConst.emptyDescription;
    }
  }

  static String? simpleValidator({required String name, required String val}) {
    if (val.isNotEmpty) {
      return null;
    } else {
      return 'Please enter your $name';
    }
  }

  static String? accountNumberValidator({required String name, required String val}) {
    if (val.isNotEmpty) {
      if (val.length < 11) {
        return 'Your $name must be at least 11 digits';
      }
      return null;
    } else {
      return 'Please enter your $name';
    }
  }

  static String? compareAccountNumberValidator({required String name, required String val, required String compareVal}) {
    if (val.isNotEmpty && compareVal.isNotEmpty) {
      if (val != compareVal) {
        return 'Your $name does not match';
      } else if (val.length < 10) {
        return 'Your $name must be at least 10 digits';
      }
      return null;
    } else {
      return 'Please enter your $name';
    }
  }

  static String? simpleCompareFieldsValidator({required String name, required String val, required String compareVal, required String compareFiledName}) {
    if (val.isNotEmpty) {
      return null;
    } else if (val != compareVal) {
      return '$name and $compareFiledName must be the same';
    } else {
      return 'Please enter your $name';
    }
  }

  static String? simpleCompareFieldsOnlyNumbers({required String name, required String val, required String compareVal, required String compareFiledName}) {
    if (val.isEmpty) {
      return 'Please enter your $name';
    } else if (val != compareVal) {
      return '$name and $compareFiledName must be the same';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
      return 'only numbers allowed';
    } else {
      return null;
    }
  }

  static String? simpleValidatorOnlyNumbers({required String name, required String val}) {
    if (val.isEmpty) {
      return 'Please enter your $name';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
      return 'only numbers allowed';
    }

    return null;
  }

  static String? reportIssueDescriptionValidator({required String name, required String val}) {
    if (val.isEmpty) {
      return 'Please enter $name';
    } else if (val.length > 200) {
      return '$name must not exceed 200 characters';
    } else {
      return null;
    }
  }

  static String? cardNumberValidator(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) {
      return StringConst.emptyCardNumber;
    } else if (RegExp(r'[^0-9 ]').hasMatch(cardNumber)) {
      return StringConst.errorNoSpecialCharacters;
    } else if (cardNumber
        .trim()
        .length < 18 && cardNumber
        .trim()
        .length < 19) {
      return StringConst.invalidCardLength;
    } else {
      return null;
    }
  }

  static String? cvvNumberValidator(String? cvvNumber) {
    if (cvvNumber == null || cvvNumber.isEmpty) {
      return StringConst.emptyCvvNumber;
    } else if (containsSpecialCharacters(cvvNumber)) {
      return 'CVV Number ${StringConst.errorNoSpecialCharacters}';
    } else if (!RegExp(r'^\d+$').hasMatch(cvvNumber)) {
      return StringConst.errorCardNumberOnlyDigits;
    } else if (cvvNumber.length < 3) {
      return StringConst.errorInvalidLengthCVVNumber;
    } else {
      return null;
    }
  }

  static String? cardHolderNameValidator(String? lastName) {
    if (lastName != null && lastName.isNotEmpty) {
      if (isNameValid(lastName)) {
        if (lastName.length <= 35) {
          return null;
        } else {
          return StringConst.errorInvalidLengthLastName;
        }
      } else if (containsDigits(lastName)) {
        return 'Holder name ${StringConst.errorNoDigitsAllowed}';
      } else if (containsSpecialCharacters(lastName)) {
        return 'Holder name ${StringConst.errorNoSpecialCharacters}';
      } else {
        return StringConst.errorEnterAtLeastTwoCharacter;
      }
    } else {
      return StringConst.emptyCardHolderName;
    }
  }

  static String? expirationValidator(String? expiration) {
    if (expiration == null || expiration.isEmpty) {
      return StringConst.emptyExpiration;
    } else if (!RegExp(r'^\d{2}/\d{2,4}$').hasMatch(expiration)) {
      return StringConst.invalidExpiration;
    }

    return null;
  }
}

class SingleSpaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newTextRaw = newValue.text;

    final newText = newTextRaw.replaceAll(RegExp(r'\s+'), ' ');

    final diff = newTextRaw.length - newText.length;

    final newOffset = newValue.selection.baseOffset - diff;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, newText.length)),
    );
  }
}
