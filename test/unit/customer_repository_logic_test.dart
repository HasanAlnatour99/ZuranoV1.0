import 'package:barber_shop_app/features/customers/data/customer_repository.dart';
import 'package:barber_shop_app/features/customers/data/models/customer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit - soft delete customer behavior', () {
    test('deleteCustomer keeps doc and sets isActive to false', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = CustomerRepository(firestore: firestore);
      await firestore
          .collection('salons')
          .doc('salon-1')
          .collection('customers')
          .doc('c-1')
          .set({
            'id': 'c-1',
            'salonId': 'salon-1',
            'fullName': 'Ali',
            'phone': '5550000',
            'isActive': true,
            'createdBy': 'u-1',
          });

      await repository.deleteCustomer('salon-1', 'c-1');

      final snap = await firestore
          .collection('salons')
          .doc('salon-1')
          .collection('customers')
          .doc('c-1')
          .get();
      expect(snap.exists, isTrue);
      expect(snap.data()?['isActive'], isFalse);
    });
  });

  group('Unit - customer search normalization', () {
    test('normalizeCustomerName trims, lowers and collapses whitespace', () {
      expect(normalizeCustomerName('  AHMAD   SALEH  '), 'ahmad saleh');
    });

    test('normalizeCustomerPhone keeps digits only', () {
      expect(normalizeCustomerPhone('+974 5500-1122'), '97455001122');
    });

    test(
      'Arabic search matches normalized Arabic name',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = CustomerRepository(firestore: firestore);
        await firestore
            .collection('salons')
            .doc('salon-1')
            .collection('customers')
            .doc('c-ar')
            .set({
              'id': 'c-ar',
              'salonId': 'salon-1',
              'fullName': 'أحمد علي',
              'phone': '5550000',
              'isActive': true,
              'createdBy': 'u-1',
              'searchKeywords': ['أ', 'أح', 'أحم', 'أحمد'],
            });

        final results = await repository.searchCustomers('salon-1', 'أحمد');
        expect(results.map((c) => c.id), contains('c-ar'));
      },
      tags: ['critical', 'localization'],
    );
  });

  group('Unit - customer pagination', () {
    test('fetchCustomersPage returns first page with limit and lastDocument', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = CustomerRepository(firestore: firestore);

      final col = firestore.collection('salons').doc('salon-1').collection('customers');
      await col.doc('c-1').set({
        'id': 'c-1',
        'salonId': 'salon-1',
        'fullName': 'Ali',
        'fullNameLower': 'ali',
        'phone': '111',
        'isActive': true,
        'createdBy': 'u-1',
        'searchKeywords': ['a', 'al', 'ali'],
      });
      await col.doc('c-2').set({
        'id': 'c-2',
        'salonId': 'salon-1',
        'fullName': 'Bader',
        'fullNameLower': 'bader',
        'phone': '222',
        'isActive': true,
        'createdBy': 'u-1',
        'searchKeywords': ['b', 'ba', 'bad'],
      });
      await col.doc('c-3').set({
        'id': 'c-3',
        'salonId': 'salon-1',
        'fullName': 'Cem',
        'fullNameLower': 'cem',
        'phone': '333',
        'isActive': true,
        'createdBy': 'u-1',
        'searchKeywords': ['c', 'ce', 'cem'],
      });

      final page1 = await repository.fetchCustomersPage(
        salonId: 'salon-1',
        limit: 2,
      );
      expect(page1.customers.length, 2);
      expect(page1.hasMore, isTrue);
      expect(page1.lastDocument, isNotNull);
    });

    test('fetchCustomersPage loadMore uses startAfterDocument', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = CustomerRepository(firestore: firestore);
      final col = firestore.collection('salons').doc('salon-1').collection('customers');

      for (final c in [
        ('c-1', 'ali'),
        ('c-2', 'bader'),
        ('c-3', 'cem'),
      ]) {
        await col.doc(c.$1).set({
          'id': c.$1,
          'salonId': 'salon-1',
          'fullName': c.$2,
          'fullNameLower': c.$2,
          'phone': '0',
          'isActive': true,
          'createdBy': 'u-1',
          'searchKeywords': [c.$2.substring(0, 1)],
        });
      }

      final first = await repository.fetchCustomersPage(salonId: 'salon-1', limit: 2);
      final second = await repository.fetchCustomersPage(
        salonId: 'salon-1',
        limit: 2,
        startAfterDocument: first.lastDocument,
      );
      expect(first.customers.map((c) => c.id).toList(), ['c-1', 'c-2']);
      expect(second.customers.map((c) => c.id).toList(), ['c-3']);
    });

    test('fetchCustomersPage search uses searchKeywords', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = CustomerRepository(firestore: firestore);
      final col = firestore.collection('salons').doc('salon-1').collection('customers');
      await col.doc('c-1').set({
        'id': 'c-1',
        'salonId': 'salon-1',
        'fullName': 'Ali Hassan',
        'fullNameLower': 'ali hassan',
        'phone': '0',
        'isActive': true,
        'createdBy': 'u-1',
        'searchKeywords': ['ali', 'hassan'],
      });

      final page = await repository.fetchCustomersPage(
        salonId: 'salon-1',
        searchTerm: 'Ali',
        limit: 25,
      );
      expect(page.customers.map((c) => c.id), contains('c-1'));
    });
  });

  group('Unit - customer phone locks', () {
    test('duplicate phone create throws DuplicateCustomerPhoneException', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = CustomerRepository(firestore: firestore);

      final firstId = await repository.createCustomer(
        salonId: 'salon-1',
        customer: const Customer(
          id: '',
          salonId: 'salon-1',
          fullName: 'Ali',
          fullNameLower: 'ali',
          phone: '+974 5500-1122',
          isActive: true,
          createdBy: 'u-1',
        ),
      );
      expect(firstId, isNotEmpty);

      expect(
        () => repository.createCustomer(
          salonId: 'salon-1',
          customer: const Customer(
            id: '',
            salonId: 'salon-1',
            fullName: 'Other',
            fullNameLower: 'other',
            phone: '+974 5500-1122',
            isActive: true,
            createdBy: 'u-1',
          ),
        ),
        throwsA(isA<DuplicateCustomerPhoneException>()),
      );
    });

    test('phone update moves lock safely', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = CustomerRepository(firestore: firestore);

      final id = await repository.createCustomer(
        salonId: 'salon-1',
        customer: const Customer(
          id: '',
          salonId: 'salon-1',
          fullName: 'Ali',
          fullNameLower: 'ali',
          phone: '111',
          isActive: true,
          createdBy: 'u-1',
        ),
      );

      final beforeSnap = await firestore
          .collection('salons')
          .doc('salon-1')
          .collection('customers')
          .doc(id)
          .get();
      final existing = Customer.fromJson({...?beforeSnap.data(), 'id': id});

      final updated = existing.copyWith(phone: '222', updatedBy: 'u-1');
      await repository.updateCustomer('salon-1', updated);

      final lock1 = CustomerRepository.customerPhoneLockId('111');
      final lock2 = CustomerRepository.customerPhoneLockId('222');
      final locksCol = firestore
          .collection('salons')
          .doc('salon-1')
          .collection('customer_phone_locks');

      expect((await locksCol.doc(lock1).get()).exists, isFalse);
      expect((await locksCol.doc(lock2).get()).exists, isTrue);
    });
  });
}
