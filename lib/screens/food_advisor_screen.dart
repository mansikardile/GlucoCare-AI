import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/food_query.dart';
import '../models/glucose_reading.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/senior_card.dart';
import '../widgets/status_badge.dart';

class FoodAdvisorScreen extends StatefulWidget {
  const FoodAdvisorScreen({super.key});

  @override
  State<FoodAdvisorScreen> createState() => _FoodAdvisorScreenState();
}

class _FoodAdvisorScreenState extends State<FoodAdvisorScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _isAnalyzing = false;
  FoodQuery? _activeResult;

  final List<String> _quickPrompts = [
    'Can I eat dosa?',
    'Can I eat mango?',
    'How much rice can I eat?',
    'Can I have Biryani?',
    'Is Roti good for dinner?',
    'Gulab Jamun',
    'Oatmeal for breakfast',
    'Masala Chai',
  ];

  @override
  void initState() {
    super.initState();
    // Default to the most recent query if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HealthProvider>(context, listen: false);
      if (provider.foodQueriesList.isNotEmpty) {
        setState(() {
          _activeResult = provider.foodQueriesList.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _submitQuery(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI clinical reasoning latency
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;
    final provider = Provider.of<HealthProvider>(context, listen: false);
    final result = await provider.askFoodAdvisor(clean);

    setState(() {
      _activeResult = result;
      _isAnalyzing = false;
      _queryController.clear();
    });
  }

  void _addFoodToMeal(FoodQuery food) {
    final provider = Provider.of<HealthProvider>(context, listen: false);

    // Estimate post meal glucose impact and log
    final base = provider.latestGlucose?.value ?? 120.0;
    double delta = 15;
    if (food.verdict == FoodVerdict.goodChoice) delta = 8;
    if (food.verdict == FoodVerdict.avoidOrConsult) delta = 40;

    provider.logGlucose(
      value: (base + delta).clamp(60.0, 300.0),
      mealContext: MealContext.afterDinner,
      note: 'Meal: ${food.foodName} (${food.portionAdvice})',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryBlue,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added ${food.foodName} to today\'s meal logs!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<HealthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🍎 AI Food Advisor', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Header Card
              SeniorCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Can I eat this?',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ask about any Indian meal, fruit, or snack. AI gives personalized portion advice based on your current glucose.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Input field
                    TextField(
                      controller: _queryController,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submitQuery,
                      decoration: InputDecoration(
                        hintText: '🔍 e.g. dosa, mango, rice, biryani',
                        filled: true,
                        fillColor: AppTheme.surfaceAlt,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        suffixIcon: _isAnalyzing
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryBlue),
                                onPressed: () => _submitQuery(_queryController.text),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Check Food Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: const Text(
                        'Check Food with AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isAnalyzing ? null : () => _submitQuery(_queryController.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick suggestion prompt chips
              Text(
                'TRY ASKING',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickPrompts.map((prompt) {
                  return InkWell(
                    onTap: () {
                      _queryController.text = prompt;
                      _submitQuery(prompt);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Text(
                        prompt,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // HERO RESULT CARD (If active result is present)
              if (_activeResult != null) ...[
                _buildFoodResultCard(context, _activeResult!),
                const SizedBox(height: 20),
              ],

              // PAST FOOD QUERIES HISTORY
              if (provider.foodQueriesList.length > 1) ...[
                Text(
                  'RECENT FOOD ADVICE HISTORY',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.foodQueriesList.take(5).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final item = provider.foodQueriesList[idx];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _activeResult = item;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.foodName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('d MMM, h:mm a').format(item.timestamp),
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge.fromFoodVerdict(item.verdict, isCompact: true),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodResultCard(BuildContext context, FoodQuery food) {
    final theme = Theme.of(context);

    Color badgeBg;
    Color badgeBorder;
    switch (food.verdict) {
      case FoodVerdict.goodChoice:
        badgeBg = AppTheme.successBg;
        badgeBorder = AppTheme.successGreen;
        break;
      case FoodVerdict.haveWithCare:
        badgeBg = AppTheme.warningBg;
        badgeBorder = AppTheme.warningAmber;
        break;
      case FoodVerdict.avoidOrConsult:
        badgeBg = AppTheme.dangerBg;
        badgeBorder = AppTheme.dangerCoral;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: badgeBorder.withValues(alpha: 0.5), width: 1.8),
        boxShadow: AppTheme.activeCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Banner Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Text(food.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.foodName.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusBadge.fromFoodVerdict(food.verdict),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Recommended Portion Box
                Text(
                  'RECOMMENDED PORTION',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🥗', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          food.portionAdvice,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Why? (Reasoning & Recent Glucose Context)
                Text(
                  'WHY?',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  food.glycemicReasoning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlueSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.insights_rounded, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          food.clinicalImpact,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Better Alternatives / Swaps
                Text(
                  '💡 HEALTHIER SWAP / COMBINATION',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  food.betterAlternative,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Action Button: Add to Today's Meal
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.restaurant_rounded, size: 20),
                  label: const Text(
                    'Add to Today\'s Meal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _addFoodToMeal(food),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
