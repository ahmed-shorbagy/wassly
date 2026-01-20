// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get createRestaurant => 'إنشاء مطعم';

  @override
  String get restaurantSetup => 'إعداد المطعم';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get restaurantName => 'اسم المطعم';

  @override
  String get description => 'الوصف';

  @override
  String get pleaseEnterRestaurantName => 'الرجاء إدخال اسم المطعم';

  @override
  String get pleaseEnterDescription => 'الرجاء إدخال الوصف';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get commercialRegistration => 'السجل التجاري';

  @override
  String get commercialRegistrationArabic => 'السجل التجاري';

  @override
  String get optional => 'اختياري';

  @override
  String get pleaseEnterPhoneNumber => 'الرجاء إدخال رقم الهاتف';

  @override
  String get pleaseEnterEmail => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get location => 'الموقع';

  @override
  String get address => 'العنوان';

  @override
  String get pleaseEnterAddress => 'الرجاء إدخال العنوان';

  @override
  String get tapToSelectLocationOnMap => 'اضغط لاختيار الموقع على الخريطة';

  @override
  String locationSet(String latitude, String longitude) {
    return 'الموقع: $latitude, $longitude';
  }

  @override
  String get locationSetToCairo => 'تم تعيين الموقع إلى القاهرة، مصر';

  @override
  String get categories => 'الفئات';

  @override
  String get selectCategories => 'اختر الفئات';

  @override
  String get tapToSelectCategories => 'اضغط لاختيار الفئات';

  @override
  String get selectedCategories => 'الفئات المختارة:';

  @override
  String get done => 'تم';

  @override
  String get edit => 'تعديل';

  @override
  String get deliverySettings => 'إعدادات التوصيل';

  @override
  String get minOrder => 'الحد الأدنى للطلب (ريال)';

  @override
  String get estimatedDeliveryTime => 'وقت التوصيل المتوقع (دقيقة)';

  @override
  String get required => 'مطلوب';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String get tapToUploadRestaurantImage => 'اضغط لتحميل صورة المطعم';

  @override
  String get change => 'تغيير';

  @override
  String get pleaseSelectImage => 'الرجاء اختيار صورة المطعم';

  @override
  String get pleaseSelectLocation => 'الرجاء اختيار الموقع';

  @override
  String get pleaseSelectAtLeastOneCategory =>
      'الرجاء اختيار فئة واحدة على الأقل';

  @override
  String get creatingRestaurant => 'جاري إنشاء المطعم...';

  @override
  String get restaurantCreatedSuccessfully => 'تم إنشاء المطعم بنجاح!';

  @override
  String get provideCredentialsToRestaurant =>
      'يرجى توفير هذه البيانات للمالك:';

  @override
  String get restaurantCanChangePasswordAfterLogin =>
      'ملاحظة: يمكن للمالك تغيير كلمة المرور بعد أول تسجيل دخول.';

  @override
  String failedToPickImage(String error) {
    return 'فشل في اختيار الصورة: $error';
  }

  @override
  String get fastFood => 'وجبات سريعة';

  @override
  String get italian => 'إيطالي';

  @override
  String get chinese => 'صيني';

  @override
  String get indian => 'هندي';

  @override
  String get mexican => 'مكسيكي';

  @override
  String get japanese => 'ياباني';

  @override
  String get thai => 'تايلندي';

  @override
  String get mediterranean => 'بحر متوسطي';

  @override
  String get american => 'أمريكي';

  @override
  String get vegetarian => 'نباتي';

  @override
  String get vegan => 'نباتي صرف';

  @override
  String get desserts => 'حلويات';

  @override
  String get beverages => 'مشروبات';

  @override
  String get healthy => 'صحي';

  @override
  String get bbq => 'مشاوي';

  @override
  String get seafood => 'مأكولات بحرية';

  @override
  String get arabic => 'عربي';

  @override
  String get egyptian => 'مصري';

  @override
  String get lebanese => 'لبناني';

  @override
  String get syrian => 'سوري';

  @override
  String get palestinian => 'فلسطيني';

  @override
  String get jordanian => 'أردني';

  @override
  String get saudi => 'سعودي';

  @override
  String get emirati => 'إماراتي';

  @override
  String get gulf => 'خليجي';

  @override
  String get moroccan => 'مغربي';

  @override
  String get tunisian => 'تونسي';

  @override
  String get algerian => 'جزائري';

  @override
  String get yemeni => 'يمني';

  @override
  String get iraqi => 'عراقي';

  @override
  String get grilledMeat => 'لحوم مشوية';

  @override
  String get kebabs => 'كباب';

  @override
  String get shawarma => 'شاورما';

  @override
  String get falafel => 'فلافل';

  @override
  String get hummus => 'حمص';

  @override
  String get mezze => 'مقبلات';

  @override
  String get foul => 'فول';

  @override
  String get taameya => 'طعمية';

  @override
  String get koshary => 'كشري';

  @override
  String get mansaf => 'منسف';

  @override
  String get mansi => 'منسي';

  @override
  String get mandi => 'مندي';

  @override
  String get kabsa => 'كبسة';

  @override
  String get majboos => 'مجبوس';

  @override
  String get maqluba => 'مقلوبة';

  @override
  String get musakhan => 'مسخن';

  @override
  String get mansafJordanian => 'منسف أردني';

  @override
  String get waraqEnab => 'ورق عنب';

  @override
  String get mahshi => 'محشي';

  @override
  String get kofta => 'كفتة';

  @override
  String get samosa => 'سمبوسة';

  @override
  String get knafeh => 'كنافة';

  @override
  String get baklava => 'بقلاوة';

  @override
  String get biryani => 'بيرياني';

  @override
  String get bakedGoods => 'مخبوزات';

  @override
  String get orientalSweets => 'حلويات شرقية';

  @override
  String get commercialRegistrationPhoto => 'صورة السجل التجاري';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get openCamera => 'فتح الكاميرا';

  @override
  String get pleaseTakeCommercialRegistrationPhoto =>
      'الرجاء التقاط صورة السجل التجاري';

  @override
  String get productManagement => 'إدارة المنتجات';

  @override
  String get products => 'المنتجات';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل منتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get productDescription => 'وصف المنتج';

  @override
  String get productPrice => 'سعر المنتج';

  @override
  String get productCategory => 'فئة المنتج';

  @override
  String get productImage => 'صورة المنتج';

  @override
  String get productAvailable => 'متوفر';

  @override
  String get productUnavailable => 'غير متوفر';

  @override
  String get pleaseEnterProductName => 'الرجاء إدخال اسم المنتج';

  @override
  String get pleaseEnterProductDescription => 'الرجاء إدخال وصف المنتج';

  @override
  String get pleaseEnterProductPrice => 'الرجاء إدخال سعر المنتج';

  @override
  String get pleaseSelectProductCategory => 'الرجاء اختيار فئة المنتج';

  @override
  String get pleaseSelectProductImage => 'الرجاء اختيار صورة المنتج';

  @override
  String get productAddedSuccessfully => 'تم إضافة المنتج بنجاح';

  @override
  String get productUpdatedSuccessfully => 'تم تحديث المنتج بنجاح';

  @override
  String get productDeletedSuccessfully => 'تم حذف المنتج بنجاح';

  @override
  String get creatingProduct => 'جاري إضافة المنتج...';

  @override
  String get updatingProduct => 'جاري تحديث المنتج...';

  @override
  String get deletingProduct => 'جاري حذف المنتج...';

  @override
  String get areYouSureDeleteProduct => 'هل أنت متأكد من حذف هذا المنتج؟';

  @override
  String get noProductsYet => 'لا توجد منتجات حتى الآن';

  @override
  String get startByAddingYourFirstProduct => 'ابدأ بإضافة منتجك الأول';

  @override
  String get selectRestaurantFirst => 'الرجاء اختيار مطعم أولاً';

  @override
  String get restaurantProducts => 'منتجات المطعم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get pleaseEnterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get pleaseConfirmPassword => 'الرجاء تأكيد كلمة المرور';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get passwordUpdatedSuccessfully => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get editRestaurant => 'تعديل المطعم';

  @override
  String get restaurantInformation => 'معلومات المطعم';

  @override
  String get restaurantStatus => 'حالة المطعم';

  @override
  String get restaurantIsOpen => 'المطعم مفتوح';

  @override
  String get restaurantIsClosed => 'المطعم مغلق';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get updateRestaurant => 'تحديث المطعم';

  @override
  String get restaurantUpdatedSuccessfully => 'تم تحديث المطعم بنجاح';

  @override
  String get updatingRestaurant => 'جاري تحديث المطعم...';

  @override
  String get restaurantNotFound => 'لم يتم العثور على المطعم';

  @override
  String get back => 'رجوع';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get leavePasswordEmptyToKeepCurrent =>
      'اترك كلمة المرور فارغة للاحتفاظ بالكلمة الحالية';

  @override
  String get cart => 'السلة';

  @override
  String get cartEmpty => 'السلة فارغة';

  @override
  String get browseRestaurants => 'تصفح المطاعم';

  @override
  String get total => 'المجموع';

  @override
  String get proceedToCheckout => 'إتمام الطلب';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get navPay => 'الدفع';

  @override
  String get remove => 'حذف';

  @override
  String get quantity => 'الكمية';

  @override
  String itemAddedToCart(String productName) {
    return 'تم إضافة $productName إلى السلة';
  }

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get areYouSureClearCart => 'هل أنت متأكد من إفراغ السلة؟';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get deliveryFee => 'رسوم التوصيل (ريال)';

  @override
  String get tax => 'الضريبة';

  @override
  String get grandTotal => 'المجموع الكلي';

  @override
  String get restaurants => 'المطاعم';

  @override
  String get nearbyRestaurants => 'مطاعم قريبة منك';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get specialOffers => 'عروض خاصة';

  @override
  String get noRestaurants => 'لا توجد مطاعم';

  @override
  String get noRestaurantsAvailable => 'لا توجد مطاعم متاحة حالياً';

  @override
  String get noRestaurantsAvailableMessage =>
      'تحقق لاحقاً للحصول على مطاعم جديدة';

  @override
  String get noRestaurantsFound => 'لم يتم العثور على مطاعم';

  @override
  String get tryDifferentSearchTerm => 'جرب مصطلح بحث مختلف';

  @override
  String get exitApp => 'الخروج';

  @override
  String get exitAppConfirmation => 'هل أنت متأكد من الخروج من التطبيق؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get exit => 'خروج';

  @override
  String get unsavedChanges => 'تغييرات غير محفوظة';

  @override
  String get unsavedChangesWarning =>
      'لديك تغييرات غير محفوظة. هل تريد تجاهلها والمتابعة؟';

  @override
  String get discard => 'تجاهل';

  @override
  String get restaurantOrders => 'طلبات المطعم';

  @override
  String get pendingOrders => 'الطلبات المعلقة';

  @override
  String get activeOrders => 'الطلبات النشطة';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get allOrders => 'جميع الطلبات';

  @override
  String get noOrdersYet => 'لا توجد طلبات حتى الآن';

  @override
  String get noPendingOrders => 'لا توجد طلبات معلقة';

  @override
  String get noPendingOrdersMessage => 'لا توجد طلبات معلقة حالياً';

  @override
  String get noActiveOrders => 'لا توجد طلبات نشطة';

  @override
  String get noActiveOrdersMessage => 'لا توجد طلبات نشطة حالياً';

  @override
  String get noOrderHistory => 'لا يوجد سجل طلبات';

  @override
  String get noOrderHistoryMessage => 'سجل الطلبات الخاص بك فارغ';

  @override
  String get orderId => 'رقم الطلب';

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String moreItems(int count) {
    return '+ $count عناصر أخرى';
  }

  @override
  String get pending => 'معلق';

  @override
  String get accepted => 'مقبول';

  @override
  String get preparing => 'قيد التحضير';

  @override
  String get ready => 'جاهز';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get cancelled => 'ملغي';

  @override
  String get orderPending => 'معلق';

  @override
  String get orderPreparing => 'قيد التحضير';

  @override
  String get orderReady => 'جاهز';

  @override
  String get orderPickedUp => 'في الطريق';

  @override
  String get orderDelivered => 'تم التسليم';

  @override
  String get orderCancelled => 'ملغي';

  @override
  String get orderPlaced => 'تم تقديم الطلب';

  @override
  String get reject => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get startPreparing => 'بدء التحضير';

  @override
  String get markAsReady => 'تحديد كجاهز';

  @override
  String get waitingForDriver => 'في انتظار السائق';

  @override
  String get orderAccepted => 'تم قبول الطلب';

  @override
  String get rejectOrder => 'رفض الطلب';

  @override
  String get rejectOrderConfirmation => 'هل أنت متأكد من رفض هذا الطلب؟';

  @override
  String get orderRejected => 'تم رفض الطلب';

  @override
  String get orderStatusUpdated => 'تم تحديث حالة الطلب';

  @override
  String get marketProducts => 'منتجات الماركت';

  @override
  String get noMarketProducts => 'لا توجد منتجات سوق';

  @override
  String get startByAddingYourFirstMarketProduct =>
      'ابدأ بإضافة منتج الماركت الأول';

  @override
  String get searchProducts => 'ابحث عن المنتجات...';

  @override
  String get searchRestaurants => 'ابحث عن مطعم...';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get startupAds => 'إعلانات البداية';

  @override
  String get bannerAds => 'إعلانات البانر';

  @override
  String get addAd => 'إضافة إعلان';

  @override
  String get addStartupAd => 'إضافة إعلان بداية';

  @override
  String get addBanner => 'إضافة بانر';

  @override
  String get editStartupAd => 'تعديل إعلان البداية';

  @override
  String get editBanner => 'تعديل البانر';

  @override
  String get bannerLocation => 'Banner Location';

  @override
  String get updateAd => 'تحديث الإعلان';

  @override
  String get updateBanner => 'تحديث البانر';

  @override
  String get adTitle => 'عنوان الإعلان';

  @override
  String get adDescription => 'وصف الإعلان';

  @override
  String get deepLink => 'رابط عميق';

  @override
  String get priority => 'الأولوية';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get adAddedSuccessfully => 'تم إضافة الإعلان بنجاح';

  @override
  String get adUpdatedSuccessfully => 'تم تحديث الإعلان بنجاح';

  @override
  String get adDeletedSuccessfully => 'تم حذف الإعلان بنجاح';

  @override
  String get creatingAd => 'جاري إنشاء الإعلان...';

  @override
  String get updatingAd => 'جاري تحديث الإعلان...';

  @override
  String get deleteAd => 'حذف الإعلان';

  @override
  String get deleteBanner => 'حذف البانر';

  @override
  String get areYouSureDeleteAd => 'هل أنت متأكد من حذف';

  @override
  String get areYouSureDeleteBanner => 'هل أنت متأكد من حذف';

  @override
  String get ad => 'الإعلان';

  @override
  String get banner => 'البانر';

  @override
  String get noStartupAds => 'لا توجد إعلانات بداية';

  @override
  String get noBannerAds => 'لا توجد إعلانات بانر';

  @override
  String get ok => 'موافق';

  @override
  String get startByAddingYourFirstStartupAd =>
      'ابدأ بإضافة إعلان البداية الأول';

  @override
  String get startByAddingYourFirstBannerAd => 'ابدأ بإضافة إعلان البانر الأول';

  @override
  String get adminDashboard => 'لوحة التحكم';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get adminAccess => 'وصول المدير';

  @override
  String get adminAccessDescription =>
      'لديك وصول كامل لإدارة جميع ميزات المنصة.\n\nلا يتطلب المصادقة.';

  @override
  String get totalRestaurants => 'المطاعم';

  @override
  String get totalOrders => 'الطلبات';

  @override
  String get totalUsers => 'المستخدمين';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get drivers => 'السائقين';

  @override
  String get users => 'المستخدمين';

  @override
  String get analytics => 'التحليلات';

  @override
  String get orders => 'الطلبات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get info => 'معلومات';

  @override
  String get all => 'الكل';

  @override
  String get minutes => 'دقيقة';

  @override
  String get free => 'مجاني';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String addProductsWorth(String amount) {
    return 'أضف منتجات بقيمة $amount لتبدأ الطلب';
  }

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get enterEmailForPasswordReset =>
      'أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور';

  @override
  String get passwordResetEmailSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني';

  @override
  String get send => 'إرسال';

  @override
  String get cannotOpenPhoneApp => 'لا يمكن فتح تطبيق الهاتف';

  @override
  String get errorCalling => 'حدث خطأ أثناء الاتصال';

  @override
  String get calling => 'جاري الاتصال';

  @override
  String get orderPlacedSuccessfully => 'تم تقديم الطلب بنجاح';

  @override
  String get pleaseLoginToPlaceOrder => 'يرجى تسجيل الدخول لتقديم الطلب';

  @override
  String get addressRequired => 'العنوان مطلوب';

  @override
  String get phoneNumberRequired => 'رقم الهاتف مطلوب';

  @override
  String get pleaseEnterValidPhoneNumber => 'الرجاء إدخال رقم هاتف صحيح';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get enterDeliveryAddress => 'أدخل عنوان التوصيل';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get orderNotes => 'ملاحظات الطلب (اختياري)';

  @override
  String get notes => 'ملاحظات';

  @override
  String get anySpecialInstructions => 'أي تعليمات خاصة؟';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get placeOrder => 'تقديم الطلب';

  @override
  String get cartIsEmpty => 'السلة فارغة';

  @override
  String get startAddingProductsFromRestaurants =>
      'ابدأ بإضافة منتجات من المطاعم';

  @override
  String get pleaseLogIn => 'يرجى تسجيل الدخول';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات';

  @override
  String get loadingOrder => 'جاري تحميل الطلب...';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get areYouSureCancelOrder => 'هل أنت متأكد من إلغاء هذا الطلب؟';

  @override
  String get yesCancel => 'نعم، إلغاء';

  @override
  String get no => 'لا';

  @override
  String get orderCancelledSuccessfully => 'تم إلغاء الطلب بنجاح';

  @override
  String get restaurant => 'المطعم';

  @override
  String get orderTime => 'وقت الطلب';

  @override
  String get totalAmount => 'المجموع الكلي';

  @override
  String get driverInformation => 'معلومات السائق';

  @override
  String get driver => 'السائق';

  @override
  String get socialLoginComingSoon =>
      'تسجيل الدخول عبر وسائل التواصل الاجتماعي قريباً';

  @override
  String marketProductAddedToCart(String productName) {
    return 'تم إضافة $productName إلى السلة';
  }

  @override
  String get failedToAddProductToCart => 'فشل إضافة المنتج إلى السلة';

  @override
  String get marketProductsOrderingComingSoon => 'طلب منتجات الماركت قريباً';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get checkout => 'الدفع';

  @override
  String get placingOrder => 'جاري تقديم الطلب...';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get deliveryInformation => 'معلومات التوصيل';

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavoritesYet => 'لا توجد عناصر مفضلة بعد';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phone => 'الهاتف';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get areYouSureLogout => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get updateProfile => 'تحديث الملف الشخصي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcome => 'أهلاً بك';

  @override
  String get loginToContinue => 'سجّل دخولك للمتابعة';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get or => 'أو';

  @override
  String get foodCategories => 'فئات الطعام';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get editCategory => 'تعديل فئة';

  @override
  String get updateCategory => 'تحديث فئة';

  @override
  String get deleteCategory => 'حذف فئة';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get pleaseEnterCategoryName => 'الرجاء إدخال اسم الفئة';

  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';

  @override
  String get categoryCreatedSuccessfully => 'تم إنشاء الفئة بنجاح';

  @override
  String get categoryUpdatedSuccessfully => 'تم تحديث الفئة بنجاح';

  @override
  String get categoryNotFound => 'الفئة غير موجودة';

  @override
  String get creatingCategory => 'جاري إنشاء الفئة...';

  @override
  String get updatingCategory => 'جاري تحديث الفئة...';

  @override
  String areYouSureDeleteCategory(String name) {
    return 'هل أنت متأكد من حذف الفئة \"$name\"؟';
  }

  @override
  String get displayOrder => 'ترتيب العرض';

  @override
  String get currency => 'جنيه مصري';

  @override
  String get currencySymbol => 'ج.م';

  @override
  String get open => 'مفتوح';

  @override
  String get closed => 'مغلق';

  @override
  String get groceries => 'البقالة';

  @override
  String get healthAndBeauty => 'الصحة والجمال';

  @override
  String get pickup => 'الاستلام';

  @override
  String get freeDelivery => 'توصيل مجاني';

  @override
  String get orderNowForDeliveryToday =>
      'اطلب الآن ليصل طلبك اليوم عند الساعة ١٠:٠٠';

  @override
  String get schedule => 'جدولة';

  @override
  String get sortBy => 'رتب حسب';

  @override
  String get relevance => 'الأكثر صلة';

  @override
  String get highestRating => 'الأعلى تقييماً';

  @override
  String get fastestDelivery => 'أسرع توصيل';

  @override
  String get lowestPrice => 'الأقل سعراً';

  @override
  String get selectDeliveryAddress => 'حدد عنوان التوصيل';

  @override
  String get defaultAddress => 'افتراضي';

  @override
  String get failedToLoadRestaurantData => 'فشل تحميل بيانات المطعم';

  @override
  String get burger => 'برجر';

  @override
  String get pizza => 'بيتزا';

  @override
  String get noodles => 'نودلز';

  @override
  String get meat => 'لحوم';

  @override
  String get min => 'د';

  @override
  String get minutesAbbreviation => 'د';

  @override
  String get pleaseLoginToContinue => 'يرجى تسجيل الدخول للمتابعة';

  @override
  String get invalidProduct => 'منتج غير صالح. يرجى المحاولة مرة أخرى.';

  @override
  String get quantityMustBeGreaterThanZero =>
      'يجب أن تكون الكمية أكبر من الصفر';

  @override
  String get cannotAddDifferentRestaurant =>
      'لا يمكن إضافة منتجات من مطاعم مختلفة. يرجى إفراغ السلة أولاً.';

  @override
  String get failedToAddItemToCart =>
      'فشل إضافة المنتج إلى السلة. يرجى المحاولة مرة أخرى.';

  @override
  String productAddedToCart(String productName) {
    return 'تم إضافة $productName إلى السلة';
  }

  @override
  String get items => 'عناصر';

  @override
  String get nA => 'غير متاح';

  @override
  String get creatingDriver => 'جاري إنشاء السائق...';

  @override
  String get personalPhoto => 'الصورة الشخصية';

  @override
  String get pleaseEnterFullName => 'يرجى إدخال الاسم الكامل';

  @override
  String get off => 'خصم';

  @override
  String get specialOffer => 'عرض خاص';

  @override
  String get discount => 'الخصم';

  @override
  String get discountPercentage => 'نسبة الخصم';

  @override
  String get discountDescription => 'وصف الخصم';

  @override
  String get discountStartDate => 'تاريخ بداية الخصم';

  @override
  String get discountEndDate => 'تاريخ نهاية الخصم';

  @override
  String get enableDiscount => 'تفعيل الخصم';

  @override
  String get disableDiscount => 'تعطيل الخصم';

  @override
  String get activeDiscount => 'خصم نشط';

  @override
  String get discountUpdatedSuccessfully => 'تم تحديث الخصم بنجاح';

  @override
  String get updatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String get save => 'حفظ';

  @override
  String get pleaseEnterDeliveryFee => 'يرجى إدخال رسوم التوصيل';

  @override
  String get pleaseEnterMinimumOrderAmount =>
      'يرجى إدخال الحد الأدنى لمبلغ الطلب';

  @override
  String get pleaseEnterDeliveryTime => 'يرجى إدخال وقت التوصيل';

  @override
  String get createDriver => 'إنشاء سائق';

  @override
  String get pleaseSelectPersonalImage => 'يرجى اختيار الصورة الشخصية';

  @override
  String get pleaseSelectDriverLicense => 'يرجى اختيار رخصة القيادة';

  @override
  String get pleaseSelectVehicleLicense => 'يرجى اختيار رخصة المركبة';

  @override
  String get pleaseSelectVehiclePhoto => 'يرجى اختيار صورة المركبة';

  @override
  String get licenseInformation => 'معلومات الرخصة';

  @override
  String get vehicleInformation => 'معلومات المركبة';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get pleaseSelectVehicleType => 'يرجى اختيار نوع المركبة';

  @override
  String get vehicleModel => 'موديل المركبة';

  @override
  String get pleaseEnterVehicleModel => 'يرجى إدخال موديل المركبة';

  @override
  String get vehicleColor => 'لون المركبة';

  @override
  String get pleaseEnterVehicleColor => 'يرجى إدخال لون المركبة';

  @override
  String get vehiclePlateNumber => 'رقم لوحة المركبة';

  @override
  String get pleaseEnterVehiclePlateNumber => 'يرجى إدخال رقم لوحة المركبة';

  @override
  String get driverLicense => 'رخصة القيادة';

  @override
  String get vehicleLicense => 'رخصة المركبة';

  @override
  String get vehiclePhoto => 'صورة المركبة';

  @override
  String get selectImageSource => 'اختر مصدر الصورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get driverCreatedSuccessfully => 'تم إنشاء السائق بنجاح';

  @override
  String get pleaseProvideTheseCredentials => 'يرجى توفير هذه البيانات للسائق:';

  @override
  String get noteDriverCanChangePassword =>
      'ملاحظة: يمكن للسائق تغيير كلمة المرور بعد أول تسجيل دخول.';

  @override
  String get tapToUploadImage => 'اضغط لرفع الصورة';

  @override
  String get marketProductCategories => 'فئات الماركت';

  @override
  String get market => 'الماركت';

  @override
  String get vegetables => 'خضروات';

  @override
  String get fruits => 'فواكه';

  @override
  String get snacks => 'وجبات خفيفة';

  @override
  String get dairy => 'ألبان';

  @override
  String get bakery => 'مخبوزات';

  @override
  String get frozen => 'مجمدة';

  @override
  String get canned => 'معلبات';

  @override
  String get spices => 'بهارات';

  @override
  String get cleaning => 'منظفات';

  @override
  String get personalCare => 'العناية الشخصية';

  @override
  String get fish => 'أسماك';

  @override
  String get dairyProducts => 'ألبان';

  @override
  String get cheese => 'جبن';

  @override
  String get eggs => 'بيض';

  @override
  String get softDrinks => 'مشروبات غازية';

  @override
  String get water => 'مياه';

  @override
  String get juices => 'عصائر';

  @override
  String get pastaAndRice => 'مكرونات و أرز';

  @override
  String get chipsAndSnacks => 'شيبسي';

  @override
  String get topCategories => 'الفئات الرئيسية';

  @override
  String get pleaseSelectCategory => 'الرجاء اختيار فئة';

  @override
  String get addressBook => 'سجل العناوين';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get noAddressesFound => 'لا توجد عناوين';

  @override
  String get addYourFirstAddress => 'أضف عنوانك الأول للبدء';

  @override
  String get deleteAddress => 'حذف العنوان';

  @override
  String get deleteAddressConfirm => 'هل أنت متأكد من حذف هذا العنوان؟';

  @override
  String get offers => 'عروض';

  @override
  String get fruitsVegetables => 'الفواكه والخضروات';

  @override
  String get poultryMeatSeafood => 'دواجن، لحوم ومأكولات بحرية';

  @override
  String get freshFood => 'أطعمة طازجة';

  @override
  String get readyToEat => 'جاهز للأكل';

  @override
  String get frozenFood => 'الأطعمة المجمدة';

  @override
  String get dairyAndEggs => 'منتجات الألبان والبيض';

  @override
  String get iceCream => 'آيس كريم';

  @override
  String get milk => 'حليب';

  @override
  String get beauty => 'الجمال';

  @override
  String get cookingAndBaking => 'الطهي والخبز';

  @override
  String get coffeeAndTea => 'القهوة والشاي';

  @override
  String get pharmacy => 'الصيدليه';

  @override
  String get tissuesAndBags => 'مناديل و اكياس';

  @override
  String get cannedFood => 'معلبات';

  @override
  String get breakfastFood => 'طعام الإفطار';

  @override
  String get babyCorner => 'ركن الأطفال';

  @override
  String get cleaningAndLaundry => 'التنظيف والغسيل';

  @override
  String get specialDiet => 'نظام غذائي خاص';

  @override
  String get spicesAndSauces => 'التوابل والصلصات';

  @override
  String get shopByCategory => 'تسوق حسب الفئة';

  @override
  String get mostSoldProducts => 'الأكثر مبيعاً';

  @override
  String get promotionalImages => 'الصور الترويجية';

  @override
  String get addPromotionalImage => 'إضافة صورة ترويجية';

  @override
  String get editPromotionalImage => 'تعديل صورة ترويجية';

  @override
  String get deletePromotionalImage => 'حذف صورة ترويجية';

  @override
  String get areYouSureDeletePromotionalImage =>
      'هل أنت متأكد من حذف الصورة الترويجية';

  @override
  String get promotionalImage => 'صورة ترويجية';

  @override
  String get noPromotionalImages => 'لا توجد صور ترويجية';

  @override
  String get startByAddingYourFirstPromotionalImage =>
      'ابدأ بإضافة صورتك الترويجية الأولى';

  @override
  String get tapToChangeImage => 'اضغط لتغيير الصورة';

  @override
  String get title => 'العنوان';

  @override
  String get optionalTitleHint => 'أدخل العنوان (اختياري)';

  @override
  String get subtitle => 'العنوان الفرعي';

  @override
  String get optionalSubtitleHint => 'أدخل العنوان الفرعي (اختياري)';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get deactivate => 'إلغاء التنشيط';

  @override
  String get activate => 'تنشيط';

  @override
  String get exploreOurRichWorld => 'استكشف عالمنا الغني';

  @override
  String get pickupFromRestaurant => 'استلام من المطعم';

  @override
  String get deliveryMode => 'طريقة الاستلام';

  @override
  String get delivery => 'توصيل';

  @override
  String get startNewOrder => 'بدء طلب جديد';

  @override
  String get clearCartConfirmation =>
      'لديك عناصر من مطعم آخر. هل تريد بدء طلب جديد ومسح السلة؟';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get cancelAction => 'إلغاء';
}
