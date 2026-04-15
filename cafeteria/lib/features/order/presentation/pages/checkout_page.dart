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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    context.read<OrderBloc>().add(
          CreateOrderEvent(
            deliveryLocation: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;
    final cart = args['cart'] as CartEntity;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderPlaced) {
          // Clear the cart after successful order
          context.read<CartBloc>().add(GetCartEvent());

          // Navigate to success animation page
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
                      AppLocalizations.of(context)!.checkout,
                      style: TextStyle(
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
                            border:
                            Border.all(color: const Color(0xFFE8D7BF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.orderSummary,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...cart.items.map((item) =>
                                  Padding(
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
                                                '${item.quantity}x ${item
                                                    .menuItemName}',
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
                                          '${item.subtotal.toStringAsFixed(
                                              2)}${AppLocalizations.of(context)!
                                              .pound}',
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
                                    AppLocalizations.of(context)!.total,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B1A08),
                                    ),
                                  ),
                                  Text(
                                    '${cart.totalPrice.toStringAsFixed(
                                        2)}${AppLocalizations.of(context)!
                                        .total}',
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
                            border:
                            Border.all(color: const Color(0xFFE8D7BF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.deliveryLocation,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B1A08),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _locationController,
                                validator: (value) {
                                  if (value == null || value
                                      .trim()
                                      .isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .deliveryLocationrequired;
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
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
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
                              AppLocalizations.of(context)!.placeOrder,
                              style: TextStyle(
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
                          Icon(Icons.arrow_back,
                              size: 16, color: Color(0xFF8B7355)),
                          SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.backToCart,
                            style: TextStyle(
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
