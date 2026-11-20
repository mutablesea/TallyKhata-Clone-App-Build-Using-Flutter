import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/primary_button.dart';

/// Customer/Supplier ledger & transaction entry screen.
class PartyDetailScreen extends StatefulWidget {
  final String partyId;
  const PartyDetailScreen({super.key, required this.partyId});

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  final _gaveCtrl = TextEditingController();
  final _gotCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _sendTaliMsg = true;
  bool _showTip = true;

  @override
  void dispose() {
    _gaveCtrl.dispose();
    _gotCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _gaveVal => double.tryParse(_gaveCtrl.text.trim()) ?? 0;
  double get _gotVal => double.tryParse(_gotCtrl.text.trim()) ?? 0;
  bool get _canSave => _gaveVal > 0 || _gotVal > 0;

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (p != null) setState(() => _date = p);
  }

  void _save(AppState app) {
    final note = _noteCtrl.text.trim();
    if (_gaveVal > 0) {
      app.addPartyTxn(
        partyId: widget.partyId,
        isGave: true,
        amount: _gaveVal,
        note: note,
        date: _date,
        sendMessage: _sendTaliMsg,
      );
    }
    if (_gotVal > 0) {
      app.addPartyTxn(
        partyId: widget.partyId,
        isGave: false,
        amount: _gotVal,
        note: note,
        date: _date,
        sendMessage: _sendTaliMsg && _gaveVal <= 0,
      );
    }
    _gaveCtrl.clear();
    _gotCtrl.clear();
    _noteCtrl.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('লেনদেন সংরক্ষণ করা হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final party = app.partyById(widget.partyId);
    if (party == null) {
      return const Scaffold(body: SizedBox());
    }

    final bal = app.partyBalance(party.id);
    final txns = app.partyTxns(party.id);
    final lastAct = app.partyLastActivity(party);
    final dec = app.decimalOn;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.orange,
              child: Text(
                party.initials,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    party.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  if (party.phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 13, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Text(
                          party.phone.startsWith('+88')
                              ? party.phone
                              : '+88${party.phone}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'del') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ডিলিট করবেন?'),
                    content: Text(
                        '${party.name}-এর সব হিসাব স্থায়ীভাবে মুছে যাবে।'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('না')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('হ্যাঁ',
                              style: TextStyle(color: AppColors.red))),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  app.deleteParty(party.id);
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'del', child: Text('ডিলিট করুন')),
            ],
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance & Report row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 16),
                          children: [
                            TextSpan(text: bal >= 0 ? 'পাবো ' : 'দেবো '),
                            TextSpan(
                              text: '৳ ${bnMoney(bal.abs(), decimal: dec)}',
                              style: TextStyle(
                                color: bal >= 0
                                    ? AppColors.red
                                    : AppColors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(${bnRelativeTime(lastAct)} আগে)',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.dueReport),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.greyBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('রিপোর্ট', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Side-by-side দিলাম/বেচা & পেলাম fields
                  Row(
                    children: [
                      Expanded(
                        child: _amountBox(
                          controller: _gaveCtrl,
                          hint: 'দিলাম/বেচা',
                          color: AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _amountBox(
                          controller: _gotCtrl,
                          hint: 'পেলাম',
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // বিবরণ field
                  TextField(
                    controller: _noteCtrl,
                    cursorColor: AppColors.red,
                    decoration: InputDecoration(
                      hintText: 'বিবরণ',
                      prefixIcon: const Icon(Icons.edit_note_outlined),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.red, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Date + টালি-মেসেজ toggle + ছবি pills
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 16),
                              const SizedBox(width: 6),
                              Text(bnDate(_date),
                                  style: const TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Flexible(
                                child: Text(
                                  'টালি-মেসেজ',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13.5),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.78,
                                child: Switch(
                                  value: _sendTaliMsg,
                                  activeTrackColor: AppColors.redLight,
                                  thumbColor: WidgetStateProperty.resolveWith(
                                    (s) => s.contains(WidgetState.selected)
                                        ? AppColors.red
                                        : Colors.white,
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _sendTaliMsg = v),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('ছবি যোগ করার ফিচার শীঘ্রই আসছে')),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 16),
                              SizedBox(width: 5),
                              Text('ছবি', style: TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Blue info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF5FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4A90D9),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF1976D2),
                          child: Icon(Icons.info_outline,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'টালি-মেসেজ অবশিষ্ট: ${bn(app.messageBalance)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'টালি-মেসেজের মাধ্যমে টালিখাতা থেকে লেনদেনের মেসেজ পাঠানো যায়।',
                                style: TextStyle(
                                    fontSize: 13.5, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (txns.isEmpty && _showTip)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFF3D7BE), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () => setState(() => _showTip = false),
                              child: const CircleAvatar(
                                radius: 13,
                                backgroundColor: AppColors.greyBg,
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.black54),
                              ),
                            ),
                          ),
                          const Text(
                            'বেচার সময় দিলাম লিখুন, অথবা আদায়ের সময় পেলাম লিখুন।\n\nআপনি ইচ্ছা করলে, বিবরণ ও ছবি যোগ করতে পারেন।',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (txns.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'লেনদেনের তালিকা',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textGrey),
                      ),
                    ),
                    for (final t in txns)
                      Card(
                        elevation: 0,
                        color: const Color(0xFFFAFAFA),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            t.note.isEmpty
                                ? (t.isGave ? 'দিলাম/বেচা' : 'পেলাম')
                                : t.note,
                            style: const TextStyle(fontSize: 15),
                          ),
                          subtitle: Text(bnFullDate(t.date),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textGrey)),
                          trailing: Text(
                            '৳ ${bnMoney(t.amount, decimal: dec)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: t.isGave ? AppColors.red : AppColors.green,
                            ),
                          ),
                          onLongPress: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('লেনদেন মুছবেন?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('না')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('হ্যাঁ',
                                          style:
                                              TextStyle(color: AppColors.red))),
                                ],
                              ),
                            );
                            if (ok == true) app.deletePartyTxn(t.id);
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: PrimaryButton(
                label: 'নিশ্চিত',
                onPressed: _canSave ? () => _save(app) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountBox({
    required TextEditingController controller,
    required String hint,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      cursorColor: color,
      style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w500),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 16),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 6),
          child: Text('৳', style: TextStyle(fontSize: 20)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }
}
