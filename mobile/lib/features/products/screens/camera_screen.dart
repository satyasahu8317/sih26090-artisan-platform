import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'product_details_screen.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  bool _isLoading = true;
  bool _isCapturing = false;
  XFile? _capturedImage;

  static const Color backgroundColor = Color(0xFFF6F1E7);
  static const Color brownColor = Color(0xFF8B5E34);
  static const Color darkBrown = Color(0xFF604532);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

      // Prefer back camera
      CameraDescription selectedCamera = _cameras!.first;

      for (final camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final image = await _controller!.takePicture();

      if (mounted) {
        setState(() {
          _capturedImage = image;
          _isCapturing = false;
        });
      }
    } catch (e) {
      debugPrint('Take photo error: $e');

      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

 void _usePhoto() {
  if (_capturedImage == null) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailsScreen(
        imagePath: _capturedImage!.path,
      ),
    ),
  );
}

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: brownColor,
                ),
              )
            : _capturedImage == null
                ? _buildCameraView()
                : _buildPhotoPreview(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CAMERA VIEW
  // ─────────────────────────────────────────────

  Widget _buildCameraView() {
    if (_controller == null ||
        !_controller!.value.isInitialized) {
      return const Center(
        child: Text(
          'Unable to open camera',
          style: TextStyle(
            color: darkBrown,
            fontSize: 16,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),

        // Top bar
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _roundButton(
                icon: Icons.close,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
_roundButton(
  icon: _controller?.value.flashMode == FlashMode.torch
      ? Icons.flash_on
      : Icons.flash_off,
  onTap: () async {
    if (_controller == null) return;

    try {
      final currentFlash = _controller!.value.flashMode;

      if (currentFlash == FlashMode.torch) {
        await _controller!.setFlashMode(
          FlashMode.off,
        );
      } else {
        await _controller!.setFlashMode(
          FlashMode.torch,
        );
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  },
),
            ],
          ),
        ),

        // AI message
        Positioned(
          left: 16,
          right: 16,
          bottom: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF54220F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Text(
                  '✨',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI will improve the photo automatically.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Capture button
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takePhoto,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: brownColor,
                    width: 5,
                  ),
                ),
                child: _isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: brownColor,
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: brownColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PHOTO PREVIEW
  // ─────────────────────────────────────────────

  Widget _buildPhotoPreview() {
    return Column(
      children: [
        // Photo
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child:Image.file(
  File(_capturedImage!.path),
  fit: BoxFit.cover,
)
                ),
              

              // AI message
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF54220F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('✨'),
                      SizedBox(width: 8),
                      Text(
                        'AI will improve the photo automatically.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom panel
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            24,
            18,
            24,
            24,
          ),
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preview Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Is this photo okay?',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B6B52),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retakePhoto,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          48,
                        ),
                        side: const BorderSide(
                          color: brownColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Retake',
                        style: TextStyle(
                          color: brownColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _usePhoto,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          48,
                        ),
                        backgroundColor: brownColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Use Photo ✓',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
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
    );
  }

  // ─────────────────────────────────────────────
  // ROUND BUTTON
  // ─────────────────────────────────────────────

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: darkBrown,
          size: 22,
        ),
      ),
    );
  }
}