// File: lib/utils/validators.dart
class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  // Password validation (at least 8 characters, with at least one letter and one number)
  static bool isValidPassword(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  // Phone number validation (for UAE format)
  static bool isValidPhoneNumber(String phoneNumber) {
    // UAE phone numbers are typically 9 digits after the country code
    final phoneRegExp = RegExp(r'^[0-9]{9}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // Empty field validation
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  // Name validation (letters only, at least 2 characters)
  static bool isValidName(String name) {
    final nameRegExp = RegExp(r'^[a-zA-Z ]{2,}$');
    return nameRegExp.hasMatch(name);
  }

  // Credit card number validation
  static bool isValidCreditCardNumber(String cardNumber) {
    // Remove spaces and dashes
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    // Check if it's a valid length and contains only digits
    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cleanNumber)) {
      return false;
    }
    
    // Luhn algorithm for credit card validation
    int sum = 0;
    bool alternate = false;
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cleanNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  // Expiry date validation (MM/YY format)
  static bool isValidExpiryDate(String expiryDate) {
    // Check format
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(expiryDate)) {
      return false;
    }
    
    // Extract month and year
    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    // Get current date
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // Check if the date is in the future
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }
    
    return true;
  }

  // CVV validation (3 or 4 digits)
  static bool isValidCVV(String cvv) {
    return RegExp(r'^[0-9]{3,4}$').hasMatch(cvv);
  }

  // Postal code validation
  static bool isValidPostalCode(String postalCode) {
    // This is a simple validation, adjust based on country requirements
    return RegExp(r'^[0-9a-zA-Z]{3,10}$').hasMatch(postalCode);
  }
}
