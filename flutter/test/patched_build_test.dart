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
}
