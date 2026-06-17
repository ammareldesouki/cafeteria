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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Fresh food, fast service'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

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

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email'**
  String get verificationCodeSent;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @pound.
  ///
  /// In en, this message translates to:
  /// **'L.E'**
  String get pound;

  /// No description provided for @varaity.
  ///
  /// In en, this message translates to:
  /// **'Varaity'**
  String get varaity;

  /// No description provided for @varaityIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Varaity is required'**
  String get varaityIsRequired;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'add'**
  String get add;

  /// No description provided for @toCart.
  ///
  /// In en, this message translates to:
  /// **'To Cart'**
  String get toCart;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @swipeToBrowseItems.
  ///
  /// In en, this message translates to:
  /// **'Swipe To Browse Items'**
  String get swipeToBrowseItems;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @supTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get supTotal;

  /// No description provided for @addItemsFromTheMenuToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add items from the menu to get started'**
  String get addItemsFromTheMenuToGetStarted;

  /// No description provided for @eachItem.
  ///
  /// In en, this message translates to:
  /// **'Each Item'**
  String get eachItem;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @deliveryLocationrequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location is required'**
  String get deliveryLocationrequired;

  /// No description provided for @deliveryLocationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid delivery location'**
  String get deliveryLocationInvalid;

  /// No description provided for @backToCart.
  ///
  /// In en, this message translates to:
  /// **'Back to Cart'**
  String get backToCart;

  /// No description provided for @customizeYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Customize Your Order'**
  String get customizeYourOrder;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @onlyLeftInStock.
  ///
  /// In en, this message translates to:
  /// **'Only  Left in Stock'**
  String get onlyLeftInStock;

  /// No description provided for @avilable.
  ///
  /// In en, this message translates to:
  /// **'Avilable'**
  String get avilable;

  /// No description provided for @selectAvarietyToSeeAvailability.
  ///
  /// In en, this message translates to:
  /// **'Select a variety to see availability'**
  String get selectAvarietyToSeeAvailability;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @addVariant.
  ///
  /// In en, this message translates to:
  /// **'Add Variant'**
  String get addVariant;

  /// No description provided for @variantName.
  ///
  /// In en, this message translates to:
  /// **'Variant Name'**
  String get variantName;

  /// No description provided for @sugarOption.
  ///
  /// In en, this message translates to:
  /// **'Offers sugar'**
  String get sugarOption;

  /// No description provided for @itemNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available'**
  String get itemNoLongerAvailable;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @sugarSpoons.
  ///
  /// In en, this message translates to:
  /// **'{count} spoon(s)'**
  String sugarSpoons(int count);

  /// No description provided for @variantSaved.
  ///
  /// In en, this message translates to:
  /// **'Variant saved'**
  String get variantSaved;

  /// No description provided for @variantDeleted.
  ///
  /// In en, this message translates to:
  /// **'Variant deleted'**
  String get variantDeleted;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for food or drinks...'**
  String get searchPlaceholder;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @todaysSpecial.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Special'**
  String get todaysSpecial;

  /// No description provided for @bestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get bestSellers;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @drinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get drinks;

  /// No description provided for @hotDrinks.
  ///
  /// In en, this message translates to:
  /// **'Hot Drinks'**
  String get hotDrinks;

  /// No description provided for @coldDrinks.
  ///
  /// In en, this message translates to:
  /// **'Cold Drinks'**
  String get coldDrinks;

  /// No description provided for @juices.
  ///
  /// In en, this message translates to:
  /// **'Juices'**
  String get juices;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @desserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get desserts;

  /// No description provided for @salads.
  ///
  /// In en, this message translates to:
  /// **'Salads'**
  String get salads;

  /// No description provided for @sandwiches.
  ///
  /// In en, this message translates to:
  /// **'Sandwiches'**
  String get sandwiches;

  /// No description provided for @mainCourse.
  ///
  /// In en, this message translates to:
  /// **'Main Course'**
  String get mainCourse;

  /// No description provided for @sides.
  ///
  /// In en, this message translates to:
  /// **'Sides'**
  String get sides;

  /// No description provided for @readyToOrder.
  ///
  /// In en, this message translates to:
  /// **'Ready to order your favorite beverages?'**
  String get readyToOrder;

  /// No description provided for @coldDrinksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refreshing iced beverages'**
  String get coldDrinksSubtitle;

  /// No description provided for @hotDrinksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warm comforting beverages'**
  String get hotDrinksSubtitle;

  /// No description provided for @sidesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your selection of side items'**
  String get sidesSubtitle;

  /// No description provided for @soups.
  ///
  /// In en, this message translates to:
  /// **'Soups'**
  String get soups;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @availableSoon.
  ///
  /// In en, this message translates to:
  /// **'Available Soon'**
  String get availableSoon;

  /// No description provided for @notAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'Not Available Today'**
  String get notAvailableToday;

  /// No description provided for @limitedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Limited Quantity'**
  String get limitedQuantity;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold Out'**
  String get soldOut;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from Cart'**
  String get removeFromCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add some delicious items to get started'**
  String get cartEmptySubtitle;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your cart?'**
  String get clearCartConfirm;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCode;

  /// No description provided for @applyPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPromoCode;

  /// No description provided for @promoCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied successfully'**
  String get promoCodeApplied;

  /// No description provided for @promoCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code'**
  String get promoCodeInvalid;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @orderPlacedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully'**
  String get orderPlacedSubtitle;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get orderConfirmed;

  /// No description provided for @orderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing Your Order'**
  String get orderPreparing;

  /// No description provided for @orderReady.
  ///
  /// In en, this message translates to:
  /// **'Order Ready'**
  String get orderReady;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderDelivered;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @favouriteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favouriteEmpty;

  /// No description provided for @favouriteEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favourite drinks will appear here'**
  String get favouriteEmptySubtitle;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

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

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

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

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items you love will appear here'**
  String get noFavoritesSubtitle;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write your review here...'**
  String get writeReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @beFirstReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this item'**
  String get beFirstReview;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergens;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @nutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Info'**
  String get nutritionInfo;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get servingSize;

  /// No description provided for @contains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get contains;

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

  /// No description provided for @glutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten Free'**
  String get glutenFree;

  /// No description provided for @spicy.
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get spicy;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Any notes for the cafeteria or delivery...'**
  String get specialInstructionsHint;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @pendingRevenueTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Revenue'**
  String get pendingRevenueTitle;

  /// No description provided for @searchByUsername.
  ///
  /// In en, this message translates to:
  /// **'Search by username'**
  String get searchByUsername;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @usersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} user(s)'**
  String usersCount(int count);

  /// No description provided for @unpaidOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unpaid order(s)'**
  String unpaidOrdersCount(int count);

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get markPaid;

  /// No description provided for @payAll.
  ///
  /// In en, this message translates to:
  /// **'Pay All'**
  String get payAll;

  /// No description provided for @partialAmount.
  ///
  /// In en, this message translates to:
  /// **'Partial amount'**
  String get partialAmount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @noPendingPayments.
  ///
  /// In en, this message translates to:
  /// **'No pending payments'**
  String get noPendingPayments;

  /// No description provided for @settlePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Settle payment'**
  String get settlePaymentTitle;

  /// No description provided for @amountExceedsDebt.
  ///
  /// In en, this message translates to:
  /// **'Amount can\'t exceed what\'s owed'**
  String get amountExceedsDebt;

  /// No description provided for @markPaidConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get markPaidConfirmTitle;

  /// No description provided for @markPaidConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Mark this order as paid? The customer owes {amount} {currency}.'**
  String markPaidConfirmBody(String amount, String currency);

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @debitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get debitCard;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @topUpWallet.
  ///
  /// In en, this message translates to:
  /// **'Top Up Wallet'**
  String get topUpWallet;

  /// No description provided for @accountMenu.
  ///
  /// In en, this message translates to:
  /// **'Account Menu'**
  String get accountMenu;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @completedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed Orders'**
  String get completedOrders;

  /// No description provided for @appAppearance.
  ///
  /// In en, this message translates to:
  /// **'App Appearance'**
  String get appAppearance;

  /// No description provided for @lightDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Light / Dark Mode'**
  String get lightDarkMode;

  /// No description provided for @recentBalanceUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Balance Updates'**
  String get recentBalanceUpdates;

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount} {currency}'**
  String youOwe(String amount, String currency);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @noInternetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get noInternetSubtitle;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get noResultsSubtitle;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again'**
  String get sessionExpired;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get unauthorized;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later'**
  String get serverError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again'**
  String get timeoutError;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get loginSuccess;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccess;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get signUpSuccess;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSaved;

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get itemAddedToCart;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// No description provided for @unpaidOnly.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Only'**
  String get unpaidOnly;

  /// No description provided for @paidOnly.
  ///
  /// In en, this message translates to:
  /// **'Paid Only'**
  String get paidOnly;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'Filter Date'**
  String get filterDate;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @activeOrder.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrder;

  /// No description provided for @totalOrder.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrder;

  /// No description provided for @rvenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get rvenue;

  /// No description provided for @pendingWallet.
  ///
  /// In en, this message translates to:
  /// **'Pending Revenue'**
  String get pendingWallet;

  /// No description provided for @additemMenu.
  ///
  /// In en, this message translates to:
  /// **'Add Item To Menu'**
  String get additemMenu;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @goToCart.
  ///
  /// In en, this message translates to:
  /// **'Go to Cart'**
  String get goToCart;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledTime;

  /// No description provided for @asSoonAsPossible.
  ///
  /// In en, this message translates to:
  /// **'As soon as possible'**
  String get asSoonAsPossible;

  /// No description provided for @scheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get scheduleForLater;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get selectDateTime;

  /// No description provided for @orderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get orderNotes;

  /// No description provided for @orderNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any special instructions for the cafeteria...'**
  String get orderNotesHint;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;
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
