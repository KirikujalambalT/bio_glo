import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bio Glow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1c7068)),
        scaffoldBackgroundColor: const Color(0xffdff5ed),
        textTheme: GoogleFonts.comfortaaTextTheme().apply(
          bodyColor: const Color(0xff171717),
          displayColor: const Color(0xff171717),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xff171717),
            backgroundColor: const Color(0xffb7e6d5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
      home: const BioGlowApp(),
    );
  }
}

enum AppStage { auth, quiz, concerns }

class _SkinGuide {
  const _SkinGuide({
    required this.url,
    required this.keywords,
    required this.careTips,
  });

  final String url;
  final List<String> keywords;
  final String careTips;
}

const _skinGuides = <String, _SkinGuide>{
  "Athlete's foot": _SkinGuide(
    url:
        'https://docs.google.com/document/d/1yCW6reRKRlJGoyXIWQsW-hYQKTumNWZf5bfQRglcQHo/edit?usp=sharing',
    keywords: ["athlete's foot", 'athletes foot', 'tinea pedis'],
    careTips:
        'Keep feet clean and dry, especially between the toes. Change socks regularly and avoid sharing towels. Ask a pharmacist or clinician about appropriate treatment.',
  ),
  'Psoriasis': _SkinGuide(
    url:
        'https://docs.google.com/document/d/129SxlIfiCkmePI1HI7BomX2U4RzxDXZZq5uYkCJIR58/edit?usp=sharing',
    keywords: ['psoriasis'],
    careTips:
        'Use a gentle, fragrance-free moisturizer and avoid picking or scrubbing plaques. A clinician can discuss treatment options tailored to you.',
  ),
  'Seborrheic dermatitis': _SkinGuide(
    url:
        'https://docs.google.com/document/d/11hZI7xPJUzyrFY6rG5l5Pn1YhOXk8asOIiN5F5Zkbp8/edit?usp=sharing',
    keywords: ['seborrheic dermatitis', 'seb derm'],
    careTips:
        'Use gentle cleansing and avoid scratching or harsh products. A clinician or pharmacist can advise on suitable scalp or skin treatments.',
  ),
  'Contact dermatitis': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1CrqWLDkV1EMkviBizYgBm5A9ytwJEVU2t3MYbht0Jfw/edit?usp=sharing',
    keywords: ['contact dermatitis'],
    careTips:
        'If you suspect a new product caused irritation, stop using it and gently rinse the area. Avoid other irritating products and seek advice if it persists or spreads.',
  ),
  'Acne': _SkinGuide(
    url:
        'https://docs.google.com/document/d/14zXJpXIHGIKgd8PGQUQH0DkHv8ipfSb4Qx7WoT6mC5E/edit?usp=sharing',
    keywords: ['acne', 'pimples'],
    careTips:
        'Wash gently, avoid picking, and choose non-comedogenic skin products. A clinician or pharmacist can help you choose an appropriate treatment.',
  ),
  'Hives': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1gfkqzENNCoXu-Jf94vOh8SIGdPVkpdcz-MkYY1-fUCc/edit?usp=sharing',
    keywords: ['hives', 'urticaria'],
    careTips:
        'A cool compress may soothe itchy skin. Consider avoiding a suspected trigger and ask a clinician or pharmacist for advice. Get emergency help for trouble breathing or swelling of the lips, tongue, or throat.',
  ),
  'Bruises': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1lYsjA6QxjPf1DUmqZB2xuZU_fJV3Ooew3bRD0kyAjfg/edit?usp=sharing',
    keywords: ['bruise', 'bruises'],
    careTips:
        'Protect the area; a cold pack wrapped in cloth may ease discomfort soon after an injury. Seek medical advice for unexplained or repeated bruises, severe pain, or a head injury.',
  ),
  'Rosacea': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1TsjyILk8VZ8lBJoz7YT2YuYazeiKxQ0K2psEi3mdi2Q/edit?usp=sharing',
    keywords: ['rosacea'],
    careTips:
        'Try gentle, fragrance-free skin care and sun protection, and note anything that seems to trigger flushing. Discuss persistent symptoms with a clinician.',
  ),
  'Keratosis pilaris': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1Mn1hleiLR-uQ5KdE6F4ZJbZHAEG8S-0gBadcenpyX8g/edit?usp=sharing',
    keywords: ['keratosis pilaris'],
    careTips:
        'Moisturize regularly and avoid harsh scrubbing. Ask a clinician about persistent irritation or treatment options.',
  ),
  'Chicken pox': _SkinGuide(
    url:
        'https://docs.google.com/document/d/10H8mZLzA-4CT3BVlDPRSG8dppeZ_9J_yyPFczu79dLo/edit?usp=sharing',
    keywords: ['chicken pox', 'chickenpox', 'varicella'],
    careTips:
        'Contact a healthcare professional for advice, especially during pregnancy, for adults, or with a weakened immune system. Avoid scratching and seek urgent care for severe symptoms or eye involvement.',
  ),
  'Eczema': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1LdtiU9tBwOFnK8QGfu6VQC0ZzLQ3mR0pK1y4OBEW3dw/edit?usp=sharing',
    keywords: ['eczema', 'atopic dermatitis'],
    careTips:
        'Use a gentle, fragrance-free moisturizer and avoid known irritants or scratching. Ask a clinician about persistent, severe, or possibly infected skin.',
  ),
  'Warts': _SkinGuide(
    url:
        'https://docs.google.com/document/d/1MatRhtSapjRv5qKoCv-8kXi23aRVBZEmyhpSEKRZyng/edit?usp=sharing',
    keywords: ['wart', 'warts'],
    careTips:
        'Avoid picking or cutting the area and do not share personal items that touch it. Ask a clinician about uncertain, painful, bleeding, facial, or genital-area growths.',
  ),
};

bool _containsPhrase(String text, String phrase) {
  final expression = RegExp('(^|[^a-z])${RegExp.escape(phrase)}([^a-z]|\$)');
  return expression.hasMatch(text);
}

class BioGlowApp extends StatefulWidget {
  const BioGlowApp({super.key});

  @override
  State<BioGlowApp> createState() => _BioGlowAppState();
}

class _BioGlowAppState extends State<BioGlowApp> {
  AppStage _stage = AppStage.auth;
  bool _isSignIn = true;
  bool _analyzed = false;
  int _quizPage = 0;
  XFile? _photo;
  String _concern = '';
  List<String> _matchedGuides = [];
  final _picker = ImagePicker();
  final _quizAnswers = <String, String>{};
  @override
  void initState() {
    super.initState();
    _loadState();
  }

  static const _questions = [
    ('What should we call you?', 'Your name or a nickname'),
    ('How old are you?', 'Your age'),
    ('What is your skin type?', 'Dry, oily, combination, normal, or sensitive'),
    (
      'What is your current skincare routine?',
      'Share the products or steps you use',
    ),
    ('How do you describe your gender?', 'Optional'),
    (
      'What are your personal skin concerns?',
      'For example: acne, redness, dryness',
    ),
    (
      'What do you prefer in skincare?',
      'Tell us about products or natural remedies',
    ),
    ('Do you live in a hot or cold place?', 'Tell us about your climate'),
    ('Have you had any skincare treatments?', 'Optional'),
    ('What is your daily makeup routine?', 'Optional'),
    ('How many hours do you usually sleep?', 'Your typical nightly sleep'),
    ('What are your stress habits?', 'Anything that may affect your skin'),
  ];

  Future<bool> _onSignIn(String email, {required bool createAccount}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalizedEmail)) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final existingEmail = prefs.getString('userEmail');
    if (createAccount
        ? existingEmail != null
        : existingEmail != normalizedEmail) {
      return false;
    }
    await prefs.setString('userEmail', normalizedEmail);
    await prefs.setBool('signedIn', true);
    setState(() => _stage = AppStage.quiz);
    return true;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final signedIn = prefs.getBool('signedIn') ?? false;
    final quizDone = prefs.getBool('quizCompleted') ?? false;
    final savedAnswers = prefs.getString('quizAnswers');
    if (savedAnswers != null) {
      _quizAnswers.addAll(Map<String, String>.from(jsonDecode(savedAnswers)));
    }
    _concern = prefs.getString('skinConcern') ?? '';
    setState(() {
      if (signedIn) {
        _stage = quizDone ? AppStage.concerns : AppStage.quiz;
      } else {
        _stage = AppStage.auth;
      }
    });
  }

  Future<void> _setQuizCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quizAnswers', jsonEncode(_quizAnswers));
    await prefs.setBool('quizCompleted', true);
    setState(() => _stage = AppStage.concerns);
  }

  Future<void> _saveQuizAnswer(String question, String answer) async {
    _quizAnswers[question] = answer;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quizAnswers', jsonEncode(_quizAnswers));
  }

  Future<void> _saveConcern(String concern) async {
    _concern = concern;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skinConcern', concern);
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) setState(() => _photo = photo);
  }

  void _findGuideMatches() {
    if (_photo == null && _concern.trim().isEmpty) return;
    final concern = _concern.toLowerCase();
    final matches = _skinGuides.entries
        .where(
          (guide) => guide.value.keywords.any(
            (keyword) => _containsPhrase(concern, keyword),
          ),
        )
        .map((guide) => guide.key)
        .toList();
    setState(() {
      _matchedGuides = matches;
      _analyzed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      AppStage.auth => AuthScreen(
        isSignIn: _isSignIn,
        onToggle: () => setState(() => _isSignIn = !_isSignIn),
        onSignIn: _onSignIn,
      ),
      AppStage.quiz => QuizScreen(
        page: _quizPage,
        total: _questions.length,
        question: _questions[_quizPage].$1,
        hint: _questions[_quizPage].$2,
        answer: _quizAnswers[_questions[_quizPage].$1] ?? '',
        onChanged: (value) => _saveQuizAnswer(_questions[_quizPage].$1, value),
        onBack: _quizPage == 0
            ? () => setState(() => _stage = AppStage.auth)
            : () => setState(() => _quizPage--),
        onContinue: () {
          if (_quizPage < _questions.length - 1) {
            setState(() => _quizPage++);
          } else {
            _setQuizCompleted();
          }
        },
      ),
      AppStage.concerns => ConcernScreen(
        photo: _photo,
        analyzed: _analyzed,
        matchedGuides: _matchedGuides,
        concern: _concern,
        onConcernChanged: _saveConcern,
        onTakePhoto: _takePhoto,
        onFindGuides: _findGuideMatches,
        onBack: () => setState(() => _stage = AppStage.quiz),
      ),
    };
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.isSignIn,
    required this.onToggle,
    required this.onSignIn,
  });
  final bool isSignIn;
  final VoidCallback onToggle;
  final Future<bool> Function(String email, {required bool createAccount})
  onSignIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final accepted = await widget.onSignIn(
      _emailController.text,
      createAccount: !widget.isSignIn,
    );
    if (!accepted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isSignIn
                ? 'No profile for this email on this device. Create one first.'
                : 'A profile already exists on this device. Log in instead.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdff5ed),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 52),
                  Text(
                    widget.isSignIn ? 'Welcome back' : 'Begin your glow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isSignIn
                        ? 'Your personal skin companion is ready.'
                        : 'Let us learn what makes your skin unique.',
                  ),
                  const SizedBox(height: 34),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Local preview profile. Your skin notes stay on this device.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(
                        widget.isSignIn ? 'Log in' : 'Create account',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: widget.onToggle,
                      child: Text(
                        widget.isSignIn
                            ? 'New to Bio Glow? Create an account'
                            : 'Already have a profile? Log in',
                      ),
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

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.page,
    required this.total,
    required this.question,
    required this.hint,
    required this.answer,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });
  final int page;
  final int total;
  final String question;
  final String hint;
  final String answer;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final _controller = TextEditingController(text: widget.answer);

  @override
  void didUpdateWidget(covariant QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _controller.text = widget.answer;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffe9ef),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.page + 1} of ${widget.total}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (widget.page + 1) / widget.total,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      color: const Color(0xffdb718d),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Let us get to know your skin',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xff171717),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.question,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.hint),
                  const SizedBox(height: 28),
                  TextField(
                    key: ValueKey(widget.page),
                    controller: _controller,
                    onChanged: widget.onChanged,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Type your answer here...',
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onContinue,
                      child: Text(
                        widget.page == widget.total - 1
                            ? 'See my skin profile'
                            : 'Continue',
                      ),
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

class ConcernScreen extends StatelessWidget {
  const ConcernScreen({
    super.key,
    required this.photo,
    required this.analyzed,
    required this.matchedGuides,
    required this.concern,
    required this.onConcernChanged,
    required this.onTakePhoto,
    required this.onFindGuides,
    required this.onBack,
  });
  final XFile? photo;
  final bool analyzed;
  final List<String> matchedGuides;
  final String concern;
  final ValueChanged<String> onConcernChanged;
  final VoidCallback onTakePhoto;
  final VoidCallback onFindGuides;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe4f3ff),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tell us what you notice',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Describe what you notice. A photo is only a visual reference; Bio Glow does not diagnose from images.',
                  ),
                  const SizedBox(height: 26),
                  TextFormField(
                    initialValue: concern,
                    onChanged: onConcernChanged,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Describe your skin concern',
                      hintText:
                          'Where is it? When did it start? How does it feel?',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Guide matching uses condition names you type here, not image recognition.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: onTakePhoto,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 30),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              photo == null
                                  ? 'Enable camera and take a photo'
                                  : 'Photo ready to review',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  if (photo != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      photo!.name,
                      style: const TextStyle(color: Color(0xff171717)),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Uint8List>(
                      future: photo!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            snapshot.data!,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: photo == null && concern.trim().isEmpty
                          ? null
                          : onFindGuides,
                      icon: const Icon(Icons.search),
                      label: const Text('Find guides from my description'),
                    ),
                  ),
                  if (analyzed) ...[
                    const SizedBox(height: 32),
                    Text(
                      matchedGuides.isEmpty
                          ? 'No guide name found'
                          : 'Guide topics mentioned in your description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      matchedGuides.isEmpty
                          ? 'Bio Glow cannot identify a skin condition from this photo or description. Browse the guides below, or ask a healthcare professional.'
                          : 'These topics were matched only because you named them. This is not a diagnosis, and your photo was not used to select them.',
                    ),
                    const SizedBox(height: 12),
                    if (matchedGuides.isNotEmpty) ...[
                      const Text(
                        'General self-care ideas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...matchedGuides.map((title) {
                        final guide = _skinGuides[title]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(guide.careTips),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () =>
                                      launchUrl(Uri.parse(guide.url)),
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open educational guide'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      const Text(
                        'For general comfort, use gentle fragrance-free products, avoid picking or scratching, and pause products that seem irritating. Seek medical care for severe, rapidly worsening, or worrying symptoms.',
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text(
                      'Browse all educational guides',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._skinGuides.entries.map(
                      (entry) => ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(entry.key),
                        childrenPadding: const EdgeInsets.only(bottom: 12),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(entry.value.careTips),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  launchUrl(Uri.parse(entry.value.url)),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open supplied guide'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.spa_outlined, color: Color(0xff1c7068)),
      ),
      const SizedBox(width: 12),
      const Text(
        'bio glow',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xff171717),
        ),
      ),
    ],
  );
}
