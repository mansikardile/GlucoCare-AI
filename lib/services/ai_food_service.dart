import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/food_query.dart';

class AIFoodService {
  static final _uuid = const Uuid();
  static const _kGeminiApiKey = 'glucocare_gemini_api_key';
  static const _kDefaultApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Saves the user's Gemini API key to local storage
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGeminiApiKey, key.trim());
  }

  /// Retrieves the saved Gemini API key or falls back to the default configured key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kGeminiApiKey);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved.trim();
    }
    if (_kDefaultApiKey.isNotEmpty) {
      return _kDefaultApiKey;
    }
    return null;
  }

  /// Evaluates food query using real Gemini LLM if API key is available, otherwise uses local clinical knowledge engine
  static Future<FoodQuery> evaluateFoodAsync({
    required String query,
    double? latestGlucose,
    bool missedRecentMed = false,
    String? patientName = 'Rajesh Sharma',
    int? patientAge = 67,
  }) async {
    final apiKey = await getApiKey();

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final geminiResult = await _callGeminiApi(
          apiKey: apiKey,
          query: query,
          latestGlucose: latestGlucose,
          missedRecentMed: missedRecentMed,
          patientName: patientName,
          patientAge: patientAge,
        );
        if (geminiResult != null) {
          return geminiResult;
        }
      } catch (_) {
        // Gracefully fallback to local clinical knowledge engine if network fails
      }
    }

    // Fallback to local clinical knowledge base
    return evaluateFood(
      query: query,
      latestGlucose: latestGlucose,
      missedRecentMed: missedRecentMed,
    );
  }

  /// Calls Google Gemini REST API with structured JSON output schema
  static Future<FoodQuery?> _callGeminiApi({
    required String apiKey,
    required String query,
    double? latestGlucose,
    bool missedRecentMed = false,
    String? patientName = 'Rajesh Sharma',
    int? patientAge = 67,
  }) async {
    // Try gemini-1.5-flash endpoint
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final prompt = '''
You are GlucoCare AI, an empathetic senior diabetes nutrition expert.
Evaluate this meal for a senior citizen:
- Patient: $patientName, age $patientAge, Type 2 Diabetes, Vegetarian.
- Current blood glucose: ${latestGlucose != null ? '$latestGlucose mg/dL' : '128 mg/dL (Normal)'}.
- Missed recent medication: ${missedRecentMed ? 'Yes (Evening dose pending)' : 'No'}.
- Food / Query: "$query"

Return ONLY a single valid JSON object with EXACTLY these keys and formats (no surrounding text or markdown):
{
  "foodName": "Title of Food (e.g. Dosa, Mango, Brown Rice, Roti)",
  "emoji": "Single relevant emoji like 🥞, 🥭, 🍚, 🥗, 🍛",
  "verdict": "goodChoice" OR "haveWithCare" OR "avoidOrConsult",
  "portionAdvice": "Specific portion size advice for a senior citizen (e.g. 1-2 small dosa + sambar)",
  "glycemicReasoning": "1-2 sentences explaining glycemic impact and carbohydrate breakdown.",
  "clinicalImpact": "1 sentence contextualizing this meal with their current glucose (${latestGlucose ?? 128} mg/dL).",
  "betterAlternative": "A healthier Indian combination or swap (e.g. Vegetable oats dosa with mint chutney)",
  "estimatedCarbsGrams": 30,
  "glycemicIndexCategory": "Low" OR "Medium" OR "High"
}
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'response_mime_type': 'application/json',
      }
    });

    final response = await http
        .post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String text = jsonResponse['candidates'][0]['content']['parts'][0]['text'] as String;

      // Strip markdown code fences if model returned them
      text = text.trim();
      if (text.startsWith('```json')) {
        text = text.substring(7);
      } else if (text.startsWith('```')) {
        text = text.substring(3);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
      text = text.trim();

      final parsed = jsonDecode(text) as Map<String, dynamic>;

      FoodVerdict verdict = FoodVerdict.haveWithCare;
      final verdictStr = (parsed['verdict'] as String? ?? '').toLowerCase();
      if (verdictStr.contains('good')) {
        verdict = FoodVerdict.goodChoice;
      } else if (verdictStr.contains('avoid') || verdictStr.contains('consult')) {
        verdict = FoodVerdict.avoidOrConsult;
      }

      return FoodQuery(
        id: _uuid.v4(),
        queryText: query,
        foodName: parsed['foodName'] as String? ?? query,
        emoji: parsed['emoji'] as String? ?? '🍽️',
        verdict: verdict,
        portionAdvice: parsed['portionAdvice'] as String? ?? '1 moderate senior serving with salad',
        glycemicReasoning: parsed['glycemicReasoning'] as String? ??
            'This food contains carbohydrates that affect blood glucose levels.',
        clinicalImpact: parsed['clinicalImpact'] as String? ??
            'Monitor your glucose 2 hours post meal to observe personal response.',
        betterAlternative: parsed['betterAlternative'] as String? ??
            'Pair with plenty of green vegetables and protein.',
        estimatedCarbsGrams: (parsed['estimatedCarbsGrams'] as num?)?.toInt() ?? 25,
        glycemicIndexCategory: parsed['glycemicIndexCategory'] as String? ?? 'Medium',
        timestamp: DateTime.now(),
      );
    }
    return null;
  }

  // Curated knowledge base for authentic senior diabetes management
  static final Map<String, Map<String, dynamic>> _foodKnowledgeBase = {
    'dosa': {
      'name': 'Dosa (Plain / Masala)',
      'emoji': '🥞',
      'baseVerdict': FoodVerdict.haveWithCare,
      'portion': '1–2 small dosa with generous sambar & vegetable chutney',
      'why':
          'Dosa is made from fermented rice and urad dal. The rice content provides fast-acting carbohydrates that can elevate blood glucose.',
      'impact':
          'Your recent readings have trended slightly higher in the evenings. Moderating carb load helps avoid post-meal spikes.',
      'alternative': 'Vegetable Rava Dosa or Oats Dosa + green mint chutney',
      'carbs': 34,
      'gi': 'Medium-High',
    },
    'mango': {
      'name': 'Ripe Mango',
      'emoji': '🥭',
      'baseVerdict': FoodVerdict.haveWithCare,
      'portion': '2–3 thin slices (approx 50g) after a protein/fiber-rich meal',
      'why':
          'Mango is rich in natural fructose and quick-absorbing simple sugars with a moderate glycemic index.',
      'impact':
          'Eating on an empty stomach triggers rapid glucose spikes. Always pair with a few almonds or after a meal.',
      'alternative': 'Guava, Papaya slices, or a small Green Apple with skin',
      'carbs': 28,
      'gi': 'Medium',
    },
    'rice': {
      'name': 'White Rice',
      'emoji': '🍚',
      'baseVerdict': FoodVerdict.haveWithCare,
      'portion': '1 small katori (half cup) paired with double dal & green salad',
      'why':
          'Polished white rice has a high glycemic index (GI > 70) and is digested quickly into blood glucose.',
      'impact':
          'Pairing white rice with fiber and protein significantly flattens the glucose curve.',
      'alternative': 'Brown rice, Foxtail millet, or Quinoa with extra vegetables',
      'carbs': 42,
      'gi': 'High',
    },
    'biryani': {
      'name': 'Biryani',
      'emoji': '🍛',
      'baseVerdict': FoodVerdict.haveWithCare,
      'portion': '1 small cup alongside a large bowl of cucumber raita and salad',
      'why':
          'Biryani combines calorie-dense rice with oils/fats. Fat delays digestion, causing prolonged post-meal elevation.',
      'impact':
          'Best consumed for lunch rather than late dinner to allow natural physical activity to absorb glucose.',
      'alternative': 'Vegetable Soya Chunk Biryani with brown basmati rice',
      'carbs': 52,
      'gi': 'Medium-High',
    },
    'roti': {
      'name': 'Wheat Roti / Chapati',
      'emoji': '🫓',
      'baseVerdict': FoodVerdict.goodChoice,
      'portion': '2 medium multigrain rotis with green leafy sabzi & dal',
      'why':
          'Whole wheat provides complex carbohydrates and dietary fiber that release energy steadily.',
      'impact':
          'Excellent staple choice that keeps your fasting and 2-hour post-meal glucose within safe ranges.',
      'alternative': 'Multigrain Roti (Wheat + Jowar + Bajra + Methi)',
      'carbs': 24,
      'gi': 'Medium',
    },
    'idli': {
      'name': 'Steamed Idli',
      'emoji': '⚪',
      'baseVerdict': FoodVerdict.goodChoice,
      'portion': '2–3 idlis with high-protein vegetable sambar',
      'why':
          'Steamed and fermented without added fat. Sambar adds essential lentils and soluble fiber.',
      'impact':
          'Gentle on digestion and provides predictable, gradual glucose release.',
      'alternative': 'Oats Idli or Ragi Idli for even higher fiber content',
      'carbs': 26,
      'gi': 'Medium',
    },
    'dal makhani': {
      'name': 'Dal Makhani',
      'emoji': '🍲',
      'baseVerdict': FoodVerdict.haveWithCare,
      'portion': '1 small bowl; minimize added cream and butter',
      'why':
          'Black lentils provide good protein, but heavy cream and butter increase saturated fat and delayed glycemic load.',
      'impact':
          'Heavy fats combined with carbs can keep night blood sugar elevated till morning.',
      'alternative': 'Yellow Moong Dal Tadka or Chana Dal with minimal ghee',
      'carbs': 22,
      'gi': 'Low-Medium',
    },
    'gulab jamun': {
      'name': 'Gulab Jamun / Indian Sweets',
      'emoji': '🍯',
      'baseVerdict': FoodVerdict.avoidOrConsult,
      'portion': 'Less than half a piece for tasting on special occasions only',
      'why':
          'Fried condensed milk solids soaked in refined sugar syrup create severe, immediate glucose surges.',
      'impact':
          'Will spike glucose well above 200 mg/dL and place extra stress on insulin sensitivity.',
      'alternative': 'Baked apple with cinnamon or sugar-free almond kheer',
      'carbs': 48,
      'gi': 'Very High',
    },
    'oats': {
      'name': 'Oatmeal / Rolled Oats',
      'emoji': '🥣',
      'baseVerdict': FoodVerdict.goodChoice,
      'portion': '1 bowl (40g dry oats) with unsweetened milk and chia seeds',
      'why':
          'Rich in Beta-glucan soluble fiber, which actively slows carbohydrate absorption and lowers cholesterol.',
      'impact':
          'One of the best breakfast options for senior blood sugar stabilization.',
      'alternative': 'Savory Vegetable Masala Oats',
      'carbs': 27,
      'gi': 'Low',
    },
    'khichdi': {
      'name': 'Moong Dal Khichdi',
      'emoji': '🥘',
      'baseVerdict': FoodVerdict.goodChoice,
      'portion': '1 medium bowl with plenty of added vegetables and a spoon of curd',
      'why':
          '1:1 ratio of dal to rice gives a balanced amino acid profile and moderate glycemic response.',
      'impact':
          'Very soothing for dinner and does not overburden evening glucose regulation.',
      'alternative': 'Millet & Moong Dal Khichdi',
      'carbs': 32,
      'gi': 'Low-Medium',
    },
    'paneer': {
      'name': 'Paneer Tikka / Paneer Bhurji',
      'emoji': '🧀',
      'baseVerdict': FoodVerdict.goodChoice,
      'portion': '100g grilled or sautéed paneer with capsicum and onion',
      'why':
          'High in casein protein and healthy fats with negligible carbohydrates.',
      'impact':
          'Helps stabilize blood sugar and keeps you feeling full longer without spiking glucose.',
      'alternative': 'Tofu or Sprouted Moong Salad for lower saturated fat',
      'carbs': 4,
      'gi': 'Very Low',
    },
    'samosa': {
      'name': 'Fried Samosa',
      'emoji': '🥟',
      'baseVerdict': FoodVerdict.avoidOrConsult,
      'portion': 'Avoid or limit to 1 mini baked samosa occasionally',
      'why':
          'Refined flour (maida) outer shell stuffed with mashed potatoes and deep-fried.',
      'impact':
          'Double spike from fast carbs and trans-fats; impairs morning fasting glucose.',
      'alternative': 'Air-fried vegetable cutlet with flaxseed coating',
      'carbs': 36,
      'gi': 'High',
    },
    'tea': {
      'name': 'Masala Chai / Tea',
      'emoji': '☕',
      'baseVerdict': FoodVerdict.goodChoice,
      'portion': '1 cup prepared with low-fat milk and zero refined sugar',
      'why':
          'Cardamom, ginger, and cinnamon in Indian tea contain beneficial antioxidants.',
      'impact':
          'Safe as long as added white sugar is avoided. Use stevia or drink unsweetened.',
      'alternative': 'Cinnamon Green Tea or Ginger Lemon Infusion',
      'carbs': 3,
      'gi': 'Low',
    },
  };

  /// Local fallback clinical evaluator
  static FoodQuery evaluateFood({
    required String query,
    double? latestGlucose,
    bool missedRecentMed = false,
  }) {
    final cleanQuery = query.toLowerCase().trim();

    String? matchedKey;
    for (final key in _foodKnowledgeBase.keys) {
      if (cleanQuery.contains(key)) {
        matchedKey = key;
        break;
      }
    }

    if (matchedKey != null) {
      final info = _foodKnowledgeBase[matchedKey]!;
      FoodVerdict verdict = info['baseVerdict'] as FoodVerdict;
      String impact = info['impact'] as String;

      if (latestGlucose != null && latestGlucose > 150) {
        if (verdict == FoodVerdict.goodChoice &&
            info['carbs'] != null &&
            (info['carbs'] as int) > 20) {
          verdict = FoodVerdict.haveWithCare;
        }
        impact =
            'Your current blood sugar is ${latestGlucose.toInt()} mg/dL (elevated). Be extra cautious with portion sizes right now.';
      }

      if (missedRecentMed) {
        impact +=
            ' Note: An evening medication dose was pending/missed, which lowers carb clearance capacity.';
      }

      return FoodQuery(
        id: _uuid.v4(),
        queryText: query,
        foodName: info['name'] as String,
        emoji: info['emoji'] as String,
        verdict: verdict,
        portionAdvice: info['portion'] as String,
        glycemicReasoning: info['why'] as String,
        clinicalImpact: impact,
        betterAlternative: info['alternative'] as String,
        estimatedCarbsGrams: info['carbs'] as int,
        glycemicIndexCategory: info['gi'] as String,
        timestamp: DateTime.now(),
      );
    }

    // Generic clinical estimator for custom unlisted food
    final bool looksSweetOrFried = cleanQuery.contains('sweet') ||
        cleanQuery.contains('cake') ||
        cleanQuery.contains('halwa') ||
        cleanQuery.contains('fry') ||
        cleanQuery.contains('jalebi') ||
        cleanQuery.contains('ladoo') ||
        cleanQuery.contains('sugar');

    final bool looksHealthy = cleanQuery.contains('salad') ||
        cleanQuery.contains('vegetable') ||
        cleanQuery.contains('soup') ||
        cleanQuery.contains('cucumber') ||
        cleanQuery.contains('sprout') ||
        cleanQuery.contains('apple') ||
        cleanQuery.contains('egg');

    FoodVerdict verdict = FoodVerdict.haveWithCare;
    String emoji = '🍽️';
    int carbs = 30;
    String gi = 'Medium';
    String portion = '1 moderate senior serving with extra salad/curd';
    String why =
        'This food provides carbohydrates that will be converted to glucose during digestion.';
    String impact =
        'Monitor your blood sugar 2 hours after having this meal to see how your body responds.';
    String alt = 'Pair with fiber (vegetables/salad) and lean protein (dal/paneer).';

    if (looksSweetOrFried) {
      verdict = FoodVerdict.avoidOrConsult;
      emoji = '🍬';
      carbs = 45;
      gi = 'High';
      portion = 'Avoid or limit to a single bite for tasting';
      why = 'Contains concentrated simple sugars and fats that cause sudden glucose spikes.';
      impact =
          'Recent readings suggest keeping carb spikes minimal to maintain your target range.';
      alt = 'Fresh seasonal fruit like papaya, guava, or roasted makhana.';
    } else if (looksHealthy) {
      verdict = FoodVerdict.goodChoice;
      emoji = '🥗';
      carbs = 12;
      gi = 'Low';
      portion = '1–2 generous servings without hesitation';
      why = 'Rich in dietary fiber and essential micronutrients with low glycemic impact.';
      impact = 'Supports steady glucose absorption and healthy digestion.';
      alt = 'Can be seasoned with lemon juice, roasted jeera, and rock salt.';
    }

    final title = query.isNotEmpty
        ? query[0].toUpperCase() + query.substring(1)
        : 'Food item';

    return FoodQuery(
      id: _uuid.v4(),
      queryText: query,
      foodName: title,
      emoji: emoji,
      verdict: verdict,
      portionAdvice: portion,
      glycemicReasoning: why,
      clinicalImpact: impact,
      betterAlternative: alt,
      estimatedCarbsGrams: carbs,
      glycemicIndexCategory: gi,
      timestamp: DateTime.now(),
    );
  }
}
