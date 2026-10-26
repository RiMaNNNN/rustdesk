/// Facts about this patched build that the user interface shows, kept free of
/// platform code so that they can be unit-tested.

/// One-line label shown on the home page and in About.
const String kPatchedBuildLabel =
    'Current Version Patched by CLAUDE - Jun & Oct 2026 - RustDesk 1.5.0 base (updater disabled)';

/// Shown in place of the update switches, which this build removes.
const String kPatchedBuildUpdaterNote =
    'Software updates are disabled in this patched build. A stock RustDesk '
    'update would overwrite the local patches (render-slowdown fix, dual-GPU '
    'defaults, encrypted-only sessions, NordVPN Meshnet guide). New versions '
    'are built from the patched source instead.';

/// Port that direct IP access listens on when its option is empty.
const String kDirectAccessDefaultPort = '21118';

/// The port direct IP access listens on: [stored] when set, else the default.
String effectiveDirectAccessPort(String stored) =>
    stored.isEmpty ? kDirectAccessDefaultPort : stored;

/// Splits a stored whitelist option into its entries.
///
/// [stored] is the raw option value, a comma-separated list. [emptyValue] is
/// what RustDesk stores for an empty list; it differs between stock and
/// custom clients, so the caller passes it in.
List<String> whitelistEntries(String stored, String emptyValue) {
  if (stored == emptyValue) {
    return const [];
  }
  return stored.split(',').where((e) => e.isNotEmpty).toList();
}

/// How the Meshnet guide reports the IP whitelist.
enum WhitelistStatus {
  /// Entries exist: only those addresses can reach the password prompt.
  active,

  /// Direct IP access listens but no address is listed: anyone who reaches
  /// the port gets the password prompt.
  missingWhileExposed,

  /// No entries and direct IP access is off: nothing to protect yet.
  off,
}

/// Classifies the whitelist for the guide from [directIpEnabled] and the
/// whitelist [entries].
WhitelistStatus whitelistStatus(
    {required bool directIpEnabled, required List<String> entries}) {
  if (entries.isNotEmpty) {
    return WhitelistStatus.active;
  }
  return directIpEnabled
      ? WhitelistStatus.missingWhileExposed
      : WhitelistStatus.off;
}
