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
  String get pleaseEnterValidPhoneNumber => 'الرجاء إدخال رقم هاتف صحيح';

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
  String get deliveryFee => 'رسوم التوصيل (ريال)';

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
}
