import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArtisanAddressScreen extends StatefulWidget {
  const ArtisanAddressScreen({super.key});

  @override
  State<ArtisanAddressScreen> createState() =>
      _ArtisanAddressScreenState();
}

class _ArtisanAddressScreenState
    extends State<ArtisanAddressScreen> {
  final TextEditingController pincodeController =
      TextEditingController();
  final TextEditingController addressController =
      TextEditingController();
  final TextEditingController villageController =
      TextEditingController();
  final TextEditingController landmarkController =
      TextEditingController();

  String? selectedState;

  final List<String> states = [
    'Rajasthan',
    'Odisha',
    'Gujarat',
    'Maharashtra',
    'Tamil Nadu',
    'Uttar Pradesh',
    'West Bengal',
    'Other',
  ];

  bool get isPincodeValid =>
      pincodeController.text.trim().length == 6;

  @override
  void dispose() {
    pincodeController.dispose();
    addressController.dispose();
    villageController.dispose();
    landmarkController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    FocusScope.of(context).unfocus();

    if (!isPincodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit pincode'),
        ),
      );
      return;
    }

    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your house/shop address'),
        ),
      );
      return;
    }

    if (selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your state'),
        ),
      );
      return;
    }

    context.go('/home');
  }

  void _skipForNow() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 390,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ---------------- HEADER ----------------
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD2B48C),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 19,
                            color: Color(0xFF604532),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Pickup\nAddress',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 23,
                            height: 0.95,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF604532),
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE0CC),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Text(
                          'Step 2 of 2',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5E34),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---------------- FORM ----------------
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PINCODE
                          _buildLabel(
                            'Pincode',
                            required: true,
                          ),

                          const SizedBox(height: 7),

                          Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD2B48C),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 45,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEDE0CC),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      bottomLeft:
                                          Radius.circular(11),
                                    ),
                                  ),
                                  child: const Text(
                                    'IN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF8B5E34),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: pincodeController,
                                    keyboardType:
                                        TextInputType.number,
                                    maxLength: 6,
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                    decoration:
                                        const InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      hintText: 'e.g. 302001',
                                      hintStyle: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFB49B88),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(
                                        horizontal: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // HOUSE / SHOP
                          _buildLabel(
                            'House / Shop No. & Street',
                            required: true,
                          ),

                          const SizedBox(height: 7),

                          _buildTextField(
                            controller: addressController,
                            hintText:
                                'e.g. No. 14, Pottery Lane, Near Hanuman Mandir',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 14),

                          // VILLAGE
                          _buildLabel(
                            'Village / Town / Mohalla',
                          ),

                          const SizedBox(height: 7),

                          _buildTextField(
                            controller: villageController,
                            hintText: 'e.g. Kishanpole Bazar',
                          ),

                          const SizedBox(height: 14),

                          // CITY + DISTRICT
                          Row(
                            children: [
                              Expanded(
                                child: _buildAutoField(
                                  label: 'City',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildAutoField(
                                  label: 'District',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // STATE
                          _buildLabel('State'),

                          const SizedBox(height: 7),

                          DropdownButtonFormField<String>(
                            initialValue: selectedState,
                            decoration: _inputDecoration(
                              hintText: 'Select state...',
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Color(0xFF8B5E34),
                            ),
                            dropdownColor: Colors.white,
                            items: states.map((state) {
                              return DropdownMenuItem<String>(
                                value: state,
                                child: Text(
                                  state,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF604532),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedState = value;
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          // LANDMARK
                          Row(
                            children: const [
                              Text(
                                'Nearby Landmark',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF604532),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '(optional)',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF9B806B),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          _buildTextField(
                            controller: landmarkController,
                            hintText:
                                'e.g. Near SBI Bank, Opp. Water Tank',
                          ),

                          const SizedBox(height: 12),

                          // HELPER
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: const Color(0xFFD2B48C),
                          ),

                          const SizedBox(height: 8),

                          const Center(
                            child: Text(
                              'Enter a valid 6-digit pincode to continue',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFFA68F7B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ---------------- SAVE ADDRESS ----------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isPincodeValid
                          ? _saveAddress
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E34),
                        disabledBackgroundColor:
                            const Color(0xFFE9DBC3),
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            const Color(0xFFC6AA83),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save Address →',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // ---------------- SKIP ----------------
                  Center(
                    child: TextButton(
                      onPressed: _skipForNow,
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9B806B),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool required = false,
  }) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF604532),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB65B3A),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(
        hintText: hintText,
      ),
    );
  }

  Widget _buildAutoField({
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF604532),
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EBDD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD2B48C),
            ),
          ),
          child: Text(
            isPincodeValid ? 'Auto-filled' : 'Auto-filled',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFB49B88),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFFB49B88),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD2B48C),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD2B48C),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF8B5E34),
          width: 1.4,
        ),
      ),
    );
  }
}