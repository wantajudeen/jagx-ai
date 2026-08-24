import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://tpgrbyotajjvpabpzmob.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get jagxApiKey =>
      dotenv.env['JAGX_API_KEY'] ?? '';

  static String get openRouterApiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static String get nvidiaApiKey =>
      dotenv.env['NVIDIA_API_KEY'] ?? '';

  static String get edenApiKey =>
      dotenv.env['EDEN_API_KEY'] ?? '';
}
