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
}
