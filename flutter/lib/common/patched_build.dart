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

/// One entry of a guide list: a short [lead] shown in bold, then its [text].
class GuideEntry {
  /// Creates the entry from its bold [lead] and the [text] that follows it.
  const GuideEntry(this.lead, this.text);

  /// Shown in bold, followed by a colon.
  final String lead;

  /// The explanation shown after the lead.
  final String text;
}

/// Title of the Meshnet guide dialog.
const String kMeshnetGuideTitle = 'Private connection through NordVPN Meshnet';

/// Text of the link that opens the guide, in the desktop Security settings and
/// in the mobile About section.
const String kMeshnetGuideLinkText =
    'Private connection through NordVPN Meshnet: the setup in use, step by step';

/// Opening paragraph of the guide.
const String kMeshnetGuideIntro =
    "These devices reach each other through NordVPN Meshnet instead of "
    "RustDesk's public servers. Meshnet gives each device a private address and "
    "an encrypted tunnel to the other, RustDesk on each device accepts direct "
    "connections on port $kDirectAccessDefaultPort only from the other device's "
    "Meshnet address, and the password and the two-factor code are still "
    "required. The setup was completed and verified on 26 and 27 October 2026. "
    "The steps below are the ones that were taken; repeat the matching step "
    "when something changes.";

/// How the parts fit together, one paragraph per entry.
const List<String> kMeshnetGuideDesign = [
  "Both devices run the NordVPN app signed in to the same Nord account, with "
      "Meshnet switched on. Meshnet gives each device a private address in the "
      "100.x.x.x range and a Nord name, and links the devices with an "
      "end-to-end encrypted tunnel (NordLynx, based on WireGuard) that keeps "
      "working while the VPN is connected.",
  "RustDesk on each device has direct IP access on, port "
      "$kDirectAccessDefaultPort, and an IP whitelist holding only the other "
      "device's Meshnet address. A connection is made by typing that address, "
      "a colon and the port in the ID field; it runs from device to device "
      "with no RustDesk server in between.",
  "The RustDesk ID is not used on this path. With the IP whitelist on, a "
      "connection by ID is refused, and RustDesk's public server now also "
      "refuses to broker a connection by ID unless the controlling device is "
      "logged in to a RustDesk account.",
];

/// What was done on the PC, in order.
const List<String> kMeshnetGuidePcSteps = [
  "NordVPN app: Meshnet switched on and left on. In the Meshnet device list, "
      "the phone's entry allows remote access (incoming connections), with "
      "traffic routing and local network access off.",
  "RustDesk, Settings, Security: \"Unlock security settings\", then "
      "\"Enable direct IP access\" ticked, port $kDirectAccessDefaultPort.",
  "\"Use IP whitelisting\" ticked, with the phone's current Meshnet address as "
      "the only entry.",
  "\"Use ID whitelisting\", optional, with the phone's RustDesk ID. The list "
      "is checked on every connection, Meshnet included: a second controlling "
      "device needs its ID added, or the list cleared, before it can connect.",
  "\"Use permanent password\" with a password of at least 16 characters, and "
      "\"Enable two-factor authentication\" with trusted devices off, so the "
      "code is asked at every connection.",
  "Windows Firewall: the installer script limited the inbound RustDesk rule to "
      "TCP port $kDirectAccessDefaultPort, plus the UDP rule. Nothing else is "
      "open.",
  "The RustDesk service runs in the background (tray icon), so the PC stays "
      "reachable whenever NordVPN is connected with Meshnet on.",
];

/// What was done on the phone, in order.
const List<String> kMeshnetGuidePhoneSteps = [
  "NordVPN app, same Nord account: Meshnet switched on. In its device list, "
      "the PC's entry allows remote access (this is what lets the PC control "
      "the phone), with traffic routing and local network access off.",
  "Split tunneling stays as you prefer it. Its only part in this setup was "
      "rebuilding the tunnel once; see \"If it does not connect\".",
  "The patched RustDesk app built from this fork, installed in place of the "
      "store version.",
  "RustDesk, Settings: \"Direct IP access\" switched on. The local address "
      "shown under it is the phone's Meshnet address; the port is "
      "$kDirectAccessDefaultPort, shown greyed as the default and typed in to "
      "make it explicit.",
  "\"Use IP whitelisting\" with the PC's current Meshnet address as the only "
      "entry, so that only the PC can reach the phone.",
  "RustDesk home screen: a permanent password set, and \"Start service\" "
      "switched on with the screen capture and input permissions granted when "
      "Android asked. This is only needed while the phone is to be controlled.",
];

/// How a session from the phone to the PC is opened, in order.
const List<String> kMeshnetGuidePhoneToPcSteps = [
  "Phone: NordVPN connected with Meshnet on, and the PC shown as online in "
      "the Meshnet device list.",
  "RustDesk, ID field: the PC's Meshnet address followed by "
      ":$kDirectAccessDefaultPort, then connect. The PC's Nord name followed "
      "by :$kDirectAccessDefaultPort works too.",
  "Enter the PC's password, then the two-factor code.",
  "The connection type, shown at the top of the session's display options, "
      "reads \"Direct and unencrypted connection\". That is the Meshnet case: "
      "the tunnel encrypts everything.",
];

/// How a session from the PC to the phone is opened, in order.
const List<String> kMeshnetGuidePcToPhoneSteps = [
  "Phone: RustDesk open with \"Start service\" on and its permanent password "
      "set; NordVPN connected with Meshnet on.",
  "PC, RustDesk ID field: the phone's Meshnet address followed by "
      ":$kDirectAccessDefaultPort, then connect.",
  "Enter the phone's password, and accept on the phone if it asks. The "
      "phone's IP whitelist must hold the PC's current Meshnet address, "
      "otherwise the phone answers that it accepts encrypted sessions only.",
];

/// Troubleshooting: the message or symptom, then what it means and what to do.
const List<GuideEntry> kMeshnetGuideHints = [
  GuideEntry(
      "\"Failed to connect, retry later\"",
      "Nothing reached the other device: the request timed out inside the "
      "tunnel. First check that Meshnet is on in both NordVPN apps and that "
      "the other device shows as online. If both are fine, the phone's tunnel "
      "is stale. This happened on 26 October 2026 after the phone had been "
      "re-linked to Meshnet: both apps showed the link as up, yet nothing on "
      "the phone could reach a Meshnet address until the tunnel was rebuilt. "
      "Switching split tunneling off and on again in the phone's NordVPN app "
      "did that; turning Meshnet off and on, disconnecting and reconnecting "
      "the VPN, or restarting the phone does the same. Wait ten seconds, then "
      "connect again."),
  GuideEntry(
      "Quick test from the phone",
      "In the phone's browser, open http:// followed by the PC's Meshnet "
      "address and :$kDirectAccessDefaultPort. An immediate error page means "
      "the tunnel carries Meshnet traffic and the fault is elsewhere; a long "
      "wait means it does not, so rebuild the tunnel as above."),
  GuideEntry(
      "\"This device accepts encrypted sessions only\"",
      "The request arrived, but from an address that is not in the other "
      "device's IP whitelist. A device gets a new Meshnet address when it is "
      "re-linked to Meshnet, and RustDesk may keep showing the old one until "
      "it is restarted. Compare the address under \"This device\" in NordVPN's "
      "Meshnet screen with the whitelist on the other side, update it, then "
      "force-stop and reopen RustDesk on the phone."),
  GuideEntry(
      "\"Your IP is blocked by the peer\"",
      "The connection was made by RustDesk ID instead of by Meshnet address: "
      "it came through the public server from the VPN's exit address, which "
      "the whitelist refuses. Type the Meshnet address."),
  GuideEntry(
      "\"Your ID is blocked by the peer\"",
      "The controlling device's RustDesk ID is not in the ID whitelist of the "
      "device you are connecting to. Add it there, or clear that list."),
  GuideEntry(
      "\"This public server currently requires users to log in\"",
      "Also a connection by ID. RustDesk's public server only brokers "
      "connections for devices logged in to a RustDesk account (Google or "
      "GitHub sign-in). The Meshnet path never touches that server, so no "
      "account is needed; log out again afterwards if the PC should not stay "
      "tied to that account."),
  GuideEntry(
      "NordVPN's diagnostics report no problem",
      "The app's connection diagnostic checks the VPN tunnel, DNS and Nord's "
      "own servers, never Meshnet, so it reports success while Meshnet traffic "
      "goes nowhere. It cannot find this fault. After running it, check that "
      "Meshnet is still on: on 26 October 2026 it was found off right after "
      "the diagnostic had run."),
  GuideEntry(
      "The session is slow or keeps dropping",
      "The Meshnet link is probably going through a NordVPN relay (the nearest "
      "one is in Singapore) instead of directly, or Android suspended the "
      "tunnel in the background. Exempt NordVPN and RustDesk from battery "
      "optimisation on the phone, wait a few seconds and connect again."),
];

/// Glossary of the parts involved.
const List<GuideEntry> kMeshnetGuideTerms = [
  GuideEntry(
      "RustDesk ID server and relay",
      "Normally a device finds the other through RustDesk's public ID server, "
      "and when the two devices cannot reach each other directly the whole "
      "session is carried by a public relay. The free relays are shared and "
      "often on another continent (from Australia about 200 to 300 ms there "
      "and back), so relayed sessions feel slow."),
  GuideEntry(
      "Why NordVPN matters",
      "With NordVPN connected, direct links between two devices usually fail "
      "because the VPN puts each device behind a strict NAT, so sessions fall "
      "back to a public relay."),
  GuideEntry(
      "NordVPN Meshnet",
      "A NordVPN feature that links your own devices into a private network. "
      "Each device gets a Meshnet address and a Nord name. Traffic between the "
      "devices is end-to-end encrypted with NordLynx (based on WireGuard), and "
      "Meshnet keeps working while the VPN is connected. NordVPN's optional "
      "post-quantum protection cannot be on at the same time as Meshnet."),
  GuideEntry(
      "Direct IP access",
      "Lets a device connect straight to this device's address on TCP port "
      "$kDirectAccessDefaultPort, without RustDesk's ID server or relay. "
      "Through Meshnet the session goes from device to device."),
  GuideEntry(
      "IP whitelist",
      "Only the listed addresses may connect to this device. List the Meshnet "
      "address of the device on the other side, so nobody else can even reach "
      "the password prompt."),
  GuideEntry(
      "ID whitelist",
      "Only the listed RustDesk IDs may connect, checked before the password on "
      "every connection, including those through Meshnet. It identifies the "
      "controlling device by the ID it reports."),
];

/// Security notes, one paragraph per entry.
const List<String> kMeshnetGuideSecurity = [
  "The Meshnet tunnel encrypts the whole session between the two devices.",
  "RustDesk's own encryption relies on the ID server to vouch for the other "
      "device's key, so connections made by address do not use it, and the "
      "session shows \"Direct and unencrypted connection\". This is expected: "
      "the Meshnet tunnel is still encrypting everything.",
  "This build refuses any other unencrypted session: one introduced by the ID "
      "server that ends up without encryption is turned away with an error, "
      "and a direct IP connection is accepted only from a whitelisted address. "
      "The setting allow-unencrypted-sessions = Y restores stock behaviour; "
      "leave it unset.",
  "Your RustDesk password, and the two-factor code if enabled, are still "
      "required. The password is never sent in readable form.",
  "Direct IP access listens on every network this device is connected to, not "
      "only on Meshnet. Without the whitelist, someone on the same Wi-Fi could "
      "reach port $kDirectAccessDefaultPort outside Meshnet and try your "
      "password. Keep the whitelist on.",
  "While the IP whitelist is on, connections made with the RustDesk ID are "
      "refused as well, because they arrive from addresses outside the list. "
      "Clear the IP whitelist to use the ID again; the ID whitelist can stay.",
  "On the PC, remote configuration changes, LAN discovery, trusted devices and "
      "the tunnel, terminal, camera and printer features are switched off, and "
      "an idle session disconnects after 10 minutes.",
];

/// How to return to connections by RustDesk ID.
const String kMeshnetGuideTurningOff =
    "Untick \"Enable direct IP access\" and clear the IP whitelist on the "
    "device concerned. Connecting with its RustDesk ID then works as before, "
    "provided the controlling device is logged in to a RustDesk account.";
