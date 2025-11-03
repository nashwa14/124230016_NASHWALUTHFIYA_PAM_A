import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // Anggap FeedbackController sudah ada di lib/controllers/feedback_controller.dart
  // final _controller = FeedbackController();
  final _messageController = TextEditingController();
  bool _loading = false;

  void _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tulis saran atau kesan Anda terlebih dahulu.')));
      }
      return;
    }

    setState(() => _loading = true);

    // final success = await _controller.submitFeedback(message);

    if (!mounted) return;

    setState(() => _loading = false);

    // if (success) {
    //   _messageController.clear();
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih! Saran Anda sudah tersimpan.')));
    // } else {
    //   // Ini akan terjadi jika getCurrentUsername() gagal (user tidak login)
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan. Harap pastikan Anda sudah login.')));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saran & Kesan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikan masukan Anda tentang aplikasi StokMate dan pengalaman Anda pada mata kuliah ini.',
            style: TextStyle(color: Colors.grey),
          ),
          const Divider(height: 30),

          // --- Form Input Umpan Balik ---
          TextField(
            controller: _messageController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Tulis kesan dan saran Anda di sini...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.teal.shade50,
            ),
          ),
          const SizedBox(height: 20),

          // --- Tombol Submit ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Icon(Icons.send),
              label: Text(_loading ? 'Mengirim...' : 'Kirim Umpan Balik'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}