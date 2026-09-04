import 'package:flutter/material.dart';

class MyCatalogScreen extends StatefulWidget {
  const MyCatalogScreen({super.key});

  @override
  State<MyCatalogScreen> createState() => _MyCatalogScreenState();
}

class _MyCatalogScreenState extends State<MyCatalogScreen> {
  String filter = 'All';

  final products = const [
    ['Blue Pottery Vase', '₹800–₹1,200', 'Published', '4,650', '7'],
    ['Clay Pot', '₹500–₹900', 'Pending', '', ''],
    ['Decorative Plate', '₹700–₹1,200', 'Published', '2,340', '3'],
    ['Woven Bag', '₹400–₹600', 'Draft', '', ''],
    ['Bangle Set', '₹300–₹500', 'Published', '1,120', '5'],
  ];

  @override
  Widget build(BuildContext context) {
    final shown = filter == 'All'
        ? products
        : products.where((p) => p[2] == filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E4),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ---------------- HEADER ----------------
                  SliverToBoxAdapter(
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(24, 14, 24, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Catalog',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5A3D2E),
                              fontFamily: 'Noto Serif',
                            ),
                          ),
                          Text(
                            'मेरी सूची',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9B8574),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---------------- FILTERS ----------------
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        scrollDirection: Axis.horizontal,
                        children: [
                          'All',
                          'Published',
                          'Pending',
                          'Draft',
                        ].map(
                          (x) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    filter = x;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 17,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: filter == x
                                        ? const Color(0xFF8B5E34)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(0xFFD9B987),
                                    ),
                                  ),
                                  child: Text(
                                    x,
                                    style: TextStyle(
                                      color: filter == x
                                          ? Colors.white
                                          : const Color(0xFF6A4A38),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),

                  // ---------------- PRODUCT LIST ----------------
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    sliver: SliverList.builder(
                      itemCount: shown.length,
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProductCard(
                            data: shown[i],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ---------------- BOTTOM NAV ----------------
            const _BottomNav(),
          ],
        ),
      ),

      // ---------------- ADD BUTTON ----------------
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF8B5E34),
          onPressed: () {
            // Route baad mein connect karenge.
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 29,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard extends StatelessWidget {
  final List<String> data;

  const _ProductCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final status = data[2];

    final bg = status == 'Published'
        ? const Color(0xFFE4F2EA)
        : status == 'Pending'
            ? const Color(0xFFFCE3DA)
            : const Color(0xFFECE1CD);

    final text = status == 'Published'
        ? const Color(0xFF27765C)
        : status == 'Pending'
            ? const Color(0xFFD76542)
            : const Color(0xFF725B43);

    return Container(
      height: 98,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD9B987),
          width: .8,
        ),
      ),

      clipBehavior: Clip.antiAlias,

      child: Row(
        children: [

          // -------- IMAGE --------
          Container(
            width: 132,
            color: const Color(0xFFC77B4C),
            child: const Icon(
              Icons.local_florist_outlined,
              size: 38,
              color: Color(0x99FFFFFF),
            ),
          ),

          // -------- PRODUCT INFO --------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                4,
                8,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // NAME + STATUS
                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          data[0],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5A3D2E),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),

                        child: Text(
                          status,
                          style: TextStyle(
                            color: text,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // PRICE
                  Text(
                    data[1],
                    style: const TextStyle(
                      color: Color(0xFF8B5E34),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  // VIEWS + ENQUIRIES
                  if (data[3].isNotEmpty)
                    Row(
                      children: [

                        const Icon(
                          Icons.visibility_rounded,
                          size: 13,
                          color: Color(0xFF84766B),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          data[3],
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF9A8B7E),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Icon(
                          Icons.chat_bubble_rounded,
                          size: 12,
                          color: Color(0xFF84766B),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          data[4],
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF9A8B7E),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // -------- ARROW --------
          const Padding(
            padding: EdgeInsets.only(right: 9),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB98B60),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,

      decoration: const BoxDecoration(
        color: Color(0xFFF9F3E8),

        border: Border(
          top: BorderSide(
            color: Color(0xFFE2D2BB),
          ),
        ),
      ),

      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,

        children: [

          _Nav(
            Icons.home_rounded,
            'Home',
          ),

          _Nav(
            Icons.article_rounded,
            'Catalog',
            selected: true,
          ),

          SizedBox(width: 58),

          _Nav(
            Icons.shopping_bag_rounded,
            'Orders',
          ),

          _Nav(
            Icons.person_rounded,
            'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NAV ITEM
// ============================================================

class _Nav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _Nav(
    this.icon,
    this.label, {
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            size: 20,
            color: selected
                ? const Color(0xFF6A4935)
                : const Color(0xFF9A7C60),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: selected
                  ? const Color(0xFF6A4935)
                  : const Color(0xFF9A7C60),
            ),
          ),
        ],
      ),
    );
  }
}