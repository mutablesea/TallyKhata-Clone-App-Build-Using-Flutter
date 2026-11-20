import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Support & FAQ chat screen with quick questions and helpline access.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _input = TextEditingController();

  static const _faq = [
    'টালিপে QR-এ চার্জ কত?',
    'ফ্রি পেতে কত টাকা ট্রান্সফার করতে হবে?',
    'অক্টোবর এর আগের ব্যালেন্স এর চার্জ কত?',
    'নগদ থেকে টালিপে বাংলা QR-এ পেমেন্ট হচ্ছে না কেন?',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('সাপোর্ট', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('হেল্পলাইন: 16247')),
            ),
            icon: const Icon(Icons.headset_mic_outlined, size: 18),
            label: const Text('হেল্পলাইন'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.history, size: 18),
            label: const Text('হিস্ট্রি'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.chat, size: 60, color: Colors.orange),
          const Center(
            child: Text(
              'স্বাগতম আপনাকে',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'কীভাবে সাহায্য করতে পারি? প্রশ্ন বেছে নিন অথবা নিজে লিখুন।',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (final q in _faq)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => setState(() => _input.text = q),
                  child: Text(
                    q,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('FAQ ভিডিও'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            top: 4,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    hintText: 'আপনি কি জানতে চান এখানে লিখুন',
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_input.text.trim().isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('আপনার প্রশ্ন পাঠানো হয়েছে')),
                  );
                  setState(() => _input.clear());
                },
                icon: const Icon(Icons.send, color: AppColors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
