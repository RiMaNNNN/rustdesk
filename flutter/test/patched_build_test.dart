import 'package:flutter_hbb/common/patched_build.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('patched build labels', () {
    test('label names the base version and says the updater is off', () {
      expect(kPatchedBuildLabel, contains('1.5.0'));
      expect(kPatchedBuildLabel, contains('Oct 2026'));
      expect(kPatchedBuildLabel, contains('updater disabled'));
    });

    test('updater note explains why updates are off', () {
      expect(kPatchedBuildUpdaterNote, contains('disabled'));
      expect(kPatchedBuildUpdaterNote, contains('patches'));
    });
  });

  group('effectiveDirectAccessPort', () {
    test('empty option falls back to 21118', () {
      expect(effectiveDirectAccessPort(''), '21118');
      expect(kDirectAccessDefaultPort, '21118');
    });

    test('stored port wins', () {
      expect(effectiveDirectAccessPort('31118'), '31118');
    });
  });

  group('whitelistEntries', () {
    test('the empty marker gives no entries, for both marker styles', () {
      expect(whitelistEntries('', ''), isEmpty);
      expect(whitelistEntries(',', ','), isEmpty);
    });

    test('comma-separated entries are split and blanks dropped', () {
      expect(whitelistEntries('100.64.1.2,100.64.0.0/10', ''),
          ['100.64.1.2', '100.64.0.0/10']);
      expect(whitelistEntries('100.64.1.2,,', ''), ['100.64.1.2']);
    });

    test('a list is kept even when it equals the other style of marker', () {
      expect(whitelistEntries(',', ''), isEmpty);
    });
  });

  group('whitelistStatus', () {
    test('entries make the whitelist active whatever direct IP does', () {
      expect(whitelistStatus(directIpEnabled: true, entries: ['100.64.1.2']),
          WhitelistStatus.active);
      expect(whitelistStatus(directIpEnabled: false, entries: ['100.64.1.2']),
          WhitelistStatus.active);
    });

    test('direct IP without entries is flagged as exposed', () {
      expect(whitelistStatus(directIpEnabled: true, entries: const []),
          WhitelistStatus.missingWhileExposed);
    });

    test('nothing enabled is simply off', () {
      expect(whitelistStatus(directIpEnabled: false, entries: const []),
          WhitelistStatus.off);
    });
  });

  group('Meshnet guide content', () {
    final stepLists = <String, List<String>>{
      'PC': kMeshnetGuidePcSteps,
      'phone': kMeshnetGuidePhoneSteps,
      'phone to PC': kMeshnetGuidePhoneToPcSteps,
      'PC to phone': kMeshnetGuidePcToPhoneSteps,
    };
    final allTexts = <String>[
      kMeshnetGuideTitle,
      kMeshnetGuideLinkText,
      kMeshnetGuideIntro,
      ...kMeshnetGuideDesign,
      for (final list in stepLists.values) ...list,
      for (final item in kMeshnetGuideHints) ...[item.lead, item.text],
      for (final item in kMeshnetGuideTerms) ...[item.lead, item.text],
      ...kMeshnetGuideSecurity,
      kMeshnetGuideTurningOff,
    ];

    test('every step list has steps and every step is a full sentence', () {
      for (final entry in stepLists.entries) {
        expect(entry.value, isNotEmpty, reason: entry.key);
        for (final step in entry.value) {
          expect(step.trim(), endsWith('.'), reason: '${entry.key}: $step');
        }
      }
    });

    test('the texts carry no address and no RustDesk ID', () {
      final ipv4 = RegExp(r'\b\d{1,3}(\.\d{1,3}){3}\b');
      final rustdeskId = RegExp(r'\b\d{9,}\b');
      for (final text in allTexts) {
        expect(ipv4.hasMatch(text), isFalse, reason: text);
        expect(rustdeskId.hasMatch(text), isFalse, reason: text);
      }
    });

    test('the only port in the texts is the direct access default', () {
      final port = RegExp(r':\d{4,5}\b');
      for (final text in allTexts) {
        for (final match in port.allMatches(text)) {
          expect(match.group(0), ':$kDirectAccessDefaultPort', reason: text);
        }
      }
      expect(kMeshnetGuidePhoneToPcSteps.join(' '),
          contains(':$kDirectAccessDefaultPort'));
      expect(kMeshnetGuidePcToPhoneSteps.join(' '),
          contains(':$kDirectAccessDefaultPort'));
    });

    test('the PC steps name the settings that were changed', () {
      final text = kMeshnetGuidePcSteps.join(' ');
      expect(text, contains('Unlock security settings'));
      expect(text, contains('Enable direct IP access'));
      expect(text, contains('Use IP whitelisting'));
      expect(text, contains('Use ID whitelisting'));
      expect(text, contains('two-factor'));
    });

    test('the phone steps name its settings and permissions', () {
      final text = kMeshnetGuidePhoneSteps.join(' ');
      expect(text, contains('Direct IP access'));
      expect(text, contains('Use IP whitelisting'));
      expect(text, contains('Start service'));
      expect(text, contains('Meshnet'));
    });

    test('troubleshooting covers the failures met during the setup', () {
      final leads = kMeshnetGuideHints.map((item) => item.lead).join(' ');
      expect(leads, contains('Failed to connect'));
      expect(leads, contains('encrypted sessions only'));
      expect(leads, contains('Your IP is blocked'));
      expect(leads, contains('Your ID is blocked'));
      expect(leads, contains('requires users to log in'));
      final timeout = kMeshnetGuideHints.first.text;
      expect(timeout, contains('split tunneling'));
      expect(timeout, contains('re-linked'));
      expect(timeout, contains('Meshnet off and on'));
    });

    test('the ID whitelist is described as checked on every connection', () {
      final term =
          kMeshnetGuideTerms.firstWhere((item) => item.lead == 'ID whitelist');
      expect(term.text, contains('every connection'));
    });
  });
}
