// Cloudinary Configuration
//
// Current Configuration:
// - Cloud Name: dxgxkqaqz
// - Upload Preset ID: 76dfc828-5ae3-4d77-a4c3-dc6bb38cc935 (unsigned)
//
// To verify this configuration:
// 1. Go to Cloudinary Dashboard (https://cloudinary.com/console)
// 2. Verify cloud name matches 'dxgxkqaqz'
// 3. Go to Settings -> Upload
// 4. Under "Upload presets", verify:
//    - Preset ID matches the one below
//    - Signing Mode is set to "Unsigned"
//    - Status is "Enabled"
class CloudinaryConfig {
  // Cloud name from your Cloudinary dashboard
  static const String cloudName = 'dsrikhjkc';

  // API credentials
  static const String apiKey = '554259332297316';
  static const String apiSecret = 'iQtgIRmdYn4yaNtx-vqzptz2iSw';

  // Unsigned upload preset ID configured in Cloudinary
  // This is the unique identifier for the preset, not the preset name
  static const String uploadPreset = 'athlete_pfp';

  // Helper method to validate configuration
  static bool isValid() {
    return cloudName.isNotEmpty &&
        uploadPreset.isNotEmpty &&
        apiKey.isNotEmpty &&
        apiSecret.isNotEmpty;
  }

  // Helper method to get debug info
  static String getDebugInfo() {
    return '''
Cloudinary Configuration:
- Cloud Name: $cloudName
- Upload Preset: $uploadPreset
- API Key: $apiKey
- Configuration Valid: ${isValid()}
''';
  }
}
