import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

class AudioRecordingScreen extends StatefulWidget {
  const AudioRecordingScreen({super.key});

  @override
  State<AudioRecordingScreen> createState() =>
      _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool isRecording = false;
  String? audioPath;

  Duration recordingDuration = Duration.zero;
  Timer? _timer;

  String get formattedTime {
    final minutes = recordingDuration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = recordingDuration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ─────────────────────────────────────
  // START RECORDING
  // ─────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required.',
            ),
          ),
        );

        return;
      }

   await _audioRecorder.start(
  const RecordConfig(
    encoder: AudioEncoder.aacLc,
  ),
  path: 'kalamitr_${DateTime.now().millisecondsSinceEpoch}.m4a',
);

      if (!mounted) return;

      setState(() {
  isRecording = true;
  recordingDuration = Duration.zero;
});

      _startTimer();
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }

  // ─────────────────────────────────────
  // STOP RECORDING
  // ─────────────────────────────────────

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      _timer?.cancel();

      if (!mounted) return;

      setState(() {
        isRecording = false;
        audioPath = path;
      });
    } catch (e) {
      debugPrint('Recording stop error: $e');
    }
  }

  // ─────────────────────────────────────
  // MIC BUTTON
  // ─────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  // ─────────────────────────────────────
  // TIMER
  // ─────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          recordingDuration += const Duration(seconds: 1);
        });
      },
    );
  }

  // ─────────────────────────────────────
  // RE-RECORD
  // ─────────────────────────────────────

  Future<void> _reRecord() async {
    if (isRecording) {
      await _stopRecording();
    }

    _timer?.cancel();

    setState(() {
      isRecording = false;
      recordingDuration = Duration.zero;
      audioPath = null;
    });
  }

  // ─────────────────────────────────────
  // DONE
  // ─────────────────────────────────────

  void _done() {
    if (audioPath == null || audioPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please record your product description first.',
          ),
        ),
      );

      return;
    }

    debugPrint('Recorded audio: $audioPath');

    // Next:
    // Navigator.push(...)
    // Review & Edit Listing screen
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────
  // UI
  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E7),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                48,
                20,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFDDBB8B),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF5C4033),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Text(
                      'Tell us about your\nproduct',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 27,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C4033),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // EXAMPLE
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  13,
                  16,
                  13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDDBB8B),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example / उदाहरण:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5E34),
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      '“यह जयपुर की हाथ से बनी नीली मिट्टी की फूलदान है...”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Color(0xFF5C4033),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // WAVEFORM PLACEHOLDER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Container(
                height: 72,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDDBB8B),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  isRecording
                      ? '•  • •  • • •  • •  • • •  • •'
                      : '• • • • • • • • • • • • • • • • • •',
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 2,
                    color: isRecording
                        ? const Color(0xFF8B5E34)
                        : const Color(0xFFDDBB8B),
                  ),
                ),
              ),
            ),

            // RECORDING AREA
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 48,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5C4033),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isRecording
                        ? 'Recording... Tap microphone to stop'
                        : audioPath != null
                            ? 'Recording complete'
                            : 'Tap microphone to start',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB09B84),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // REAL MIC BUTTON
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isRecording
                            ? const Color(0xFFB94A3A)
                            : const Color(0xFF8B5E34),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5E34)
                                .withOpacity(0.18),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        isRecording
                            ? Icons.stop
                            : Icons.mic,
                        color: const Color(0xFFFFFCF5),
                        size: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM BUTTONS
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 63,
                      child: OutlinedButton(
                        onPressed: audioPath == null
                            ? null
                            : _reRecord,
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFFFCF5),
                          side: BorderSide(
                            color: audioPath == null
                                ? const Color(0xFFD8C5B4)
                                : const Color(0xFF8B5E34),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Re-record',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: audioPath == null
                                ? const Color(0xFFB8A99B)
                                : const Color(0xFF8B5E34),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: SizedBox(
                      height: 63,
                      child: ElevatedButton(
                        onPressed:
                            audioPath == null || isRecording
                                ? null
                                : _done,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF8B5E34),
                          disabledBackgroundColor:
                              const Color(0xFFD6BFA6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Done →',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}