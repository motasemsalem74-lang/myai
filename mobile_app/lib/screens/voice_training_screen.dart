import 'package:flutter/material.dart';
import 'package:record/record.dart';

class VoiceTrainingScreen extends StatefulWidget {
  const VoiceTrainingScreen({super.key});

  @override
  State<VoiceTrainingScreen> createState() => _VoiceTrainingScreenState();
}

class _VoiceTrainingScreenState extends State<VoiceTrainingScreen> {
  final _recorder = AudioRecorder();
  final List<String> _audioSamples = [];
  bool _isRecording = false;
  bool _isTraining = false;
  double _trainingProgress = 0.0;

  final int _requiredSamples = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تدريب الصوت'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // التعليمات
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 التعليمات:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction('1', 'سجل $_requiredSamples عينات صوتية'),
                    _buildInstruction('2', 'كل عينة يجب أن تكون 10-30 ثانية'),
                    _buildInstruction('3', 'تحدث بطريقتك الطبيعية'),
                    _buildInstruction('4', 'اختر مكان هادئ للتسجيل'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // العينات المسجلة
            Text(
              'العينات المسجلة: ${_audioSamples.length}/$_requiredSamples',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // قائمة العينات
            Expanded(
              child: _audioSamples.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_none,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لم تسجل أي عينات بعد',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _audioSamples.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.audiotrack),
                            title: Text('عينة ${index + 1}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _audioSamples.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // التقدم في التدريب
            if (_isTraining) ...[
              LinearProgressIndicator(
                value: _trainingProgress,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'جاري التدريب... ${(_trainingProgress * 100).toInt()}%',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // أزرار التحكم
            if (!_isTraining) ...[
              ElevatedButton.icon(
                onPressed: _audioSamples.length < _requiredSamples
                    ? (_isRecording ? _stopRecording : _startRecording)
                    : null,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'إيقاف التسجيل' : 'بدء التسجيل'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _isRecording ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _audioSamples.length >= _requiredSamples
                    ? _startTraining
                    : null,
                icon: const Icon(Icons.school),
                label: const Text('بدء التدريب'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        await _recorder.start(const RecordConfig(), path: 'voice_sample_${DateTime.now().millisecondsSinceEpoch}.m4a');
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      _showError('فشل بدء التسجيل: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();

      if (path != null) {
        // قراءة الملف وتحويله إلى base64
        // في التطبيق الحقيقي، يتم تحميل الملف
        setState(() {
          _audioSamples.add('sample_${_audioSamples.length}');
          _isRecording = false;
        });

        _showSuccess('تم حفظ العينة بنجاح!');
      }
    } catch (e) {
      _showError('فشل إيقاف التسجيل: $e');
    }
  }

  Future<void> _startTraining() async {
    setState(() {
      _isTraining = true;
      _trainingProgress = 0.0;
    });

    try {
      // محاكاة التدريب
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _trainingProgress = i / 100;
        });
      }

      // في التطبيق الحقيقي:
      // await ApiService.trainVoice('user_123', _audioSamples);

      setState(() {
        _isTraining = false;
      });

      _showSuccess('تم التدريب بنجاح! ✅');

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isTraining = false;
      });
      _showError('فشل التدريب: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}
