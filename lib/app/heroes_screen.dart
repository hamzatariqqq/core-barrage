import 'package:flutter/material.dart';

import 'progression/game_progress.dart';
import 'progression/level_progress.dart';
import 'progression/selected_hero.dart';

class HeroesScreen extends StatefulWidget {
  const HeroesScreen({super.key});

  @override
  State<HeroesScreen> createState() => _HeroesScreenState();
}

class _HeroesScreenState extends State<HeroesScreen>
    with SingleTickerProviderStateMixin {
  final GameProgress _progress = GameProgress.instance;
  final LevelProgress _levels = LevelProgress.instance;

  late final AnimationController _pulseController;

  static const List<_HeroData> _heroes = [
    _HeroData(
      name: 'VOLT',
      role: 'SHOCK TROOPER',
      description:
      'Fast assault commander built for aggressive frontline combat.',
      icon: Icons.flash_on_rounded,
      accent: Color(0xFF25C8FF),
      power: 1250,
      bonus: '+12% DMG',
      specialty: 'ASSAULT',
      unlockLevel: 1,
    ),
    _HeroData(
      name: 'BRUTE',
      role: 'HEAVY GUARD',
      description:
      'Armored commander designed to hold the line under heavy fire.',
      icon: Icons.shield_rounded,
      accent: Color(0xFFFF9D3A),
      power: 1680,
      bonus: '+20% ARMOR',
      specialty: 'DEFENSE',
      unlockLevel: 3,
    ),
    _HeroData(
      name: 'NOVA',
      role: 'PLASMA SCOUT',
      description:
      'Advanced scout specializing in speed and high-energy attacks.',
      icon: Icons.auto_awesome_rounded,
      accent: Color(0xFFC267FF),
      power: 1940,
      bonus: '+15% SPEED',
      specialty: 'TACTICAL',
      unlockLevel: 5,
    ),
    _HeroData(
      name: 'GHOST',
      role: 'STEALTH OPERATIVE',
      description:
      'Covert commander trained for precision attacks and rapid movement.',
      icon: Icons.visibility_off_rounded,
      accent: Color(0xFF72E6C2),
      power: 2210,
      bonus: '+18% CRIT',
      specialty: 'STEALTH',
      unlockLevel: 8,
    ),
    _HeroData(
      name: 'VIPER',
      role: 'TACTICAL MARKSMAN',
      description:
      'Long-range specialist capable of delivering devastating precision fire.',
      icon: Icons.gps_fixed_rounded,
      accent: Color(0xFFB7E34A),
      power: 2540,
      bonus: '+22% DMG',
      specialty: 'PRECISION',
      unlockLevel: 11,
    ),
    _HeroData(
      name: 'TITAN',
      role: 'ELITE COMMANDER',
      description:
      'End-game commander combining exceptional firepower, armor and leadership.',
      icon: Icons.military_tech_rounded,
      accent: Color(0xFFFF5757),
      power: 3100,
      bonus: '+25% POWER',
      specialty: 'ELITE',
      unlockLevel: 14,
    ),
  ];

  int get _selectedHero {
    final value = SelectedHero.current;
    if (value < 0 || value >= _heroes.length) {
      return 0;
    }
    return value;
  }

  _HeroData get _hero => _heroes[_selectedHero];

  bool _isUnlocked(_HeroData hero) {
    return _levels.highestUnlockedLevel >= hero.unlockLevel;
  }

  int get _unlockedCount =>
      _heroes.where((hero) => _isUnlocked(hero)).length;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _selectHero(int index) {
    final hero = _heroes[index];

    if (!_isUnlocked(hero)) {
      _showLockedMessage(
        '${hero.name} unlocks when Campaign Level ${hero.unlockLevel} is reached.',
        hero.accent,
      );
      return;
    }

    SelectedHero.select(index);
    setState(() {});
  }

  void _showLockedMessage(String text, Color accent) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0A1D29),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: accent.withValues(alpha: .55),
            ),
          ),
          content: Row(
            children: [
              Icon(
                Icons.lock_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04101A),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: _Background(),
            ),
            Column(
              children: [
                _Header(
                  coins: _progress.coins,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      12,
                      14,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        _HeroShowcase(
                          hero: _hero,
                          pulseController: _pulseController,
                        ),
                        const SizedBox(height: 12),
                        _CommanderProfile(
                          hero: _hero,
                          progress: _progress,
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          unlocked: _unlockedCount,
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(
                          _heroes.length,
                              (index) {
                            final hero = _heroes[index];

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                index == _heroes.length - 1
                                    ? 0
                                    : 10,
                              ),
                              child: _HeroCard(
                                hero: hero,
                                unlocked: _isUnlocked(hero),
                                selected:
                                _selectedHero == index,
                                onTap: () =>
                                    _selectHero(index),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        const _Tip(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BACKGROUND
// ============================================================

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B253A),
            Color(0xFF07131F),
            Color(0xFF03080E),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0x0B38BFFF)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        line,
      );
    }

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        line,
      );
    }

    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x2025C8FF),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2,
            size.height * .20,
          ),
          radius: size.width * .72,
        ),
      );

    canvas.drawRect(
      Offset.zero & size,
      glow,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) =>
      false;
}

// ============================================================
// HEADER
// ============================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.coins,
    required this.onBack,
  });

  final int coins;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      margin: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF173B59),
            Color(0xFF081B2A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2C6A91),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF102F47),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFF4389B5),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'HEROES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'COMMANDER ROSTER',
                  style: TextStyle(
                    color: Color(0xFF6ED8FF),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _Coins(value: coins),
        ],
      ),
    );
  }
}

class _Coins extends StatelessWidget {
  const _Coins({
    required this.value,
  });

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 68,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xCC07151F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x99FFC82F),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            size: 17,
            color: Color(0xFFFFC82F),
          ),
          const SizedBox(width: 5),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHOWCASE
// ============================================================

class _HeroShowcase extends StatelessWidget {
  const _HeroShowcase({
    required this.hero,
    required this.pulseController,
  });

  final _HeroData hero;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          radius: .95,
          colors: [
            hero.accent.withValues(alpha: .25),
            const Color(0xFF0B2A40),
            const Color(0xFF06111D),
          ],
        ),
        border: Border.all(
          color: hero.accent.withValues(alpha: .65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: hero.accent.withValues(alpha: .12),
            blurRadius: 22,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            top: 12,
            child: _Badge(
              icon: Icons.check_rounded,
              text: 'EQUIPPED',
              color: const Color(0xFF43E78D),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _Badge(
              icon: Icons.gps_fixed_rounded,
              text: hero.specialty,
              color: hero.accent,
            ),
          ),
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, child) {
              return Transform.scale(
                scale:
                1 + pulseController.value * .025,
                child: child,
              );
            },
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    hero.accent.withValues(alpha: .22),
                    const Color(0xC806121C),
                  ],
                ),
                border: Border.all(
                  color:
                  hero.accent.withValues(alpha: .65),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    hero.accent.withValues(alpha: .30),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                hero.icon,
                size: 62,
                color: hero.accent,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 11,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xEA06131D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF315C75),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hero.icon,
                    color: hero.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          hero.role,
                          style: TextStyle(
                            color: hero.accent,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${hero.power} PWR',
                    style: const TextStyle(
                      color: Color(0xFFFFD438),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xDD07151F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: .48),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class _CommanderProfile extends StatelessWidget {
  const _CommanderProfile({
    required this.hero,
    required this.progress,
  });

  final _HeroData hero;
  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▣  COMMANDER PROFILE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            hero.description,
            style: const TextStyle(
              color: Color(0xFFABC2D0),
              fontSize: 10,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'POWER',
                  value: '${hero.power}',
                  color: const Color(0xFFFFD438),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(
                  label: 'BONUS',
                  value: hero.bonus,
                  color: hero.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(
                  label: 'ARMY',
                  value: '${progress.startingArmy}',
                  color: const Color(0xFF43E78D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xB507151F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: .30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7896A7),
              fontSize: 7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LIST
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.unlocked,
  });

  final int unlocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.groups_rounded,
          color: Color(0xFF4CCEFF),
          size: 18,
        ),
        const SizedBox(width: 7),
        const Expanded(
          child: Text(
            'SQUAD COMMANDERS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$unlocked OF 6 UNLOCKED',
          style: const TextStyle(
            color: Color(0xFF789BAD),
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hero,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  final _HeroData hero;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = !unlocked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(
            minHeight: 112,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                hero.accent.withValues(
                  alpha: selected
                      ? .19
                      : muted
                      ? .035
                      : .08,
                ),
                const Color(0xFF081923),
              ],
            ),
            border: Border.all(
              width: selected ? 1.8 : 1,
              color: selected
                  ? hero.accent
                  : muted
                  ? const Color(0xFF344854)
                  : hero.accent.withValues(
                alpha: .40,
              ),
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: hero.accent.withValues(
                  alpha: .18,
                ),
                blurRadius: 15,
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: RadialGradient(
                    colors: [
                      hero.accent.withValues(
                        alpha: muted ? .08 : .26,
                      ),
                      const Color(0xFF07131C),
                    ],
                  ),
                  border: Border.all(
                    color: muted
                        ? const Color(0xFF3A4850)
                        : hero.accent.withValues(
                      alpha: .42,
                    ),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      hero.icon,
                      color: muted
                          ? const Color(0xFF5E6C74)
                          : hero.accent,
                      size: 39,
                    ),
                    if (muted)
                      Container(
                        width: 31,
                        height: 31,
                        decoration: const BoxDecoration(
                          color: Color(0xE6071118),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFFD0D6DA),
                          size: 17,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hero.name,
                            style: TextStyle(
                              color: muted
                                  ? const Color(0xFF9AA5AB)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF43E78D),
                            size: 18,
                          ),
                      ],
                    ),
                    Text(
                      hero.role,
                      style: TextStyle(
                        color: muted
                            ? const Color(0xFF697B86)
                            : hero.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          muted
                              ? '??? PWR'
                              : '${hero.power} PWR',
                          style: const TextStyle(
                            color: Color(0xFFFFD438),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            muted
                                ? 'LEVEL ${hero.unlockLevel}'
                                : hero.bonus,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: muted
                                  ? const Color(0xFF78858C)
                                  : hero.accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: 23,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: muted
                            ? const Color(0xFF202A30)
                            : selected
                            ? hero.accent.withValues(
                          alpha: .16,
                        )
                            : const Color(0xFF102B3C),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: muted
                              ? const Color(0xFF3B484F)
                              : hero.accent.withValues(
                            alpha: .40,
                          ),
                        ),
                      ),
                      child: Text(
                        muted
                            ? 'UNLOCK AT LEVEL ${hero.unlockLevel}'
                            : selected
                            ? '✓  EQUIPPED'
                            : 'TAP TO EQUIP',
                        style: TextStyle(
                          color: muted
                              ? const Color(0xFF87939A)
                              : hero.accent,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF091824),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF24475E),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF42C7FF),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Win campaign missions to unlock stronger commanders.',
              style: TextStyle(
                color: Color(0xFFA3BDCC),
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroData {
  const _HeroData({
    required this.name,
    required this.role,
    required this.description,
    required this.icon,
    required this.accent,
    required this.power,
    required this.bonus,
    required this.specialty,
    required this.unlockLevel,
  });

  final String name;
  final String role;
  final String description;
  final IconData icon;
  final Color accent;
  final int power;
  final String bonus;
  final String specialty;
  final int unlockLevel;
}

BoxDecoration _panel() {
  return BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xEE102B42),
        Color(0xEE071521),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: const Color(0xFF235677),
    ),
  );
}