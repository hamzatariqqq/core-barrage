import 'package:flutter/material.dart';

import 'progression/game_progress.dart';
import 'upgrades_screen.dart';

class WeaponsScreen extends StatefulWidget {
  const WeaponsScreen({
    super.key,
  });

  @override
  State<WeaponsScreen> createState() => _WeaponsScreenState();
}

class _WeaponsScreenState extends State<WeaponsScreen>
    with SingleTickerProviderStateMixin {
  final GameProgress _progress = GameProgress.instance;

  late final AnimationController _pulseController;

  int selectedWeapon = 0;

  final List<_WeaponData> weapons = const [
    _WeaponData(
      name: 'THUNDER CANNON',
      shortName: 'THUNDER',
      rarity: 'RARE',
      damage: 120,
      fireRate: 3.4,
      bulletSpeed: 8,
      criticalChance: 10,
      unlocked: true,
      accent: Color(0xFF22B9FF),
      icon: Icons.bolt_rounded,
    ),
    _WeaponData(
      name: 'BASIC BLASTER',
      shortName: 'BLASTER',
      rarity: 'COMMON',
      damage: 95,
      fireRate: 3.8,
      bulletSpeed: 7,
      criticalChance: 7,
      unlocked: true,
      accent: Color(0xFF4ADE67),
      icon: Icons.flash_on_rounded,
    ),
    _WeaponData(
      name: 'SHOTGUN',
      shortName: 'SHOTGUN',
      rarity: 'LOCKED',
      damage: 160,
      fireRate: 2.0,
      bulletSpeed: 6,
      criticalChance: 15,
      unlocked: false,
      accent: Color(0xFFFF9C42),
      icon: Icons.blur_on_rounded,
    ),
    _WeaponData(
      name: 'ROCKET LAUNCHER',
      shortName: 'ROCKET',
      rarity: 'LOCKED',
      damage: 230,
      fireRate: 1.3,
      bulletSpeed: 5,
      criticalChance: 18,
      unlocked: false,
      accent: Color(0xFFFF554D),
      icon: Icons.rocket_launch_rounded,
    ),
    _WeaponData(
      name: 'LASER GUN',
      shortName: 'LASER',
      rarity: 'LOCKED',
      damage: 180,
      fireRate: 4.5,
      bulletSpeed: 10,
      criticalChance: 20,
      unlocked: false,
      accent: Color(0xFFA45CFF),
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  _WeaponData get weapon => weapons[selectedWeapon];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _openUpgrades() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const UpgradesScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  void _selectWeapon(int index) {
    final item = weapons[index];

    if (!item.unlocked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1400),
          backgroundColor: const Color(0xFF102535),
          content: Row(
            children: [
              Icon(
                Icons.lock_rounded,
                color: item.accent,
                size: 19,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'This weapon is not unlocked yet.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedWeapon = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040A11),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: _WeaponsBackground(),
            ),

            Column(
              children: [
                _TopBar(
                  coins: _progress.coins,
                  onBack: () => Navigator.pop(context),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      24,
                    ),
                    child: Column(
                      children: [
                        _WeaponTitle(
                          weapon: weapon,
                        ),

                        const SizedBox(height: 10),

                        _WeaponShowcase(
                          weapon: weapon,
                          pulseController: _pulseController,
                          damageLevel: _progress.damageLevel,
                        ),

                        const SizedBox(height: 11),

                        _StatsPanel(
                          weapon: weapon,
                          damageLevel: _progress.damageLevel,
                          fireRateLevel: _progress.fireRateLevel,
                        ),

                        const SizedBox(height: 11),

                        _UpgradePanel(
                          damageLevel: _progress.damageLevel,
                          fireRateLevel: _progress.fireRateLevel,
                          onUpgrades: _openUpgrades,
                        ),

                        const SizedBox(height: 15),

                        _SectionHeader(
                          title: 'WEAPON COLLECTION',
                          subtitle:
                          '${weapons.where((e) => e.unlocked).length} / ${weapons.length} AVAILABLE',
                        ),

                        const SizedBox(height: 8),

                        _WeaponCollection(
                          weapons: weapons,
                          selected: selectedWeapon,
                          onSelected: _selectWeapon,
                        ),
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

class _WeaponsBackground extends StatelessWidget {
  const _WeaponsBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF07192A),
            Color(0xFF07111C),
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
    final grid = Paint()
      ..color = const Color(0x0C34B8FF)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 45) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    for (double x = 0; x < size.width; x += 55) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        grid,
      );
    }

    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x1732C7FF),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2,
            size.height * .28,
          ),
          radius: size.width * .7,
        ),
      );

    canvas.drawRect(
      Offset.zero & size,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// TOP BAR
// ============================================================

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.coins,
    required this.onBack,
  });

  final int coins;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF173B59),
            Color(0xFF0B2235),
            Color(0xFF071722),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2C6184),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
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
              borderRadius: BorderRadius.circular(11),
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF102F47),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: const Color(0xFF4389B5),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
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
                  'WEAPONS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'TACTICAL ARMORY',
                  style: TextStyle(
                    color: Color(0xFF6ECDF7),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),

          _CoinDisplay(
            value: coins,
          ),
        ],
      ),
    );
  }
}

class _CoinDisplay extends StatelessWidget {
  const _CoinDisplay({
    required this.value,
  });

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 70,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xB307151F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x77FFC82F),
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
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WEAPON TITLE
// ============================================================

class _WeaponTitle extends StatelessWidget {
  const _WeaponTitle({
    required this.weapon,
  });

  final _WeaponData weapon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EQUIPPED WEAPON',
                style: TextStyle(
                  color: Color(0xFF729CB5),
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                weapon.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: .95,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: weapon.accent.withValues(
                        alpha: .16,
                      ),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: weapon.accent,
                      ),
                    ),
                    child: Text(
                      weapon.rarity,
                      style: TextStyle(
                        color: weapon.accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .6,
                      ),
                    ),
                  ),

                  const SizedBox(width: 7),

                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4ADE67),
                    size: 14,
                  ),

                  const SizedBox(width: 3),

                  const Text(
                    'READY',
                    style: TextStyle(
                      color: Color(0xFF4ADE67),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0x99040E16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF284A60),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: Color(0xFFFFCC2F),
                size: 15,
              ),
              Icon(
                Icons.star_rounded,
                color: Color(0xFFFFCC2F),
                size: 15,
              ),
              Icon(
                Icons.star_rounded,
                color: Color(0xFFFFCC2F),
                size: 15,
              ),
              Icon(
                Icons.star_rounded,
                color: Color(0xFF46535C),
                size: 15,
              ),
              Icon(
                Icons.star_rounded,
                color: Color(0xFF46535C),
                size: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SHOWCASE
// ============================================================

class _WeaponShowcase extends StatelessWidget {
  const _WeaponShowcase({
    required this.weapon,
    required this.pulseController,
    required this.damageLevel,
  });

  final _WeaponData weapon;
  final AnimationController pulseController;
  final int damageLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const RadialGradient(
          radius: .9,
          colors: [
            Color(0xFF164C75),
            Color(0xFF0A253C),
            Color(0xFF06111D),
          ],
        ),
        border: Border.all(
          color: weapon.accent.withValues(alpha: .55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: weapon.accent.withValues(alpha: .10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ShowcasePainter(
                accent: weapon.accent,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + pulseController.value * .025,
                child: child,
              );
            },
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: weapon.accent.withValues(alpha: .22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: weapon.accent.withValues(alpha: .22),
                    blurRadius: 55,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                weapon.icon,
                color: weapon.accent,
                size: 105,
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: _SmallInfoBadge(
              label: 'CLASS',
              value: weapon.rarity,
              color: weapon.accent,
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: _SmallInfoBadge(
              label: 'DAMAGE LV.',
              value: '$damageLevel / 20',
              color: const Color(0xFFFFC82F),
            ),
          ),

          Positioned(
            bottom: 13,
            left: 13,
            right: 13,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xD905121D),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xFF28536D),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    color: weapon.accent,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'WEAPON SYSTEM ONLINE',
                      style: TextStyle(
                        color: Color(0xFFB6CEDC),
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                  const Text(
                    'READY',
                    style: TextStyle(
                      color: Color(0xFF4ADE67),
                      fontSize: 7,
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

class _ShowcasePainter extends CustomPainter {
  const _ShowcasePainter({
    required this.accent,
  });

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final linePaint = Paint()
      ..color = accent.withValues(alpha: .12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      center,
      90,
      linePaint,
    );

    canvas.drawCircle(
      center,
      112,
      linePaint,
    );

    canvas.drawLine(
      Offset(center.dx, 28),
      Offset(center.dx, size.height - 45),
      linePaint,
    );

    canvas.drawLine(
      Offset(25, center.dy),
      Offset(size.width - 25, center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _ShowcasePainter oldDelegate,
      ) {
    return oldDelegate.accent != accent;
  }
}

class _SmallInfoBadge extends StatelessWidget {
  const _SmallInfoBadge({
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xD907151F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: .45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7397AC),
              fontSize: 6,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATS
// ============================================================

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.weapon,
    required this.damageLevel,
    required this.fireRateLevel,
  });

  final _WeaponData weapon;
  final int damageLevel;
  final int fireRateLevel;

  @override
  Widget build(BuildContext context) {
    final damageMultiplier =
        1 + ((damageLevel - 1) * .12);

    final fireRateMultiplier =
        1 + ((fireRateLevel - 1) * .08);

    final effectiveDamage =
    (weapon.damage * damageMultiplier).round();

    final effectiveFireRate =
        weapon.fireRate * fireRateMultiplier;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _panel(),
      child: Column(
        children: [
          const _PanelHeading(
            icon: Icons.analytics_rounded,
            title: 'COMBAT PERFORMANCE',
          ),

          const SizedBox(height: 12),

          _StatRow(
            icon: Icons.gps_fixed_rounded,
            label: 'DAMAGE',
            value: '$effectiveDamage',
            progress: effectiveDamage / 300,
            accent: const Color(0xFFFF5D52),
          ),

          _StatRow(
            icon: Icons.speed_rounded,
            label: 'FIRE RATE',
            value: '${effectiveFireRate.toStringAsFixed(1)}/s',
            progress: effectiveFireRate / 7,
            accent: const Color(0xFFFFC82F),
          ),

          _StatRow(
            icon: Icons.rocket_launch_rounded,
            label: 'BULLET SPEED',
            value: '${weapon.bulletSpeed}',
            progress: weapon.bulletSpeed / 10,
            accent: const Color(0xFF20C6FF),
          ),

          _StatRow(
            icon: Icons.my_location_rounded,
            label: 'CRITICAL CHANCE',
            value: '${weapon.criticalChance}%',
            progress: weapon.criticalChance / 25,
            accent: const Color(0xFFA45CFF),
            bottom: true,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.accent,
    this.bottom = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color accent;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom ? 0 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: accent.withValues(alpha: .25),
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFFA3C3D7),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFF020A10),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UPGRADE PANEL
// ============================================================

class _UpgradePanel extends StatelessWidget {
  const _UpgradePanel({
    required this.damageLevel,
    required this.fireRateLevel,
    required this.onUpgrades,
  });

  final int damageLevel;
  final int fireRateLevel;
  final VoidCallback onUpgrades;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _panel(),
      child: Column(
        children: [
          const _PanelHeading(
            icon: Icons.upgrade_rounded,
            title: 'WEAPON UPGRADES',
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _UpgradeSummary(
                  icon: Icons.gps_fixed_rounded,
                  label: 'DAMAGE',
                  value: 'LV. $damageLevel',
                  color: const Color(0xFFFF5D52),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _UpgradeSummary(
                  icon: Icons.speed_rounded,
                  label: 'FIRE RATE',
                  value: 'LV. $fireRateLevel',
                  color: const Color(0xFFFFC82F),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 105,
                height: 58,
                child: FilledButton(
                  onPressed: onUpgrades,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF078FFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF52C9FF),
                      ),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upgrade_rounded,
                        size: 19,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'UPGRADES',
                        style: TextStyle(
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
        ],
      ),
    );
  }
}

class _UpgradeSummary extends StatelessWidget {
  const _UpgradeSummary({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      decoration: _smallPanel(),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF83B4D0),
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.inventory_2_rounded,
          color: Color(0xFF4CCEFF),
          size: 17,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ),

        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7195AA),
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COLLECTION
// ============================================================

class _WeaponCollection extends StatelessWidget {
  const _WeaponCollection({
    required this.weapons,
    required this.selected,
    required this.onSelected,
  });

  final List<_WeaponData> weapons;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: weapons.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final item = weapons[index];
          final active = selected == index;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 94,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    item.accent.withValues(alpha: .22),
                    const Color(0xFF091825),
                  ],
                )
                    : null,
                color: active
                    ? null
                    : const Color(0xFF091825),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  width: active ? 2.2 : 1,
                  color: active
                      ? item.accent
                      : const Color(0xFF20394C),
                ),
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: item.accent.withValues(
                      alpha: .25,
                    ),
                    blurRadius: 14,
                  ),
                ]
                    : null,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 43,
                          color: item.unlocked
                              ? item.accent
                              : const Color(0xFF637180),
                        ),

                        if (!item.unlocked)
                          Container(
                            width: 27,
                            height: 27,
                            decoration: const BoxDecoration(
                              color: Color(0xD9071118),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFFB1BBC2),
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Text(
                    item.shortName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.unlocked
                          ? Colors.white
                          : const Color(0xFF798591),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.unlocked
                        ? active
                        ? 'EQUIPPED'
                        : 'AVAILABLE'
                        : 'LOCKED',
                    style: TextStyle(
                      color: item.unlocked
                          ? item.accent
                          : const Color(0xFF6B7680),
                      fontSize: 6,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PANEL HEADING
// ============================================================

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF51CCFF),
          size: 17,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            color: Color(0xFF244A61),
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DATA
// ============================================================

class _WeaponData {
  const _WeaponData({
    required this.name,
    required this.shortName,
    required this.rarity,
    required this.damage,
    required this.fireRate,
    required this.bulletSpeed,
    required this.criticalChance,
    required this.unlocked,
    required this.accent,
    required this.icon,
  });

  final String name;
  final String shortName;
  final String rarity;

  final int damage;
  final double fireRate;
  final int bulletSpeed;
  final int criticalChance;

  final bool unlocked;

  final Color accent;
  final IconData icon;
}

// ============================================================
// DECORATIONS
// ============================================================

BoxDecoration _panel() {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xEE102B42),
        Color(0xEE071521),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: const Color(0xFF235677),
    ),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
}

BoxDecoration _smallPanel() {
  return BoxDecoration(
    color: const Color(0xDD071622),
    borderRadius: BorderRadius.circular(11),
    border: Border.all(
      color: const Color(0xFF244A65),
    ),
  );
}