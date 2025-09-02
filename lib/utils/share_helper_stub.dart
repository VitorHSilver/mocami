// Stub for non-web platforms. Defines the same API used by the web helper.
Future<String?> shareCsv(String filename, String csv) async {
  // No-op on non-web; the native flow uses path_provider + share_plus instead.
  return null;
}
