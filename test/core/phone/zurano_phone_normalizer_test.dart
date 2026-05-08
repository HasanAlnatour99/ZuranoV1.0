import 'package:flutter_test/flutter_test.dart';

import 'package:barber_shop_app/core/phone/zurano_phone_country_repository.dart';
import 'package:barber_shop_app/core/phone/zurano_phone_normalizer.dart';

void main() {
  final repo = const ZuranoPhoneCountryRepository();
  final qa = repo.findByIsoCode('QA')!;
  final ae = repo.findByIsoCode('AE')!;
  final sa = repo.findByIsoCode('SA')!;

  group('ZuranoPhoneNormalizer', () {
    test('QA local 70001043 -> +97470001043', () {
      final r = ZuranoPhoneNormalizer.normalize(input: '70001043', country: qa);
      expect(r.isValid, true);
      expect(r.e164, '+97470001043');
    });

    test('QA 97470001043 -> +97470001043', () {
      final r = ZuranoPhoneNormalizer.normalize(
        input: '97470001043',
        country: qa,
      );
      expect(r.isValid, true);
      expect(r.e164, '+97470001043');
    });

    test('QA 0097470001043 -> +97470001043', () {
      final r = ZuranoPhoneNormalizer.normalize(
        input: '0097470001043',
        country: qa,
      );
      expect(r.isValid, true);
      expect(r.e164, '+97470001043');
    });

    test('AE 0501234567 -> +971501234567', () {
      final r = ZuranoPhoneNormalizer.normalize(
        input: '0501234567',
        country: ae,
      );
      expect(r.isValid, true);
      expect(r.e164, '+971501234567');
    });

    test('AE +971501234567 -> +971501234567', () {
      final r = ZuranoPhoneNormalizer.normalize(
        input: '+971501234567',
        country: ae,
      );
      expect(r.isValid, true);
      expect(r.e164, '+971501234567');
    });

    test('SA 05xxxxxxxx trunk -> +9665xxxxxxxx', () {
      final r = ZuranoPhoneNormalizer.normalize(
        input: '0551234567',
        country: sa,
      );
      expect(r.isValid, true);
      expect(r.e164, '+966551234567');
    });

    test('Empty input invalid', () {
      final r = ZuranoPhoneNormalizer.normalize(input: '', country: qa);
      expect(r.isValid, false);
      expect(r.e164, '');
    });

    test('Very short input invalid', () {
      final r = ZuranoPhoneNormalizer.normalize(input: '12', country: qa);
      expect(r.isValid, false);
    });
  });

  group('ZuranoPhoneCountryRepository', () {
    test('Search by +974 finds Qatar', () {
      final results = repo.search('+974');
      expect(results.any((c) => c.isoCode == 'QA'), true);
    });

    test('Search by QA finds Qatar', () {
      final results = repo.search('QA');
      expect(results.any((c) => c.isoCode == 'QA'), true);
    });

    test('Search by Qatar finds Qatar', () {
      final results = repo.search('Qatar');
      expect(results.any((c) => c.isoCode == 'QA'), true);
    });
  });
}

