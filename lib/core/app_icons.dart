class AppIcons {
  AppIcons._();

  static const Map<String, String> _byPackage = {
    'com.zhiliaoapp.musically': 'assets/images/TikTok.png',
    'com.ss.android.ugc.trill': 'assets/images/TikTok.png',
    'com.facebook.katana': 'assets/images/Facebook.png',
    'com.instagram.android': 'assets/images/Instagram.png',
    'com.google.android.youtube': 'assets/images/YouTube.png',
    'com.facebook.orca': 'assets/images/Messenger.png',
    'com.whatsapp': 'assets/images/WhatsApp.png',
    'com.twitter.android': 'assets/images/Twitter.png',
    'com.google.android.googlequicksearchbox': 'assets/images/google.png',
  };

  static String? of(String packageName) => _byPackage[packageName];
}