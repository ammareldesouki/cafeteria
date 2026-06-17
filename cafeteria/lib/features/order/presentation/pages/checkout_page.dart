import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/manager/cart_bloc.dart';
import '../../../cart/presentation/manager/cart_event.dart';
import '../manager/order_bloc.dart';
import '../manager/order_event.dart';
import '../manager/order_state.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _scheduled = false;
  TimeOfDay? _scheduledTime;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DateTime? get _scheduledFor {
    if (!_scheduled || _scheduledTime == null) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B1A08),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    if (_scheduled && _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectDateTime),
          backgroundColor: Colors.red,
        ),
      );
      _pickTime();
      return;
    }

    context.read<OrderBloc>().add(
          CreateOrderEvent(
            deliveryLocation: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            note: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
            scheduledFor: _scheduledFor,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final cart = args['cart'] as CartEntity;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlaced) {
          context.read<CartBloc>().add(GetCartEvent());
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  OrderSuccessPage(order: state.order),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF3B1A08),
                      radius: 20,
                      child:
                          Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.checkout,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B1A08),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Order Summary Card ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFE8D7BF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.orderSummary,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...cart.items.map((item) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.quantity}x ${item.menuItemName}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF3B1A08),
                                                ),
                                              ),
                                              if (item.variantName !=
                                                  null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  item.variantName!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF8B7355),
                                                  ),
                                                ),
                                              ],
                                              if (item.sugar != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${l10n.sugar}: ${l10n.sugarSpoons(item.sugar!)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF8B7355),
                                                  ),
                                                ),
                                              ],
                                              if (item.selectedExtras != null &&
                                                  item.selectedExtras!
                                                      .isNotEmpty)
                                                ...item.selectedExtras!.map(
                                                    (e) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 2),
                                                          child: Text(
                                                            '+ ${e.name} (+${e.price.toStringAsFixed(0)} ${l10n.pound})',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 11,
                                                              color: Color(
                                                                  0xFFC07722),
                                                            ),
                                                          ),
                                                        )),
                                              if (item.note != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Note: ${item.note}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF8B7355),
                                                    fontStyle:
                                                        FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${item.subtotal.toStringAsFixed(2)}${l10n.pound}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3B1A08),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(color: Color(0xFFE8D7BF)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.total,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B1A08),
                                    ),
                                  ),
                                  Text(
                                    '${cart.totalPrice.toStringAsFixed(2)}${l10n.total}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC07722),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Delivery Location ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFE8D7BF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.deliveryLocation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _locationController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return l10n.deliveryLocationrequired;
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Schedule ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFE8D7BF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.scheduleForLater,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // ASAP / Schedule toggle
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _scheduled = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: !_scheduled
                                              ? const Color(0xFF3B1A08)
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.asSoonAsPossible,
                                            style: TextStyle(
                                              color: !_scheduled
                                                  ? Colors.white
                                                  : const Color(0xFF8B7355),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child:                                   GestureDetector(
                                      onTap: () {
                                        setState(() => _scheduled = true);
                                        if (_scheduledTime == null) {
                                          _pickTime();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _scheduled
                                              ? const Color(0xFF3B1A08)
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            l10n.scheduleForLater,
                                            style: TextStyle(
                                              color: _scheduled
                                                  ? Colors.white
                                                  : const Color(0xFF8B7355),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_scheduled) ...[
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _pickTime,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF9F5),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE8D7BF)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.access_time,
                                            color: Color(0xFF8B7355),
                                            size: 18),
                                        const SizedBox(width: 10),
                                        Text(
                                          _scheduledTime != null
                                              ? _scheduledTime!
                                                  .format(context)
                                              : l10n.selectDateTime,
                                          style: TextStyle(
                                            color: _scheduledTime != null
                                                ? const Color(0xFF3B1A08)
                                                : const Color(0xFF8B7355),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.edit_calendar,
                                            color: Color(0xFF8B7355),
                                            size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Order Notes ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFE8D7BF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.orderNotes,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: l10n.orderNotesHint,
                                  hintStyle: const TextStyle(
                                      color: Color(0xFFB8A08E)),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE8D7BF)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE8D7BF)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF3B1A08)),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom buttons ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        final isPlacing = state is OrderPlacing;
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isPlacing ? null : _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B1A08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: isPlacing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.placeOrder,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back,
                              size: 16, color: Color(0xFF8B7355)),
                          const SizedBox(width: 6),
                          Text(
                            l10n.backToCart,
                            style: const TextStyle(
                              color: Color(0xFF8B7355),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
