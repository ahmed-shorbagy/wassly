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

  /// No description provided for @provideCredentialsToRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Please provide these credentials to the restaurant owner:'**
  String get provideCredentialsToRestaurant;

  /// No description provided for @restaurantCanChangePasswordAfterLogin.
  ///
  /// In en, this message translates to:
  /// **'Note: Restaurant owner can change password after first login.'**
  String get restaurantCanChangePasswordAfterLogin;

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

  /// No description provided for @restaurantInformation.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Information'**
  String get restaurantInformation;

  /// No description provided for @restaurantStatus.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Status'**
  String get restaurantStatus;

  /// No description provided for @restaurantIsOpen.
  ///
  /// In en, this message translates to:
  /// **'Restaurant is open'**
  String get restaurantIsOpen;

  /// No description provided for @restaurantIsClosed.
  ///
  /// In en, this message translates to:
  /// **'Restaurant is closed'**
  String get restaurantIsClosed;

  /// No description provided for @manageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get manageProducts;

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

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// No description provided for @browseRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Browse Restaurants'**
  String get browseRestaurants;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get navProfile;

  /// No description provided for @navPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get navPay;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String itemAddedToCart(String productName);

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @areYouSureClearCart.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the cart?'**
  String get areYouSureClearCart;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @nearbyRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Nearby Restaurants'**
  String get nearbyRestaurants;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @noRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No Restaurants'**
  String get noRestaurants;

  /// No description provided for @noRestaurantsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No restaurants available at the moment'**
  String get noRestaurantsAvailable;

  /// No description provided for @noRestaurantsAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new restaurants'**
  String get noRestaurantsAvailableMessage;

  /// No description provided for @noRestaurantsFound.
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get noRestaurantsFound;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @exitAppConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitAppConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @unsavedChangesWarning.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them and continue?'**
  String get unsavedChangesWarning;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @restaurantOrders.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Orders'**
  String get restaurantOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pendingOrders;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get allOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @noPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'No Pending Orders'**
  String get noPendingOrders;

  /// No description provided for @noPendingOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'No pending orders at the moment'**
  String get noPendingOrdersMessage;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No Active Orders'**
  String get noActiveOrders;

  /// No description provided for @noActiveOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'No active orders at the moment'**
  String get noActiveOrdersMessage;

  /// No description provided for @noOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'No Order History'**
  String get noOrderHistory;

  /// No description provided for @noOrderHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order history is empty'**
  String get noOrderHistoryMessage;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more items'**
  String moreItems(int count);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get onTheWay;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @orderPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderPending;

  /// No description provided for @orderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderPreparing;

  /// No description provided for @orderReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orderReady;

  /// No description provided for @orderPickedUp.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get orderPickedUp;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDelivered;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @startPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparing;

  /// No description provided for @markAsReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markAsReady;

  /// No description provided for @waitingForDriver.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Driver'**
  String get waitingForDriver;

  /// No description provided for @orderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order accepted'**
  String get orderAccepted;

  /// No description provided for @rejectOrder.
  ///
  /// In en, this message translates to:
  /// **'Reject Order'**
  String get rejectOrder;

  /// No description provided for @rejectOrderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this order?'**
  String get rejectOrderConfirmation;

  /// No description provided for @orderRejected.
  ///
  /// In en, this message translates to:
  /// **'Order rejected'**
  String get orderRejected;

  /// No description provided for @orderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order status updated'**
  String get orderStatusUpdated;

  /// No description provided for @marketProducts.
  ///
  /// In en, this message translates to:
  /// **'Market Products'**
  String get marketProducts;

  /// No description provided for @noMarketProducts.
  ///
  /// In en, this message translates to:
  /// **'No Market Products'**
  String get noMarketProducts;

  /// No description provided for @startByAddingYourFirstMarketProduct.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first market product'**
  String get startByAddingYourFirstMarketProduct;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @searchRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants...'**
  String get searchRestaurants;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @startupAds.
  ///
  /// In en, this message translates to:
  /// **'Startup Ads'**
  String get startupAds;

  /// No description provided for @bannerAds.
  ///
  /// In en, this message translates to:
  /// **'Banner Ads'**
  String get bannerAds;

  /// No description provided for @addAd.
  ///
  /// In en, this message translates to:
  /// **'Add Ad'**
  String get addAd;

  /// No description provided for @addStartupAd.
  ///
  /// In en, this message translates to:
  /// **'Add Startup Ad'**
  String get addStartupAd;

  /// No description provided for @addBanner.
  ///
  /// In en, this message translates to:
  /// **'Add Banner'**
  String get addBanner;

  /// No description provided for @editStartupAd.
  ///
  /// In en, this message translates to:
  /// **'Edit Startup Ad'**
  String get editStartupAd;

  /// No description provided for @editBanner.
  ///
  /// In en, this message translates to:
  /// **'Edit Banner'**
  String get editBanner;

  /// No description provided for @bannerLocation.
  ///
  /// In en, this message translates to:
  /// **'Banner Location'**
  String get bannerLocation;

  /// No description provided for @updateAd.
  ///
  /// In en, this message translates to:
  /// **'Update Ad'**
  String get updateAd;

  /// No description provided for @updateBanner.
  ///
  /// In en, this message translates to:
  /// **'Update Banner'**
  String get updateBanner;

  /// No description provided for @adTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad Title'**
  String get adTitle;

  /// No description provided for @adDescription.
  ///
  /// In en, this message translates to:
  /// **'Ad Description'**
  String get adDescription;

  /// No description provided for @deepLink.
  ///
  /// In en, this message translates to:
  /// **'Deep Link'**
  String get deepLink;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @adAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ad added successfully'**
  String get adAddedSuccessfully;

  /// No description provided for @adUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ad updated successfully'**
  String get adUpdatedSuccessfully;

  /// No description provided for @adDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ad deleted successfully'**
  String get adDeletedSuccessfully;

  /// No description provided for @creatingAd.
  ///
  /// In en, this message translates to:
  /// **'Creating ad...'**
  String get creatingAd;

  /// No description provided for @updatingAd.
  ///
  /// In en, this message translates to:
  /// **'Updating ad...'**
  String get updatingAd;

  /// No description provided for @deleteAd.
  ///
  /// In en, this message translates to:
  /// **'Delete Ad'**
  String get deleteAd;

  /// No description provided for @deleteBanner.
  ///
  /// In en, this message translates to:
  /// **'Delete Banner'**
  String get deleteBanner;

  /// No description provided for @areYouSureDeleteAd.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureDeleteAd;

  /// No description provided for @areYouSureDeleteBanner.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSureDeleteBanner;

  /// No description provided for @ad.
  ///
  /// In en, this message translates to:
  /// **'ad'**
  String get ad;

  /// No description provided for @banner.
  ///
  /// In en, this message translates to:
  /// **'banner'**
  String get banner;

  /// No description provided for @noStartupAds.
  ///
  /// In en, this message translates to:
  /// **'No Startup Ads'**
  String get noStartupAds;

  /// No description provided for @noBannerAds.
  ///
  /// In en, this message translates to:
  /// **'No Banner Ads'**
  String get noBannerAds;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @startByAddingYourFirstStartupAd.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first startup ad'**
  String get startByAddingYourFirstStartupAd;

  /// No description provided for @startByAddingYourFirstBannerAd.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first banner ad'**
  String get startByAddingYourFirstBannerAd;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @adminAccess.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminAccess;

  /// No description provided for @adminAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'You have full administrative access to all platform features.\n\nNo authentication required.'**
  String get adminAccessDescription;

  /// No description provided for @totalRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get totalRestaurants;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get totalOrders;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get totalUsers;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @addProductsWorth.
  ///
  /// In en, this message translates to:
  /// **'Add products worth {amount} to start the order'**
  String addProductsWorth(String amount);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @enterEmailForPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get enterEmailForPasswordReset;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent to your email'**
  String get passwordResetEmailSent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @cannotOpenPhoneApp.
  ///
  /// In en, this message translates to:
  /// **'Cannot open phone app'**
  String get cannotOpenPhoneApp;

  /// No description provided for @errorCalling.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while calling'**
  String get errorCalling;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get calling;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get orderPlacedSuccessfully;

  /// No description provided for @pleaseLoginToPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Please log in to place an order'**
  String get pleaseLoginToPlaceOrder;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @enterDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your delivery address'**
  String get enterDeliveryAddress;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @orderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order Notes (Optional)'**
  String get orderNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @anySpecialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Any special instructions?'**
  String get anySpecialInstructions;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @startAddingProductsFromRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Start adding products from restaurants'**
  String get startAddingProductsFromRestaurants;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @loadingOrder.
  ///
  /// In en, this message translates to:
  /// **'Loading order...'**
  String get loadingOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @areYouSureCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get areYouSureCancelOrder;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @orderCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get orderCancelledSuccessfully;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @orderTime.
  ///
  /// In en, this message translates to:
  /// **'Order Time'**
  String get orderTime;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @driverInformation.
  ///
  /// In en, this message translates to:
  /// **'Driver Information'**
  String get driverInformation;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @socialLoginComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Social login coming soon'**
  String get socialLoginComingSoon;

  /// No description provided for @marketProductAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String marketProductAddedToCart(String productName);

  /// No description provided for @failedToAddProductToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add product to cart'**
  String get failedToAddProductToCart;

  /// No description provided for @marketProductsOrderingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Market products ordering coming soon'**
  String get marketProductsOrderingComingSoon;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @placingOrder.
  ///
  /// In en, this message translates to:
  /// **'Placing your order...'**
  String get placingOrder;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginToContinue;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @foodCategories.
  ///
  /// In en, this message translates to:
  /// **'Food Categories'**
  String get foodCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get updateCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @categoryCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreatedSuccessfully;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @categoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryNotFound;

  /// No description provided for @creatingCategory.
  ///
  /// In en, this message translates to:
  /// **'Creating category...'**
  String get creatingCategory;

  /// No description provided for @updatingCategory.
  ///
  /// In en, this message translates to:
  /// **'Updating category...'**
  String get updatingCategory;

  /// No description provided for @areYouSureDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \"{name}\"?'**
  String areYouSureDeleteCategory(String name);

  /// No description provided for @displayOrder.
  ///
  /// In en, this message translates to:
  /// **'Display Order'**
  String get displayOrder;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currency;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'ج.م'**
  String get currencySymbol;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @groceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get groceries;

  /// No description provided for @healthAndBeauty.
  ///
  /// In en, this message translates to:
  /// **'Health & Beauty'**
  String get healthAndBeauty;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @orderNowForDeliveryToday.
  ///
  /// In en, this message translates to:
  /// **'Order now for your order to arrive today at 10:00'**
  String get orderNowForDeliveryToday;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Most Relevant'**
  String get relevance;

  /// No description provided for @highestRating.
  ///
  /// In en, this message translates to:
  /// **'Highest Rating'**
  String get highestRating;

  /// No description provided for @fastestDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fastest Delivery'**
  String get fastestDelivery;

  /// No description provided for @lowestPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest Price'**
  String get lowestPrice;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Address'**
  String get selectDeliveryAddress;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @failedToLoadRestaurantData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load restaurant data'**
  String get failedToLoadRestaurantData;

  /// No description provided for @burger.
  ///
  /// In en, this message translates to:
  /// **'Burger'**
  String get burger;

  /// No description provided for @pizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get pizza;

  /// No description provided for @noodles.
  ///
  /// In en, this message translates to:
  /// **'Noodles'**
  String get noodles;

  /// No description provided for @meat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get meat;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @minutesAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesAbbreviation;

  /// No description provided for @pleaseLoginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get pleaseLoginToContinue;

  /// No description provided for @invalidProduct.
  ///
  /// In en, this message translates to:
  /// **'Invalid product. Please try again.'**
  String get invalidProduct;

  /// No description provided for @quantityMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than zero'**
  String get quantityMustBeGreaterThanZero;

  /// No description provided for @cannotAddDifferentRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Cannot add products from different restaurants. Please clear cart first.'**
  String get cannotAddDifferentRestaurant;

  /// No description provided for @failedToAddItemToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item to cart. Please try again.'**
  String get failedToAddItemToCart;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String productAddedToCart(String productName);

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @nA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get nA;

  /// No description provided for @creatingDriver.
  ///
  /// In en, this message translates to:
  /// **'Creating driver...'**
  String get creatingDriver;

  /// No description provided for @personalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Personal Photo'**
  String get personalPhoto;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get pleaseEnterFullName;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @discountPercentage.
  ///
  /// In en, this message translates to:
  /// **'Discount Percentage'**
  String get discountPercentage;

  /// No description provided for @discountDescription.
  ///
  /// In en, this message translates to:
  /// **'Discount Description'**
  String get discountDescription;

  /// No description provided for @discountStartDate.
  ///
  /// In en, this message translates to:
  /// **'Discount Start Date'**
  String get discountStartDate;

  /// No description provided for @discountEndDate.
  ///
  /// In en, this message translates to:
  /// **'Discount End Date'**
  String get discountEndDate;

  /// No description provided for @enableDiscount.
  ///
  /// In en, this message translates to:
  /// **'Enable Discount'**
  String get enableDiscount;

  /// No description provided for @disableDiscount.
  ///
  /// In en, this message translates to:
  /// **'Disable Discount'**
  String get disableDiscount;

  /// No description provided for @activeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Active Discount'**
  String get activeDiscount;

  /// No description provided for @discountUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Discount updated successfully'**
  String get discountUpdatedSuccessfully;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseEnterDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Please enter delivery fee'**
  String get pleaseEnterDeliveryFee;

  /// No description provided for @pleaseEnterMinimumOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter minimum order amount'**
  String get pleaseEnterMinimumOrderAmount;

  /// No description provided for @pleaseEnterDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Please enter delivery time'**
  String get pleaseEnterDeliveryTime;

  /// No description provided for @createDriver.
  ///
  /// In en, this message translates to:
  /// **'Create Driver'**
  String get createDriver;

  /// No description provided for @pleaseSelectPersonalImage.
  ///
  /// In en, this message translates to:
  /// **'Please select personal image'**
  String get pleaseSelectPersonalImage;

  /// No description provided for @pleaseSelectDriverLicense.
  ///
  /// In en, this message translates to:
  /// **'Please select driver license'**
  String get pleaseSelectDriverLicense;

  /// No description provided for @pleaseSelectVehicleLicense.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle license'**
  String get pleaseSelectVehicleLicense;

  /// No description provided for @pleaseSelectVehiclePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle photo'**
  String get pleaseSelectVehiclePhoto;

  /// No description provided for @licenseInformation.
  ///
  /// In en, this message translates to:
  /// **'License Information'**
  String get licenseInformation;

  /// No description provided for @vehicleInformation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @pleaseSelectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle type'**
  String get pleaseSelectVehicleType;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @pleaseEnterVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle model'**
  String get pleaseEnterVehicleModel;

  /// No description provided for @vehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Color'**
  String get vehicleColor;

  /// No description provided for @pleaseEnterVehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle color'**
  String get pleaseEnterVehicleColor;

  /// No description provided for @vehiclePlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Plate Number'**
  String get vehiclePlateNumber;

  /// No description provided for @pleaseEnterVehiclePlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle plate number'**
  String get pleaseEnterVehiclePlateNumber;

  /// No description provided for @driverLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver License'**
  String get driverLicense;

  /// No description provided for @vehicleLicense.
  ///
  /// In en, this message translates to:
  /// **'Vehicle License'**
  String get vehicleLicense;

  /// No description provided for @vehiclePhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photo'**
  String get vehiclePhoto;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @driverCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Driver Created Successfully'**
  String get driverCreatedSuccessfully;

  /// No description provided for @pleaseProvideTheseCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please provide these credentials to the driver:'**
  String get pleaseProvideTheseCredentials;

  /// No description provided for @noteDriverCanChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Note: Driver can change password after first login.'**
  String get noteDriverCanChangePassword;

  /// No description provided for @tapToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload image'**
  String get tapToUploadImage;

  /// No description provided for @marketProductCategories.
  ///
  /// In en, this message translates to:
  /// **'Market Categories'**
  String get marketProductCategories;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// No description provided for @bakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get bakery;

  /// No description provided for @frozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get frozen;

  /// No description provided for @canned.
  ///
  /// In en, this message translates to:
  /// **'Canned'**
  String get canned;

  /// No description provided for @spices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get spices;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @personalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get personalCare;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @dairyProducts.
  ///
  /// In en, this message translates to:
  /// **'Dairy Products'**
  String get dairyProducts;

  /// No description provided for @cheese.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get cheese;

  /// No description provided for @eggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get eggs;

  /// No description provided for @softDrinks.
  ///
  /// In en, this message translates to:
  /// **'Soft Drinks'**
  String get softDrinks;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @juices.
  ///
  /// In en, this message translates to:
  /// **'Juices'**
  String get juices;

  /// No description provided for @pastaAndRice.
  ///
  /// In en, this message translates to:
  /// **'Pasta and Rice'**
  String get pastaAndRice;

  /// No description provided for @chipsAndSnacks.
  ///
  /// In en, this message translates to:
  /// **'Chips and Snacks'**
  String get chipsAndSnacks;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @addressBook.
  ///
  /// In en, this message translates to:
  /// **'Address Book'**
  String get addressBook;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found'**
  String get noAddressesFound;

  /// No description provided for @addYourFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your first address to get started'**
  String get addYourFirstAddress;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @deleteAddressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressConfirm;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @fruitsVegetables.
  ///
  /// In en, this message translates to:
  /// **'Fruits & Vegetables'**
  String get fruitsVegetables;

  /// No description provided for @poultryMeatSeafood.
  ///
  /// In en, this message translates to:
  /// **'Poultry, Meat & Seafood'**
  String get poultryMeatSeafood;

  /// No description provided for @freshFood.
  ///
  /// In en, this message translates to:
  /// **'Fresh Food'**
  String get freshFood;

  /// No description provided for @readyToEat.
  ///
  /// In en, this message translates to:
  /// **'Ready to Eat'**
  String get readyToEat;

  /// No description provided for @frozenFood.
  ///
  /// In en, this message translates to:
  /// **'Frozen Food'**
  String get frozenFood;

  /// No description provided for @dairyAndEggs.
  ///
  /// In en, this message translates to:
  /// **'Dairy & Eggs'**
  String get dairyAndEggs;

  /// No description provided for @iceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get iceCream;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @cookingAndBaking.
  ///
  /// In en, this message translates to:
  /// **'Cooking & Baking'**
  String get cookingAndBaking;

  /// No description provided for @coffeeAndTea.
  ///
  /// In en, this message translates to:
  /// **'Coffee & Tea'**
  String get coffeeAndTea;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @tissuesAndBags.
  ///
  /// In en, this message translates to:
  /// **'Tissues & Bags'**
  String get tissuesAndBags;

  /// No description provided for @cannedFood.
  ///
  /// In en, this message translates to:
  /// **'Canned Food'**
  String get cannedFood;

  /// No description provided for @breakfastFood.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Food'**
  String get breakfastFood;

  /// No description provided for @babyCorner.
  ///
  /// In en, this message translates to:
  /// **'Baby Corner'**
  String get babyCorner;

  /// No description provided for @cleaningAndLaundry.
  ///
  /// In en, this message translates to:
  /// **'Cleaning & Laundry'**
  String get cleaningAndLaundry;

  /// No description provided for @specialDiet.
  ///
  /// In en, this message translates to:
  /// **'Special Diet'**
  String get specialDiet;

  /// No description provided for @spicesAndSauces.
  ///
  /// In en, this message translates to:
  /// **'Spices & Sauces'**
  String get spicesAndSauces;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get shopByCategory;

  /// No description provided for @mostSoldProducts.
  ///
  /// In en, this message translates to:
  /// **'Most Sold Products'**
  String get mostSoldProducts;

  /// No description provided for @promotionalImages.
  ///
  /// In en, this message translates to:
  /// **'Promotional Images'**
  String get promotionalImages;

  /// No description provided for @addPromotionalImage.
  ///
  /// In en, this message translates to:
  /// **'Add Promotional Image'**
  String get addPromotionalImage;

  /// No description provided for @editPromotionalImage.
  ///
  /// In en, this message translates to:
  /// **'Edit Promotional Image'**
  String get editPromotionalImage;

  /// No description provided for @deletePromotionalImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Promotional Image'**
  String get deletePromotionalImage;

  /// No description provided for @areYouSureDeletePromotionalImage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the promotional image'**
  String get areYouSureDeletePromotionalImage;

  /// No description provided for @promotionalImage.
  ///
  /// In en, this message translates to:
  /// **'Promotional Image'**
  String get promotionalImage;

  /// No description provided for @noPromotionalImages.
  ///
  /// In en, this message translates to:
  /// **'No Promotional Images'**
  String get noPromotionalImages;

  /// No description provided for @startByAddingYourFirstPromotionalImage.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first promotional image'**
  String get startByAddingYourFirstPromotionalImage;

  /// No description provided for @tapToChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to change image'**
  String get tapToChangeImage;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @optionalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter optional title'**
  String get optionalTitleHint;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get subtitle;

  /// No description provided for @optionalSubtitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter optional subtitle'**
  String get optionalSubtitleHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @exploreOurRichWorld.
  ///
  /// In en, this message translates to:
  /// **'Explore our rich world'**
  String get exploreOurRichWorld;

  /// No description provided for @pickupFromRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Pickup from Restaurant'**
  String get pickupFromRestaurant;

  /// No description provided for @deliveryMode.
  ///
  /// In en, this message translates to:
  /// **'Delivery Mode'**
  String get deliveryMode;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @startNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Start New Order'**
  String get startNewOrder;

  /// No description provided for @clearCartConfirmation.
  ///
  /// In en, this message translates to:
  /// **'You have items from another restaurant. Start a new order to clear the cart?'**
  String get clearCartConfirmation;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;
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
