import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/currency_for_country.dart';
import '../../../core/utils/firebase_error_message.dart';
import '../../../core/utils/input_validators.dart';
import '../../../core/utils/localized_input_validators.dart';
import '../../../core/utils/phone_normalizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/firebase_providers.dart';
import '../../../router/router_session_refresh.dart';
import '../../onboarding/domain/value_objects/country_option.dart';
import '../../onboarding/domain/value_objects/salon_business_type.dart';
import '../../onboarding/domain/value_objects/user_address.dart';

final class CreateSalonSubmitResult {
  const CreateSalonSubmitResult._({
    required this.didSucceed,
    this.salonId,
    this.errorMessage,
  });

  const CreateSalonSubmitResult.success(String salonId)
    : this._(didSucceed: true, salonId: salonId);

  const CreateSalonSubmitResult.failure(String message)
    : this._(didSucceed: false, errorMessage: message);

  const CreateSalonSubmitResult.validationFailed() : this._(didSucceed: false);

  final bool didSucceed;
  final String? salonId;
  final String? errorMessage;
}

final createSalonControllerProvider =
    NotifierProvider.autoDispose<CreateSalonController, CreateSalonFormState>(
      CreateSalonController.new,
    );

class CreateSalonController extends Notifier<CreateSalonFormState> {
  @override
  CreateSalonFormState build() => const CreateSalonFormState();

  void updateSalonName(String value) {
    state = state.copyWith(
      salonName: value,
      salonNameTouched: true,
      submissionError: null,
    );
  }

  void updateBusinessType(SalonBusinessType? value) {
    state = state.copyWith(
      businessType: value,
      businessTypeTouched: true,
      submissionError: null,
    );
  }

  void updateCountry(CountryOption? value) {
    state = state.copyWith(
      country: value,
      countryTouched: true,
      submissionError: null,
    );
  }

  void updateCity(String value) {
    state = state.copyWith(
      city: value,
      cityTouched: true,
      submissionError: null,
    );
  }

  void updateStreet(String value) {
    state = state.copyWith(
      street: value,
      streetTouched: true,
      submissionError: null,
    );
  }

  void updateBuilding(String value) {
    state = state.copyWith(
      building: value,
      buildingTouched: true,
      submissionError: null,
    );
  }

  void updatePostalCode(String value) {
    state = state.copyWith(
      postalCode: value,
      postalTouched: true,
      submissionError: null,
    );
  }

  void updateSalonPhoneNational(String value) {
    state = state.copyWith(
      salonPhoneNational: value,
      salonPhoneTouched: true,
      submissionError: null,
    );
  }

  Future<CreateSalonSubmitResult> submit({
    required String profileSyncTimeoutMessage,
  }) async {
    if (state.isSubmitting) {
      return const CreateSalonSubmitResult.validationFailed();
    }
    state = state.copyWith(hasSubmitted: true, submissionError: null);
    if (!state.isFormValid) {
      return const CreateSalonSubmitResult.validationFailed();
    }

    var session = ref.read(sessionUserProvider).asData?.value;
    final authRepo = ref.read(authRepositoryProvider);
    var authUid = authRepo.lastCredentialUid;
    if (authUid == null || authUid.isEmpty) {
      authUid = ref.read(firebaseAuthProvider).currentUser?.uid;
    }
    if (session == null && authUid != null) {
      session = await ref.read(userRepositoryProvider).getUser(authUid);
    }
    if (session == null) {
      const msg =
          'No active authenticated user/profile found. Please sign in again.';
      state = state.copyWith(submissionError: msg);
      return const CreateSalonSubmitResult.failure(msg);
    }

    state = state.copyWith(isSubmitting: true);

    final country = state.country!;
    final address = UserAddress.salonLocation(
      countryCode: country.isoCode,
      countryName: country.nameEn,
      city: state.city.trim(),
      street: state.street.trim(),
      building: state.building.trim(),
      postalCode: state.postalCode.trim().isEmpty
          ? null
          : state.postalCode.trim(),
    );

    String? contactPhone;
    if (state.salonPhoneNational.trim().isNotEmpty) {
      contactPhone = PhoneNormalizer.normalizeForStorage(
        '${country.dialCode}${state.salonPhoneNational.replaceAll(RegExp(r'\D'), '')}',
      );
    }

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final existing = await userRepo.getUser(session.uid);
      final existingSid = existing?.salonId?.trim();
      if (existingSid != null && existingSid.isNotEmpty) {
        refreshSessionAndRouter(ref);
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (!ref.mounted) {
          return CreateSalonSubmitResult.success(existingSid);
        }
        state = state.copyWith(isSubmitting: false);
        return CreateSalonSubmitResult.success(existingSid);
      }

      final moneyCode = currencyCodeForCountryIso(address.countryCode);
      final created = await ref
          .read(salonRepositoryProvider)
          .createSalonForOwner(
            owner: session,
            salonName: state.salonName.trim(),
            businessType: state.businessType!,
            address: address,
            contactPhone: contactPhone,
            currencyCode: moneyCode,
          );
      refreshSessionAndRouter(ref);

      const step = Duration(milliseconds: 50);
      const maxAttempts = 100;
      for (var i = 0; i < maxAttempts; i++) {
        if (!ref.mounted) {
          return CreateSalonSubmitResult.success(created.salonId);
        }
        final profile = await userRepo.getUser(session.uid);
        final id = profile?.salonId?.trim();
        if (id != null && id.isNotEmpty && id == created.salonId) {
          refreshSessionAndRouter(ref);
          state = state.copyWith(isSubmitting: false);
          return CreateSalonSubmitResult.success(created.salonId);
        }
        await Future<void>.delayed(step);
      }

      if (!ref.mounted) {
        return CreateSalonSubmitResult.success(created.salonId);
      }
      state = state.copyWith(
        isSubmitting: false,
        submissionError: profileSyncTimeoutMessage,
      );
      return CreateSalonSubmitResult.failure(profileSyncTimeoutMessage);
    } on FirebaseAuthException catch (error) {
      final msg = FirebaseErrorMessage.fromException(error);
      if (!ref.mounted) {
        return CreateSalonSubmitResult.failure(msg);
      }
      state = state.copyWith(isSubmitting: false, submissionError: msg);
      return CreateSalonSubmitResult.failure(msg);
    } on FirebaseException catch (error) {
      final msg = FirebaseErrorMessage.fromException(error);
      if (!ref.mounted) {
        return CreateSalonSubmitResult.failure(msg);
      }
      state = state.copyWith(isSubmitting: false, submissionError: msg);
      return CreateSalonSubmitResult.failure(msg);
    } catch (error) {
      final msg = FirebaseErrorMessage.fromException(error);
      if (!ref.mounted) {
        return CreateSalonSubmitResult.failure(msg);
      }
      state = state.copyWith(isSubmitting: false, submissionError: msg);
      return CreateSalonSubmitResult.failure(msg);
    }
  }
}

class CreateSalonFormState {
  const CreateSalonFormState({
    this.salonName = '',
    this.businessType,
    this.country,
    this.city = '',
    this.street = '',
    this.building = '',
    this.postalCode = '',
    this.salonPhoneNational = '',
    this.salonNameTouched = false,
    this.businessTypeTouched = false,
    this.countryTouched = false,
    this.cityTouched = false,
    this.streetTouched = false,
    this.buildingTouched = false,
    this.postalTouched = false,
    this.salonPhoneTouched = false,
    this.hasSubmitted = false,
    this.isSubmitting = false,
    this.submissionError,
  });

  final String salonName;
  final SalonBusinessType? businessType;
  final CountryOption? country;
  final String city;
  final String street;
  final String building;
  final String postalCode;
  final String salonPhoneNational;
  final bool salonNameTouched;
  final bool businessTypeTouched;
  final bool countryTouched;
  final bool cityTouched;
  final bool streetTouched;
  final bool buildingTouched;
  final bool postalTouched;
  final bool salonPhoneTouched;
  final bool hasSubmitted;
  final bool isSubmitting;
  final String? submissionError;

  bool get _show => hasSubmitted;

  String? salonNameErrorFor(AppLocalizations l10n) => salonNameTouched || _show
      ? LocalizedInputValidators.requiredField(
          l10n,
          salonName,
          l10n.fieldLabelSalonName,
        )
      : null;

  String? businessTypeErrorFor(AppLocalizations l10n) =>
      businessTypeTouched || _show
      ? (businessType == null ? l10n.validationBusinessTypeRequired : null)
      : null;

  String? countryErrorFor(AppLocalizations l10n) => countryTouched || _show
      ? (country == null ? l10n.validationCountryRequired : null)
      : null;

  String? cityErrorFor(AppLocalizations l10n) => cityTouched || _show
      ? LocalizedInputValidators.requiredField(l10n, city, l10n.fieldLabelCity)
      : null;

  String? streetErrorFor(AppLocalizations l10n) => streetTouched || _show
      ? LocalizedInputValidators.requiredField(
          l10n,
          street,
          l10n.fieldLabelStreet,
        )
      : null;

  String? buildingErrorFor(AppLocalizations l10n) => buildingTouched || _show
      ? LocalizedInputValidators.requiredField(
          l10n,
          building,
          l10n.fieldLabelBuildingUnit,
        )
      : null;

  String? salonPhoneErrorFor(AppLocalizations l10n) {
    if (!(salonPhoneTouched || _show)) return null;
    if (salonPhoneNational.trim().isEmpty) return null;
    if (country == null) return l10n.validationCountryRequired;
    final combined =
        '${country!.dialCode}${salonPhoneNational.replaceAll(RegExp(r'\D'), '')}';
    return LocalizedInputValidators.phone(l10n, combined);
  }

  bool get isFormValid {
    if (!InputValidators.isNonEmptyTrimmed(salonName)) return false;
    if (businessType == null) return false;
    if (country == null) return false;
    if (!InputValidators.isNonEmptyTrimmed(city)) return false;
    if (!InputValidators.isNonEmptyTrimmed(street)) return false;
    if (!InputValidators.isNonEmptyTrimmed(building)) return false;
    if (salonPhoneNational.trim().isNotEmpty) {
      final combined =
          '${country!.dialCode}${salonPhoneNational.replaceAll(RegExp(r'\D'), '')}';
      if (!InputValidators.isValidPhone(combined)) return false;
    }
    return true;
  }

  CreateSalonFormState copyWith({
    String? salonName,
    Object? businessType = _sentinel,
    Object? country = _sentinel,
    String? city,
    String? street,
    String? building,
    String? postalCode,
    String? salonPhoneNational,
    bool? salonNameTouched,
    bool? businessTypeTouched,
    bool? countryTouched,
    bool? cityTouched,
    bool? streetTouched,
    bool? buildingTouched,
    bool? postalTouched,
    bool? salonPhoneTouched,
    bool? hasSubmitted,
    bool? isSubmitting,
    Object? submissionError = _sentinel2,
  }) {
    return CreateSalonFormState(
      salonName: salonName ?? this.salonName,
      businessType: businessType == _sentinel
          ? this.businessType
          : businessType as SalonBusinessType?,
      country: country == _sentinel ? this.country : country as CountryOption?,
      city: city ?? this.city,
      street: street ?? this.street,
      building: building ?? this.building,
      postalCode: postalCode ?? this.postalCode,
      salonPhoneNational: salonPhoneNational ?? this.salonPhoneNational,
      salonNameTouched: salonNameTouched ?? this.salonNameTouched,
      businessTypeTouched: businessTypeTouched ?? this.businessTypeTouched,
      countryTouched: countryTouched ?? this.countryTouched,
      cityTouched: cityTouched ?? this.cityTouched,
      streetTouched: streetTouched ?? this.streetTouched,
      buildingTouched: buildingTouched ?? this.buildingTouched,
      postalTouched: postalTouched ?? this.postalTouched,
      salonPhoneTouched: salonPhoneTouched ?? this.salonPhoneTouched,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: submissionError == _sentinel2
          ? this.submissionError
          : submissionError as String?,
    );
  }
}

const Object _sentinel = Object();
const Object _sentinel2 = Object();
