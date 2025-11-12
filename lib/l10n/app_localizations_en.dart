// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createRestaurant => 'Create Restaurant';

  @override
  String get restaurantSetup => 'Restaurant Setup';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get restaurantName => 'Restaurant Name';

  @override
  String get description => 'Description';

  @override
  String get pleaseEnterRestaurantName => 'Please enter restaurant name';

  @override
  String get pleaseEnterDescription => 'Please enter description';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get commercialRegistration => 'Commercial Registration';

  @override
  String get commercialRegistrationArabic => 'السجل التجاري';

  @override
  String get optional => 'Optional';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get pleaseEnterValidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get pleaseEnterAddress => 'Please enter address';

  @override
  String get tapToSelectLocationOnMap => 'Tap to select location on map';

  @override
  String locationSet(String latitude, String longitude) {
    return 'Location: $latitude, $longitude';
  }

  @override
  String get locationSetToCairo => 'Location set to Cairo, Egypt';

  @override
  String get categories => 'Categories';

  @override
  String get selectCategories => 'Select Categories';

  @override
  String get tapToSelectCategories => 'Tap to select categories';

  @override
  String get selectedCategories => 'Selected Categories:';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get deliverySettings => 'Delivery Settings';

  @override
  String get deliveryFee => 'Delivery Fee (\$)';

  @override
  String get minOrder => 'Min Order (\$)';

  @override
  String get estimatedDeliveryTime => 'Estimated Delivery Time (minutes)';

  @override
  String get required => 'Required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get tapToUploadRestaurantImage => 'Tap to upload restaurant image';

  @override
  String get change => 'Change';

  @override
  String get pleaseSelectImage => 'Please select a restaurant image';

  @override
  String get pleaseSelectLocation => 'Please select a location';

  @override
  String get pleaseSelectAtLeastOneCategory =>
      'Please select at least one category';

  @override
  String get creatingRestaurant => 'Creating your restaurant...';

  @override
  String get restaurantCreatedSuccessfully =>
      'Restaurant created successfully!';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get fastFood => 'Fast Food';

  @override
  String get italian => 'Italian';

  @override
  String get chinese => 'Chinese';

  @override
  String get indian => 'Indian';

  @override
  String get mexican => 'Mexican';

  @override
  String get japanese => 'Japanese';

  @override
  String get thai => 'Thai';

  @override
  String get mediterranean => 'Mediterranean';

  @override
  String get american => 'American';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get vegan => 'Vegan';

  @override
  String get desserts => 'Desserts';

  @override
  String get beverages => 'Beverages';

  @override
  String get healthy => 'Healthy';

  @override
  String get bbq => 'BBQ';

  @override
  String get seafood => 'Seafood';
}
