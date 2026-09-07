import 'package:flutter/material.dart';

import 'audio_recording_screen.dart';
import 'ai_processing_screen.dart';
class DescribeProductScreen extends StatefulWidget {
  const DescribeProductScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<DescribeProductScreen> createState() =>
      _DescribeProductScreenState();
}

class _DescribeProductScreenState
    extends State<DescribeProductScreen> {
  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brownColor = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color borderColor = Color(0xFFDDBB8B);
  static const Color mutedColor = Color(0xFFB09B84);

  bool isVoiceMode = true;

  final TextEditingController _descriptionController =
      TextEditingController();

  final List<String> materials = [
    'Clay',
    'Silk',
    'Brass',
    'Bamboo',
    'Teak wood',
    'Cotton',
  ];

  final List<String> techniques = [
    'Hand-thrown',
    'Block printed',
    'Lost-wax cast',
    'Hand-stitched',
    'Hand-painted',
  ];

  final List<String> origins = [
    'Jaipur',
    'Varanasi',
    'Rajasthan',
    'Madhubani',
    'Bastar',
  ];

  final Set<String> selectedMaterials = {};
  final Set<String> selectedTechniques = {};
  final Set<String> selectedOrigins = {};

  String? audioPath;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openVoiceRecorder() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AudioRecordingScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        audioPath = result;
      });
    }
  }
void _continue() {
  if (isVoiceMode) {
    if (audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please record your product description first.',
          ),
        ),
      );
      return;
    }
  } else {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your product first.',
          ),
        ),
      );
      return;
    }
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AiProcessingScreen(
        imagePath: widget.imagePath,
      ),
    ),
  );
}

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? brownColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : mutedColor,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : darkBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEDE0CC)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? brownColor : borderColor,
          ),
        ),
        child: Text(
          '+ $label',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: selected ? brownColor : darkBrown,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceMode() {
    return Expanded(
      child: Column(
        children: [
          // Example
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAY SOMETHING LIKE - उदाहरण',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: brownColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '“यह जयपुर की हाथ से बनी नीली मिट्टी की फूलदान है, इसे प्राकृतिक रंगों से रंगा गया है।”',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Waveform
          Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              audioPath != null
                  ? '•  • •  • • •  • •  • • •  • •'
                  : '• • • • • • • • • • • • • • • •',
              style: TextStyle(
                fontSize: 15,
                letterSpacing: 2,
                color: audioPath != null
                    ? brownColor
                    : borderColor,
              ),
            ),
          ),

          const Spacer(),

          Text(
            audioPath != null ? 'Recording complete' : '00:00',
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            audioPath != null
                ? 'Your description is ready'
                : 'Tap the mic to start',
            style: const TextStyle(
              fontSize: 12,
              color: mutedColor,
            ),
          ),

          const SizedBox(height: 22),

          GestureDetector(
            onTap: _openVoiceRecorder,
            child: Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: brownColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            '✎  Or type it instead',
            style: TextStyle(
              fontSize: 11,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeMode() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // AI hint
            const Row(
              children: [
                Text(
                  '✨',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(width: 5),
                Text(
                  'AI will enhance your description for better reach',
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description field
            Container(
              height: 175,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: darkBrown,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      'Write about your product...\n\nTip: mention material, technique, origin, and size — the AI will do the rest!',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: mutedColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'MATERIAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: materials.map((material) {
                return _buildChip(
                  label: material,
                  selected:
                      selectedMaterials.contains(material),
                  onTap: () {
                    setState(() {
                      if (selectedMaterials.contains(material)) {
                        selectedMaterials.remove(material);
                      } else {
                        selectedMaterials.add(material);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            const Text(
              'TECHNIQUE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: techniques.map((technique) {
                return _buildChip(
                  label: technique,
                  selected:
                      selectedTechniques.contains(technique),
                  onTap: () {
                    setState(() {
                      if (selectedTechniques
                          .contains(technique)) {
                        selectedTechniques.remove(technique);
                      } else {
                        selectedTechniques.add(technique);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            const Text(
              'ORIGIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: origins.map((origin) {
                return _buildChip(
                  label: origin,
                  selected:
                      selectedOrigins.contains(origin),
                  onTap: () {
                    setState(() {
                      if (selectedOrigins.contains(origin)) {
                        selectedOrigins.remove(origin);
                      } else {
                        selectedOrigins.add(origin);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = isVoiceMode
        ? audioPath != null
        : _descriptionController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            16,
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: darkBrown,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Text(
                    'Describe your product',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Voice / Type selector
              Container(
                height: 48,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    _buildModeButton(
                      title: 'Voice',
                      icon: Icons.mic,
                      selected: isVoiceMode,
                      onTap: () {
                        setState(() {
                          isVoiceMode = true;
                        });
                      },
                    ),
                    _buildModeButton(
                      title: 'Type',
                      icon: Icons.edit,
                      selected: !isVoiceMode,
                      onTap: () {
                        setState(() {
                          isVoiceMode = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (isVoiceMode)
                _buildVoiceMode()
              else
                _buildTypeMode(),

              // Continue
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canContinue ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brownColor,
                    disabledBackgroundColor:
                        const Color(0xFFE8D9C2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isVoiceMode
                        ? 'Record or type to continue'
                        : 'Continue →',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: canContinue
                          ? Colors.white
                          : const Color(0xFFC5AD91),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}