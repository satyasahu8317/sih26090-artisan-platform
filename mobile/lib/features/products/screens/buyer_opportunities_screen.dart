import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerOpportunitiesScreen extends StatefulWidget {
  const BuyerOpportunitiesScreen({super.key});

  @override
  State<BuyerOpportunitiesScreen> createState() =>
      _BuyerOpportunitiesScreenState();
}

class _BuyerOpportunitiesScreenState
    extends State<BuyerOpportunitiesScreen> {
  int selectedFilter = 0;

  final List<String> filters = [
    'Best Match',
    'New',
    'Accepted',
    'Passed',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ───────── HEADER ─────────
                    const Text(
                      'Buyer Opportunities',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF604532),
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'AI-matched to your craft profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9D8C7D),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ───────── STATS ─────────
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            number: '3',
                            label: 'New',
                            backgroundColor: const Color(0xFFFAE8E1),
                            numberColor: const Color(0xFFC45B38),
                            labelColor: const Color(0xFFC45B38),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            number: '1',
                            label: 'Accepted',
                            backgroundColor: const Color(0xFFE7F3ED),
                            numberColor: const Color(0xFF287058),
                            labelColor: const Color(0xFF287058),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            number: '8',
                            label: 'Total',
                            backgroundColor: const Color(0xFFEDE0CC),
                            numberColor: const Color(0xFF8B5E34),
                            labelColor: const Color(0xFF8B5E34),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ───────── FILTERS ─────────
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = selectedFilter == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFilter = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF996735)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFD2B48C),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                filters[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF604532),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ───────── OPPORTUNITY 1 ─────────
                    _opportunityCard(
                      matchLabel: 'BEST\nMATCH',
                      matchPercentage: '94%',
                      matchColor: const Color(0xFF287058),
                      company: 'GiftWala Corp ·',
                      location: 'Mumbai, MH',
                      title: 'Corporate Gift Boxes',
                      quantity: '300 units',
                      budget: '₹400–₹500/pc',
                      deadline: '15 days',
                      productMatch: true,
                      capacityMatch: true,
                      priceMatch: true,
                      deliveryMatch: true,
                    ),

                    const SizedBox(height: 16),

                    // ───────── OPPORTUNITY 2 ─────────
                    _opportunityCard(
                      matchLabel: 'HIGH\nMATCH',
                      matchPercentage: '87%',
                      matchColor: const Color(0xFF996735),
                      company: 'Dilli Haat Emporium ·',
                      location: 'Delhi',
                      title: 'Handwoven Stoles',
                      quantity: '50 pieces',
                      budget: '₹800–₹1,200/pc',
                      deadline: '21 days',
                      productMatch: true,
                      capacityMatch: true,
                      priceMatch: true,
                      deliveryMatch: false,
                    ),

                    const SizedBox(height: 16),

                    // ───────── OPPORTUNITY 3 ─────────
                    _opportunityCard(
                      matchLabel: 'GOOD\nMATCH',
                      matchPercentage: '79%',
                      matchColor: const Color(0xFF996735),
                      company: 'Craft Bazaar ·',
                      location: 'Jaipur, RJ',
                      title: 'Handcrafted Decor',
                      quantity: '100 pieces',
                      budget: '₹600–₹900/pc',
                      deadline: '18 days',
                      productMatch: true,
                      capacityMatch: true,
                      priceMatch: false,
                      deliveryMatch: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ───────── BOTTOM NAV ─────────
      bottomNavigationBar: _bottomNavigationBar(),

      // ───────── CENTER ADD BUTTON ─────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF8B351C),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }

  // ───────── STAT CARD ─────────

  Widget _statCard({
    required String number,
    required String label,
    required Color backgroundColor,
    required Color numberColor,
    required Color labelColor,
  }) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: numberColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  // ───────── OPPORTUNITY CARD ─────────

  Widget _opportunityCard({
    required String matchLabel,
    required String matchPercentage,
    required Color matchColor,
    required String company,
    required String location,
    required String title,
    required String quantity,
    required String budget,
    required String deadline,
    required bool productMatch,
    required bool capacityMatch,
    required bool priceMatch,
    required bool deliveryMatch,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            offset: Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // ───── TOP MATCH HEADER ─────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 75,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: matchColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    matchLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D8C7D),
                        ),
                      ),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D8C7D),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Match progress
                SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: int.parse(
                                  matchPercentage.replaceAll('%', ''),
                                ) /
                                100,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFEDE0CC),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(matchColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        matchPercentage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: matchColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFD2B48C),
          ),

          // ───── REQUIREMENT CONTENT ─────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF604532),
                  ),
                ),

                const SizedBox(height: 12),

                // Quantity / Budget / Deadline
                Row(
                  children: [
                    Expanded(
                      child: _infoBox(
                        icon: Icons.inventory_2_outlined,
                        value: quantity,
                        label: 'Qty',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoBox(
                        icon: Icons.currency_rupee,
                        value: budget,
                        label: 'Budget',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoBox(
                        icon: Icons.timer_outlined,
                        value: deadline,
                        label: 'Deadline',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Matching chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _matchChip('Product', productMatch),
                    _matchChip('Capacity', capacityMatch),
                    _matchChip('Price', priceMatch),
                    _matchChip('Delivery', deliveryMatch),
                  ],
                ),

                const SizedBox(height: 13),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
  onPressed: () {
    context.push('/submit-quote');
  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5E34),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'I Can Fulfill ✓',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/requirement-detail');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8B5E34),
                            side: const BorderSide(
                              color: Color(0xFF8B5E34),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'View Detail →',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

  // ───────── INFO BOX ─────────

  Widget _infoBox({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0CC),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF8B5E34),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF604532),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9D8C7D),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── MATCH CHIP ─────────

  Widget _matchChip(String label, bool matched) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: matched
            ? const Color(0xFFE7F3ED)
            : const Color(0xFFFFF0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label ${matched ? '✓' : '~'}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: matched
              ? const Color(0xFF287058)
              : const Color(0xFFC56A32),
        ),
      ),
    );
  }

  // ───────── BOTTOM NAVIGATION ─────────

  Widget _bottomNavigationBar() {
    return BottomAppBar(
      color: const Color(0xFFF6F1E7),
      elevation: 8,
      height: 74,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: false,
            ),
            _navItem(
              icon: Icons.description_outlined,
              label: 'Catalog',
              selected: false,
            ),

            const SizedBox(width: 55),

            _navItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Orders',
              selected: false,
            ),
            _navItem(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return SizedBox(
      width: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 21,
            color: selected
                ? const Color(0xFF8B5E34)
                : const Color(0xFF9D8C7D),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: selected
                  ? const Color(0xFF8B5E34)
                  : const Color(0xFF9D8C7D),
            ),
          ),
        ],
      ),
    );
  }
}