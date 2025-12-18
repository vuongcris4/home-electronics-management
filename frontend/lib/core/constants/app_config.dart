class AppConfig {
  // Đọc từ command line lúc build/run
  static const String apiHost = String.fromEnvironment(
    'API_HOST', 
    defaultValue: 'localhost',
  );

  static const String protocol = String.fromEnvironment(
    'PROTOCOL', 
    defaultValue: 'https',
  );

  // Tự động suy luận URL dựa trên thông số trên
  static String get baseUrl => "$protocol://$apiHost/api";
  
  // Nếu dùng https thì ws phải là wss
  static String get wsUrl => "${protocol == 'https' ? 'wss' : 'ws'}://$apiHost/ws";
}