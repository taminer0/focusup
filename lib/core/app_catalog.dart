class AppCatalogItem {
  final String package;
  final String name;
  const AppCatalogItem(this.package, this.name);
}

/// Danh sách app hiển thị ở màn chọn. Sau này có native thì thay bằng danh sách app cài trên máy.
class AppCatalog {
  AppCatalog._();

  static const items = [
    AppCatalogItem('com.zhiliaoapp.musically', 'TikTok'),
    AppCatalogItem('com.instagram.android', 'Instagram'),
    AppCatalogItem('com.google.android.youtube', 'YouTube'),
    AppCatalogItem('com.facebook.katana', 'Facebook'),
    AppCatalogItem('com.facebook.orca', 'Messenger'),
    AppCatalogItem('com.twitter.android', 'Twitter'),
    AppCatalogItem('com.whatsapp', 'WhatsApp'),
    AppCatalogItem('com.google.android.googlequicksearchbox', 'Google'),
  ];

  static String nameOf(String package) => items
      .firstWhere((e) => e.package == package,
      orElse: () => AppCatalogItem(package, package))
      .name;
}