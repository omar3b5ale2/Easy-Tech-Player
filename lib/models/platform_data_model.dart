class PlatformData {
  final String platformName;
  final String platformBaseUrl;
  final String token;
  PlatformData({
    required this.platformName,
    required this.platformBaseUrl,
    required this.token,

  });

  // Convert a Map to a PlatformData object
  factory PlatformData.fromMap(Map<String, dynamic> map) {
    return PlatformData(
      platformName: map['platform_name'],
      platformBaseUrl: map['platform_base_url'],
      token: map['token']
    );
  }

  // Convert a PlatformData object to a Map
  // Map<String, dynamic> toMap() {
  //   return {
  //     'platform_name': platformName,
  //     'platform_base_url': platformBaseUrl,
  //     'token': token,
  //
  //   };
  // }
}