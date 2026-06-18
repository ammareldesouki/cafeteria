// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'الكافيتيريا';

  @override
  String get appTagline => 'طعام طازج، خدمة سريعة';

  @override
  String get welcome => 'اهلا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال رابط الاسترداد';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get createAccount => 'إنشاء حساب جديد';

  @override
  String get verificationCodeSent => 'تم إرسال رمز التحقق إلى بريدك الإلكتروني';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get verify => 'تحقق';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'انثى';

  @override
  String get pound => 'جنيه';

  @override
  String get varaity => 'نوع';

  @override
  String get varaityIsRequired => 'اختيار النوع اجباري';

  @override
  String get add => 'اضف';

  @override
  String get toCart => 'الي السلة';

  @override
  String get home => 'الصفجة الرئسية';

  @override
  String get favourite => 'المفضلة';

  @override
  String get cart => 'السلة';

  @override
  String get order => 'الطلبات';

  @override
  String get swipeToBrowseItems => 'حرك لليمين او اليسار لتري المنتجات';

  @override
  String get total => 'الإجمالي';

  @override
  String get supTotal => 'المجموع الفرعي';

  @override
  String get addItemsFromTheMenuToGetStarted =>
      'حط حاجة في السلة متسبهاش فاضية';

  @override
  String get eachItem => 'القطعة ';

  @override
  String get inStock => 'متوفر';

  @override
  String get deliveryLocation => 'مكان التوصيل ';

  @override
  String get deliveryLocationrequired => 'لازم تحط مكان للتوصيل ';

  @override
  String get deliveryLocationInvalid => 'Enter a valid delivery location';

  @override
  String get backToCart => 'العودة للعربة';

  @override
  String get customizeYourOrder => 'خلي طلبك علي مزاجك';

  @override
  String get customize => 'خصص';

  @override
  String get onlyLeftInStock => 'المتبقي من الخزون';

  @override
  String get avilable => 'المتوفر';

  @override
  String get selectAvarietyToSeeAvailability =>
      'اختر النوع لتعرف المتبقي من المخزون';

  @override
  String get required => 'مطلوب';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get firstNameRequired => 'الاسم الأول مطلوب';

  @override
  String get lastNameRequired => 'اسم العائلة مطلوب';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get phoneInvalid => 'أدخل رقم هاتف صحيحًا';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get menu => 'القائمة';

  @override
  String get categories => 'الفئات';

  @override
  String get category => 'الفئة';

  @override
  String get addVariant => 'إضافة نوع';

  @override
  String get variantName => 'اسم النوع';

  @override
  String get sugarOption => 'يوفر سكر';

  @override
  String get itemNoLongerAvailable => 'هذا الصنف لم يعد متاحًا';

  @override
  String get pickDate => 'اختر تاريخًا';

  @override
  String get sugar => 'السكر';

  @override
  String sugarSpoons(int count) {
    return '$count ملعقة';
  }

  @override
  String get variantSaved => 'تم حفظ النوع';

  @override
  String get variantDeleted => 'تم حذف النوع';

  @override
  String get allItems => 'جميع العناصر';

  @override
  String get search => 'بحث';

  @override
  String get searchPlaceholder => 'ابحث عن طعام أو مشروبات...';

  @override
  String get popular => 'الأكثر شيوعًا';

  @override
  String get recommended => 'موصى به';

  @override
  String get newArrivals => 'الوافدون الجدد';

  @override
  String get todaysSpecial => 'عرض اليوم';

  @override
  String get bestSellers => 'الأكثر مبيعًا';

  @override
  String get featured => 'مميز';

  @override
  String get breakfast => 'الإفطار';

  @override
  String get lunch => 'الغداء';

  @override
  String get dinner => 'العشاء';

  @override
  String get drinks => 'المشروبات';

  @override
  String get hotDrinks => 'المشروبات الساخنة';

  @override
  String get coldDrinks => 'المشروبات الباردة';

  @override
  String get juices => 'العصائر';

  @override
  String get snacks => 'الوجبات الخفيفة';

  @override
  String get desserts => 'الحلويات';

  @override
  String get salads => 'السلطات';

  @override
  String get sandwiches => 'السندويشات';

  @override
  String get mainCourse => 'الطبق الرئيسي';

  @override
  String get sides => 'الأطباق الجانبية';

  @override
  String get readyToOrder => 'هل أنت مستعد لطلب مشروباتك المفضلة؟';

  @override
  String get coldDrinksSubtitle => 'مشروبات مثلجة منعشة';

  @override
  String get hotDrinksSubtitle => 'مشروبات دافئة ومريحة';

  @override
  String get sidesSubtitle => 'اختر تشكيلتك من الأطباق الجانبية';

  @override
  String get soups => 'الشوربات';

  @override
  String get outOfStock => 'نفذ من المخزون';

  @override
  String get lowStock => 'كمية محدودة';

  @override
  String get availableSoon => 'متوفر قريبًا';

  @override
  String get notAvailableToday => 'غير متوفر اليوم';

  @override
  String get limitedQuantity => 'كمية محدودة';

  @override
  String get soldOut => 'نفذت الكمية';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get removeFromCart => 'إزالة من السلة';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get cartEmptySubtitle => 'أضف بعض العناصر اللذيذة للبدء';

  @override
  String get continueShopping => 'مواصلة التسوق';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get placeOrder => 'تقديم الطلب';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get subtotal => 'المجموع الجزئي';

  @override
  String get tax => 'الضريبة';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get discount => 'الخصم';

  @override
  String get quantity => 'الكمية';

  @override
  String get item => 'عنصر';

  @override
  String get items => 'عناصر';

  @override
  String get remove => 'إزالة';

  @override
  String get clear => 'مسح';

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get clearCartConfirm => 'هل أنت متأكد أنك تريد إفراغ سلتك؟';

  @override
  String get promoCode => 'كود الخصم';

  @override
  String get applyPromoCode => 'تطبيق';

  @override
  String get promoCodeApplied => 'تم تطبيق كود الخصم بنجاح';

  @override
  String get promoCodeInvalid => 'كود الخصم غير صحيح';

  @override
  String get orderPlaced => 'تم تقديم الطلب!';

  @override
  String get orderPlacedSubtitle => 'تم تقديم طلبك بنجاح';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get reorder => 'إعادة الطلب';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelOrderConfirm => 'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟';

  @override
  String get orderCancelled => 'تم إلغاء الطلب';

  @override
  String get orderConfirmed => 'تم تأكيد الطلب';

  @override
  String get orderPreparing => 'جاري تحضير طلبك';

  @override
  String get orderReady => 'طلبك جاهز';

  @override
  String get orderDelivered => 'تم التسليم';

  @override
  String get estimatedTime => 'الوقت المتوقع';

  @override
  String get minutes => 'دقائق';

  @override
  String get favouriteEmpty => 'لا يوجد شي مفضل ';

  @override
  String get favouriteEmptySubtitle => 'ضيف اللي بتحبو ';

  @override
  String get processing => 'بيتحضر';

  @override
  String get completed => 'تم التحضير';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get cancelled => 'ملغي';

  @override
  String get pending => 'معلق ';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get favorites => 'المفضلة';

  @override
  String get addToFavorites => 'أضف إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get noFavorites => 'لا توجد مفضلات بعد';

  @override
  String get noFavoritesSubtitle => 'ستظهر هنا العناصر التي تحبها';

  @override
  String get reviews => 'التقييمات';

  @override
  String get addReview => 'إضافة تقييم';

  @override
  String get yourReview => 'تقييمك';

  @override
  String get rating => 'التقييم';

  @override
  String get writeReview => 'اكتب تقييمك هنا...';

  @override
  String get submitReview => 'إرسال التقييم';

  @override
  String get noReviews => 'لا توجد تقييمات بعد';

  @override
  String get beFirstReview => 'كن أول من يقيّم هذا العنصر';

  @override
  String get calories => 'السعرات الحرارية';

  @override
  String get protein => 'البروتين';

  @override
  String get carbs => 'الكربوهيدرات';

  @override
  String get fat => 'الدهون';

  @override
  String get allergens => 'مسببات الحساسية';

  @override
  String get ingredients => 'المكونات';

  @override
  String get nutritionInfo => 'المعلومات الغذائية';

  @override
  String get servingSize => 'حجم الحصة';

  @override
  String get contains => 'يحتوي على';

  @override
  String get vegetarian => 'نباتي';

  @override
  String get vegan => 'نباتي صرف';

  @override
  String get glutenFree => 'خالٍ من الغلوتين';

  @override
  String get spicy => 'حار';

  @override
  String get address => 'العنوان';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get editAddress => 'تعديل العنوان';

  @override
  String get street => 'الشارع';

  @override
  String get city => 'المدينة';

  @override
  String get floor => 'الطابق';

  @override
  String get apartment => 'الشقة';

  @override
  String get specialInstructions => 'تعليمات خاصة';

  @override
  String get specialInstructionsHint => 'أي ملاحظات للكافيتيريا أو التوصيل...';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get markAsPaid => 'تأكيد الدفع';

  @override
  String get pendingRevenueTitle => 'المبالغ المستحقة';

  @override
  String get searchByUsername => 'ابحث باسم المستخدم';

  @override
  String get totalRevenue => 'إجمالي المستحق';

  @override
  String usersCount(int count) {
    return '$count مستخدم';
  }

  @override
  String unpaidOrdersCount(int count) {
    return '$count طلب غير مدفوع';
  }

  @override
  String get markPaid => 'تحديد كمدفوع';

  @override
  String get payAll => 'دفع الكل';

  @override
  String get partialAmount => 'مبلغ جزئي';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get noPendingPayments => 'لا توجد مبالغ مستحقة';

  @override
  String get settlePaymentTitle => 'تسجيل دفعة';

  @override
  String get amountExceedsDebt => 'المبلغ لا يمكن أن يتجاوز المستحق';

  @override
  String get markPaidConfirmTitle => 'تأكيد الدفع';

  @override
  String markPaidConfirmBody(String amount, String currency) {
    return 'هل تريد تسجيل هذا الطلب كمدفوع؟ العميل عليه $amount $currency.';
  }

  @override
  String get creditCard => 'بطاقة ائتمان';

  @override
  String get debitCard => 'بطاقة خصم';

  @override
  String get wallet => 'المحفظة';

  @override
  String get walletBalance => 'رصيد المحفظة';

  @override
  String get topUpWallet => 'شحن المحفظة';

  @override
  String get accountMenu => 'قائمة الحساب';

  @override
  String get account => 'الحساب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get completedOrders => 'الطلبات المكتملة';

  @override
  String get appAppearance => 'مظهر التطبيق';

  @override
  String get lightDarkMode => 'الوضع الفاتح / الداكن';

  @override
  String get recentBalanceUpdates => 'آخر تحديثات الرصيد';

  @override
  String get noRecentTransactions => 'لا توجد معاملات حديثة';

  @override
  String youOwe(String amount, String currency) {
    return 'عليك دفع $amount $currency';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get skip => 'تخطي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get refresh => 'تحديث';

  @override
  String get close => 'إغلاق';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get priceHighToLow => 'السعر: من الأعلى إلى الأدنى';

  @override
  String get priceLowToHigh => 'السعر: من الأدنى إلى الأعلى';

  @override
  String get mostPopular => 'الأكثر شيوعًا';

  @override
  String get newest => 'الأحدث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetSubtitle => 'يرجى التحقق من اتصالك والمحاولة مرة أخرى';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get noDataFound => 'لم يتم العثور على بيانات';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get noResultsSubtitle => 'حاول تعديل بحثك أو الفلاتر';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى';

  @override
  String get unauthorized => 'وصول غير مصرح به';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقًا';

  @override
  String get timeoutError => 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get logoutSuccess => 'تم تسجيل الخروج بنجاح';

  @override
  String get signUpSuccess => 'تم إنشاء الحساب بنجاح';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get reviewSubmitted => 'تم إرسال التقييم بنجاح';

  @override
  String get addressSaved => 'تم حفظ العنوان بنجاح';

  @override
  String get itemAddedToCart => 'تمت إضافة العنصر إلى السلة';

  @override
  String get itemRemovedFromCart => 'تمت إزالة العنصر من السلة';

  @override
  String get unpaidOnly => 'غير مدفوع فقط';

  @override
  String get paidOnly => 'مدفوع فقط';

  @override
  String get filterDate => 'تصفية حسب التاريخ';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get activeOrder => 'الطلبات النشطة';

  @override
  String get totalOrder => 'إجمالي الطلبات';

  @override
  String get rvenue => 'الإيرادات';

  @override
  String get pendingWallet => 'الإيرادات المعلقة';

  @override
  String get additemMenu => 'اضف عنصر للقائمة';

  @override
  String get price => 'المبلغ';

  @override
  String get itemName => 'اسم المنتج';

  @override
  String get goToCart => 'اذهب للسلة';

  @override
  String get scheduledTime => 'مجدول';

  @override
  String get asSoonAsPossible => 'في أقرب وقت';

  @override
  String get scheduleForLater => 'جدولة لوقت لاحق';

  @override
  String get selectDateTime => 'اختر التاريخ والوقت';

  @override
  String get orderNotes => 'ملاحظات الطلب';

  @override
  String get orderNotesHint => 'أي تعليمات خاصة للكافيتيريا...';

  @override
  String get extras => 'إضافات';
}
