import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AgriPortal bilingual support — English (en) and Nepali (ne)
//
// Usage:
//   final t = AppLocalizations.of(context);
//   Text(t.explore)
//
// Toggle language from settings:
//   LanguageController.instance.setLanguage('ne');
// ─────────────────────────────────────────────────────────────────────────────

class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._();
  LanguageController._();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isNepali => _locale.languageCode == 'ne';

  void setLanguage(String code) {
    _locale = Locale(code);
    notifyListeners();
  }

  void toggle() => setLanguage(isNepali ? 'en' : 'ne');
}

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return l ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get _ne => locale.languageCode == 'ne';

  // ── App name ──────────────────────────────────────────────────────────────
  String get appName => 'AgriPortal';

  // ── Common ────────────────────────────────────────────────────────────────
  String get ok        => _ne ? 'ठिक छ'      : 'OK';
  String get cancel    => _ne ? 'रद्द गर्नुस' : 'Cancel';
  String get save      => _ne ? 'सुरक्षित'    : 'Save';
  String get submit    => _ne ? 'पेश गर्नुस'  : 'Submit';
  String get loading   => _ne ? 'लोड हुँदैछ'  : 'Loading...';
  String get error     => _ne ? 'त्रुटि'       : 'Error';
  String get back      => _ne ? 'फिर्ता'       : 'Back';
  String get edit      => _ne ? 'सम्पादन'      : 'Edit';
  String get delete    => _ne ? 'मेटाउनुस'     : 'Delete';
  String get confirm   => _ne ? 'पुष्टि गर्नुस': 'Confirm';
  String get search    => _ne ? 'खोज्नुस'      : 'Search';
  String get filter    => _ne ? 'फिल्टर'       : 'Filter';
  String get sort      => _ne ? 'क्रम'         : 'Sort';
  String get browse    => _ne ? 'ब्राउज'        : 'Browse';
  String get settings  => _ne ? 'सेटिङ'        : 'Settings';
  String get logout    => _ne ? 'बाहिर निस्कनुस': 'Logout';
  String get retry     => _ne ? 'पुन: प्रयास'  : 'Retry';
  String get seeAll    => _ne ? 'सबै हेर्नुस'  : 'See All';
  String get close     => _ne ? 'बन्द'         : 'Close';
  String get continueStr => _ne ? 'अगाडि बढ्नुस': 'Continue';
  String get send      => _ne ? 'पठाउनुस'      : 'Send';
  String get approve   => _ne ? 'स्वीकृत'       : 'Approve';
  String get reject    => _ne ? 'अस्वीकार'      : 'Reject';
  String get pending   => _ne ? 'विचाराधीन'     : 'Pending';
  String get approved  => _ne ? 'स्वीकृत'       : 'Approved';
  String get rejected  => _ne ? 'अस्वीकृत'      : 'Rejected';
  String get verified  => _ne ? 'प्रमाणित'       : 'Verified';
  String get active    => _ne ? 'सक्रिय'         : 'Active';
  String get inactive  => _ne ? 'निष्क्रिय'      : 'Inactive';
  String get year      => _ne ? 'वर्ष'           : 'year';
  String get years     => _ne ? 'वर्षहरू'        : 'years';
  String get month     => _ne ? 'महिना'          : 'month';
  String get required  => _ne ? 'आवश्यक'         : 'Required';
  String get optional  => _ne ? 'ऐच्छिक'         : 'Optional';
  String get farmer    => _ne ? 'किसान'          : 'Farmer';
  String get landOwner => _ne ? 'जमिन मालिक'     : 'Land Owner';
  String get failedToUpdateSavedLands => _ne ? 'सुरक्षित जमिनहरू अपडेट गर्न असफल' : 'Failed to update saved lands';
  String get landNotFound => _ne ? 'जमिन फेला परेन' : 'Land not found';
  String get savedToYourCollection => _ne ? 'तपाईंको संग्रहमा सुरक्षित गरियो' : 'Saved to your collection';
  String get applicationSubmittedSuccess => _ne ? 'आवेदन पेश गरियो! प्रशासकले चाँडै समीक्षा गर्नेछ।' : 'Application submitted! Admin will review shortly.';
  String get perMonth => _ne ? 'प्रति महिना' : 'per month';
  String get yr => _ne ? 'वर्ष' : 'yr';
  String get yrs => _ne ? 'वर्ष' : 'yrs';
  String get pleaseEnterIntendedCrops => _ne ? 'कृपया उद्देश्यित बालीहरू प्रविष्ट गर्नुस' : 'Please enter intended crops';
  String get pleaseWriteAtLeast20Characters => _ne ? 'कृपया कम्तीमा 20 वर्ण लेख्नुस' : 'Please write at least 20 characters';
  String get submissionFailed => _ne ? 'प्रस्तुतीकरण असफल:' : 'Submission failed:';
  String get yourContactDetailsRemainPrivate => _ne ? 'यस आवेदनलाई प्रशासकले अनुमोदन गर्नेसम्म तपाईंको सम्पर्क विवरणहरू गोप्य रहन्छ।' : 'Your contact details remain private until admin approves this application.';
  String get irrigated => _ne ? 'सिँचाइ गरिएको' : 'Irrigated';
  String get verifyNow => _ne ? 'अहिले प्रमाणित गर्नुस' : 'Verify Now';

  // ── Login screen ──────────────────────────────────────────────────────────
  String get findYourPerfectFarmland  => _ne ? 'आफ्नो उत्तम कृषि जमिन खोज्नुस' : 'Find Your Perfect\nFarmland';
  String get loginSubtitle            => _ne ? 'नेपालभरि प्रमाणित जमिन मालिकसँग जोडिनुस' : 'Connect with verified landowners across Nepal and start growing on your ideal plot.';
  String get iWantTo                  => _ne ? 'म चाहन्छु...'        : 'I want to...';
  String get roleFarmer               => _ne ? 'किसान'               : 'Farmer';
  String get roleFarmerSubtitle       => _ne ? 'जमिन खोज्न र लिज लिन' : 'Find & lease land';
  String get roleLandOwner            => _ne ? 'जमिन मालिक'            : 'Land Owner';
  String get roleLandOwnerSubtitle     => _ne ? 'आफ्नो जमिन सूचीबद्ध गर्न' : 'List your land';
  String get continueWithGoogle       => _ne ? 'Google सँग जारी राख्नुस': 'Continue with Google';
  String get continueWithPhone        => _ne ? 'फोन नम्बरसँग जारी राख्नुस': 'Continue with Phone';
  String get orDivider                => _ne ? 'वा'                  : 'or';
  String get termsPrefix              => _ne ? 'जारी राखेर तपाईं हाम्रो ': 'By continuing, you agree to our ';
  String get terms                    => _ne ? 'शर्तहरू'             : 'Terms';
  String get and                      => _ne ? ' र '                 : ' & ';
  String get privacyPolicy            => _ne ? 'गोपनीयता नीति'       : 'Privacy Policy';
  String get phoneLogin               => _ne ? 'फोन लगइन'           : 'Phone Login';
  String get enterVerificationCode    => _ne ? 'प्रमाणिकरण कोड प्रविष्ट गर्नुस': 'Enter Verification Code';
  String get sendOtp                  => _ne ? 'OTP पठाउनुस'         : 'Send OTP';
  String get verifyAndContinue        => _ne ? 'प्रमाणित गरी अगाडि बढ्नुस': 'Verify & Continue';
  String get phoneHint                => _ne ? '९८XXXXXXXX'          : '98XXXXXXXX';
  String get nepalPhonePrefix         => _ne ? '🇳🇵 +977'            : '🇳🇵 +977';
  String get changeNumber             => _ne ? 'नम्बर परिवर्तन गर्नुस': 'Change number';
  String get enterNepalPhone          => _ne ? 'नेपाली फोन नम्बर प्रविष्ट गर्नुस': 'Enter your Nepal phone number to receive an OTP';
  String get otpSentTo                => _ne ? 'को लागि OTP पठाइयो +977 ': 'A 6-digit code was sent to +977 ';

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get onboardingSkip           => _ne ? 'छोड्नुस'             : 'Skip';
  String get getStarted               => _ne ? 'सुरु गर्नुस'         : 'Get Started';
  String get next                     => _ne ? 'अर्को'               : 'Next';
  String get onb1Title                => _ne ? 'कृषि जमिन खोज्नुस'   : 'Find Agricultural Land';
  String get onb1Body                 => _ne ? 'नेपालभरि हजारौं प्रमाणित कृषि जमिन एक ठाउँमा' : 'Thousands of verified agricultural plots across Nepal in one place.';
  String get onb2Title                => _ne ? 'सुरक्षित सम्पर्क'    : 'Safe Contact';
  String get onb2Body                 => _ne ? 'KYC प्रमाणिकरण पछि मात्र मालिकसँग सम्पर्क गर्नुस' : 'Connect with landowners only after KYC verification — both parties are secure.';
  String get onb3Title                => _ne ? 'सजिलो सम्झौता'       : 'Easy Agreement';
  String get onb3Body                 => _ne ? 'आवेदन पेश गर्नुस, समीक्षा पाउनुस र लिज सम्झौता गर्नुस' : 'Submit applications, get reviewed, and finalize your lease agreement seamlessly.';
  String get landListings             => _ne ? 'जमिन सूची'           : 'Land Listings';
  String get statListings             => _ne ? 'जमिन सूचीहरू'        : 'Land Listings';
  String get statFarmers              => _ne ? 'प्रमाणित किसानहरू'   : 'Verified Farmers';
  String get statAgreements           => _ne ? 'सम्झौताहरू'          : 'Agreements';

  // ── Bottom nav ────────────────────────────────────────────────────────────
  String get explore      => _ne ? 'खोज्नुस'    : 'Explore';
  String get myLands      => _ne ? 'मेरो जमिन'  : 'My Lands';
  String get applications => _ne ? 'आवेदनहरू'   : 'Applications';
  String get messages     => _ne ? 'सन्देशहरू'  : 'Messages';
  String get profile      => _ne ? 'प्रोफाइल'   : 'Profile';

  // ── Land listings screen ──────────────────────────────────────────────────
  String get recommendedLands        => _ne ? 'सिफारिस गरिएका जमिन' : 'Recommended Lands';
  String get allListings             => _ne ? 'सबै सूचीहरू'         : 'All Listings';
  String get landsAvailable          => _ne ? 'जमिनहरू उपलब्ध'      : 'lands available';
  String get noLandsFound            => _ne ? 'जमिन फेला परेन'       : 'No Lands Found';
  String get noLandsSubtitle         => _ne ? 'अहिलेसम्म कुनै कृषि जमिन सूचीबद्ध छैन।' : 'No agricultural land listings yet. Check back soon or adjust your filters.';
  String get searchByDistrict        => _ne ? 'जिल्ला, बाली प्रकारले खोज्नुस...' : 'Search by district, crop type...';
  String get filterLands             => _ne ? 'जमिन फिल्टर गर्नुस'  : 'Filter Lands';
  String get apply                   => _ne ? 'लागू गर्नुस'          : 'Apply';
  String get province                => _ne ? 'प्रदेश'              : 'Province';
  String get all                     => _ne ? 'सबै'                 : 'All';
  String get bagmati                 => _ne ? 'बाग्मती'            : 'Bagmati';
  String get gandaki                 => _ne ? 'गण्डकी'             : 'Gandaki';
  String get lumbini                 => _ne ? 'लुम्बिनी'            : 'Lumbini';
  String get koshi                   => _ne ? 'कोशी'                : 'Koshi';
  String get kathmandu               => _ne ? 'काठमाडौं'            : 'Kathmandu';
  String get lalitpur                => _ne ? 'ललितपुर'            : 'Lalitpur';
  String get bhaktapur               => _ne ? 'भक्तपुर'            : 'Bhaktapur';
  String get pokhara                 => _ne ? 'पोखरा'              : 'Pokhara';
  String get chitwan                 => _ne ? 'चितवन'              : 'Chitwan';
  String get paddy                   => _ne ? 'धान'                 : 'Paddy';
  String get vegetable               => _ne ? 'तरकारी'              : 'Vegetable';
  String get orchard                 => _ne ? 'बगान'                : 'Orchard';
  String get pasture                 => _ne ? 'चरन'                 : 'Pasture';
  String get allCategories           => _ne ? 'सबै'                 : 'All';
  String get nepal                   => _ne ? 'नेपाल'               : 'Nepal';
  String get mapView                 => _ne ? 'नक्सा दृश्य'         : 'Map View';
  String get listView                => _ne ? 'सूची दृश्य'          : 'List View';
  String get perMonthSuffix          => _ne ? '/महिना'               : '/mo';
  String get ropani                  => _ne ? 'रोपनी'               : 'Ro.';
  String get bigha                   => _ne ? 'बिघा'                : 'bigha';
  String get district                => _ne ? 'जिल्ला'               : 'District';
  String get priceRangeMonthly       => _ne ? 'मूल्य श्रेणी (मासिक)' : 'Price Range (Monthly)';
  String get areaRangeRopani         => _ne ? 'क्षेत्रफल श्रेणी (रोपनी)' : 'Area Range (Ropani)';
  String get narrowDownYourSearch    => _ne ? 'आफ्नो खोजलाई सीमित गर्नुस' : 'Narrow down your search';
  String get reset                   => _ne ? 'रिसेट'                : 'Reset';
  // Banners
  String get banner1Headline         => _ne ? 'उपजाऊ। प्रमाणित। तपाईंको।' : 'Fertile. Verified. Yours.';
  String get banner1Subtitle         => _ne ? 'नेपालका प्रदेशहरूमा प्रमाणित कृषि भूमि खोज्नुहोस्' : 'Discover certified agricultural land across Nepal\'s provinces';
  String get banner2Headline         => _ne ? 'आजै खेती सुरु गर्नुहोस्।' : 'Start Farming Today.';
  String get banner2Subtitle         => _ne ? 'KYC प्रमाणित किसानहरूलाई प्रिमियम सूचीहरूमा प्राथमिकता प्राप्त हुन्छ' : 'KYC-verified farmers get priority access to premium listings';
  String get banner3Headline         => _ne ? 'प्रिमियम चिया बागानहरू।' : 'Premium Tea Gardens.';
  String get banner3Subtitle         => _ne ? 'इलामका उत्कृष्ट चिया बागानहरू किरायामा — सीमित उपलब्धता' : 'Ilam\'s finest tea garden leases — limited availability';
  String get virtualTour             => _ne ? 'भर्चुअल टुर' : 'Virtual Tour';

  // ── Land detail ───────────────────────────────────────────────────────────
  String get aboutThisLand           => _ne ? 'यस जमिनबारे'         : 'About This Land';
  String get applyNow                => _ne ? 'आवेदन दिनुस'          : 'Apply Now';
  String get applied                 => _ne ? 'आवेदन दिइयो'          : 'Applied';
  String get saved                   => _ne ? 'सुरक्षित'             : 'Saved';
  String get viewPhotos              => _ne ? 'फोटो हेर्नुस'         : 'View Photos';
  String get landGallery             => _ne ? 'जमिन ग्यালरी'         : 'Land Gallery';
  String get suggestedCrops          => _ne ? 'सिफारिस गरिएका बाली' : 'Suggested Crops';
  String get landFeatures            => _ne ? 'जमिनको विशेषताहरू'    : 'Land Features';
  String get similarLands            => _ne ? 'यस्तै जमिनहरू'        : 'Similar Lands';
  String get exploreEveryCorner      => _ne ? 'यस जमिनको हरेक কুনা अन्वেষণ করুন।' : 'Explore every corner of this land.';
  String get main                    => _ne ? 'मुख्य'                : 'Main';
  String get field                   => _ne ? 'खेत'                 : 'Field';
  String get waterLabel              => _ne ? 'पानी'                : 'Water';
  String get view                    => _ne ? 'दृश्य'                : 'View';
  String get bestSuitedForSoil       => _ne ? 'यस माटो प्रकारको लागि सबैभन्दा उपयुक्त।' : 'Best suited for this soil type.';
  String get rice                    => _ne ? 'ধান'                 : 'Rice';
  String get wheat                   => _ne ? 'गहुँ'                : 'Wheat';
  String get vegetables              => _ne ? 'तरकारी'              : 'Vegetables';
  String get tea                     => _ne ? 'चिया'                : 'Tea';
  String get irrigation              => _ne ? 'सिँचाई'                : 'Irrigation';
  String get roadAccess              => _ne ? 'সডক পাহুঁচ'            : 'Road Access';
  String get electricity             => _ne ? 'বিজুলি'                : 'Electricity';
  String get fencing                 => _ne ? 'বারাম্বা'              : 'Fencing';
  String get storage                 => _ne ? 'ভাণ্ডার'               : 'Storage';
  String get soilTest                => _ne ? 'माटो परीक्षण'          : 'Soil Test';
  String get landLocation            => _ne ? 'जमिनको स्थान'         : 'Land Location';
  String get message                 => _ne ? 'सन्देश'               : 'Message';
  String get chat                    => _ne ? 'च्याट'                : 'Chat';
  String get totalArea               => _ne ? 'कुल क्षेत्रफल'        : 'Total Area';
  String get soilType                => _ne ? 'माटोको प्रकार'        : 'Soil Type';
  String get waterSource             => _ne ? 'পানীর উৎস'         : 'Water Source';
  String get leaseTerm               => _ne ? 'লিজ মেয়াদ'             : 'Lease Term';
  String get flexible                => _ne ? 'লাচিলো'                : 'Flexible';
  String get submitApplication       => _ne ? 'आवेदन पेश गर्नুস'    : 'Submit Application';
  String get farmingExperience       => _ne ? 'খেতি অনুভব'           : 'Farming Experience';
  String get intendedCrops           => _ne ? 'उद्देश्यित बालीहरू'   : 'Intended Crops';
  String get proposalMessage         => _ne ? 'प्रस्ताव सन्देश'      : 'Proposal Message';
  String get cropsHint               => _ne ? 'जस्तै: धान, गहुँ, तरकारी': 'e.g. Rice, Wheat, Vegetables';
  String get proposalHint            => _ne ? 'आफ्नो खेती योजना वर्णन गर्नुस...' : 'Describe your farming plan...';
  String get kycRequired             => _ne ? 'KYC प्रमाणिकरण आवश्यक': 'KYC Verification Required';
  String get signInRequired          => _ne ? 'साइन इन आवश्यक'       : 'Sign In Required';
  String get contactUnlocked         => _ne ? 'सम्पर्क खुलेको'       : 'Contact unlocked';
  String get exactLocationNotProvided=> _ne ? 'मालिकले सटीक स्थान प्रदान गरेको छैन' : 'Exact location not provided by owner';
  String get viewFullMap             => _ne ? 'पूर्ण नक्सा हेर्नुस'  : 'View full map';

  // ── My Lands screen ───────────────────────────────────────────────────────
  String get listings                => _ne ? 'सूचीहरू'              : 'Listings';
  String get applicants              => _ne ? 'आवेदकहरू'             : 'Applicants';
  String get pendingStr              => _ne ? 'विचाराधीन'             : 'Pending';
  String get revenue                 => _ne ? 'आम्दानी'               : 'Revenue';
  String get listLand                => _ne ? 'जमिन सूचीबद्ध गर्नुस' : 'List Land';
  String get listYourLandBtn         => _ne ? 'आफ्नो जमिन सूचीबद्ध गर्नुस': 'List Your Land';
  String get noLandsHere             => _ne ? 'यहाँ कुनै जमिन छैन'   : 'No Lands Here';
  String get noLandsHereSubtitle     => _ne ? '"जमिन सूचीबद्ध गर्नुस" ट्याप गर्नुस' : 'Tap "List Land" to add your first agricultural land listing.';
  String get editListing             => _ne ? 'सूची सम्पादन गर्नुस'  : 'Edit Listing';
  String get listYourLand            => _ne ? 'तपाईंको जमिन सूचीबद्ध गर्नुस' : 'List Your Land';
  String get addLand                 => _ne ? 'जमिन थप्नुस'          : 'Add Land';
  String get landTitle               => _ne ? 'जमिन शीर्षक *'         : 'Land Title *';
  String get landTitleHint           => _ne ? 'उदा: उपजाऊ धान खेत — चितवन' : 'e.g. Fertile Paddy Fields — Chitwan';
  String get titleRequired           => _ne ? 'शीर्षक आवश्यक छ'       : 'Title is required';
  String get municipality            => _ne ? 'नगरपालिका *'          : 'Municipality *';
  String get pleaseWaitImages        => _ne ? 'कृपया सबै छविहरू अपलोड हुन कुर्नुहोस्' : 'Please wait for all images to finish uploading';
  String get area                    => _ne ? 'क्षेत्रफल'             : 'Area';
  String get areaRopani              => _ne ? 'क्षेत्रफल (रोपनी)'    : 'Area (Ropani)';
  String get leasePerMonth           => _ne ? 'लिज/महिना (NPR)'      : 'Lease/Month (NPR)';
  String get irrigationAvailable     => _ne ? 'सिँचाइ उपलब्ध'        : 'Irrigation Available';
  String get hasIrrigationSub        => _ne ? 'जमिनमा सिँचाइ पूर्वाधार छ' : 'Land has irrigation infrastructure';
  String get coverPhoto              => _ne ? 'मुख्य फोटो'           : 'Cover Photo';
  String get tapToAddPhoto           => _ne ? 'फोटो थप्न ट्याप गर्नुस': 'Tap to add a photo';
  String get submitListing           => _ne ? 'सूची पेश गर्नुस'      : 'Submit Listing';
  String get editListingTitle        => _ne ? 'सूची सम्पादन'         : 'Edit Listing';
  String get landCategory            => _ne ? 'जमिन वर्ग'            : 'Land Category';
  String get viewApplications        => _ne ? 'आवेदनहरू हेर्नुस'      : 'View Applications';
  String get deactivateListing       => _ne ? 'सूची निष्क्रिय गर्नुस' : 'Deactivate Listing';
  String get activateListing         => _ne ? 'सूची सक्रिय गर्नुस'   : 'Activate Listing';
  String get deleteListing           => _ne ? 'सूची मेटाउनुस'        : 'Delete Listing';
  String get goodMorning             => _ne ? 'शुभ प्रभात'           : 'Good morning';
  String get goodAfternoon           => _ne ? 'शुभ अपरान्ह'          : 'Good afternoon';
  String get goodEvening             => _ne ? 'शुभ सन्ध्या'          : 'Good evening';
  String get viewKycStatus           => _ne ? 'KYC स्थिति हेर्नुस'   : 'View KYC Status';
  String get submitKyc               => _ne ? 'KYC पेश गर्नुस'       : 'Submit KYC';

  // ── Applications screen ───────────────────────────────────────────────────
  String get myApplications          => _ne ? 'मेरा आवेदनहरू'        : 'My Applications';
  String get noApplicationsYetTitle  => _ne ? 'अहिलेसम्म कुनै आवेदन छैन': 'No Applications Yet';
  String get noApplicationsSubtitle  => _ne ? 'उपलब्ध जमिन ब्राउज गरी पहिलो आवेदन दिनुस।' : 'Browse available lands and submit\nyour first application.';
  String get browseAvailableLands    => _ne ? 'उपलब्ध जमिन हेर्नुस'  : 'Browse Available Lands';
  String get unknownLand             => _ne ? 'अज्ञात जमिन'          : 'Unknown Land';
  String get appliedOn               => _ne ? 'आवेदन मिति'           : 'Applied on';
  String get noApplicationsYet       => _ne ? 'कुनै आवेदन छैन'        : 'No applications yet';

  // ── Chat screen ───────────────────────────────────────────────────────────
  String get searchConversations     => _ne ? 'कुराकानीहरू खोज्नुस...' : 'Search conversations...';
  String get noMessagesYet           => _ne ? 'अहिलेसम्म कुनै सन्देश छैन': 'No Messages Yet';
  String get noMessagesSubtitle      => _ne ? 'कुनै सूची हेरेर जमिन मालिकसँग कुराकानी सुरु गर्नुस।' : 'Start a conversation with a land owner by viewing a listing.';
  String get signInToView            => _ne ? 'सन्देशहरू हेर्न साइन इन गर्नुस' : 'Sign in to view messages';
  String get online                  => _ne ? 'अनलाइन'               : 'Online';
  String get offline                 => _ne ? 'अफलाइन'               : 'Offline';
  String get typeMessage             => _ne ? 'सन्देश टाइप गर्नुस...' : 'Type a message...';
  String get sayHello                => _ne ? 'अहिलेसम्म कुनै सन्देश छैन।\nनमस्ते भन्नुस!' : 'No messages yet.\nSay hello!';
  String get today                   => _ne ? 'आज'                   : 'Today';
  String get yesterday               => _ne ? 'हिजो'                 : 'Yesterday';
  String get camera                  => _ne ? 'क्यामेरा'             : 'Camera';
  String get gallery                 => _ne ? 'ग्यालरी'              : 'Gallery';
  String get document                => _ne ? 'कागजात'               : 'Document';
  String get location                => _ne ? 'स्थान'                : 'Location';

  // ── Profile Screen ───────────────────────────────────────────────────────
  String get profileTitle            => _ne ? 'प्रोफाइल'             : 'Profile';
  String get notSignedIn             => _ne ? 'साइन इन गरिएको छैन'   : 'Not Signed In';
  String get signIn                  => _ne ? 'साइन इन गर्नुहोस्'    : 'Sign In';
  String get kycVerified             => _ne ? 'KYC प्रमाणित'         : 'KYC Verified';
  String get kycPending              => _ne ? 'KYC विचाराधीन'        : 'KYC Pending';
  String get kycRejected             => _ne ? 'KYC अस्वीकृत'         : 'KYC Rejected';
  String get editProfile             => _ne ? 'प्रोफाइल सम्पादन गर्नुहोस्' : 'Edit Profile';
  String get kycVerification         => _ne ? 'KYC प्रमाणीकरण'       : 'KYC Verification';
  String get myWallet                => _ne ? 'मेरो वालेट'            : 'My Wallet';
  String get myLandListings          => _ne ? 'मेरो जमिन सूचीहरू'    : 'My Land Listings';
  String get savedLands              => _ne ? 'सुरक्षित जमिनहरू'      : 'Saved Lands';
  String get reviewsAndRatings       => _ne ? 'समीक्षा र मूल्याङ्कनहरू' : 'Reviews & Ratings';
  String get helpAndSupport          => _ne ? 'मद्दत र सहयोग'        : 'Help & Support';
  String get switchToFarmer          => _ne ? 'किसानमा स्विच गर्नुहोस्' : 'Switch to Farmer';
  String get switchToLandOwner       => _ne ? 'जमिन मालिकमा स्विच गर्नुहोस्' : 'Switch to Land Owner';
  String get adminPanel              => _ne ? 'प्रशासक प्यानल'        : 'Admin Panel';
  String get applicationsStat        => _ne ? 'आवेदनहरू'              : 'Applications';
  String get approvedStat            => _ne ? 'स्वीकृत'               : 'Approved';
  String get ratingStat              => _ne ? 'मूल्याङ्कन'            : 'Rating';
  String get addMoney                => _ne ? 'पैसा थप्नुहोस्'        : 'Add Money';
  String get saveChanges             => _ne ? 'परिवर्तनहरू सुरक्षित गर्नुहोस्' : 'Save Changes';
  String get fullName                => _ne ? 'पूरा नाम'              : 'Full Name';
  String get phoneNumber             => _ne ? 'फोन नम्बर'            : 'Phone Number';
  String get bioOptional             => _ne ? 'बायो (वैकल्पिक)'      : 'Bio (optional)';
  String get profileUpdatedSuccessfully => _ne ? 'प्रोफाइल सफलतापूर्वक अपडेट गरियो' : 'Profile updated successfully';
  String get switchTo                => _ne ? 'स्विच गर्नुहोस्'        : 'Switch to';
  String get switchRoleMessage       => _ne ? 'तपाईं यसको दृश्यमा स्विच गर्नुहुन्छ। तपाईं कुनै समयमा फिर्ता स्विच गर्न सक्नुहुन्छ।' : 'You will be switched to the view. You can switch back at any time.';
  String get switchLabel             => _ne ? 'स्विच'                 : 'Switch';

  // ── Public profile screen ─────────────────────────────────────────────────
  String get publicProfileTitle      => _ne ? 'प्रोफाइल'             : 'Profile';
  String get userNotFound            => _ne ? 'प्रयोगकर्ता फेला परेन' : 'User not found';
  String get publicProfileListings   => _ne ? 'सूचीहरू'              : 'Listings';
  String get noListingsYet           => _ne ? 'अहिलेसम्म कुनै सूची छैन' : 'No listings yet';
  String get noListingsYetSubtitle   => _ne ? 'यस प्रयोगकर्ताले अहिलेसम्म कुनै जमिन सूचीबद्ध गरेको छैन' : 'This user hasn\'t listed any land yet.';

  // ── Settings screen ───────────────────────────────────────────────────────
  String get appearance              => _ne ? 'उपस्थिति'             : 'Appearance';
  String get theme                   => _ne ? 'थिम'                  : 'Theme';
  String get light                   => _ne ? 'हल्को'                : 'Light';
  String get dark                    => _ne ? 'गाढा'                 : 'Dark';
  String get system                  => _ne ? 'प्रणाली'              : 'System';
  String get language                => _ne ? 'भाषा'                 : 'Language';
  String get english                 => _ne ? 'अंग्रेजी'             : 'English';
  String get nepali                  => _ne ? 'नेपाली'               : 'Nepali';
  String get notifications           => _ne ? 'सूचनाहरू'             : 'Notifications';
  String get pushNotifications       => _ne ? 'पुश सूचनाहरू'          : 'Push Notifications';
  String get legal                   => _ne ? 'कानूनी'                : 'Legal';
  String get termsOfService          => _ne ? 'सेवा शर्तहरू'          : 'Terms of Service';

  // ── Notifications screen ──────────────────────────────────────────────────
  String get notificationsTitle      => _ne ? 'सूचनाहरू'             : 'Notifications';
  String get markAllRead             => _ne ? 'सबै पढिएको चिन्ह लगाउनुस': 'Mark all read';
  String get noNotifications         => _ne ? 'कुनै सूचना छैन'        : 'No Notifications';
  String get allCaughtUp             => _ne ? 'तपाईं सबै अपडेटमा हुनुहुन्छ!' : 'You are all caught up! Notifications will appear here.';

  // ── KYC screen ────────────────────────────────────────────────────────────
  String get kycTitle                => _ne ? 'KYC प्रमाणिकरण'       : 'KYC Verification';
  String get kycInfoBanner           => _ne ? 'नागरिकता ID र सेल्फी अपलोड गर्नुस। दस्तावेजहरू सुरक्षित छन्।' : 'Upload your Citizenship ID and a selfie. Documents are securely stored and reviewed by our admin team.';
  String get personalInfo            => _ne ? 'व्यक्तिगत जानकारी'    : 'Personal Information';
  String get citizenshipId           => _ne ? 'नागरिकता ID'           : 'Citizenship ID';
  String get frontSide               => _ne ? 'अगाडिको भाग'           : 'Front Side';
  String get backSide                => _ne ? 'पछाडिको भाग'           : 'Back Side';
  String get selfieVerification      => _ne ? 'सेल्फी प्रमाणिकरण'    : 'Selfie Verification';
  String get selfieHint              => _ne ? 'चेहरा स्पष्ट देखिने सेल्फी': 'Clear selfie with face visible';
  String get addressInfo             => _ne ? 'ठेगाना जानकारी'        : 'Address Information';
  String get streetTole              => _ne ? 'सडक / टोल'             : 'Street / Tole';
  String get wardNo                  => _ne ? 'वार्ड नं.'              : 'Ward No.';
  String get municipalityCity        => _ne ? 'नगरपालिका / सहर'       : 'Municipality / City';
  String get submitForApproval       => _ne ? 'अनुमोदनका लागि पेश गर्नुस': 'Submit for Admin Approval';
  String get submittedForReview      => _ne ? 'समीक्षाका लागि पेश गरियो': 'Submitted for Review';
  String get kycSuccessBody          => _ne ? 'तपाईंको KYC दस्तावेजहरू १-२ कार्य दिनमा समीक्षा गरिनेछ।' : 'Our admin team will verify your documents within 1–2 business days.';
  String get occupation              => _ne ? 'पेशा'                  : 'Occupation';
  String get dateOfBirth             => _ne ? 'जन्म मिति'             : 'Date of Birth';
  String get tapToUpload             => _ne ? 'अपलोड गर्न ट्याप गर्नుస': 'Tap to upload';
  String get retake                  => _ne ? 'पुन: खिच्नुस'          : 'Retake';
  String get uploaded                => _ne ? 'अपलोड भयो'            : 'Uploaded';
  String get uploadAllDocs           => _ne ? 'कृपया सबै आवश्यक दस्तावेजहरू अपलोड गर्नुस।': 'Please upload all required documents.';
  String get kycVerificationRequired => _ne ? 'KYC प्रमाणिकरण आवश्यक': 'KYC Verification Required';

  // ── Wallet screen ─────────────────────────────────────────────────────────
  String get walletTitle             => _ne ? 'मेरो वालेट'            : 'My Wallet';
  String get availableBalance        => _ne ? 'उपलब्ध ब्यालेन्स'     : 'Available Balance';
  String get readyToList             => _ne ? 'जमिन सूचीबद्ध गर्न तयार': 'Ready to list land';
  String get needMoreBalance         => _ne ? 'सूचीबद्ध गर्न थप Rs चाहिन्छ': 'more to list';
  String get quickAdd                => _ne ? 'छिटो थप'               : 'Quick Add';
  String get transactionHistory      => _ne ? 'लेनदेन इतिहास'        : 'Transaction History';
  String get noTransactions          => _ne ? 'अहिलेसम्म कुनै लेनदेन छैन': 'No transactions yet';
  String get addToWallet             => _ne ? 'वालेटमा थप्नुस'        : 'Add to Wallet';
  String get listingFeeNote          => _ne ? 'प्रत्येक जमिन सूचीबद्ध गर्दा Rs 20 काटिन्छ।': 'A listing fee of Rs 20 is deducted each time you list a new land.';
  String get amount                  => _ne ? 'रकम'                   : 'Amount';
  String get amountNPR               => _ne ? 'रकम (NPR)'             : 'Amount (NPR)';
  String get currentBalance          => _ne ? 'हालको ब्यालेन्स'       : 'Current balance';
  String get minimumReminder         => _ne ? 'जमिन सूचीबद्ध गर्न कम्तीमा Rs 20 चाहिन्छ।': 'Minimum Rs 20 is needed to list a land.';

  // ── Saved Lands screen ────────────────────────────────────────────────────
  String get savedLandsTitle         => _ne ? 'सुरक्षित जमिनहरू'      : 'Saved Lands';
  String get noSavedLands            => _ne ? 'कुनै सुरक्षित जमिन छैन': 'No Saved Lands';
  String get noSavedSubtitle         => _ne ? 'मनपरेको सूचीमा मुटु आइकन ट्याप गर्नुस।': 'Tap the heart icon on any listing to save lands you are interested in.';
  String get browseLands             => _ne ? 'जमिन ब्राउज गर्नुस'   : 'Browse Lands';

  // ── Reviews screen ────────────────────────────────────────────────────────
  String get reviewsTitle            => _ne ? 'समीक्षा र मूल्याङ्कन' : 'Reviews & Ratings';
  String get writeReview             => _ne ? 'समीक्षा लेख्नुस'       : 'Write a Review';
  String get allReviews              => _ne ? 'सबै समीक्षाहरू'        : 'All Reviews';
  String get noReviewsYet            => _ne ? 'अहिलेसम्म कुनै समीक्षा छैन': 'No Reviews Yet';
  String get yourRating              => _ne ? 'तपाईंको मूल्याङ्कन'    : 'Your Rating';
  String get submitReview            => _ne ? 'समीक्षा पेश गर्नुस'    : 'Submit Review';
  String get reviewPlaceholder       => _ne ? 'यस जमिन मालिक वा किसानसँगको अनुभव साझा गर्नुस...' : 'Share your experience with this land owner or farmer...';
  String get reviewSubmitted         => _ne ? 'समीक्षा पेश भयो!'      : 'Review submitted!';

  // ── Help & Support screen ─────────────────────────────────────────────────
  String get helpTitle               => _ne ? 'मद्दत र समर्थन'       : 'Help & Support';
  String get faq                     => _ne ? 'बारम्बार सोधिने प्रश्नहरू': 'FAQ';
  String get contactUs               => _ne ? 'सम्पर्क गर्नुस'        : 'Contact Us';
  String get searchFaq               => _ne ? 'बारम्बार सोधिने प्रश्नहरू खोज्नुस...' : 'Search frequently asked questions...';
  String get noFaqMatch              => _ne ? 'तपाईंको खोजसँग मिल्दो प्रश्न फेला परेन' : 'No FAQs matched your search';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ne'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
