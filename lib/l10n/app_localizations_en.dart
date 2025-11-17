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
  String get deliveryFee => 'Delivery Fee';

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

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get browseRestaurants => 'Browse Restaurants';

  @override
  String get total => 'Total';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get remove => 'Remove';

  @override
  String get quantity => 'Quantity';

  @override
  String itemAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get cannotAddDifferentRestaurant =>
      'Cannot add items from different restaurants. Please clear cart first.';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get areYouSureClearCart => 'Are you sure you want to clear the cart?';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'Tax';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get searchRestaurants => 'Search restaurants...';

  @override
  String get nearbyRestaurants => 'Nearby Restaurants';

  @override
  String get viewAll => 'View All';

  @override
  String get specialOffers => 'Special Offers';

  @override
  String get noRestaurants => 'No Restaurants';

  @override
  String get noRestaurantsAvailable => 'No restaurants available at the moment';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exitAppConfirmation => 'Are you sure you want to exit the app?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesWarning =>
      'You have unsaved changes. Do you want to discard them and continue?';

  @override
  String get discard => 'Discard';

  @override
  String get restaurantOrders => 'Restaurant Orders';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get orderHistory => 'Order History';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get noPendingOrders => 'No Pending Orders';

  @override
  String get noPendingOrdersMessage => 'No pending orders at the moment';

  @override
  String get noActiveOrders => 'No Active Orders';

  @override
  String get noActiveOrdersMessage => 'No active orders at the moment';

  @override
  String get noOrderHistory => 'No Order History';

  @override
  String get noOrderHistoryMessage => 'Your order history is empty';

  @override
  String get orderId => 'Order ID';

  @override
  String get orderItems => 'Order Items';

  @override
  String get moreItems => 'more items';

  @override
  String get pending => 'Pending';

  @override
  String get accepted => 'Accepted';

  @override
  String get preparing => 'Preparing';

  @override
  String get ready => 'Ready';

  @override
  String get onTheWay => 'On the Way';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markAsReady => 'Mark as Ready';

  @override
  String get waitingForDriver => 'Waiting for Driver';

  @override
  String get orderAccepted => 'Order accepted';

  @override
  String get rejectOrder => 'Reject Order';

  @override
  String get rejectOrderConfirmation =>
      'Are you sure you want to reject this order?';

  @override
  String get orderRejected => 'Order rejected';

  @override
  String get orderStatusUpdated => 'Order status updated';

  @override
  String get marketProducts => 'Market Products';

  @override
  String get noMarketProducts => 'No Market Products';

  @override
  String get startByAddingYourFirstMarketProduct =>
      'Start by adding your first market product';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get startupAds => 'Startup Ads';

  @override
  String get bannerAds => 'Banner Ads';

  @override
  String get addAd => 'Add Ad';

  @override
  String get addStartupAd => 'Add Startup Ad';

  @override
  String get addBanner => 'Add Banner';

  @override
  String get editStartupAd => 'Edit Startup Ad';

  @override
  String get editBanner => 'Edit Banner';

  @override
  String get updateAd => 'Update Ad';

  @override
  String get updateBanner => 'Update Banner';

  @override
  String get adTitle => 'Ad Title';

  @override
  String get adDescription => 'Ad Description';

  @override
  String get deepLink => 'Deep Link';

  @override
  String get priority => 'Priority';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get adAddedSuccessfully => 'Ad added successfully';

  @override
  String get adUpdatedSuccessfully => 'Ad updated successfully';

  @override
  String get adDeletedSuccessfully => 'Ad deleted successfully';

  @override
  String get creatingAd => 'Creating ad...';

  @override
  String get updatingAd => 'Updating ad...';

  @override
  String get deleteAd => 'Delete Ad';

  @override
  String get deleteBanner => 'Delete Banner';

  @override
  String get areYouSureDeleteAd => 'Are you sure you want to delete';

  @override
  String get areYouSureDeleteBanner => 'Are you sure you want to delete';

  @override
  String get ad => 'ad';

  @override
  String get banner => 'banner';

  @override
  String get noStartupAds => 'No Startup Ads';

  @override
  String get noBannerAds => 'No Banner Ads';

  @override
  String get startByAddingYourFirstStartupAd =>
      'Start by adding your first startup ad';

  @override
  String get startByAddingYourFirstBannerAd =>
      'Start by adding your first banner ad';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get adminAccess => 'Admin Access';

  @override
  String get adminAccessDescription =>
      'You have full administrative access to all platform features.\n\nNo authentication required.';

  @override
  String get totalRestaurants => 'Restaurants';

  @override
  String get totalOrders => 'Orders';

  @override
  String get totalUsers => 'Users';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get drivers => 'Drivers';

  @override
  String get users => 'Users';

  @override
  String get analytics => 'Analytics';

  @override
  String get orders => 'Orders';

  @override
  String get settings => 'Settings';

  @override
  String get ok => 'OK';

  @override
  String get info => 'Info';

  @override
  String get all => 'All';

  @override
  String get minutes => 'minutes';

  @override
  String get free => 'Free';

  @override
  String get viewCart => 'View Cart';

  @override
  String addProductsWorth(String amount) {
    return 'Add products worth $amount to start the order';
  }

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterEmailForPasswordReset =>
      'Enter your email to receive a password reset link';

  @override
  String get passwordResetEmailSent =>
      'Password reset link has been sent to your email';

  @override
  String get send => 'Send';

  @override
  String get cannotOpenPhoneApp => 'Cannot open phone app';

  @override
  String get errorCalling => 'Error occurred while calling';

  @override
  String get calling => 'Calling';

  @override
  String get orderPlacedSuccessfully => 'Order placed successfully';

  @override
  String get pleaseLoginToPlaceOrder => 'Please log in to place an order';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get enterDeliveryAddress => 'Enter your delivery address';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get orderNotes => 'Order Notes (Optional)';

  @override
  String get notes => 'Notes';

  @override
  String get anySpecialInstructions => 'Any special instructions?';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get cartIsEmpty => 'Cart is empty';

  @override
  String get startAddingProductsFromRestaurants =>
      'Start adding products from restaurants';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get loadingOrder => 'Loading order...';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get areYouSureCancelOrder =>
      'Are you sure you want to cancel this order?';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get no => 'No';

  @override
  String get orderCancelledSuccessfully => 'Order cancelled successfully';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get orderTime => 'Order Time';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get driverInformation => 'Driver Information';

  @override
  String get driver => 'Driver';

  @override
  String get socialLoginComingSoon => 'Social login coming soon';

  @override
  String marketProductAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get failedToAddProductToCart => 'Failed to add product to cart';

  @override
  String get marketProductsOrderingComingSoon =>
      'Market products ordering coming soon';

  @override
  String get myOrders => 'My Orders';

  @override
  String get viewDetails => 'View Details';

  @override
  String get checkout => 'Checkout';

  @override
  String get placingOrder => 'Placing your order...';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get deliveryInformation => 'Delivery Information';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get profile => 'Profile';

  @override
  String get myProfile => 'My Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get logout => 'Logout';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get login => 'Login';
}
