class AppConfig {
  // Domain chính (Authority)
  static const String apiHost = "mrh3.dongnama.app";

  // Base URL cho API HTTP
  static const String baseUrl = "https://$apiHost/api";

  // Base URL cho WebSocket (lưu ý wss://)
  static const String wsUrl = "wss://$apiHost/ws";
}
