import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @createRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Create Restaurant'**
  String get createRestaurant;

  /// No description provided for @restaurantSetup.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Setup'**
  String get restaurantSetup;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @restaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name'**
  String get restaurantName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @pleaseEnterRestaurantName.
  ///
  /// In en, this message translates to:
  /// **'Please enter restaurant name'**
  String get pleaseEnterRestaurantName;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get pleaseEnterDescription;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @commercialRegistration.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration'**
  String get commercialRegistration;

  /// No description provided for @commercialRegistrationArabic.
  ///
  /// In en, this message translates to:
  /// **'السجل التجاري'**
  String get commercialRegistrationArabic;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @pleaseEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get pleaseEnterAddress;

  /// No description provided for @tapToSelectLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Tap to select location on map'**
  String get tapToSelectLocationOnMap;

  /// No description provided for @locationSet.
  ///
  /// In en, this message translates to:
  /// **'Location: {latitude}, {longitude}'**
  String locationSet(String latitude, String longitude);

  /// No description provided for @locationSetToCairo.
  ///
  /// In en, this message translates to:
  /// **'Location set to Cairo, Egypt'**
  String get locationSetToCairo;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @selectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select Categories'**
  String get selectCategories;

  /// No description provided for @tapToSelectCategories.
  ///
  /// In en, this message translates to:
  /// **'Tap to select categories'**
  String get tapToSelectCategories;

  /// No description provided for @selectedCategories.
  ///
  /// In en, this message translates to:
  /// **'Selected Categories:'**
  String get selectedCategories;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deliverySettings.
  ///
  /// In en, this message translates to:
  /// **'Delivery Settings'**
  String get deliverySettings;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee (\$)'**
  String get deliveryFee;

  /// No description provided for @minOrder.
  ///
  /// In en, this message translates to:
  /// **'Min Order (\$)'**
  String get minOrder;

  /// No description provided for @estimatedDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery Time (minutes)'**
  String get estimatedDeliveryTime;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @tapToUploadRestaurantImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload restaurant image'**
  String get tapToUploadRestaurantImage;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @pleaseSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Please select a restaurant image'**
  String get pleaseSelectImage;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get pleaseSelectLocation;

  /// No description provided for @pleaseSelectAtLeastOneCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one category'**
  String get pleaseSelectAtLeastOneCategory;

  /// No description provided for @creatingRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Creating your restaurant...'**
  String get creatingRestaurant;

  /// No description provided for @restaurantCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Restaurant created successfully!'**
  String get restaurantCreatedSuccessfully;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @fastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get fastFood;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @indian.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get indian;

  /// No description provided for @mexican.
  ///
  /// In en, this message translates to:
  /// **'Mexican'**
  String get mexican;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thai;

  /// No description provided for @mediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get mediterranean;

  /// No description provided for @american.
  ///
  /// In en, this message translates to:
  /// **'American'**
  String get american;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @desserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get desserts;

  /// No description provided for @beverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @bbq.
  ///
  /// In en, this message translates to:
  /// **'BBQ'**
  String get bbq;

  /// No description provided for @seafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get seafood;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @egyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian'**
  String get egyptian;

  /// No description provided for @lebanese.
  ///
  /// In en, this message translates to:
  /// **'Lebanese'**
  String get lebanese;

  /// No description provided for @syrian.
  ///
  /// In en, this message translates to:
  /// **'Syrian'**
  String get syrian;

  /// No description provided for @palestinian.
  ///
  /// In en, this message translates to:
  /// **'Palestinian'**
  String get palestinian;

  /// No description provided for @jordanian.
  ///
  /// In en, this message translates to:
  /// **'Jordanian'**
  String get jordanian;

  /// No description provided for @saudi.
  ///
  /// In en, this message translates to:
  /// **'Saudi'**
  String get saudi;

  /// No description provided for @emirati.
  ///
  /// In en, this message translates to:
  /// **'Emirati'**
  String get emirati;

  /// No description provided for @gulf.
  ///
  /// In en, this message translates to:
  /// **'Gulf'**
  String get gulf;

  /// No description provided for @moroccan.
  ///
  /// In en, this message translates to:
  /// **'Moroccan'**
  String get moroccan;

  /// No description provided for @tunisian.
  ///
  /// In en, this message translates to:
  /// **'Tunisian'**
  String get tunisian;

  /// No description provided for @algerian.
  ///
  /// In en, this message translates to:
  /// **'Algerian'**
  String get algerian;

  /// No description provided for @yemeni.
  ///
  /// In en, this message translates to:
  /// **'Yemeni'**
  String get yemeni;

  /// No description provided for @iraqi.
  ///
  /// In en, this message translates to:
  /// **'Iraqi'**
  String get iraqi;

  /// No description provided for @grilledMeat.
  ///
  /// In en, this message translates to:
  /// **'Grilled Meat'**
  String get grilledMeat;

  /// No description provided for @kebabs.
  ///
  /// In en, this message translates to:
  /// **'Kebabs'**
  String get kebabs;

  /// No description provided for @shawarma.
  ///
  /// In en, this message translates to:
  /// **'Shawarma'**
  String get shawarma;

  /// No description provided for @falafel.
  ///
  /// In en, this message translates to:
  /// **'Falafel'**
  String get falafel;

  /// No description provided for @hummus.
  ///
  /// In en, this message translates to:
  /// **'Hummus'**
  String get hummus;

  /// No description provided for @mezze.
  ///
  /// In en, this message translates to:
  /// **'Mezze'**
  String get mezze;

  /// No description provided for @foul.
  ///
  /// In en, this message translates to:
  /// **'Foul'**
  String get foul;

  /// No description provided for @taameya.
  ///
  /// In en, this message translates to:
  /// **'Taameya'**
  String get taameya;

  /// No description provided for @koshary.
  ///
  /// In en, this message translates to:
  /// **'Koshary'**
  String get koshary;

  /// No description provided for @mansaf.
  ///
  /// In en, this message translates to:
  /// **'Mansaf'**
  String get mansaf;

  /// No description provided for @mansi.
  ///
  /// In en, this message translates to:
  /// **'Mansi'**
  String get mansi;

  /// No description provided for @mandi.
  ///
  /// In en, this message translates to:
  /// **'Mandi'**
  String get mandi;

  /// No description provided for @kabsa.
  ///
  /// In en, this message translates to:
  /// **'Kabsa'**
  String get kabsa;

  /// No description provided for @majboos.
  ///
  /// In en, this message translates to:
  /// **'Majboos'**
  String get majboos;

  /// No description provided for @maqluba.
  ///
  /// In en, this message translates to:
  /// **'Maqluba'**
  String get maqluba;

  /// No description provided for @musakhan.
  ///
  /// In en, this message translates to:
  /// **'Musakhan'**
  String get musakhan;

  /// No description provided for @mansafJordanian.
  ///
  /// In en, this message translates to:
  /// **'Mansaf Jordanian'**
  String get mansafJordanian;

  /// No description provided for @waraqEnab.
  ///
  /// In en, this message translates to:
  /// **'Waraq Enab'**
  String get waraqEnab;

  /// No description provided for @mahshi.
  ///
  /// In en, this message translates to:
  /// **'Mahshi'**
  String get mahshi;

  /// No description provided for @kofta.
  ///
  /// In en, this message translates to:
  /// **'Kofta'**
  String get kofta;

  /// No description provided for @samosa.
  ///
  /// In en, this message translates to:
  /// **'Samosa'**
  String get samosa;

  /// No description provided for @knafeh.
  ///
  /// In en, this message translates to:
  /// **'Knafeh'**
  String get knafeh;

  /// No description provided for @baklava.
  ///
  /// In en, this message translates to:
  /// **'Baklava'**
  String get baklava;

  /// No description provided for @biryani.
  ///
  /// In en, this message translates to:
  /// **'Biryani'**
  String get biryani;

  /// No description provided for @bakedGoods.
  ///
  /// In en, this message translates to:
  /// **'Baked Goods'**
  String get bakedGoods;

  /// No description provided for @orientalSweets.
  ///
  /// In en, this message translates to:
  /// **'Oriental Sweets'**
  String get orientalSweets;

  /// No description provided for @commercialRegistrationPhoto.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration Photo'**
  String get commercialRegistrationPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @pleaseTakeCommercialRegistrationPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please take commercial registration photo'**
  String get pleaseTakeCommercialRegistrationPhoto;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productManagement;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescription;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get productPrice;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Product Category'**
  String get productCategory;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// No description provided for @productAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get productAvailable;

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get productUnavailable;

  /// No description provided for @pleaseEnterProductName.
  ///
  /// In en, this message translates to:
  /// **'Please enter product name'**
  String get pleaseEnterProductName;

  /// No description provided for @pleaseEnterProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter product description'**
  String get pleaseEnterProductDescription;

  /// No description provided for @pleaseEnterProductPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter product price'**
  String get pleaseEnterProductPrice;

  /// No description provided for @pleaseSelectProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select product category'**
  String get pleaseSelectProductCategory;

  /// No description provided for @pleaseSelectProductImage.
  ///
  /// In en, this message translates to:
  /// **'Please select product image'**
  String get pleaseSelectProductImage;

  /// No description provided for @productAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccessfully;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @creatingProduct.
  ///
  /// In en, this message translates to:
  /// **'Creating product...'**
  String get creatingProduct;

  /// No description provided for @updatingProduct.
  ///
  /// In en, this message translates to:
  /// **'Updating product...'**
  String get updatingProduct;

  /// No description provided for @deletingProduct.
  ///
  /// In en, this message translates to:
  /// **'Deleting product...'**
  String get deletingProduct;

  /// No description provided for @areYouSureDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get areYouSureDeleteProduct;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @startByAddingYourFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first product'**
  String get startByAddingYourFirstProduct;

  /// No description provided for @selectRestaurantFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a restaurant first'**
  String get selectRestaurantFirst;

  /// No description provided for @restaurantProducts.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Products'**
  String get restaurantProducts;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @editRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Edit Restaurant'**
  String get editRestaurant;

  /// No description provided for @updateRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Update Restaurant'**
  String get updateRestaurant;

  /// No description provided for @restaurantUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Restaurant updated successfully'**
  String get restaurantUpdatedSuccessfully;

  /// No description provided for @updatingRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Updating restaurant...'**
  String get updatingRestaurant;

  /// No description provided for @restaurantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Restaurant not found'**
  String get restaurantNotFound;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @leavePasswordEmptyToKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Leave password empty to keep current password'**
  String get leavePasswordEmptyToKeepCurrent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
