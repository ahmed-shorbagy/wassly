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
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get deliverTo => 'Deliver to';

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
  String get restaurantCreatedSuccessfully => 'Restaurant created successfully';

  @override
  String get provideCredentialsToRestaurant =>
      'Please provide these credentials to the restaurant:';

  @override
  String get restaurantCanChangePasswordAfterLogin =>
      'The restaurant can change their password after their first login.';

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
  String get productOptions => 'Product Options';

  @override
  String get addGroup => 'Add Group';

  @override
  String get noOptionsAdded => 'No options added yet';

  @override
  String get groupName => 'Group Name';

  @override
  String get multipleSelections => 'Multiple Selections';

  @override
  String get addOption => 'Add Option';

  @override
  String get optionName => 'Option Name';

  @override
  String get price => 'Price';

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
  String get restaurantInformation => 'Restaurant Information';

  @override
  String get restaurantStatus => 'Restaurant Status';

  @override
  String get restaurantIsOpen => 'Restaurant is open';

  @override
  String get restaurantIsClosed => 'Restaurant is closed';

  @override
  String get manageProducts => 'Manage Products';

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
  String get navHome => 'Home';

  @override
  String get navOrders => 'My Orders';

  @override
  String get navProfile => 'My Profile';

  @override
  String get navPay => 'Pay';

  @override
  String get remove => 'Remove';

  @override
  String get quantity => 'Quantity';

  @override
  String itemAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get areYouSureClearCart => 'Are you sure you want to clear the cart?';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get tax => 'Tax';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get markets => 'Markets';

  @override
  String get restaurantsAndMarkets => 'Restaurants & Markets';

  @override
  String get nearbyRestaurants => 'Nearby Restaurants';

  @override
  String get topRatedBrands => 'Top Rated Brands';

  @override
  String get newOnWassly => 'New & Trending';

  @override
  String get nearbyFavorites => 'Nearby Favorites';

  @override
  String get viewAll => 'View All';

  @override
  String get specialOffers => 'Exclusive Deals';

  @override
  String get noRestaurants => 'No Restaurants';

  @override
  String get noRestaurantsAvailable => 'No restaurants available at the moment';

  @override
  String get noRestaurantsAvailableMessage =>
      'Check back later for new restaurants';

  @override
  String get noRestaurantsFound => 'No restaurants found';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

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
  String get allOrders => 'All Orders';

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
  String moreItems(int count) {
    return '+ $count more items';
  }

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
  String get orderPending => 'Pending';

  @override
  String get orderPreparing => 'Preparing';

  @override
  String get orderReady => 'Ready';

  @override
  String get orderPickedUp => 'On the Way';

  @override
  String get orderDelivered => 'Delivered';

  @override
  String get orderCancelled => 'Cancelled';

  @override
  String get orderPlaced => 'Order Placed';

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
  String get marketOrders => 'Market Orders';

  @override
  String get marketProducts => 'Market Products';

  @override
  String get selectPartnerTypeTitle => 'How do you want to partner with us?';

  @override
  String get driverSubtitle => 'Deliver orders and earn money';

  @override
  String get noMarketProducts => 'No Market Products';

  @override
  String get startByAddingYourFirstMarketProduct =>
      'Start by adding your first market product';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get searchRestaurants => 'Search restaurants...';

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
  String get bannerLocation => 'Banner Location';

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
  String get ok => 'OK';

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
  String get pleaseEnterValidPhoneNumber => 'Please enter a valid phone number';

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
  String get paymentMethod => 'Payment Method';

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

  @override
  String get welcome => 'Welcome';

  @override
  String get loginToContinue => 'Log in to continue';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signup => 'Sign Up';

  @override
  String get or => 'or';

  @override
  String get foodCategories => 'Food Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get updateCategory => 'Update Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get pleaseEnterCategoryName => 'Please enter category name';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get categoryCreatedSuccessfully => 'Category created successfully';

  @override
  String get categoryUpdatedSuccessfully => 'Category updated successfully';

  @override
  String get categoryNotFound => 'Category not found';

  @override
  String get creatingCategory => 'Creating category...';

  @override
  String get updatingCategory => 'Updating category...';

  @override
  String areYouSureDeleteCategory(String name) {
    return 'Are you sure you want to delete the category \"$name\"?';
  }

  @override
  String get displayOrder => 'Display Order';

  @override
  String get currency => 'EGP';

  @override
  String get currencySymbol => 'ج.م';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get groceries => 'Groceries';

  @override
  String get healthAndBeauty => 'Health & Beauty';

  @override
  String get pickup => 'Pickup';

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String get orderNowForDeliveryToday =>
      'Order now for your order to arrive today at 10:00';

  @override
  String get schedule => 'Schedule';

  @override
  String get sortBy => 'Sort By';

  @override
  String get relevance => 'Most Relevant';

  @override
  String get highestRating => 'Highest Rating';

  @override
  String get fastestDelivery => 'Fastest Delivery';

  @override
  String get lowestPrice => 'Lowest Price';

  @override
  String get selectDeliveryAddress => 'Select Delivery Address';

  @override
  String get defaultAddress => 'Default';

  @override
  String get failedToLoadRestaurantData => 'Failed to load restaurant data';

  @override
  String get burger => 'Burger';

  @override
  String get pizza => 'Pizza';

  @override
  String get noodles => 'Noodles';

  @override
  String get meat => 'Meat';

  @override
  String get min => 'min';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get pleaseLoginToContinue => 'Please login to continue';

  @override
  String get invalidProduct => 'Invalid product. Please try again.';

  @override
  String get quantityMustBeGreaterThanZero =>
      'Quantity must be greater than zero';

  @override
  String get cannotAddDifferentRestaurant =>
      'Cannot add products from different restaurants. Please clear cart first.';

  @override
  String get failedToAddItemToCart =>
      'Failed to add item to cart. Please try again.';

  @override
  String productAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get items => 'items';

  @override
  String get nA => 'N/A';

  @override
  String get creatingDriver => 'Creating driver...';

  @override
  String get personalPhoto => 'Personal Photo';

  @override
  String get pleaseEnterFullName => 'Please enter full name';

  @override
  String get off => 'OFF';

  @override
  String get specialOffer => 'Special Offer';

  @override
  String get discount => 'Discount';

  @override
  String get discountPercentage => 'Discount Percentage';

  @override
  String get discountDescription => 'Discount Description';

  @override
  String get discountStartDate => 'Discount Start Date';

  @override
  String get discountEndDate => 'Discount End Date';

  @override
  String get enableDiscount => 'Enable Discount';

  @override
  String get disableDiscount => 'Disable Discount';

  @override
  String get activeDiscount => 'Active Discount';

  @override
  String get discountUpdatedSuccessfully => 'Discount updated successfully';

  @override
  String get updatedSuccessfully => 'updated successfully';

  @override
  String get save => 'Save';

  @override
  String get pleaseEnterDeliveryFee => 'Please enter delivery fee';

  @override
  String get pleaseEnterMinimumOrderAmount =>
      'Please enter minimum order amount';

  @override
  String get pleaseEnterDeliveryTime => 'Please enter delivery time';

  @override
  String get createDriver => 'Create Driver';

  @override
  String get pleaseSelectPersonalImage => 'Please select personal image';

  @override
  String get pleaseSelectDriverLicense => 'Please select driver license';

  @override
  String get pleaseSelectVehicleLicense => 'Please select vehicle license';

  @override
  String get pleaseSelectVehiclePhoto => 'Please select vehicle photo';

  @override
  String get licenseInformation => 'License Information';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get pleaseSelectVehicleType => 'Please select vehicle type';

  @override
  String get vehicleModel => 'Vehicle Model';

  @override
  String get pleaseEnterVehicleModel => 'Please enter vehicle model';

  @override
  String get vehicleColor => 'Vehicle Color';

  @override
  String get pleaseEnterVehicleColor => 'Please enter vehicle color';

  @override
  String get vehiclePlateNumber => 'Vehicle Plate Number';

  @override
  String get pleaseEnterVehiclePlateNumber =>
      'Please enter vehicle plate number';

  @override
  String get driverLicense => 'Driver License';

  @override
  String get vehicleLicense => 'Vehicle License';

  @override
  String get vehiclePhoto => 'Vehicle Photo';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get driverCreatedSuccessfully => 'Driver Created Successfully';

  @override
  String get pleaseProvideTheseCredentials =>
      'Please provide these credentials to the driver:';

  @override
  String get noteDriverCanChangePassword =>
      'Note: Driver can change password after first login.';

  @override
  String get tapToUploadImage => 'Tap to upload image';

  @override
  String get marketProductCategories => 'Market Categories';

  @override
  String get market => 'Market';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fruits => 'Fruits';

  @override
  String get snacks => 'Snacks';

  @override
  String get dairy => 'Dairy';

  @override
  String get bakery => 'Bakery';

  @override
  String get frozen => 'Frozen';

  @override
  String get canned => 'Canned';

  @override
  String get spices => 'Spices';

  @override
  String get cleaning => 'Cleaning';

  @override
  String get personalCare => 'Personal Care';

  @override
  String get fish => 'Fish';

  @override
  String get dairyProducts => 'Dairy Products';

  @override
  String get cheese => 'Cheese';

  @override
  String get eggs => 'Eggs';

  @override
  String get softDrinks => 'Soft Drinks';

  @override
  String get water => 'Water';

  @override
  String get juices => 'Juices';

  @override
  String get pastaAndRice => 'Pasta and Rice';

  @override
  String get chipsAndSnacks => 'Chips and Snacks';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get addressBook => 'Address Book';

  @override
  String get addAddress => 'Add Address';

  @override
  String get noAddressesFound => 'No addresses found';

  @override
  String get addYourFirstAddress => 'Add your first address to get started';

  @override
  String get deleteAddress => 'Delete Address';

  @override
  String get deleteAddressConfirm =>
      'Are you sure you want to delete this address?';

  @override
  String get offers => 'Offers';

  @override
  String get fruitsVegetables => 'Fruits & Vegetables';

  @override
  String get poultryMeatSeafood => 'Poultry, Meat & Seafood';

  @override
  String get freshFood => 'Fresh Food';

  @override
  String get readyToEat => 'Ready to Eat';

  @override
  String get frozenFood => 'Frozen Food';

  @override
  String get dairyAndEggs => 'Dairy & Eggs';

  @override
  String get iceCream => 'Ice Cream';

  @override
  String get milk => 'Milk';

  @override
  String get beauty => 'Beauty';

  @override
  String get cookingAndBaking => 'Cooking & Baking';

  @override
  String get coffeeAndTea => 'Coffee & Tea';

  @override
  String get pharmacy => 'Pharmacies';

  @override
  String get cakeAndCoffee => 'Cake & Coffee';

  @override
  String get vegetablesAndFruits => 'Vegetables & Fruits';

  @override
  String get tissuesAndBags => 'Tissues & Bags';

  @override
  String get cannedFood => 'Canned Food';

  @override
  String get breakfastFood => 'Breakfast Food';

  @override
  String get babyCorner => 'Baby Corner';

  @override
  String get cleaningAndLaundry => 'Cleaning & Laundry';

  @override
  String get specialDiet => 'Special Diet';

  @override
  String get spicesAndSauces => 'Spices & Sauces';

  @override
  String get shopByCategory => 'Shop by Category';

  @override
  String get mostSoldProducts => 'Most Sold Products';

  @override
  String get promotionalImages => 'Promotional Images';

  @override
  String get addPromotionalImage => 'Add Promotional Image';

  @override
  String get editPromotionalImage => 'Edit Promotional Image';

  @override
  String get deletePromotionalImage => 'Delete Promotional Image';

  @override
  String get areYouSureDeletePromotionalImage =>
      'Are you sure you want to delete the promotional image';

  @override
  String get promotionalImage => 'Promotional Image';

  @override
  String get noPromotionalImages => 'No Promotional Images';

  @override
  String get startByAddingYourFirstPromotionalImage =>
      'Start by adding your first promotional image';

  @override
  String get tapToChangeImage => 'Tap to change image';

  @override
  String get title => 'Title';

  @override
  String get optionalTitleHint => 'Enter optional title';

  @override
  String get subtitle => 'Subtitle';

  @override
  String get optionalSubtitleHint => 'Enter optional subtitle';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get exploreOurRichWorld => 'Explore our rich world';

  @override
  String get pickupFromRestaurant => 'Pickup from Restaurant';

  @override
  String get deliveryMode => 'Delivery Mode';

  @override
  String get delivery => 'Delivery';

  @override
  String get startNewOrder => 'Start New Order';

  @override
  String get clearCartConfirmation =>
      'You have items from another restaurant. Start a new order to clear the cart?';

  @override
  String get newOrder => 'New Order';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get subject => 'Subject';

  @override
  String get submit => 'Submit';

  @override
  String get supportChat => 'Support Chat';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get fieldRequired => 'Required';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get retry => 'Retry';

  @override
  String get management => 'Management';

  @override
  String get catalog => 'Catalog';

  @override
  String get marketing => 'Marketing';

  @override
  String get system => 'System';

  @override
  String get restaurantCategories => 'Restaurant Categories';

  @override
  String get articles => 'Articles';

  @override
  String get proTip => 'Pro Tip';

  @override
  String get proTipDescription =>
      'Use the menu (top-left) to access all management tools.';

  @override
  String get selectOptionFromDrawer => 'Select an option from the drawer';

  @override
  String get joinAsPartner => 'Join as Partner';

  @override
  String get startGrowingWithWassly => 'Start growing with Wassly';

  @override
  String get fullNameStoreName => 'Full Name / Store Name';

  @override
  String get businessDocuments => 'Business Documents';

  @override
  String get storeLogoOptional => 'Store Logo / Cover (Optional)';

  @override
  String get vehicleInfo => 'Vehicle Info';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get car => 'Car';

  @override
  String get bicycle => 'Bicycle';

  @override
  String get signUpAsPartner => 'Sign Up as Partner';

  @override
  String get pleaseUploadAllDriverDocuments =>
      'Please upload all required driver documents';

  @override
  String get pleaseUploadCommercialRegistration =>
      'Please upload commercial registration photo';

  @override
  String get marketRegisteredSuccessfully => 'Market registered successfully!';

  @override
  String get driverRegisteredWaitingApproval =>
      'Driver registered successfully! Please wait for admin approval.';

  @override
  String get photoAttached => 'Photo Attached';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get driverDocuments => 'Driver Documents';

  @override
  String get newAccount => 'New Account';

  @override
  String get joinWasslyNow => 'Join Wassly Now';

  @override
  String get discoverWassly => 'Discover Wassly';

  @override
  String get restaurantDashboardTitle => 'Restaurant Dashboard';

  @override
  String get driverDashboardTitle => 'Driver Dashboard';

  @override
  String get marketDashboardTitle => 'Market Dashboard';

  @override
  String welcomeName(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get manageRestaurantSubtitle =>
      'Manage your restaurant orders and menu';

  @override
  String get manageMarketSubtitle => 'Monitor your sales and inventory';

  @override
  String get welcomeToRestaurantDashboard => 'Welcome to Restaurant Dashboard';

  @override
  String get welcomeToMarketDashboard => 'Welcome to Market Dashboard';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get viewOrders => 'View Orders';

  @override
  String get restaurantSettings => 'Restaurant Settings';

  @override
  String get marketSettings => 'Market Settings';

  @override
  String get myRestaurant => 'My Restaurant';

  @override
  String get myMarket => 'My Market';

  @override
  String get myMarketLabel => 'My Market';

  @override
  String newPartnerType(String type) {
    return 'New $type';
  }

  @override
  String get signupAddress => 'Signup Address';

  @override
  String get continueText => 'Continue';

  @override
  String get completeSetup => 'Complete Setup';

  @override
  String get restaurantImage => 'Restaurant Image';

  @override
  String get contactAndLocation => 'Contact & Location';

  @override
  String get accountPassword => 'Account Password';

  @override
  String get tellUsAboutRestaurant => 'Tell us about your restaurant';

  @override
  String get restaurantNameAsterisk => 'Restaurant Name *';

  @override
  String get restaurantNameHint => 'e.g., Mario\'s Pizza';

  @override
  String get nameAtLeast3Chars => 'Name must be at least 3 characters';

  @override
  String get descriptionAsterisk => 'Description *';

  @override
  String get descriptionHint => 'Describe your cuisine and specialties';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get descriptionAtLeast10Chars =>
      'Description must be at least 10 characters';

  @override
  String get whatCuisineDoYouServe => 'What type of cuisine do you serve?';

  @override
  String get noCategoriesSelected => 'No categories selected';

  @override
  String get select => 'Select';

  @override
  String get selectAtLeastOneCategoryHint =>
      'Select at least one category to help customers find your restaurant';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get addBeautifulRestaurantImage =>
      'Add a beautiful image of your restaurant';

  @override
  String get recommendedImageSize => 'Recommended: 1200x600px';

  @override
  String get imageSelected => 'Image selected';

  @override
  String get howReachYou => 'How can customers reach you?';

  @override
  String get emailAddressAsterisk => 'Email Address *';

  @override
  String get restaurantEmailHint => 'restaurant@example.com';

  @override
  String get phoneNumberAsterisk => 'Phone Number *';

  @override
  String get phoneHint => '+1 (555) 123-4567';

  @override
  String get fullAddressAsterisk => 'Full Address *';

  @override
  String get addressHint => '123 Main St, City, State, ZIP';

  @override
  String get completeAddressRequired => 'Please enter a complete address';

  @override
  String get updateDetailsFromProfileHint =>
      'You can update these details anytime from your profile settings.';

  @override
  String get createPasswordForRestaurant =>
      'Create a password for your restaurant account';

  @override
  String get passwordAsterisk => 'Password *';

  @override
  String get passwordHint => 'Enter a secure password';

  @override
  String get confirmPasswordAsterisk => 'Confirm Password *';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get passwordSecureHint =>
      'This password will be used to log into your restaurant account. Make sure to keep it secure.';

  @override
  String get imageSelectedSuccessfully => 'Image selected successfully';

  @override
  String get myProducts => 'My Products';

  @override
  String get availabilityUpdated => 'Availability updated';

  @override
  String get addFirstProduct => 'Add First Product';

  @override
  String areYouSureDeleteProductWithName(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get restaurantIdNotFound => 'Restaurant ID not found';

  @override
  String get error => 'Error';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get refresh => 'Refresh';

  @override
  String get unknownCategory => 'Unknown Category';

  @override
  String get delete => 'Delete';

  @override
  String get discountPercentageHint => 'e.g., 20 for 20%';

  @override
  String get noStartDate => 'No start date';

  @override
  String get noEndDate => 'No end date';

  @override
  String get noTicketsFound => 'No tickets found';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get notProvided => 'Not provided';

  @override
  String get name => 'Name';

  @override
  String get online => 'ONLINE';

  @override
  String get offline => 'OFFLINE';

  @override
  String get statusUpdated => 'Status updated';

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get createMarket => 'Create Market';

  @override
  String get discountOn => 'Discount ON';

  @override
  String get discountOff => 'Discount OFF';

  @override
  String get noMarketsYet => 'No Markets Yet';

  @override
  String get noRestaurantsYet => 'No Restaurants Yet';

  @override
  String get startByCreatingFirstMarket =>
      'Start by creating your first market';

  @override
  String get startByCreatingFirstRestaurant =>
      'Start by creating your first restaurant';

  @override
  String get deleteRestaurant => 'Delete Restaurant';

  @override
  String deleteRestaurantConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone and will also delete all associated products.';
  }

  @override
  String get seedMarketsTitle => 'Seed Markets';

  @override
  String get seedMarketsConfirm =>
      'This will create several default markets for testing. Continue?';

  @override
  String get seedingMarkets => 'Seeding markets...';

  @override
  String get marketsSeededSuccessfully => 'Markets seeded successfully!';

  @override
  String failedToSeedMarkets(String error) {
    return 'Failed to seed markets: $error';
  }

  @override
  String get seed => 'Seed';

  @override
  String get searchHint => 'Search...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String categoriesLabel(String categories) {
    return 'Categories: $categories';
  }

  @override
  String get noCategories => 'No categories';

  @override
  String get youAreOnline => 'You are Online';

  @override
  String get youAreOffline => 'You are Offline';

  @override
  String get waitingForOrders => 'Waiting for orders...';

  @override
  String get goOnlineToAcceptOrders => 'Go online to accept orders';

  @override
  String get activeOrder => 'Active Order';

  @override
  String get availableOrders => 'Available Orders';

  @override
  String get scanningArea => 'Scanning area...';

  @override
  String get noOrdersNearby => 'No orders nearby yet';

  @override
  String get earnings => 'Earnings';

  @override
  String get deliveries => 'Deliveries';

  @override
  String get history => 'History';

  @override
  String get toCustomer => 'To Customer';

  @override
  String get toRestaurant => 'To Restaurant';

  @override
  String get dropoff => 'Dropoff';

  @override
  String get swipeToComplete => 'Swipe to Complete';

  @override
  String get confirmPickup => 'Confirm Pickup';

  @override
  String get orderAcceptedExclamation => 'Order Accepted!';

  @override
  String get failedToAcceptOrder => 'Failed to accept order';

  @override
  String get orderDeliveredSuccessfully => 'Order Delivered! Great job.';

  @override
  String get failedToUpdateStatus => 'Failed to update status';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get loadingRestaurantData => 'Loading restaurant data...';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get pleaseLogin => 'Please login';

  @override
  String get errorScreen => 'Error Screen';

  @override
  String get addArticle => 'Add Article';

  @override
  String get editArticle => 'Edit Article';

  @override
  String get articleCreated => 'Article created successfully';

  @override
  String get failedToUploadImage => 'Failed to upload image';

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get noDriversYet => 'No drivers yet';

  @override
  String get tapToAddImage => 'Tap to add image';

  @override
  String get titleLabel => 'Title *';

  @override
  String get titleHint => 'Enter title';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get contentLabel => 'Content *';

  @override
  String get contentHint => 'Enter content';

  @override
  String get contentRequired => 'Content is required';

  @override
  String get authorLabel => 'Author';

  @override
  String get authorHint => 'Enter author name';

  @override
  String get publishArticle => 'Publish Article';

  @override
  String get articleVisible => 'Article will be visible to users';

  @override
  String get articleSavedAsDraft => 'Article will be saved as draft';

  @override
  String get saveArticle => 'Save Article';

  @override
  String get userManagement => 'User Management';

  @override
  String get driverManagement => 'Driver Management';

  @override
  String get searchUsersHint => 'Search users...';

  @override
  String get searchDriversHint => 'Search drivers...';

  @override
  String get searchOrdersHint => 'Search orders...';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get noDriversFound => 'No drivers found';

  @override
  String get addDriver => 'Add Driver';

  @override
  String get addFirstDriver => 'Add First Driver';

  @override
  String get driverDeletedSuccessfully => 'Driver deleted successfully';

  @override
  String get seedMarkets => 'Seed Markets';

  @override
  String get restaurantManagement => 'Restaurant Management';

  @override
  String get reviews => 'Reviews';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String get orderManagement => 'Order Management';

  @override
  String get editDriver => 'Edit Driver';

  @override
  String get deleteDriver => 'Delete Driver';

  @override
  String get driverNotFound => 'Driver not found';

  @override
  String get noRecentOrders => 'No recent orders';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get appVersion => 'App Version';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get appSettings => 'App Settings';

  @override
  String get about => 'About';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get adminPanelSubtitle => 'Full access without authentication';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get marketCategory => 'Market Category';

  @override
  String get marketName => 'Market Name';

  @override
  String get tapToUploadMarketImage => 'Tap to upload market image';

  @override
  String get creatingMarket => 'Creating Market...';

  @override
  String get marketCreatedSuccessfully => 'Market created successfully';

  @override
  String get provideCredentialsToMarket =>
      'Please provide these credentials to the market owner:';

  @override
  String get marketCanChangePasswordAfterLogin =>
      'The market owner can change their password after logging in.';

  @override
  String get areYouSureDeleteCategoryGeneric =>
      'Are you sure you want to delete this category?';

  @override
  String totalAmountLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get pickUp => 'Pick Up';

  @override
  String get markDelivered => 'Mark Delivered';

  @override
  String get orderPickedUpSuccess => 'Order picked up';

  @override
  String get orderDeliveredSuccess => 'Order delivered';

  @override
  String get deleteArticle => 'Delete Article';

  @override
  String get updateArticle => 'Update Article';

  @override
  String get driverAccountStatus => 'Driver account status';

  @override
  String get driverUpdatedSuccessfully => 'Driver updated successfully';

  @override
  String tapToUpload(String label) {
    return 'Tap to upload $label';
  }

  @override
  String get restaurantAccountStatus => 'Restaurant account status';

  @override
  String get emailLabel => 'Email:';

  @override
  String get passwordLabel => 'Password:';

  @override
  String get selectProductToLink => 'Select a product to link';

  @override
  String get noLinkedProduct => 'No linked product';

  @override
  String get discountImage => 'Discount Image';

  @override
  String get linkedProduct => 'Linked Product';

  @override
  String get tapToUploadDiscountImage => 'Tap to upload discount image';

  @override
  String get unknown => 'Unknown';

  @override
  String get picked_up => 'Picked Up';

  @override
  String get customer => 'Customer';

  @override
  String get displayOrderHelper => 'Lower numbers appear first';

  @override
  String get pleaseEnterOrder => 'Please enter order';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get adminRole => 'Administrator';

  @override
  String get restaurantRole => 'Restaurant';

  @override
  String get driverRole => 'Driver';

  @override
  String get customerRole => 'Customer';

  @override
  String get areYouSureDeleteDriver =>
      'Are you sure you want to delete this driver?';

  @override
  String get statusLabel => 'Status';

  @override
  String get updateDriver => 'Update Driver';

  @override
  String get takeBreakOrGoOnline =>
      'Take a break or go online\nto start earning';

  @override
  String estEarnings(String amount, String currency) {
    return 'Est. Earnings: $amount $currency';
  }

  @override
  String get pendingApprovals => 'Pending Approvals';

  @override
  String get totalEarningsToday => 'Total Earnings Today';

  @override
  String get acceptingOrders => 'You are accepting orders';

  @override
  String get currentlyOffline => 'You are currently offline';

  @override
  String get wallet => 'Wallet';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get cashCollected => 'Cash Collected';

  @override
  String get transactions => 'Transactions';

  @override
  String get driverBonusSettings => 'Driver Bonus Settings';

  @override
  String get minMonthlyDeliveries => 'Min Monthly Deliveries';

  @override
  String get bonusAmount => 'Bonus Amount';

  @override
  String get distributeMonthlyBonuses => 'Distribute Last Month\'s Bonuses';

  @override
  String get bonusDistributionSuccess => 'Bonuses distributed successfully';

  @override
  String get bonusEnabled => 'Enable Bonus Feature';

  @override
  String get bonusTarget => 'Bonus Target';

  @override
  String ordersDeliveriedThisMonth(int count) {
    return '$count orders delivered this month';
  }

  @override
  String bonusProgress(int current, int target) {
    return 'Bonus Progress: $current/$target orders';
  }

  @override
  String reachTargetForBonus(int target, String amount) {
    return 'Reach $target orders this month for $amount bonus!';
  }

  @override
  String get confirm => 'Confirm';
}
