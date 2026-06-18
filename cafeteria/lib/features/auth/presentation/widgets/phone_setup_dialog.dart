import 'package:flutter/material.dart';
import '../../../../core/network/dio_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_entity.dart';

/// Blocking dialog that collects a phone number for accounts that don't have
/// one (e.g. Google sign-in). It saves directly to `POST /user/phone` and can
/// only be dismissed by saving a valid number.
class PhoneSetupDialog extends StatefulWidget {
  const PhoneSetupDialog({super.key});

  @override
  State<PhoneSetupDialog> createState() => _PhoneSetupDialogState();
}

class _PhoneSetupDialogState extends State<PhoneSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await NetworkDioHandler().dio.post(
        '/user/phone',
        data: {'phoneNumber': _controller.text.trim()},
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = l10n.couldNotSavePhone;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addPhoneTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1A08),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addPhoneSubtitle,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8B7355)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return l10n.phoneRequired;
                    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(t)) {
                      return l10n.phoneInvalid;
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B1A08),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.saveChanges),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ensures a customer has a phone number before proceeding past sign-in.
/// Admins are exempt. Returns true once a number exists (or was just saved).
Future<bool> ensurePhoneNumber(BuildContext context, UserEntity user) async {
  if (user.role == 'admin' || user.phoneNumber.trim().isNotEmpty) return true;
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PhoneSetupDialog(),
  );
  return saved == true;
}
