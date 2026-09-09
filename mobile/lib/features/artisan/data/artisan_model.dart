class ArtisanDashboard {
  final ArtisanDashboardProfile profile;
  final ArtisanDashboardSummary summary;

  const ArtisanDashboard({
    required this.profile,
    required this.summary,
  });

  factory ArtisanDashboard.fromJson(Map<String, dynamic> json) {
    return ArtisanDashboard(
      profile: ArtisanDashboardProfile.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
      summary: ArtisanDashboardSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
    );
  }
}

class ArtisanDashboardProfile {
  final String name;
  final String craftType;

  const ArtisanDashboardProfile({
    required this.name,
    required this.craftType,
  });

  factory ArtisanDashboardProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return ArtisanDashboardProfile(
      name: json['name'] as String,
      craftType: json['craftType'] as String,
    );
  }
}

class ArtisanDashboardSummary {
  final int productCount;
  final int publishedProductCount;
  final int pendingOrdersCount;
  final int newEnquiriesCount;
  final int unreadNotificationsCount;

  const ArtisanDashboardSummary({
    required this.productCount,
    required this.publishedProductCount,
    required this.pendingOrdersCount,
    required this.newEnquiriesCount,
    required this.unreadNotificationsCount,
  });

  factory ArtisanDashboardSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return ArtisanDashboardSummary(
      productCount: (json['productCount'] as num).toInt(),
      publishedProductCount:
          (json['publishedProductCount'] as num).toInt(),
      pendingOrdersCount:
          (json['pendingOrdersCount'] as num).toInt(),
      newEnquiriesCount:
          (json['newEnquiriesCount'] as num).toInt(),
      unreadNotificationsCount:
          (json['unreadNotificationsCount'] as num).toInt(),
    );
  }
}

class ArtisanProfile {
  final String name;
  final String craftType;
  final String state;
  final String district;
  final String preferredLanguage;

  const ArtisanProfile({
    required this.name,
    required this.craftType,
    required this.state,
    required this.district,
    required this.preferredLanguage,
  });

  factory ArtisanProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    String readString(
      String key, {
      String fallback = '',
    }) {
      final value = json[key];

      if (value is String && value.trim().isNotEmpty) {
        return value;
      }

      return fallback;
    }

    return ArtisanProfile(
      name: readString(
        'name',
        fallback: 'Artisan',
      ),
      craftType: readString(
        'craftType',
        fallback: 'Artisan',
      ),
      state: readString(
        'state',
        fallback: 'India',
      ),
      district: readString(
        'district',
        fallback: '',
      ),
      preferredLanguage: readString(
        'preferredLanguage',
        fallback: 'English',
      ),
    );
  }
}