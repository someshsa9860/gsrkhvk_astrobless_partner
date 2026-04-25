// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Astrobless Partner';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get seeAll => 'See all';

  @override
  String get or => 'or';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get platformFeePrefix => 'Platform:';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String entriesCount(int count) {
    return '$count entries';
  }

  @override
  String get termsDisclaimer =>
      'By continuing, you agree to our Terms of Service\nand Privacy Policy';

  @override
  String get welcomeAstrologer => 'Welcome,\nAstrologer';

  @override
  String get enterMobileNumber => 'Enter your mobile number to continue';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get mobileNumberHint => '98765 43210';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get otpSentTo => 'We sent a 6-digit code to ';

  @override
  String get otpInvalidError => 'Incorrect code. Please try again.';

  @override
  String get otpExpiredError => 'Code expired. Request a new one.';

  @override
  String get otpAttemptsError => 'Too many wrong attempts. Request a new code.';

  @override
  String get verify => 'Verify';

  @override
  String resendCountdown(String seconds) {
    return 'Resend code in 0:$seconds';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get emailSignInTitle => 'Email Sign In';

  @override
  String get signInTab => 'Sign In';

  @override
  String get registerTab => 'Register';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get enterCredentials => 'Enter your credentials to continue';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get joinAsPro => 'Join as a professional astrologer';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Pandit Rajesh Sharma';

  @override
  String get passwordHint => 'Min 8 chars, one uppercase, one digit';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get emailVerificationNotice =>
      'We\'ll send a verification code to your email';

  @override
  String get navHome => 'Home';

  @override
  String get navConsults => 'Consults';

  @override
  String get navEarnings => 'Earnings';

  @override
  String get navProfile => 'Profile';

  @override
  String get goodMorning => 'Good morning!';

  @override
  String get todaysOverview => 'Today\'s Overview';

  @override
  String get todaysEarnings => 'Today\'s Earnings';

  @override
  String get thisWeek => 'This Week';

  @override
  String get totalConsults => 'Total Consults';

  @override
  String get rating => 'Rating';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get myProfile => 'My Profile';

  @override
  String get earnings => 'Earnings';

  @override
  String get consults => 'Consults';

  @override
  String get recentConsultations => 'Recent Consultations';

  @override
  String get youAreOnline => 'You are Online';

  @override
  String get youAreOffline => 'You are Offline';

  @override
  String get customersCanSeeYou => 'Customers can see and contact you';

  @override
  String get toggleToReceive => 'Toggle to start receiving requests';

  @override
  String get consultationsTitle => 'Consultations';

  @override
  String get allTab => 'All';

  @override
  String get completedTab => 'Completed';

  @override
  String get pendingTab => 'Pending';

  @override
  String get noConsultationsYet => 'No consultations yet';

  @override
  String get goOnlineHint => 'Go online to start receiving requests';

  @override
  String get consultationDetailTitle => 'Consultation Detail';

  @override
  String get chatConsultation => 'Chat Consultation';

  @override
  String get startedLabel => 'Started';

  @override
  String get durationLabel => 'Duration';

  @override
  String get rateLabel => 'Rate';

  @override
  String get yourEarnings => 'Your Earnings';

  @override
  String get customerPaid => 'Customer paid';

  @override
  String get customerLabel => 'Customer';

  @override
  String get activeConsultation => 'Active consultation';

  @override
  String get endConsultationTitle => 'End Consultation?';

  @override
  String get endConsultationBody =>
      'Are you sure you want to end this consultation?';

  @override
  String get endButton => 'End';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String get export => 'Export';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get grossRevenue => 'Gross Revenue';

  @override
  String get platformFee => 'Platform Fee';

  @override
  String get lastPayoutProcessed => 'Last Payout Processed';

  @override
  String get history => 'History';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get reviewsRatings => 'Reviews & Ratings';

  @override
  String get kycStatus => 'KYC Status';

  @override
  String get kycApproved => 'Approved';

  @override
  String get bankPayoutDetails => 'Bank & Payout Details';

  @override
  String get accountSection => 'Account';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get languagesLabel => 'Languages';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkTheme => 'Dark';

  @override
  String get supportSection => 'Support';

  @override
  String get helpFaq => 'Help & FAQ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get appVersion => 'App Version';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutTitle => 'Sign Out?';

  @override
  String get signOutBody => 'You will be signed out of your account.';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayNameHint => 'How customers will see you';

  @override
  String get bioLabel => 'Bio';

  @override
  String get bioHint => 'Tell customers about yourself';

  @override
  String get yearsExperience => 'Years of Experience';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get specialties => 'Specialties';

  @override
  String get pricingPerMin => 'Pricing (₹ per minute)';

  @override
  String get chatRateLabel => 'Chat Rate (₹/min)';

  @override
  String get callRateLabel => 'Call Rate (₹/min)';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsHint =>
      'You\'ll be notified about consultations,\nearnings, and platform updates';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get chatRequests => 'Chat Requests';

  @override
  String get chatRequestsDesc => 'New incoming chat consultations';

  @override
  String get callRequests => 'Call Requests';

  @override
  String get callRequestsDesc => 'Incoming voice & video calls';

  @override
  String get kundliRequests => 'Kundli Requests';

  @override
  String get kundliRequestsDesc => 'New Kundli report requests';

  @override
  String get earningsUpdates => 'Earnings Updates';

  @override
  String get earningsUpdatesDesc => 'Payouts and credit alerts';

  @override
  String get platformUpdates => 'Platform Updates';

  @override
  String get platformUpdatesDesc => 'News, features, and announcements';

  @override
  String get alertStyle => 'Alert Style';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get securitySection => 'Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get aboutSection => 'About';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get buildProfile => 'Build your profile';

  @override
  String get buildProfileSubtitle => 'Customers see this. Make it compelling.';

  @override
  String get nameAlias => 'Your name / alias';

  @override
  String get nameAliasHint => 'e.g. Pandit Rajesh Ji';

  @override
  String get bioDescHint =>
      'Brief description of your expertise and approach...';

  @override
  String get yourSpecialties => 'Your specialties';

  @override
  String get specialtiesHint =>
      'Select at least one. This helps customers find you.';

  @override
  String get languagesYouSpeak => 'Languages you speak';

  @override
  String get languagesHint =>
      'Customers filter by language. More = more reach.';

  @override
  String get setYourRates => 'Set your rates';

  @override
  String get ratesSubtitle =>
      'You keep 70% of what customers pay. These are your per-minute rates.';

  @override
  String get chatRateTitle => 'Chat Rate';

  @override
  String get chatRateDesc => 'Per minute for text consultations';

  @override
  String get callRateTitle => 'Call Rate';

  @override
  String get callRateDesc => 'Per minute for voice consultations';

  @override
  String get minRateHint =>
      'Minimum rate is ₹20/min. You can change this anytime from your profile.';

  @override
  String get continueButton => 'Continue';

  @override
  String get getStarted => 'Get Started 🚀';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get resetPasswordSubtitle =>
      'Enter the email address linked to your account. We\'ll send a reset code.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String resetCodeSentTo(String email) {
    return 'We sent a password reset code to\n$email';
  }

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get unmute => 'Unmute';

  @override
  String get mute => 'Mute';

  @override
  String get speaker => 'Speaker';

  @override
  String get callConnected => 'Connected';

  @override
  String get callConnecting => 'Connecting...';

  @override
  String get endCall => 'End Call';

  @override
  String get chatBillingBar => 'Billing per minute';

  @override
  String get incomingChatRequest => 'Incoming Chat Request';

  @override
  String get incomingCallRequest => 'Incoming Call Request';

  @override
  String get secondsLeft => 'seconds left';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';
}
