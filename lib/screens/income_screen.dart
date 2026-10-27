import 'package:flutter/material.dart';
import '../providers/os_controller.dart';
import '../theme/os_theme.dart';
import '../widgets/os_widgets.dart';

class IncomeScreen extends StatelessWidget {
  final PersonalOSController controller;

  const IncomeScreen({super.key, required this.controller});

  void _showAddEntryModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isIncome = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PersonalOSTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Log Earning or Expense',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PersonalOSTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Income (+₹)'),
                        selected: isIncome,
                        selectedColor:
                            PersonalOSTheme.neonLime.withOpacity(0.3),
                        onSelected: (_) => setModalState(() => isIncome = true),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Expense (-₹)'),
                        selected: !isIncome,
                        selectedColor:
                            PersonalOSTheme.coralRed.withOpacity(0.3),
                        onSelected: (_) =>
                            setModalState(() => isIncome = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Client / Source / Item',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subCtrl,
                    decoration: InputDecoration(
                      labelText: 'Category (e.g. Freelance Edit, Affiliate)',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (${controller.currencySymbol})',
                      filled: true,
                      fillColor: PersonalOSTheme.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PersonalOSTheme.neonLime,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final amt =
                            double.tryParse(amountCtrl.text.trim()) ?? 0;
                        if (titleCtrl.text.trim().isNotEmpty && amt > 0) {
                          controller.addFinancialEntry(
                            title: titleCtrl.text.trim(),
                            subtitle: subCtrl.text.trim().isEmpty
                                ? 'Student Side Hustle'
                                : subCtrl.text.trim(),
                            amount: amt,
                            isIncome: isIncome,
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text(
                        'Save Transaction',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProgress =
        (controller.totalEarnings / controller.monthlyIncomeGoal)
            .clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
      children: [
        // Top Header
        const Text(
          'Income & Opportunities 💸',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: PersonalOSTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Low-cost student side income: Freelance, Outreach & Affiliate tests',
          style: TextStyle(
            fontSize: 12,
            color: PersonalOSTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Monthly Student Earning Goal Card (Matches Screenshot 6 "Earn $200,000" fire bar)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PersonalOSTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PersonalOSTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monthly Side-Income Target',
                    style: TextStyle(
                      color: PersonalOSTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PersonalOSTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Zero-Capital Focus',
                      style: TextStyle(
                        color: PersonalOSTheme.neonLime,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goalProgress,
                  minHeight: 10,
                  backgroundColor: PersonalOSTheme.surfaceElevated,
                  color: PersonalOSTheme.neonLime,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('💰 ', style: TextStyle(fontSize: 14)),
                  Text(
                    '${controller.currencySymbol}${controller.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: PersonalOSTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    ' of ${controller.currencySymbol}${controller.monthlyIncomeGoal.toStringAsFixed(0)} goal',
                    style: const TextStyle(
                      color: PersonalOSTheme.neonLime,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Total Earnings vs Expenses Comparison Card (Matches Screenshot 6 green/red chart)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PersonalOSTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PersonalOSTheme.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Earnings',
                        style: TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '💰 ${controller.currencySymbol}${controller.totalEarnings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: PersonalOSTheme.neonLime,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '💸 ${controller.currencySymbol}${controller.totalExpenses.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: PersonalOSTheme.coralRed,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Stacked Weekly Income vs Expense Bars (Screenshot 6 bottom-center)
              SizedBox(
                height: 85,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (idx) {
                    final incHeights = [48.0, 32.0, 62.0, 28.0, 54.0, 70.0, 64.0];
                    final expHeights = [14.0, 18.0, 12.0, 20.0, 10.0, 15.0, 12.0];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 14,
                          height: incHeights[idx],
                          decoration: const BoxDecoration(
                            color: PersonalOSTheme.neonLime,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        Container(
                          width: 14,
                          height: expHeights[idx],
                          decoration: const BoxDecoration(
                            color: PersonalOSTheme.coralRed,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(6)),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Client Outreach, Freelance & Affiliate Pipeline
        const SectionHeader(
            title: 'Outreach, Freelance & Affiliate Experiments'),
        ...controller.leads.map((lead) {
          final isPaid = lead.status == 'Paid';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: PersonalOSTheme.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: PersonalOSTheme.neonYellow.withOpacity(0.2),
                  child: const Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: PersonalOSTheme.neonLime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.clientOrSource,
                        style: const TextStyle(
                          color: PersonalOSTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead.serviceType,
                        style: const TextStyle(
                          color: PersonalOSTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${controller.currencySymbol}${lead.potentialAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: PersonalOSTheme.neonLime,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => controller.advanceLeadStatus(lead.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? PersonalOSTheme.neonLime.withOpacity(0.25)
                              : PersonalOSTheme.primaryPurple.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${lead.status} ➔',
                          style: TextStyle(
                            color: isPaid
                                ? PersonalOSTheme.neonLime
                                : PersonalOSTheme.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),

        // Recent Payouts & Expenses (Matches Screenshot 6 green pill banner)
        SectionHeader(
          title: 'Actual Earnings & Expenses Ledger',
          actionLabel: 'Log Entry',
          onAction: () => _showAddEntryModal(context),
        ),
        ...controller.transactions.map((tx) {
          final isHighlight = tx.isIncome && tx.amount >= 5000;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlight
                  ? PersonalOSTheme.neonLime
                  : PersonalOSTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PersonalOSTheme.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isHighlight
                      ? Colors.black.withOpacity(0.15)
                      : PersonalOSTheme.surfaceElevated,
                  child: Icon(
                    tx.isIncome ? Icons.south_west : Icons.north_east,
                    size: 16,
                    color: isHighlight
                        ? Colors.black
                        : (tx.isIncome
                            ? PersonalOSTheme.neonLime
                            : PersonalOSTheme.coralRed),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: TextStyle(
                          color: isHighlight
                              ? Colors.black
                              : PersonalOSTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        tx.subtitle,
                        style: TextStyle(
                          color: isHighlight
                              ? Colors.black87
                              : PersonalOSTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${tx.isIncome ? '+' : '-'}${controller.currencySymbol}${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isHighlight
                        ? Colors.black
                        : (tx.isIncome
                            ? PersonalOSTheme.neonLime
                            : PersonalOSTheme.coralRed),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
