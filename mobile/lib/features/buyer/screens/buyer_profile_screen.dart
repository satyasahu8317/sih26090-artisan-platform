import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/buyer_provider.dart';

class BuyerProfileScreen extends ConsumerStatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  ConsumerState<BuyerProfileScreen> createState() =>
      _BuyerProfileScreenState();
}

class _BuyerProfileScreenState
    extends ConsumerState<BuyerProfileScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(buyerProfileProvider);
    final enquiriesAsync = ref.watch(buyerMyEnquiriesProvider);
    final ordersAsync = ref.watch(buyerMyOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: profileAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _buildError(),
                data: (profile) {
                  final enquiryCount =
                      enquiriesAsync.valueOrNull?.length ?? 0;

                  final orderCount =
                      ordersAsync.valueOrNull?.length ?? 0;

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(buyerProfileProvider);
                      ref.invalidate(
                        buyerMyEnquiriesProvider,
                      );
                      ref.invalidate(
                        buyerMyOrdersProvider,
                      );
                    },
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        8,
                        12,
                        20,
                      ),
                      child: Column(
                        children: [
                          _buildCompanyCard(profile),
                          const SizedBox(height: 10),
                          _buildBuyerType(
                            profile.businessType,
                          ),
                          const SizedBox(height: 10),
                          _buildStats(
                            enquiryCount,
                            orderCount,
                          ),
                          const SizedBox(height: 10),
                          _buildCategories(),
                          const SizedBox(height: 10),
                          _buildRecentEnquiries(
                            enquiriesAsync,
                          ),
                          const SizedBox(height: 10),
                          _buildOrderHistory(
                            orderCount,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButtons(context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigation(context),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE0CC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Color(0xFF604532),
              ),
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyer Profile',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                Text(
                  'Business account',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF9A806A),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              context.push('/buyer-notifications');
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 17,
                color: Color(0xFF604532),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ERROR =================

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 35,
            color: Color(0xFFB65B3A),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load profile',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF604532),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(buyerProfileProvider);
              ref.invalidate(
                buyerMyEnquiriesProvider,
              );
              ref.invalidate(
                buyerMyOrdersProvider,
              );
            },
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMPANY =================

  Widget _buildCompanyCard(dynamic profile) {
    final businessName =
        profile.businessName?.trim().isNotEmpty == true
            ? profile.businessName!
            : profile.name?.trim().isNotEmpty == true
                ? profile.name!
                : 'Buyer';

    final locationParts = <String>[];

    if (profile.district != null &&
        profile.district!.trim().isNotEmpty) {
      locationParts.add(profile.district!);
    }

    if (profile.state != null &&
        profile.state!.trim().isNotEmpty) {
      locationParts.add(profile.state!);
    }

    final location = locationParts.join(', ');

    final businessType =
        profile.businessType?.trim().isNotEmpty == true
            ? profile.businessType!
            : 'Business';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD2B48C),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E5DD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                businessName.isNotEmpty
                    ? businessName[0].toUpperCase()
                    : 'B',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5E34),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '📍 $location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 7,
                      color: Color(0xFF9A806A),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.business_center_outlined,
                      size: 10,
                      color: Color(0xFF487B68),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        businessType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF487B68),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUYER TYPE =================

  Widget _buildBuyerType(String? currentType) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'BUYER TYPE',
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: .4,
            color: Color(0xFF9A806A),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _typeCard(
              '🏪',
              'Retail Shop',
              _isBuyerType(
                currentType,
                'Retail Shop',
              ),
            ),
            const SizedBox(width: 6),
            _typeCard(
              '🛍️',
              'Boutique',
              _isBuyerType(
                currentType,
                'Boutique',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _typeCard(
              '🎁',
              'Corporate\nGifting',
              _isBuyerType(
                currentType,
                'Corporate Gifting',
              ),
            ),
            const SizedBox(width: 6),
            _typeCard(
              '🔄',
              'Reseller',
              _isBuyerType(
                currentType,
                'Reseller',
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isBuyerType(
    String? currentType,
    String type,
  ) {
    if (currentType == null) return false;

    return currentType
            .trim()
            .toLowerCase() ==
        type.trim().toLowerCase();
  }

  Widget _typeCard(
    String icon,
    String title,
    bool selected,
  ) {
    return Expanded(
      child: Container(
        height: 45,
        padding:
            const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE5F0EA)
              : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected
                ? const Color(0xFF5A927A)
                : const Color(0xFFD2B48C),
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style:
                  const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF604532),
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                size: 13,
                color: Color(0xFF487B68),
              ),
          ],
        ),
      ),
    );
  }

  // ================= STATS =================

  Widget _buildStats(
    int enquiryCount,
    int orderCount,
  ) {
    return Row(
      children: [
        _statCard(
          '—',
          'Saved',
          Icons.favorite_border,
        ),
        const SizedBox(width: 7),
        _statCard(
          enquiryCount.toString(),
          'Enquiries Sent',
          Icons.send_outlined,
        ),
        const SizedBox(width: 7),
        _statCard(
          orderCount.toString(),
          'Orders',
          Icons.shopping_bag_outlined,
        ),
      ],
    );
  }

  Widget _statCard(
    String number,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 68,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE0CFB8),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 14,
              color: const Color(0xFFB65B3A),
            ),
            const SizedBox(height: 3),
            Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF604532),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 6.5,
                color: Color(0xFF9A806A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORIES =================

  Widget _buildCategories() {
    final categories = [
      ('🏺', 'Pottery'),
      ('🧵', 'Textiles'),
      ('💍', 'Jewellery'),
      ('🎨', 'Paintings'),
      ('🏠', 'Home Decor'),
    ];

    return _section(
      title: 'INTERESTED CRAFT CATEGORIES',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...categories.map(
            (category) => Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F0E3),
                borderRadius:
                    BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD2B48C),
                ),
              ),
              child: Text(
                '${category.$1}  ${category.$2}',
                style: const TextStyle(
                  fontSize: 7,
                  color: Color(0xFF765944),
                ),
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD2B48C),
              ),
            ),
            child: const Text(
              '+ Add',
              style: TextStyle(
                fontSize: 7,
                color: Color(0xFF8B5E34),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RECENT ENQUIRIES =================

  Widget _buildRecentEnquiries(
    AsyncValue enquiriesAsync,
  ) {
    return _section(
      title: 'RECENT ENQUIRIES',
      child: enquiriesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        error: (_, __) => const Text(
          'Unable to load enquiries',
          style: TextStyle(
            fontSize: 7,
            color: Color(0xFFB65B3A),
          ),
        ),
        data: (enquiries) {
          if (enquiries.isEmpty) {
            return const Text(
              'No enquiries yet.',
              style: TextStyle(
                fontSize: 7,
                color: Color(0xFF9A806A),
              ),
            );
          }

          final visibleEnquiries =
              enquiries.take(3).toList();

          return Column(
            children: [
              ...List.generate(
                visibleEnquiries.length,
                (index) {
                  final enquiry =
                      visibleEnquiries[index];

                  return Padding(
                    padding:
                        EdgeInsets.only(
                      bottom: index ==
                              visibleEnquiries.length -
                                  1
                          ? 0
                          : 6,
                    ),
                    child: _enquiryRow(
                      enquiry.id,
                      enquiry.status,
                      enquiry.message,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _enquiryRow(
    String id,
    String? status,
    String? message,
  ) {
    final isReplied =
        status?.toLowerCase() == 'replied' ||
        status?.toLowerCase() == 'responded' ||
        status?.toLowerCase() == 'accepted';

    return Container(
      height: 43,
      padding:
          const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE1D0BA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE0CC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 13,
              color: Color(0xFF8B5E34),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Enquiry ${id.length > 8 ? id.substring(0, 8) : id}',
                  style: const TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF604532),
                  ),
                ),
                Text(
                  message?.isNotEmpty == true
                      ? message!
                      : 'Enquiry message',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 6.5,
                    color: Color(0xFF9A806A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isReplied
                  ? const Color(0xFFE5F1EC)
                  : const Color(0xFFF8E9D9),
              borderRadius:
                  BorderRadius.circular(6),
            ),
            child: Text(
              status ?? 'Pending',
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w600,
                color: isReplied
                    ? const Color(0xFF3D765F)
                    : const Color(0xFFB65B3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ORDER HISTORY =================

  Widget _buildOrderHistory(int orderCount) {
    return GestureDetector(
      onTap: () {
        context.push('/buyer-orders');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE0CFB8),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 19,
              color: Color(0xFFB09A84),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF604532),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    orderCount == 0
                        ? 'No orders placed yet.'
                        : '$orderCount order${orderCount == 1 ? '' : 's'} placed.',
                    style: const TextStyle(
                      fontSize: 6.5,
                      color: Color(0xFF9A806A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFFAA927E),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTONS =================

  Widget _buildActionButtons(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.go('/buyer-home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFB65B3A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 12,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(9),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: _showEditProfileDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(0xFF8B5E34),
              side: const BorderSide(
                color: Color(0xFFB65B3A),
              ),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 11,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(9),
              ),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= EDIT PROFILE =================

  Future<void> _showEditProfileDialog() async {
    final profile =
        ref.read(buyerProfileProvider).valueOrNull;

    if (profile == null) return;

    final nameController =
        TextEditingController(
      text: profile.name ?? '',
    );

    final businessNameController =
        TextEditingController(
      text: profile.businessName ?? '',
    );

    final businessTypeController =
        TextEditingController(
      text: profile.businessType ?? '',
    );

    final stateController =
        TextEditingController(
      text: profile.state ?? '',
    );

    final districtController =
        TextEditingController(
      text: profile.district ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
                  const Color(0xFFF6F1E7),
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF604532),
                ),
              ),
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    _editField(
                      nameController,
                      'Name',
                    ),
                    const SizedBox(height: 9),
                    _editField(
                      businessNameController,
                      'Business name',
                    ),
                    const SizedBox(height: 9),
                    _editField(
                      businessTypeController,
                      'Business type',
                    ),
                    const SizedBox(height: 9),
                    _editField(
                      stateController,
                      'State',
                    ),
                    const SizedBox(height: 9),
                    _editField(
                      districtController,
                      'District',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUpdating
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF8B5E34),
                    ),
                  ),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF8B5E34),
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          setDialogState(() {
                            _isUpdating = true;
                          });

                          final success =
                              await _updateProfile(
                            nameController.text,
                            businessNameController
                                .text,
                            businessTypeController
                                .text,
                            stateController.text,
                            districtController
                                .text,
                          );

                          if (!mounted) return;

                          if (success) {
                            Navigator.pop(
                              dialogContext,
                            );

                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile updated successfully',
                                ),
                              ),
                            );
                          } else {
                            setDialogState(() {
                              _isUpdating = false;
                            });

                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to update profile',
                                ),
                              ),
                            );
                          }
                        },
                  child: _isUpdating
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    businessNameController.dispose();
    businessTypeController.dispose();
    stateController.dispose();
    districtController.dispose();
  }

  Widget _editField(
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF8B6B51),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFD2B48C),
          ),
        ),
      ),
    );
  }

  Future<bool> _updateProfile(
    String name,
    String businessName,
    String businessType,
    String state,
    String district,
  ) async {
    try {
      await ref
          .read(
            buyerProfileRepositoryProvider,
          )
          .updateProfile(
            name: name.trim(),
            businessName:
                businessName.trim(),
            businessType:
                businessType.trim(),
            state: state.trim(),
            district: district.trim(),
          );

      ref.invalidate(
        buyerProfileProvider,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // ================= SECTION =================

  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0CFB8),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: .4,
              color: Color(0xFF9A806A),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _buildBottomNavigation(
    BuildContext context,
  ) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Search'),
      (Icons.grid_view_rounded, 'Categories'),
      (Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD2B48C),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) {
            final selected = index == 4;

            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  context.go('/buyer-home');
                } else if (index == 1) {
                  context.go('/buyer-search');
                } else if (index == 3) {
                  context.go('/buyer-orders');
                }
              },
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 37,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF8B5E34)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Icon(
                      items[index].$1,
                      size: 17,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF9A6C43),
                    ),
                  ),
                  Text(
                    items[index].$2,
                    style: TextStyle(
                      fontSize: 6.5,
                      color: selected
                          ? const Color(0xFF8B5E34)
                          : const Color(0xFF9A806A),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}