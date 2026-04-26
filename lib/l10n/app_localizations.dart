import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Astrobless Partner'**
  String get appName;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// See all link
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Divider between auth options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Label prefix for platform fee amount
  ///
  /// In en, this message translates to:
  /// **'Platform:'**
  String get platformFeePrefix;

  /// Number of reviews
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(int count);

  /// Number of transaction entries
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entriesCount(int count);

  /// No description provided for @termsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service\nand Privacy Policy'**
  String get termsDisclaimer;

  /// No description provided for @welcomeAstrologer.
  ///
  /// In en, this message translates to:
  /// **'Welcome,\nAstrologer'**
  String get welcomeAstrologer;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to continue'**
  String get enterMobileNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @mobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'98765 43210'**
  String get mobileNumberHint;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// Prefix before the masked phone/email
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to '**
  String get otpSentTo;

  /// No description provided for @otpInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Please try again.'**
  String get otpInvalidError;

  /// No description provided for @otpExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Request a new one.'**
  String get otpExpiredError;

  /// No description provided for @otpAttemptsError.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts. Request a new code.'**
  String get otpAttemptsError;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code in 0:{seconds}'**
  String resendCountdown(String seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @emailSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Sign In'**
  String get emailSignInTitle;

  /// No description provided for @signInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTab;

  /// No description provided for @registerTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTab;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get enterCredentials;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @joinAsPro.
  ///
  /// In en, this message translates to:
  /// **'Join as a professional astrologer'**
  String get joinAsPro;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Pandit Rajesh Sharma'**
  String get fullNameHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 chars, one uppercase, one digit'**
  String get passwordHint;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @emailVerificationNotice.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to your email'**
  String get emailVerificationNotice;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navConsults.
  ///
  /// In en, this message translates to:
  /// **'Consults'**
  String get navConsults;

  /// No description provided for @navEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get navEarnings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get goodMorning;

  /// No description provided for @todaysOverview.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get todaysOverview;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaysEarnings;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @totalConsults.
  ///
  /// In en, this message translates to:
  /// **'Total Consults'**
  String get totalConsults;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @consults.
  ///
  /// In en, this message translates to:
  /// **'Consults'**
  String get consults;

  /// No description provided for @recentConsultations.
  ///
  /// In en, this message translates to:
  /// **'Recent Consultations'**
  String get recentConsultations;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are Online'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are Offline'**
  String get youAreOffline;

  /// No description provided for @customersCanSeeYou.
  ///
  /// In en, this message translates to:
  /// **'Customers can see and contact you'**
  String get customersCanSeeYou;

  /// No description provided for @toggleToReceive.
  ///
  /// In en, this message translates to:
  /// **'Toggle to start receiving requests'**
  String get toggleToReceive;

  /// No description provided for @consultationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Consultations'**
  String get consultationsTitle;

  /// No description provided for @allTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// No description provided for @completedTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTab;

  /// No description provided for @pendingTab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTab;

  /// No description provided for @noConsultationsYet.
  ///
  /// In en, this message translates to:
  /// **'No consultations yet'**
  String get noConsultationsYet;

  /// No description provided for @goOnlineHint.
  ///
  /// In en, this message translates to:
  /// **'Go online to start receiving requests'**
  String get goOnlineHint;

  /// No description provided for @consultationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Consultation Detail'**
  String get consultationDetailTitle;

  /// No description provided for @chatConsultation.
  ///
  /// In en, this message translates to:
  /// **'Chat Consultation'**
  String get chatConsultation;

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get startedLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateLabel;

  /// No description provided for @yourEarnings.
  ///
  /// In en, this message translates to:
  /// **'Your Earnings'**
  String get yourEarnings;

  /// No description provided for @customerPaid.
  ///
  /// In en, this message translates to:
  /// **'Customer paid'**
  String get customerPaid;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @activeConsultation.
  ///
  /// In en, this message translates to:
  /// **'Active consultation'**
  String get activeConsultation;

  /// No description provided for @endConsultationTitle.
  ///
  /// In en, this message translates to:
  /// **'End Consultation?'**
  String get endConsultationTitle;

  /// No description provided for @endConsultationBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end this consultation?'**
  String get endConsultationBody;

  /// No description provided for @endButton.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endButton;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTitle;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @grossRevenue.
  ///
  /// In en, this message translates to:
  /// **'Gross Revenue'**
  String get grossRevenue;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// No description provided for @lastPayoutProcessed.
  ///
  /// In en, this message translates to:
  /// **'Last Payout Processed'**
  String get lastPayoutProcessed;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @reviewsRatings.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsRatings;

  /// No description provided for @kycStatus.
  ///
  /// In en, this message translates to:
  /// **'KYC Status'**
  String get kycStatus;

  /// No description provided for @kycApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get kycApproved;

  /// No description provided for @bankPayoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank & Payout Details'**
  String get bankPayoutDetails;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @languagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesLabel;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaq;

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

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your account.'**
  String get signOutBody;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'How customers will see you'**
  String get displayNameHint;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell customers about yourself'**
  String get bioHint;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsExperience;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @pricingPerMin.
  ///
  /// In en, this message translates to:
  /// **'Pricing (₹ per minute)'**
  String get pricingPerMin;

  /// No description provided for @chatRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat Rate (₹/min)'**
  String get chatRateLabel;

  /// No description provided for @callRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Call Rate (₹/min)'**
  String get callRateLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified about consultations,\nearnings, and platform updates'**
  String get notificationsHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @chatRequests.
  ///
  /// In en, this message translates to:
  /// **'Chat Requests'**
  String get chatRequests;

  /// No description provided for @chatRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'New incoming chat consultations'**
  String get chatRequestsDesc;

  /// No description provided for @callRequests.
  ///
  /// In en, this message translates to:
  /// **'Call Requests'**
  String get callRequests;

  /// No description provided for @callRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Incoming voice & video calls'**
  String get callRequestsDesc;

  /// No description provided for @kundliRequests.
  ///
  /// In en, this message translates to:
  /// **'Kundli Requests'**
  String get kundliRequests;

  /// No description provided for @kundliRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'New Kundli report requests'**
  String get kundliRequestsDesc;

  /// No description provided for @earningsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Earnings Updates'**
  String get earningsUpdates;

  /// No description provided for @earningsUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Payouts and credit alerts'**
  String get earningsUpdatesDesc;

  /// No description provided for @platformUpdates.
  ///
  /// In en, this message translates to:
  /// **'Platform Updates'**
  String get platformUpdates;

  /// No description provided for @platformUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'News, features, and announcements'**
  String get platformUpdatesDesc;

  /// No description provided for @alertStyle.
  ///
  /// In en, this message translates to:
  /// **'Alert Style'**
  String get alertStyle;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @buildProfile.
  ///
  /// In en, this message translates to:
  /// **'Build your profile'**
  String get buildProfile;

  /// No description provided for @buildProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers see this. Make it compelling.'**
  String get buildProfileSubtitle;

  /// No description provided for @nameAlias.
  ///
  /// In en, this message translates to:
  /// **'Your name / alias'**
  String get nameAlias;

  /// No description provided for @nameAliasHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pandit Rajesh Ji'**
  String get nameAliasHint;

  /// No description provided for @bioDescHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of your expertise and approach...'**
  String get bioDescHint;

  /// No description provided for @yourSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Your specialties'**
  String get yourSpecialties;

  /// No description provided for @specialtiesHint.
  ///
  /// In en, this message translates to:
  /// **'Select at least one. This helps customers find you.'**
  String get specialtiesHint;

  /// No description provided for @languagesYouSpeak.
  ///
  /// In en, this message translates to:
  /// **'Languages you speak'**
  String get languagesYouSpeak;

  /// No description provided for @languagesHint.
  ///
  /// In en, this message translates to:
  /// **'Customers filter by language. More = more reach.'**
  String get languagesHint;

  /// No description provided for @setYourRates.
  ///
  /// In en, this message translates to:
  /// **'Set your rates'**
  String get setYourRates;

  /// No description provided for @ratesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You keep 70% of what customers pay. These are your per-minute rates.'**
  String get ratesSubtitle;

  /// No description provided for @chatRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Rate'**
  String get chatRateTitle;

  /// No description provided for @chatRateDesc.
  ///
  /// In en, this message translates to:
  /// **'Per minute for text consultations'**
  String get chatRateDesc;

  /// No description provided for @callRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Rate'**
  String get callRateTitle;

  /// No description provided for @callRateDesc.
  ///
  /// In en, this message translates to:
  /// **'Per minute for voice consultations'**
  String get callRateDesc;

  /// No description provided for @minRateHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum rate is ₹20/min. You can change this anytime from your profile.'**
  String get minRateHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started 🚀'**
  String get getStarted;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address linked to your account. We\'ll send a reset code.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @resetCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset code to\n{email}'**
  String resetCodeSentTo(String email);

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get callConnected;

  /// No description provided for @callConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get callConnecting;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @chatBillingBar.
  ///
  /// In en, this message translates to:
  /// **'Billing per minute'**
  String get chatBillingBar;

  /// No description provided for @incomingChatRequest.
  ///
  /// In en, this message translates to:
  /// **'Incoming Chat Request'**
  String get incomingChatRequest;

  /// No description provided for @incomingCallRequest.
  ///
  /// In en, this message translates to:
  /// **'Incoming Call Request'**
  String get incomingCallRequest;

  /// No description provided for @secondsLeft.
  ///
  /// In en, this message translates to:
  /// **'seconds left'**
  String get secondsLeft;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  String get supportTicketsTitle;
  String get myTickets;
  String get newTicket;
  String get noTicketsYet;
  String get noTicketsHint;
  String get ticketDetailTitle;
  String get closeTicketButton;
  String get closeTicketTitle;
  String get closeTicketBody;
  String get ticketClosedBanner;
  String get replyHint;
  String get newTicketTitle;
  String get subjectLabel;
  String get subjectHint;
  String get descriptionLabel;
  String get descriptionHint;
  String get categoryLabel;
  String get submitTicket;
  String get ticketCreated;
  String get statusOpen;
  String get statusInProgress;
  String get statusWaitingOnUser;
  String get statusResolved;
  String get statusClosed;
  String get priorityLow;
  String get priorityMedium;
  String get priorityHigh;
  String get priorityUrgent;
  String get categoryPayment;
  String get categoryConsultation;
  String get categoryKyc;
  String get categoryPuja;
  String get categoryOrder;
  String get categoryGeneral;
  String get inProgressTab;
  String get kundliRequestsTitle;
  String get kundliRequestTitle;
  String get birthDetailsSection;
  String get selectSla;
  String get acceptAndStart;
  String get writeReport;
  String get requestAccepted;
  String get requestDeclined;
  String get declineRequest;
  String get reasonOptionalHint;
  String get reportCannotBeEmpty;
  String get reportSubmittedNotice;
  String get submitReportTitle;
  String get submitReportBody;
  String get submit;
  String get customerBalanceLowSession;
  String get customerBalanceLowCall;
  String get previewLabel;
  String get editLabel;
  String get dateLabel;
  String get timeLabel;
  String get placeLabel;
  String get nameLabel;
  String get questionLabel;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
