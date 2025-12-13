enum Flavor {
  customer,
  partner,
  admin,
}

enum AppType {
  customer,
  restaurant,
  driver,
  admin,
}

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String packageName;
  final AppThemeConfig theme;
  final List<AppType> supportedTypes;
  
  FlavorConfig._internal({
    required this.flavor,
    required this.appName,
    required this.packageName,
    required this.theme,
    required this.supportedTypes,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception('FlavorConfig not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static void initialize({required Flavor flavor}) {
    switch (flavor) {
      case Flavor.customer:
        _instance = FlavorConfig._internal(
          flavor: Flavor.customer,
          appName: 'To Order',
          packageName: 'com.wassly.customer',
          theme: AppThemeConfig(
            primaryColor: 0xFFFF6B35, // Orange
            secondaryColor: 0xFF004E89, // Blue
            isDark: false,
          ),
          supportedTypes: [AppType.customer],
        );
        break;

      case Flavor.partner:
        _instance = FlavorConfig._internal(
          flavor: Flavor.partner,
          appName: 'To Order Partner',
          packageName: 'com.wassly.partner',
          theme: AppThemeConfig(
            primaryColor: 0xFF2E7D32, // Green
            secondaryColor: 0xFF1565C0, // Dark Blue
            isDark: false,
          ),
          supportedTypes: [AppType.restaurant, AppType.driver],
        );
        break;

      case Flavor.admin:
        _instance = FlavorConfig._internal(
          flavor: Flavor.admin,
          appName: 'To Order Admin',
          packageName: 'com.wassly.admin',
          theme: AppThemeConfig(
            primaryColor: 0xFF6A1B9A, // Purple
            secondaryColor: 0xFF00695C, // Teal
            isDark: false,
          ),
          supportedTypes: [AppType.admin],
        );
        break;
    }
  }

  bool isCustomerApp() => flavor == Flavor.customer;
  bool isPartnerApp() => flavor == Flavor.partner;
  bool isAdminApp() => flavor == Flavor.admin;

  bool supports(AppType type) => supportedTypes.contains(type);
}

class AppThemeConfig {
  final int primaryColor;
  final int secondaryColor;
  final bool isDark;

  AppThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });
}

