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

  @override
  String get arabic => 'Arabic';

  @override
  String get egyptian => 'Egyptian';

  @override
  String get lebanese => 'Lebanese';

  @override
  String get syrian => 'Syrian';

  @override
  String get palestinian => 'Palestinian';

  @override
  String get jordanian => 'Jordanian';

  @override
  String get saudi => 'Saudi';

  @override
  String get emirati => 'Emirati';

  @override
  String get gulf => 'Gulf';

  @override
  String get moroccan => 'Moroccan';

  @override
  String get tunisian => 'Tunisian';

  @override
  String get algerian => 'Algerian';

  @override
  String get yemeni => 'Yemeni';

  @override
  String get iraqi => 'Iraqi';

  @override
  String get grilledMeat => 'Grilled Meat';

  @override
  String get kebabs => 'Kebabs';

  @override
  String get shawarma => 'Shawarma';

  @override
  String get falafel => 'Falafel';

  @override
  String get hummus => 'Hummus';

  @override
  String get mezze => 'Mezze';

  @override
  String get foul => 'Foul';

  @override
  String get taameya => 'Taameya';

  @override
  String get koshary => 'Koshary';

  @override
  String get mansaf => 'Mansaf';

  @override
  String get mansi => 'Mansi';

  @override
  String get mandi => 'Mandi';

  @override
  String get kabsa => 'Kabsa';

  @override
  String get majboos => 'Majboos';

  @override
  String get maqluba => 'Maqluba';

  @override
  String get musakhan => 'Musakhan';

  @override
  String get mansafJordanian => 'Mansaf Jordanian';

  @override
  String get waraqEnab => 'Waraq Enab';

  @override
  String get mahshi => 'Mahshi';

  @override
  String get kofta => 'Kofta';

  @override
  String get samosa => 'Samosa';

  @override
  String get knafeh => 'Knafeh';

  @override
  String get baklava => 'Baklava';

  @override
  String get biryani => 'Biryani';

  @override
  String get bakedGoods => 'Baked Goods';

  @override
  String get orientalSweets => 'Oriental Sweets';

  @override
  String get commercialRegistrationPhoto => 'Commercial Registration Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get openCamera => 'Open Camera';

  @override
  String get pleaseTakeCommercialRegistrationPhoto =>
      'Please take commercial registration photo';

  @override
  String get productManagement => 'Product Management';

  @override
  String get products => 'Products';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productName => 'Product Name';

  @override
  String get productDescription => 'Product Description';

  @override
  String get productPrice => 'Product Price';

  @override
  String get productCategory => 'Product Category';

  @override
  String get productImage => 'Product Image';

  @override
  String get productAvailable => 'Available';

  @override
  String get productUnavailable => 'Unavailable';

  @override
  String get pleaseEnterProductName => 'Please enter product name';

  @override
  String get pleaseEnterProductDescription =>
      'Please enter product description';

  @override
  String get pleaseEnterProductPrice => 'Please enter product price';

  @override
  String get pleaseSelectProductCategory => 'Please select product category';

  @override
  String get pleaseSelectProductImage => 'Please select product image';

  @override
  String get productAddedSuccessfully => 'Product added successfully';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully';

  @override
  String get creatingProduct => 'Creating product...';

  @override
  String get updatingProduct => 'Updating product...';

  @override
  String get deletingProduct => 'Deleting product...';

  @override
  String get areYouSureDeleteProduct =>
      'Are you sure you want to delete this product?';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get startByAddingYourFirstProduct =>
      'Start by adding your first product';

  @override
  String get selectRestaurantFirst => 'Please select a restaurant first';

  @override
  String get restaurantProducts => 'Restaurant Products';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get editRestaurant => 'Edit Restaurant';

  @override
  String get updateRestaurant => 'Update Restaurant';

  @override
  String get restaurantUpdatedSuccessfully => 'Restaurant updated successfully';

  @override
  String get updatingRestaurant => 'Updating restaurant...';

  @override
  String get restaurantNotFound => 'Restaurant not found';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading...';

  @override
  String get leavePasswordEmptyToKeepCurrent =>
      'Leave password empty to keep current password';
}
