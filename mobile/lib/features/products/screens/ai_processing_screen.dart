import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen> {
  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brownColor = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);
  static const Color greenColor = Color(0xFF368267);
  static const Color mutedColor = Color(0xFF9B8B7A);
  static const Color lightBrown = Color(0xFFEDE0CC);

  int currentStep = 2;
  Timer? _timer;

  final List<String> steps = [
    'Cleaning your photo...',
    'Understanding your voice...',
    'Creating your description...',
    'Finding a fair market price...',
    'Almost done...',
  ];

  final List<String> hindiSteps = [
    'फोटो सुधार की जा रही है',
    'आवाज़ समझी जा रही है',
    'विवरण तैयार किया जा रहा है',
    'उचित मूल्य खोजा जा रहा है',
    'लगभग तैयार...',
  ];

  @override
  void initState() {
    super.initState();

    // Temporary UI progress.
    // Later this will be replaced with actual AI job status.
  
_timer = Timer.periodic(
  const Duration(seconds: 2),
  (timer) {
    if (!mounted) return;

    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      timer.cancel();

      context.push(
        '/review-edit-listing',
        extra: widget.imagePath,
      );
    }
  },
);
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get progress {
    return (currentStep + 1) / steps.length;
  }

  int get progressPercent {
    return (progress * 100).round();
  }

  Widget _buildStep(int index) {
    final bool completed = index < currentStep;
    final bool active = index == currentStep;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? greenColor
                  : active
                      ? brownColor
                      : const Color(0xFFE9DCC8),
            ),
            child: completed
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : active
                    ? const SizedBox(
                        width: 8,
                        height: 8,
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            size: 7,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active || completed
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: completed
                        ? darkBrown
                        : active
                            ? darkBrown
                            : mutedColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hindiSteps[index],
                  style: TextStyle(
                    fontSize: 9,
                    color: completed
                        ? mutedColor
                        : active
                            ? mutedColor
                            : const Color(0xFFC2B3A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE2C9A5),
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFD58A58),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_florist,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 12),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blue Pottery Vase',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Being processed...',
                style: TextStyle(
                  fontSize: 10,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 390,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: brownColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Center(
                      child: Text(
                        '✦',
                        style: TextStyle(
                          fontSize: 23,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title
                  const Text(
                    'AI is working on it...',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: darkBrown,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Please wait a moment.',
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Processing + percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Processing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: brownColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE8D9C2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        brownColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Processing steps
                  ...List.generate(
                    steps.length,
                    (index) => _buildStep(index),
                  ),

                  const SizedBox(height: 8),

                  _buildProductCard(),

                  const SizedBox(height: 12),

                  // Notification box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: lightBrown,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          '🔔',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "We'll notify you when it's ready.",
                            style: TextStyle(
                              fontSize: 10,
                              color: darkBrown,
                            ),
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
      ),
    );
  }
}