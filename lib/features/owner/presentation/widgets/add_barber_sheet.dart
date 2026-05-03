import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/utils/currency_for_country.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/formatting/staff_role_localized.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/localized_input_validators.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'add_barber/add_barber_header.dart';
import 'add_barber/add_barber_password_checklist.dart';
import 'add_barber/commission_preview_card.dart';
import 'add_barber/form_section_card.dart';
import 'add_barber/responsive_fields_grid.dart';
import 'add_barber/sticky_create_barber_footer.dart';
import 'add_barber/work_settings_switch_tile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../payroll/domain/effective_payroll_period.dart';
import '../../../employees/data/models/employee.dart';
import '../../../employees/data/models/staff_provisioning_result.dart';
import '../../../employees/domain/commission_type.dart';
import '../../../employees/domain/employee_role.dart';
import '../../../employees/domain/staff_provisioning_exception.dart';
import '../../../team/presentation/widgets/team_commission_type_picker_sheet.dart';
import '../../../team/presentation/widgets/team_profile_photo_picker.dart';
import '../../../team/presentation/widgets/team_role_picker_sheet.dart';

const double _previewSampleSales = 10000;

Future<void> showAddBarberSheet(
  BuildContext context, {
  required String salonId,
  Employee? existing,
}) {
  return showAppModalBottomSheet<void>(
    context: context,
    expand: true,
    builder: (_) => AddBarberSheet(
      salonId: salonId,
      parentContext: context,
      existing: existing,
    ),
  );
}

class AddBarberSheet extends ConsumerStatefulWidget {
  const AddBarberSheet({
    super.key,
    required this.salonId,
    required this.parentContext,
    this.existing,
  });

  final String salonId;
  final BuildContext parentContext;
  final Employee? existing;

  @override
  ConsumerState<AddBarberSheet> createState() => _AddBarberSheetState();
}

class _AddBarberSheetState extends ConsumerState<AddBarberSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _commissionPctController;
  late final TextEditingController _commissionFixedController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late CommissionType _commissionType;
  late bool _attendanceRequired;
  late bool _isBookable;
  late bool _isActive;
  late String _selectedRole;
  late Map<String, bool> _permissions;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _requirePasswordChangeOnFirstLogin = true;
  XFile? _selectedProfileImage;
  String? _existingProfileImageUrl;
  String? _initialProfileImageUrl;

  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _usernameFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;

  bool _saving = false;
  bool _isFormValid = false;
  bool _hasSubmittedCreate = false;
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _usernameTouched = false;
  bool _phoneTouched = false;
  bool _commissionTouched = false;
  String? _nameError;
  String? _emailError;
  String? _usernameError;
  String? _phoneError;
  String? _commissionPctError;
  String? _commissionFixedError;

  /// UTC calendar date for payroll proration (aligned with Cloud Function month boundaries).
  late DateTime _hiredAt;
  /// [SalonPayrollPeriods.monthly] | [SalonPayrollPeriods.weekly] — matches salon
  /// default is stored as null on save.
  late String _payrollPeriodOverrideChoice;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _emailController = TextEditingController();
    _usernameController = TextEditingController(
      text: (existing?.username ?? '').trim(),
    );
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _commissionPctController = TextEditingController(
      text: _initialPercentText(existing),
    );
    _commissionFixedController = TextEditingController(
      text: _initialFixedText(existing),
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _usernameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
    _commissionType = CommissionType.fromFirestore(
      existing?.commissionType ?? EmployeeCommissionTypes.percentage,
    );
    _selectedRole = _normalizeRole(existing?.role ?? UserRoles.barber);
    _existingProfileImageUrl = existing?.avatarUrl;
    _initialProfileImageUrl = existing?.avatarUrl;
    _permissions = _defaultPermissionsForRole(_selectedRole);
    _attendanceRequired = existing?.attendanceRequired ?? true;
    _isBookable = existing?.isBookable ?? _selectedRole == UserRoles.barber;
    _isActive = existing?.isActive ?? true;
    _hiredAt = _initialHireDateUtc(existing);
    final salon = ref.read(sessionSalonStreamProvider).asData?.value;
    _payrollPeriodOverrideChoice = effectivePayrollPeriodFor(
      salonDefaultPayrollPeriod: salon?.defaultPayrollPeriod ?? '',
      employeePayrollPeriodOverride: existing?.payrollPeriodOverride,
    );

    _commissionPctController.addListener(_onFormFieldChanged);
    _commissionFixedController.addListener(_onFormFieldChanged);
    _nameController.addListener(_onFormFieldChanged);
    _emailController.addListener(_onFormFieldChanged);
    _usernameController.addListener(_onFormFieldChanged);
    _phoneController.addListener(_onFormFieldChanged);
    _passwordController.addListener(_onFormFieldChanged);
    _confirmPasswordController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    if (!mounted) {
      return;
    }
    _updateCanSubmit();
  }

  static String _initialPercentText(Employee? existing) {
    if (existing == null) {
      return '';
    }
    final v = existing.resolvedCommissionPercentage;
    if (v <= 0) {
      return '';
    }
    return _trimTrailingZeros(v);
  }

  static String _initialFixedText(Employee? existing) {
    if (existing == null) {
      return '';
    }
    final v = existing.resolvedCommissionFixedAmount;
    if (v <= 0) {
      return '';
    }
    return _trimTrailingZeros(v);
  }

  static String _trimTrailingZeros(double v) {
    final s = v.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static DateTime _initialHireDateUtc(Employee? existing) {
    final n = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(n.year, n.month, n.day);
    if (existing?.hiredAt != null) {
      final h = existing!.hiredAt!;
      return DateTime.utc(h.year, h.month, h.day);
    }
    if (existing?.createdAt != null) {
      final c = existing!.createdAt!;
      return DateTime.utc(c.year, c.month, c.day);
    }
    return todayUtc;
  }

  Future<void> _pickHiredAt() async {
    if (_saving) {
      return;
    }
    final initialLocal = DateTime(
      _hiredAt.year,
      _hiredAt.month,
      _hiredAt.day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initialLocal,
      firstDate: DateTime(1990),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
    );
    if (picked != null && mounted) {
      setState(() {
        _hiredAt = DateTime.utc(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _commissionPctController.dispose();
    _commissionFixedController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  double? _parsePositivePercent(String text) {
    final t = text.trim();
    if (t.isEmpty) {
      return null;
    }
    return double.tryParse(t.replaceAll(',', '.'));
  }

  double? _parseNonNegativeFixed(String text) {
    final t = text.trim();
    if (t.isEmpty) {
      return null;
    }
    return double.tryParse(t.replaceAll(',', '.'));
  }

  bool _validate(AppLocalizations l10n) {
    if (widget.existing != null) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      setState(() {
        _nameError = LocalizedInputValidators.requiredField(
          l10n,
          name,
          l10n.teamFieldFullName,
        );
        _phoneError = phone.isEmpty ? null : validatePhone(phone);
        _emailError = null;
        _usernameError = null;
        _commissionPctError = null;
        _commissionFixedError = null;
      });
      return _nameError == null && _phoneError == null;
    }
    setState(() {
      _hasSubmittedCreate = true;
      _nameTouched = true;
      _emailTouched = true;
      _usernameTouched = true;
      _phoneTouched = true;
      _commissionTouched = true;
    });
    _updateCanSubmit();
    return _isFormValid;
  }

  void _updateCanSubmit() {
    final isNew = widget.existing == null;
    if (!isNew) {
      setState(() {
        _isFormValid = true;
      });
      return;
    }

    final fullNameError = validateFullName(_nameController.text);
    final emailError = validateEmail(_emailController.text);
    final usernameError = validateUsername(_usernameController.text);
    final phoneError = validatePhone(_phoneController.text);
    final passwordError = validatePassword(_passwordController.text);
    final commissionError = validateCommission(_commissionPctController.text);

    setState(() {
      _nameError = (_nameTouched || _hasSubmittedCreate) ? fullNameError : null;
      _emailError = (_emailTouched || _hasSubmittedCreate) ? emailError : null;
      _usernameError = (_usernameTouched || _hasSubmittedCreate)
          ? usernameError
          : null;
      _phoneError = (_phoneTouched || _hasSubmittedCreate) ? phoneError : null;
      _commissionPctError = (_commissionTouched || _hasSubmittedCreate)
          ? commissionError
          : null;
      _commissionFixedError = null;
      _isFormValid =
          fullNameError == null &&
          emailError == null &&
          usernameError == null &&
          phoneError == null &&
          passwordError == null &&
          commissionError == null;
    });
  }

  ({double pct, double fixed}) _resolvedCommissionNumbers() {
    final pct = _parsePositivePercent(_commissionPctController.text) ?? 0;
    final fixedAmt =
        _parseNonNegativeFixed(_commissionFixedController.text) ?? 0;
    return (pct: pct, fixed: fixedAmt);
  }

  Employee _employeeWithCommission({
    required Employee base,
    required double commissionPct,
    required double commissionFixed,
    required String commissionTypeStr,
  }) {
    final rateLegacy =
        (commissionTypeStr == EmployeeCommissionTypes.percentage ||
            commissionTypeStr == EmployeeCommissionTypes.percentagePlusFixed)
        ? commissionPct
        : 0.0;
    final valueLegacy = switch (commissionTypeStr) {
      EmployeeCommissionTypes.fixed => commissionFixed,
      _ => commissionPct,
    };

    return base.copyWith(
      commissionPercentage:
          (commissionTypeStr == EmployeeCommissionTypes.percentage ||
              commissionTypeStr == EmployeeCommissionTypes.percentagePlusFixed)
          ? commissionPct
          : 0,
      commissionFixedAmount:
          (commissionTypeStr == EmployeeCommissionTypes.fixed ||
              commissionTypeStr == EmployeeCommissionTypes.percentagePlusFixed)
          ? commissionFixed
          : 0,
      commissionType: commissionTypeStr,
      commissionRate: rateLegacy,
      commissionValue: valueLegacy,
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_saving || !_validate(l10n)) {
      return;
    }

    final existing = widget.existing;
    final role = _normalizeRole(_selectedRole);
    final displayNameRaw = _nameController.text;
    if (displayNameRaw.trim().isEmpty) {
      setState(() {
        _nameError = l10n.addBarberValidationFullNameRequired;
      });
      return;
    }
    final nameForEmployeeRecord = displayNameRaw.trim();
    final email = _emailController.text.trim().toLowerCase();
    final username = _usernameController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final phoneValue = phone.isEmpty ? null : phone;
    final numbers = _resolvedCommissionNumbers();
    final typeStr = _commissionType.firestoreValue;
    final permissions = <String, bool>{
      ..._defaultPermissionsForRole(role),
      ..._permissions,
    };
    final isBarber = role == UserRoles.barber;
    final isBookable = isBarber ? _isBookable : false;
    final attendanceRequired = _attendanceRequired;
    final commissionPercent = isBarber ? numbers.pct : 0.0;
    final isActive = _isActive;

    setState(() => _saving = true);

    final employeeRepository = ref.read(employeeRepositoryProvider);
    final provisioningRepository = ref.read(
      staffProvisioningRepositoryProvider,
    );

    try {
      StaffProvisioningResult? provisioningResult;
      if (existing == null) {
        final createdStaff = await provisioningRepository
            .createStaffMemberWithAuth(
              salonId: widget.salonId,
              email: email,
              username: username,
              displayName: displayNameRaw,
              phone: phoneValue,
              password: _passwordController.text,
              role: role,
              commissionPercent: commissionPercent,
              attendanceRequired: attendanceRequired,
              isBookable: isBookable,
              isActive: isActive,
              permissions: permissions,
            );
        provisioningResult = createdStaff;
        if (kDebugMode) {
          developer.log(
            'staff_provisioned uid=${createdStaff.uid} '
            'employeeId=${createdStaff.employeeId} '
            'username=${createdStaff.username} '
            'authEmail=${createdStaff.email} '
            'salonId=${widget.salonId} role=$role',
            name: 'team.addBarber',
          );
        }
      }

      var profilePhotoUrl = _existingProfileImageUrl;
      final employeeIdForPhoto = provisioningResult?.employeeId ?? existing?.id;
      if (_selectedProfileImage != null && employeeIdForPhoto != null) {
        profilePhotoUrl = await employeeRepository.uploadEmployeeProfilePhoto(
          salonId: widget.salonId,
          employeeId: employeeIdForPhoto,
          image: _selectedProfileImage!,
        );
      }

      final employee = _employeeWithCommission(
        base:
            (existing ??
                    Employee(
                      id: '',
                      salonId: '',
                      name: '',
                      email: '',
                      role: UserRoles.barber,
                    ))
                .copyWith(
                  id: provisioningResult?.employeeId ?? existing!.id,
                  salonId: widget.salonId,
                  uid: provisioningResult?.uid ?? existing?.uid,
                  name: nameForEmployeeRecord,
                  email: provisioningResult?.email ?? existing!.email,
                  username: provisioningResult?.username ?? existing?.username,
                  usernameLower: provisioningResult != null
                      ? username.trim().toLowerCase()
                      : existing?.usernameLower,
                  phone: phoneValue,
                  role: role,
                  attendanceRequired: attendanceRequired,
                  isBookable: isBookable,
                  isActive: isActive,
                  status: isActive ? 'active' : 'inactive',
                  mustChangePassword: existing == null
                      ? _requirePasswordChangeOnFirstLogin
                      : existing.mustChangePassword,
                  avatarUrl: profilePhotoUrl,
                  hiredAt: _hiredAt,
                  payrollPeriodOverride: _normalizeRole(role) == UserRoles.owner
                      ? null
                      : () {
                          final salon =
                              ref.read(sessionSalonStreamProvider).asData?.value;
                          final def = SalonPayrollPeriods.normalize(
                            salon?.defaultPayrollPeriod,
                          );
                          final choice = SalonPayrollPeriods.normalize(
                            _payrollPeriodOverrideChoice,
                          );
                          return choice == def ? null : choice;
                        }(),
                ),
        commissionPct: commissionPercent,
        commissionFixed: numbers.fixed,
        commissionTypeStr: typeStr,
      );

      await employeeRepository.updateEmployee(widget.salonId, employee);
      if (profilePhotoUrl != null && profilePhotoUrl.trim().isNotEmpty) {
        await employeeRepository.updateEmployeePhoto(
          salonId: widget.salonId,
          employeeId: employee.id,
          photoUrl: profilePhotoUrl,
        );
      } else if ((_initialProfileImageUrl?.trim().isNotEmpty ?? false)) {
        await employeeRepository.clearEmployeePhoto(
          salonId: widget.salonId,
          employeeId: employee.id,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
      if (widget.parentContext.mounted) {
        if (existing == null) {
          final theme = Theme.of(widget.parentContext);
          final scheme = theme.colorScheme;
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.addBarberSuccessMessage),
                  const SizedBox(height: 4),
                  Text(
                    l10n.addBarberSuccessSubtext,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(widget.parentContext).showSnackBar(
            SnackBar(
              content: Text(l10n.teamEditBarberSuccess(nameForEmployeeRecord)),
            ),
          );
        }
      }
    } on StaffProvisioningException catch (error, stackTrace) {
      developer.log(
        'Failed to provision staff member',
        name: 'team.addBarber',
        error: error,
        stackTrace: stackTrace,
      );
      _showErrorSnackBar(_messageForProvisioningError(l10n, error));
    } catch (error, stackTrace) {
      developer.log(
        'Failed to save team member',
        name: 'team.addBarber',
        error: error,
        stackTrace: stackTrace,
      );
      _showErrorSnackBar(l10n.teamSaveErrorGeneric);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!widget.parentContext.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      widget.parentContext,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageForProvisioningError(
    AppLocalizations l10n,
    StaffProvisioningException error,
  ) {
    final fromServer = error.message?.trim();
    if (fromServer != null && fromServer.isNotEmpty) {
      return fromServer;
    }
    return switch (error.kind) {
      StaffProvisioningFailureKind.emailAlreadyExists =>
        l10n.staffInviteErrorEmailTaken,
      StaffProvisioningFailureKind.permissionDenied =>
        l10n.staffInviteErrorPermission,
      StaffProvisioningFailureKind.network => l10n.staffInviteErrorNetwork,
      StaffProvisioningFailureKind.invalidArgument =>
        l10n.staffInviteErrorInvalidArgs,
      StaffProvisioningFailureKind.unknown => l10n.staffInviteErrorGeneric,
    };
  }

  String _commissionHelper(AppLocalizations l10n) {
    return switch (_commissionType) {
      CommissionType.percentage => l10n.teamCommissionHelperPercentage,
      CommissionType.fixed => l10n.teamCommissionHelperFixed,
      CommissionType.percentagePlusFixed =>
        l10n.teamCommissionHelperPercentagePlusFixed,
    };
  }

  String _previewLine(AppLocalizations l10n, String localeName) {
    final pct = _parsePositivePercent(_commissionPctController.text);
    final fixedAmt = _parseNonNegativeFixed(_commissionFixedController.text);
    final nf = NumberFormat.decimalPattern(localeName);
    final salesS = nf.format(_previewSampleSales);
    final pctDec = (pct ?? 0) / 100.0;
    final pctLabel = pct != null ? '${_trimTrailingZeros(pct)}%' : '—';

    switch (_commissionType) {
      case CommissionType.percentage:
        final result = _previewSampleSales * pctDec;
        return l10n.teamCommissionPreviewEquationPercent(
          salesS,
          pctLabel,
          nf.format(result),
        );
      case CommissionType.fixed:
        final f = fixedAmt ?? 0;
        return l10n.teamCommissionPreviewEquationFixed(nf.format(f));
      case CommissionType.percentagePlusFixed:
        final f = fixedAmt ?? 0;
        final result = f + _previewSampleSales * pctDec;
        return l10n.teamCommissionPreviewEquationMixed(
          nf.format(f),
          salesS,
          pctLabel,
          nf.format(result),
        );
    }
  }

  String? validateFullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a valid full name';
    if (text.length < 2 || text.length > 60) return 'Enter a valid full name';
    return null;
  }

  String? validateEmail(String? value) {
    final text = value?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return 'Enter a valid email address';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  String? validateUsername(String? value) {
    final text = value?.trim().toLowerCase() ?? '';
    if (text.isEmpty) {
      return 'Use 3–24 characters: letters, numbers, dot, or underscore';
    }
    if (text.length < 3 || text.length > 24) {
      return 'Use 3–24 characters: letters, numbers, dot, or underscore';
    }
    final regex = RegExp(r'^[a-z0-9._]+$');
    if (!regex.hasMatch(text)) {
      return 'Use 3–24 characters: letters, numbers, dot, or underscore';
    }
    return null;
  }

  String? validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a valid phone number';
    final regex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!regex.hasMatch(text)) return 'Enter a valid phone number';
    return null;
  }

  String? validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty || text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateCommission(String? value) {
    if (_selectedRole != UserRoles.barber) return null;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Commission must be between 0 and 100';
    final number = double.tryParse(text);
    if (number == null || number < 0 || number > 100) {
      return 'Commission must be between 0 and 100';
    }
    return null;
  }

  void _onUsernameChanged(String value) {
    final lower = value.toLowerCase();
    if (lower != value) {
      final selectionIndex = _usernameController.selection.baseOffset;
      _usernameController.value = TextEditingValue(
        text: lower,
        selection: TextSelection.collapsed(
          offset: selectionIndex.clamp(0, lower.length),
        ),
      );
    }
    _usernameTouched = true;
    _updateCanSubmit();
  }

  void _onCreateFieldChanged({required void Function() markTouched}) {
    markTouched();
    _updateCanSubmit();
  }

  EmployeeRole _selectedEmployeeRole() {
    return _selectedRole == UserRoles.admin
        ? EmployeeRole.admin
        : EmployeeRole.barber;
  }

  String _roleToUserRole(EmployeeRole role) {
    return switch (role) {
      EmployeeRole.admin => UserRoles.admin,
      EmployeeRole.barber => UserRoles.barber,
      _ => UserRoles.barber,
    };
  }

  Future<void> _showRolePicker() async {
    if (_saving) {
      return;
    }
    final role = await showModalBottomSheet<EmployeeRole>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeamRolePickerSheet(
        selectedRole: _selectedEmployeeRole(),
        onRoleSelected: (selected) => Navigator.of(context).pop(selected),
      ),
    );
    if (!mounted || role == null) {
      return;
    }
    setState(() {
      _selectedRole = _roleToUserRole(role);
      _permissions = _defaultPermissionsForRole(_selectedRole);
      _isBookable = _selectedRole == UserRoles.barber;
      _commissionTouched = true;
    });
    _updateCanSubmit();
  }

  String _commissionTypeLabel(AppLocalizations l10n, CommissionType type) {
    return switch (type) {
      CommissionType.percentage => l10n.teamCommissionTypePercentage,
      CommissionType.fixed => l10n.teamCommissionTypeFixed,
      CommissionType.percentagePlusFixed =>
        l10n.teamCommissionTypePercentagePlusFixed,
    };
  }

  Future<void> _openCommissionTypePicker() async {
    final type = await showModalBottomSheet<CommissionType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          TeamCommissionTypePickerSheet(selectedType: _commissionType),
    );

    if (type == null || !mounted) {
      return;
    }

    setState(() {
      _commissionType = type;
      _commissionTouched = true;
    });
    _updateCanSubmit();
  }

  static final _decimalInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];
  static final _usernameInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
  ];
  static final _phoneInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
  ];

  String _normalizeRole(String value) {
    final role = value.trim().toLowerCase();

    if (role == 'administrator') return UserRoles.admin;
    if (role == UserRoles.admin) return UserRoles.admin;
    if (role == UserRoles.barber) return UserRoles.barber;
    if (role == 'read only') return UserRoles.readonly;
    if (role == 'read_only') return UserRoles.readonly;
    if (role == UserRoles.readonly) return UserRoles.readonly;

    return UserRoles.barber;
  }

  Map<String, bool> _defaultPermissionsForRole(String role) {
    final normalizedRole = _normalizeRole(role);
    switch (normalizedRole) {
      case UserRoles.admin:
        return const {
          'canViewDashboard': true,
          'canManageTeam': true,
          'canManageServices': true,
          'canManageSales': true,
          'canViewFinance': true,
          'canManageExpenses': true,
          'canManagePayroll': true,
          'canManageAttendance': true,
          'canViewAnalytics': true,
          'canManageCustomers': true,
          'canEditSettings': false,
        };
      case UserRoles.readonly:
        return const {
          'canViewDashboard': true,
          'canManageTeam': false,
          'canManageServices': false,
          'canManageSales': false,
          'canViewFinance': true,
          'canManageExpenses': false,
          'canManagePayroll': false,
          'canViewAnalytics': true,
          'canManageCustomers': false,
          'canEditSettings': false,
        };
      case UserRoles.barber:
      default:
        return const {
          'canViewDashboard': false,
          'canManageTeam': false,
          'canManageServices': false,
          'canManageSales': true,
          'canViewFinance': false,
          'canManageExpenses': false,
          'canManagePayroll': false,
          'canViewAnalytics': false,
          'canManageCustomers': true,
          'canEditSettings': false,
        };
    }
  }

  Future<void> _onProfilePhotoTap() async {
    if (!mounted || _saving) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto =
        _selectedProfileImage != null ||
        (_existingProfileImageUrl?.trim().isNotEmpty ?? false);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        Widget whitePurpleIcon(IconData icon) {
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9DDFE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF7C3AED)),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: whitePurpleIcon(Icons.photo_camera_rounded),
                  title: Text(l10n.teamPhotoActionTake),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: whitePurpleIcon(Icons.photo_library_rounded),
                  title: Text(l10n.teamPhotoActionGallery),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                if (hasPhoto)
                  ListTile(
                    leading: whitePurpleIcon(Icons.delete_outline_rounded),
                    title: Text(l10n.teamPhotoActionRemove),
                    onTap: () => Navigator.pop(context, 'remove'),
                  ),
                ListTile(
                  leading: whitePurpleIcon(Icons.close_rounded),
                  title: Text(l10n.teamPhotoActionCancel),
                  onTap: () => Navigator.pop(context, 'cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || action == null || action == 'cancel') {
      return;
    }
    if (action == 'remove') {
      setState(() {
        _selectedProfileImage = null;
        _existingProfileImageUrl = null;
      });
      return;
    }

    final source = action == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (!mounted || image == null) {
      return;
    }
    setState(() {
      _selectedProfileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localeName = Localizations.localeOf(context).toString();
    final salonForMoney = ref.watch(sessionSalonStreamProvider).asData?.value;
    final salonMoneyCode = resolvedSalonMoneyCurrency(
      salonCurrencyCode: salonForMoney?.currencyCode,
      salonCountryIso: salonForMoney?.countryCode,
    );
    final media = MediaQuery.of(context);
    final maxH = media.size.height * 0.92;
    final w = media.size.width;
    final horizontalPadding = w < 360 ? 12.0 : 16.0;
    final sectionRadius = w < 360 ? 22.0 : 28.0;
    final compactHeader = w < 360;
    final footerReserve = 108.0 + MediaQuery.paddingOf(context).bottom;

    final showPct =
        _commissionType == CommissionType.percentage ||
        _commissionType == CommissionType.percentagePlusFixed;
    final showFixed =
        _commissionType == CommissionType.fixed ||
        _commissionType == CommissionType.percentagePlusFixed;

    final isNew = widget.existing == null;
    final heroTitle = isNew
        ? l10n.teamAddBarberSheetTitle
        : l10n.teamEditBarberSheetTitle;
    final heroSubtitle = isNew
        ? l10n.addBarberSheetHeroSubtitle
        : l10n.teamAddBarberSheetSubtitle;

    final primaryFooterLabel = isNew
        ? (_saving ? l10n.addBarberButtonCreating : l10n.addBarberButtonCreate)
        : l10n.teamSaveChangesAction;

    final footerIcon = isNew
        ? Icons.person_add_alt_1_rounded
        : Icons.save_rounded;

    final scrollChildren = <Widget>[
      TeamProfilePhotoPicker(
        selectedImage: _selectedProfileImage,
        existingImageUrl: _existingProfileImageUrl,
        isUploading: _saving,
        onPickImage: _onProfilePhotoTap,
        onRemoveImage: () {
          setState(() {
            _selectedProfileImage = null;
            _existingProfileImageUrl = null;
          });
        },
      ),
      SizedBox(height: horizontalPadding),
      FormSectionCard(
        radius: sectionRadius,
        title: l10n.addBarberSectionPersonalDetails,
        icon: Icons.person_outline_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isNew)
              ResponsiveFieldsGrid(
                children: [
                  AppTextField(
                    label: l10n.addBarberFieldFullName,
                    controller: _nameController,
                    hintText: l10n.addBarberPlaceholderFullName,
                    errorText: _nameError,
                    enabled: !_saving,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _onCreateFieldChanged(
                      markTouched: () => _nameTouched = true,
                    ),
                    onSubmitted: (_) => _emailFocus.requestFocus(),
                  ),
                  AppTextField(
                    label: l10n.addBarberFieldEmailAddress,
                    controller: _emailController,
                    hintText: l10n.addBarberPlaceholderEmail,
                    helperText: l10n.addBarberHelperEmailLogin,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    enabled: !_saving,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _onCreateFieldChanged(
                      markTouched: () => _emailTouched = true,
                    ),
                    onSubmitted: (_) => _usernameFocus.requestFocus(),
                  ),
                  AppTextField(
                    label: l10n.addBarberFieldUsername,
                    controller: _usernameController,
                    hintText: l10n.addBarberPlaceholderUsername,
                    keyboardType: TextInputType.text,
                    errorText: _usernameError,
                    enabled: !_saving,
                    inputFormatters: _usernameInputFormatters,
                    focusNode: _usernameFocus,
                    textInputAction: TextInputAction.next,
                    onChanged: _onUsernameChanged,
                    onSubmitted: (_) => _phoneFocus.requestFocus(),
                  ),
                  AppTextField(
                    label: l10n.addBarberFieldPhoneNumber,
                    controller: _phoneController,
                    hintText: l10n.addBarberPlaceholderPhone,
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    enabled: !_saving,
                    inputFormatters: _phoneInputFormatters,
                    focusNode: _phoneFocus,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _onCreateFieldChanged(
                      markTouched: () => _phoneTouched = true,
                    ),
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                ],
              )
            else ...[
              AppTextField(
                label: l10n.teamFieldFullName,
                controller: _nameController,
                errorText: _nameError,
                enabled: !_saving,
              ),
              const SizedBox(height: AppSpacing.medium),
              if ((widget.existing!.username ?? '').trim().isNotEmpty)
                AppTextField(
                  label: l10n.teamFieldUsername,
                  controller: _usernameController,
                  enabled: false,
                )
              else ...[
                Text(
                  l10n.teamFieldEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                SelectableText(
                  widget.existing!.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.medium),
              AppTextField(
                label: l10n.teamFieldPhone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                errorText: _phoneError,
                enabled: !_saving,
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      '${l10n.ownerEmployeeRole}: ${localizedStaffRole(l10n, _selectedRole)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isNew) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                l10n.ownerEmployeeRole,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _saving ? null : _showRolePicker,
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.38),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9DDFE)),
                          ),
                          child: Icon(
                            _selectedRole == UserRoles.admin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.content_cut_rounded,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizedStaffRole(l10n, _selectedRole),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      if (isNew) ...[
        SizedBox(height: horizontalPadding),
        FormSectionCard(
          radius: sectionRadius,
          title: l10n.addBarberSectionLoginPassword,
          icon: Icons.lock_outline_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveFieldsGrid(
                children: [
                  AppTextField(
                    label: l10n.addBarberFieldPassword,
                    controller: _passwordController,
                    hintText: l10n.addBarberPlaceholderPassword,
                    helperText: l10n.addBarberHelperPasswordShared,
                    obscureText: _obscurePassword,
                    enabled: !_saving,
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _updateCanSubmit(),
                    onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                    suffixIcon: IconButton(
                      onPressed: _saving
                          ? null
                          : () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  AppTextField(
                    label: l10n.addBarberFieldConfirmPassword,
                    controller: _confirmPasswordController,
                    hintText: l10n.addBarberPlaceholderConfirmPassword,
                    helperText: _requirePasswordChangeOnFirstLogin
                        ? l10n.addBarberHelperMustChangePassword
                        : null,
                    obscureText: _obscureConfirm,
                    enabled: !_saving,
                    focusNode: _confirmPasswordFocus,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _updateCanSubmit(),
                    suffixIcon: IconButton(
                      onPressed: _saving
                          ? null
                          : () {
                              setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              );
                            },
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                l10n.addBarberPasswordRulesHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              AddBarberPasswordChecklist(
                l10n: l10n,
                password: _passwordController.text,
                confirm: _confirmPasswordController.text,
              ),
              const SizedBox(height: AppSpacing.small),
              WorkSettingsSwitchTile(
                title: l10n.addBarberRequirePasswordChangeOnFirstLogin,
                subtitle: _requirePasswordChangeOnFirstLogin
                    ? l10n.addBarberHelperMustChangePassword
                    : null,
                value: _requirePasswordChangeOnFirstLogin,
                onChanged: _saving
                    ? null
                    : (v) => setState(
                        () => _requirePasswordChangeOnFirstLogin = v,
                      ),
                icon: Icons.key_rounded,
                enabled: !_saving,
              ),
            ],
          ),
        ),
        SizedBox(height: horizontalPadding),
      ],
      FormSectionCard(
        radius: sectionRadius,
        title: l10n.addBarberSectionCommissionWork,
        icon: Icons.payments_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.teamFieldHiringDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            InkWell(
              onTap: _saving ? null : _pickHiredAt,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9DDFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9DDFE)),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.teamFieldHiringDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd(localeName).format(
                              DateTime(
                                _hiredAt.year,
                                _hiredAt.month,
                                _hiredAt.day,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.teamFieldHiringDateHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (_normalizeRole(_selectedRole) != UserRoles.owner) ...[
              const SizedBox(height: AppSpacing.medium),
              AppSelectField<String>(
                label: l10n.teamPayrollPeriodLabel,
                hintText: l10n.teamPayrollPeriodHint,
                sheetTitle: l10n.teamPayrollPeriodLabel,
                value: _payrollPeriodOverrideChoice,
                options: [
                  AppSelectOption(
                    value: SalonPayrollPeriods.monthly,
                    label: l10n.teamPayrollPeriodMonthly,
                  ),
                  AppSelectOption(
                    value: SalonPayrollPeriods.weekly,
                    label: l10n.teamPayrollPeriodWeekly,
                  ),
                ],
                onChanged: (v) {
                  if (v == null || _saving) {
                    return;
                  }
                  setState(() => _payrollPeriodOverrideChoice = v);
                },
                enabled: !_saving,
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            Text(
              l10n.teamFieldCommissionType,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            InkWell(
              onTap: _saving ? null : _openCommissionTypePicker,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9DDFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9DDFE)),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.teamFieldCommissionType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _commissionTypeLabel(l10n, _commissionType),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF7C3AED),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional.topStart,
              child: ResponsiveFieldsGrid(
                children: [
                  if (showPct)
                    AppTextField(
                      label: l10n.teamFieldCommissionPercentagePercent,
                      controller: _commissionPctController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: _decimalInputFormatters,
                      helperText: l10n.teamCommissionPercentInputHint,
                      errorText: _commissionPctError,
                      enabled: !_saving,
                      onChanged: (_) => _onCreateFieldChanged(
                        markTouched: () => _commissionTouched = true,
                      ),
                    ),
                  if (showFixed)
                    AppTextField(
                      label: l10n.teamFieldCommissionFixedAmount(salonMoneyCode),
                      controller: _commissionFixedController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: _decimalInputFormatters,
                      errorText: _commissionFixedError,
                      enabled: !_saving,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              _commissionHelper(l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            CommissionPreviewCard(
              title: l10n.teamCommissionPreviewLabel,
              equationLine: _previewLine(l10n, localeName),
              disclaimer: l10n.teamCommissionPreviewDisclaimer,
              sampleNote: l10n.teamCommissionPreviewSampleNote,
            ),
            const SizedBox(height: AppSpacing.medium),
            WorkSettingsSwitchTile(
              title: l10n.teamFieldAttendanceRequired,
              subtitle: l10n.teamFieldAttendanceRequiredHint,
              value: _attendanceRequired,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _attendanceRequired = value),
              icon: Icons.event_available_outlined,
              enabled: !_saving,
            ),
            const SizedBox(height: AppSpacing.small),
            WorkSettingsSwitchTile(
              title: l10n.teamFieldBookable,
              subtitle: l10n.teamFieldBookableHint,
              value: _selectedRole == UserRoles.barber ? _isBookable : false,
              onChanged: _saving
                  ? null
                  : (_selectedRole != UserRoles.barber)
                  ? null
                  : (value) => setState(() => _isBookable = value),
              icon: Icons.calendar_month_outlined,
              enabled: !_saving && _selectedRole == UserRoles.barber,
            ),
            const SizedBox(height: AppSpacing.small),
            WorkSettingsSwitchTile(
              title: l10n.teamFieldActiveStatus,
              subtitle: l10n.teamFieldActiveStatusHint,
              value: _isActive,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _isActive = value),
              icon: Icons.toggle_on_outlined,
              enabled: !_saving,
            ),
          ],
        ),
      ),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AddBarberHeader(
              title: heroTitle,
              subtitle: heroSubtitle,
              compact: compactHeader,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ColoredBox(
                color: scheme.surfaceContainerLow,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      behavior: HitTestBehavior.deferToChild,
                      child: CustomScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              horizontalPadding,
                              horizontalPadding,
                              horizontalPadding,
                              footerReserve,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(scrollChildren),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StickyCreateBarberFooter(
                      label: primaryFooterLabel,
                      onPressed: _saving ? null : _submit,
                      isLoading: _saving,
                      isDisabled: _saving || (isNew && !_isFormValid),
                      leadingIcon: footerIcon,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
