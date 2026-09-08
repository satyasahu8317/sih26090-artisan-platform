import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../orders/data/artisan_order_model.dart';
import '../../orders/providers/orders_provider.dart';

class OrderTrackScreen extends ConsumerStatefulWidget {
  final String? orderId;
  final String? initialStatus;
  final int? requestedQty;

  const OrderTrackScreen({
    super.key,
    this.orderId,
    this.initialStatus,
    this.requestedQty,
  });

  @override
  ConsumerState<OrderTrackScreen> createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends ConsumerState<OrderTrackScreen> {
  static const background = Color(0xFFF6F1E7);
  static const brown = Color(0xFF8B5E34);
  static const darkBrown = Color(0xFF604532);
  static const green = Color(0xFF2E7058);
  static const red = Color(0xFF9E260F);
  static const border = Color(0xFFD2B48C);

  late String currentStatus;
  bool isUpdating = false;
  String? detailStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.initialStatus ?? 'PENDING';
  }

  Future<void> _executeAction({required String action, int? acceptedQty}) async {
    final orderId = widget.orderId;
    if (orderId == null || isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final repository = ref.read(ordersRepositoryProvider);
      switch (action) {
        case 'accept':
          await repository.acceptOrder(orderId);
          currentStatus = 'ACCEPTED';
          break;
        case 'partial':
          await repository.partiallyAcceptOrder(orderId, acceptedQty!);
          currentStatus = 'PARTIALLY_ACCEPTED';
          break;
        case 'reject':
          await repository.rejectOrder(orderId);
          currentStatus = 'REJECTED';
          break;
        case 'fulfilling':
          await repository.markFulfilling(orderId);
          currentStatus = 'FULFILLING';
          break;
        case 'complete':
          await repository.completeOrder(orderId);
          currentStatus = 'COMPLETED';
          break;
      }

      ref.invalidate(artisanOrdersProvider(null));
      ref.invalidate(artisanOrdersProvider('COMPLETED'));

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update the order. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _showStatusActions() async {
    if (widget.orderId == null || isUpdating) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: background,
      builder: (context) {
        final actions = <String, String>{
          if (currentStatus == 'PENDING') ...{
            'accept': 'Accept Order',
            'partial': 'Partial Accept',
            'reject': 'Reject Order',
          },
          if (currentStatus == 'ACCEPTED' ||
              currentStatus == 'PARTIALLY_ACCEPTED')
            'fulfilling': 'Mark Fulfilling',
          if (currentStatus == 'FULFILLING') 'complete': 'Mark Complete',
        };

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: actions.entries
                  .map(
                    (entry) => ListTile(
                      title: Text(entry.value),
                      onTap: () => Navigator.pop(context, entry.key),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );

    if (action == null) return;
    if (action == 'partial') {
      final acceptedQty = await _showPartialQuantityDialog();
      if (acceptedQty == null) return;
      await _executeAction(action: action, acceptedQty: acceptedQty);
      return;
    }
    await _executeAction(action: action);
  }

  Future<int?> _showPartialQuantityDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        title: const Text('Partial Accept'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Accepted quantity',
            hintText: widget.requestedQty == null
                ? null
                : 'Less than ${widget.requestedQty}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, int.tryParse(controller.text.trim()));
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    if (orderId != null) {
      final order = ref.watch(orderDetailsProvider(orderId));
      return order.when(
        loading: () => const Scaffold(
          backgroundColor: background,
          body: Center(
            child: CircularProgressIndicator(color: brown),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          backgroundColor: background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to load this order',
                  style: TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => ref.invalidate(
                    orderDetailsProvider(orderId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (order) {
          detailStatus = order.status;
          return _buildLoadedOrder(order);
        },
      );
    }

    return _buildLoadedOrder(null);
  }

  Widget _buildLoadedOrder(ArtisanOrderDetail? order) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, order),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  children: [
                    _overdueCard(),
                    const SizedBox(height: 12),
                    _productionProgress(),
                    const SizedBox(height: 12),
                    _orderTimeline(),
                    const SizedBox(height: 12),
                    _saveProgressButton(),
                    const SizedBox(height: 12),
                    _orderDetails(order),
                    const SizedBox(height: 12),
                    _keyDates(order),
                    const SizedBox(height: 12),
                    _earningsBreakdown(order),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            _bottomActions(context),
          ],
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

  Widget _header(BuildContext context, ArtisanOrderDetail? order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      color: brown,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order?.id ?? widget.orderId ?? 'ORDER DETAILS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  order?.buyer.businessName ?? 'Order Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              detailStatus ?? currentStatus,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── OVERDUE ─────────────────

  Widget _overdueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF9E260F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overdue!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Deadline: 18 Feb 2025 · Pack by 15 Feb 2025',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '0 days left',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── PRODUCTION ─────────────────

  Widget _productionProgress() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Production Progress',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                '0%',
                style: TextStyle(
                  color: brown,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: Color(0xFFE4DDD3),
              valueColor: AlwaysStoppedAnimation<Color>(brown),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── TIMELINE ─────────────────

  Widget _orderTimeline() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              color: darkBrown,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          _timelineItem(
            icon: Icons.check,
            title: 'Order Confirmed',
            percent: '0%',
            completed: true,
          ),

          _timelineItem(
            icon: Icons.inventory_2_outlined,
            title: 'Raw Material Ready',
            percent: '25%',
          ),

          _timelineItem(
            icon: Icons.hourglass_bottom,
            title: 'Halfway Done',
            percent: '50%',
          ),

          _timelineItem(
            icon: Icons.auto_awesome,
            title: 'Final Finishing',
            percent: '75%',
          ),

          _timelineItem(
            icon: Icons.inventory_outlined,
            title: 'Ready to Pack',
            percent: '100%',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String percent,
    bool completed = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? green
                        : const Color(0xFFE8DED0),
                    border: Border.all(
                      color: completed ? green : border,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 12,
                    color: completed ? Colors.white : brown,
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: const Color(0xFFD8C9B8),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: completed
                            ? darkBrown
                            : const Color(0xFF806F60),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    percent,
                    style: const TextStyle(
                      color: Color(0xFF9A8575),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── SAVE PROGRESS ─────────────────

  Widget _saveProgressButton() {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: const Text(
          'Save Progress Update',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ───────────────── ORDER DETAILS ─────────────────

  Widget _orderDetails(ArtisanOrderDetail? order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              color: darkBrown,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          _detailRow('Product', order?.product?.displayName ?? 'Not specified'),
          _detailRow('Buyer', order?.buyer.businessName ?? 'Not specified'),
          _detailRow('Quantity', '${order?.requestedQty ?? 0} units'),
          _detailRow(
            'Price/Unit',
            order?.unitPrice == null ? 'Not specified' : '₹${order!.unitPrice}',
          ),
          _detailRow('Status', order?.status ?? currentStatus),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF9A8575),
                fontSize: 8.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkBrown,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── KEY DATES ─────────────────

  Widget _keyDates(ArtisanOrderDetail? order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Dates',
            style: TextStyle(
              color: darkBrown,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          _dateRow(
            icon: Icons.check_circle,
            title: 'Order Confirmed',
            date: _formatDate(order?.createdAt),
            status: 'Done',
            done: true,
          ),

          _dateRow(
            icon: Icons.inventory_2_outlined,
            title: 'Material Deadline',
            date: _formatDate(order?.requiredBy),
            status: order?.requiredBy == null ? '—' : 'Required by',
            done: false,
          ),

          _dateRow(
            icon: Icons.local_shipping_outlined,
            title: 'Expected Packing',
            date: _formatDate(order?.updatedAt),
            status: '—',
          ),

          _dateRow(
            icon: Icons.warning_amber_rounded,
            title: 'Delivery Deadline',
            date: '—',
            status: '—',
          ),
        ],
      ),
    );
  }

  Widget _dateRow({
    required IconData icon,
    required String title,
    required String date,
    required String status,
    bool done = false,
    bool warning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: done
                ? green
                : warning
                    ? red
                    : brown,
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF9A8575),
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),

          Text(
            status,
            style: TextStyle(
              color: done
                  ? green
                  : warning
                      ? red
                      : const Color(0xFF9A8575),
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── EARNINGS ─────────────────

  Widget _earningsBreakdown(ArtisanOrderDetail? order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Breakdown',
            style: TextStyle(
              color: darkBrown,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

              _earningRow(
                '${order?.requestedQty ?? 0} × ${order?.unitPrice ?? 'Not specified'}',
                order?.totalAmount == null ? 'Not specified' : '₹${order!.totalAmount}',
              ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF9E260F),
              borderRadius: BorderRadius.circular(10),
            ),
                child: Row(
              children: [
                Expanded(
                  child: Text(
                    'You will earn',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                    ),
                  ),
                ),
                    Text(
                      order?.totalAmount == null
                          ? 'Not specified'
                          : '₹${order!.totalAmount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF806F60),
                fontSize: 8.5,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: darkBrown,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '—';
    final date = value.toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }

  // ───────────────── BOTTOM ACTIONS ─────────────────

  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 12),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(
            color: border.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 15,
              ),
              label: const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: brown,
                side: const BorderSide(color: border),
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.orderId == null || isUpdating
                  ? null
                  : _showStatusActions,
              icon: const Icon(
                Icons.edit_outlined,
                size: 15,
              ),
              label: isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}