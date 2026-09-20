import 'package:flutter/material.dart';

import 'progression/game_progress.dart';

class UpgradesScreen extends StatefulWidget {
  const UpgradesScreen({
    super.key,
  });

  @override
  State<UpgradesScreen> createState() => _UpgradesScreenState();
}

class _UpgradesScreenState extends State<UpgradesScreen> {
  final GameProgress progress = GameProgress.instance;

  String? _upgradingType;

  Future<void> _upgrade(String type) async {
    if (_upgradingType != null) return;

    setState(() {
      _upgradingType = type;
    });

    bool success = false;

    switch (type) {
      case 'damage':
        success = await progress.upgradeDamage();
        break;

      case 'fireRate':
        success = await progress.upgradeFireRate();
        break;

      case 'army':
        success = await progress.upgradeArmy();
        break;

      case 'health':
        success = await progress.upgradeHealth();
        break;
    }

    if (!mounted) return;

    setState(() {
      _upgradingType = null;
    });

    if (!success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFF102535),
          content: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFFFC82F),
                size: 19,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Not enough coins or this upgrade is already maxed.',
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 900),
        backgroundColor: Color(0xFF123F2B),
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF56EA91),
              size: 19,
            ),
            SizedBox(width: 9),
            Text(
              'Upgrade complete!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
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
      backgroundColor: const Color(0xFF040A10),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: _UpgradeBackground(),
            ),

            Column(
              children: [
                _UpgradeTopBar(
                  coins: progress.coins,
                  onBack: () {
                    Navigator.pop(context);
                  },
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      12,
                      12,
                      28,
                    ),
                    child: Column(
                      children: [
                        _PowerSummary(
                          progress: progress,
                        ),

                        const SizedBox(height: 12),

                        const _SectionHeading(
                          icon: Icons.tune_rounded,
                          title: 'PERMANENT UPGRADES',
                          subtitle: 'MAX LEVEL 20',
                        ),

                        const SizedBox(height: 9),

                        _UpgradeCard(
                          icon:
                          Icons.local_fire_department_rounded,
                          title: 'WEAPON DAMAGE',
                          subtitle:
                          'Increase the damage dealt by every shot.',
                          level: progress.damageLevel,
                          value:
                          '+${((progress.damageMultiplier - 1) * 100).round()}% DAMAGE',
                          nextValue:
                          '+${progress.damageLevel * 12}% DAMAGE',
                          accent: const Color(0xFFFF665A),
                          cost: progress.damageUpgradeCost(),
                          coins: progress.coins,
                          upgrading:
                          _upgradingType == 'damage',
                          onUpgrade: () {
                            _upgrade('damage');
                          },
                        ),

                        const SizedBox(height: 10),

                        _UpgradeCard(
                          icon: Icons.speed_rounded,
                          title: 'FIRE RATE',
                          subtitle:
                          'Increase weapon firing speed in every battle.',
                          level: progress.fireRateLevel,
                          value:
                          '+${((progress.fireRateMultiplier - 1) * 100).round()}% SPEED',
                          nextValue:
                          '+${progress.fireRateLevel * 8}% SPEED',
                          accent: const Color(0xFF26C8FF),
                          cost: progress.fireRateUpgradeCost(),
                          coins: progress.coins,
                          upgrading:
                          _upgradingType == 'fireRate',
                          onUpgrade: () {
                            _upgrade('fireRate');
                          },
                        ),

                        const SizedBox(height: 10),

                        _UpgradeCard(
                          icon: Icons.groups_rounded,
                          title: 'STARTING ARMY',
                          subtitle:
                          'Deploy more soldiers at the start of every mission.',
                          level: progress.armyLevel,
                          value:
                          '${progress.startingArmy} SOLDIERS',
                          nextValue:
                          '${progress.startingArmy + 2} SOLDIERS',
                          accent: const Color(0xFF37E888),
                          cost: progress.armyUpgradeCost(),
                          coins: progress.coins,
                          upgrading:
                          _upgradingType == 'army',
                          onUpgrade: () {
                            _upgrade('army');
                          },
                        ),

                        const SizedBox(height: 10),

                        _UpgradeCard(
                          icon:
                          Icons.health_and_safety_rounded,
                          title: 'ARMOR',
                          subtitle:
                          'Increase your vehicle maximum health.',
                          level: progress.healthLevel,
                          value:
                          '${progress.maxHealth.round()} HP',
                          nextValue:
                          '${progress.maxHealth.round() + 20} HP',
                          accent: const Color(0xFFA76AFF),
                          cost: progress.healthUpgradeCost(),
                          coins: progress.coins,
                          upgrading:
                          _upgradingType == 'health',
                          onUpgrade: () {
                            _upgrade('health');
                          },
                        ),

                        const SizedBox(height: 14),

                        const _UpgradeTip(),
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

class _UpgradeBackground extends StatelessWidget {
  const _UpgradeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A2033),
            Color(0xFF07131F),
            Color(0xFF03080E),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _UpgradeGridPainter(),
      ),
    );
  }
}

class _UpgradeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x0B38BFFF)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 46) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (double x = 0; x < size.width; x += 58) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    final glowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x1738C8FF),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2,
            size.height * .20,
          ),
          radius: size.width * .7,
        ),
      );

    canvas.drawRect(
      Offset.zero & size,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

// ============================================================
// TOP BAR
// ============================================================

class _UpgradeTopBar extends StatelessWidget {
  const _UpgradeTopBar({
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
              onTap: onBack,
              borderRadius: BorderRadius.circular(11),
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
                  'UPGRADES',
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
                  'COMMAND CENTER',
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
// POWER SUMMARY
// ============================================================

class _PowerSummary extends StatelessWidget {
  const _PowerSummary({
    required this.progress,
  });

  final GameProgress progress;

  int get _power {
    return 1000 +
        progress.damageLevel * 45 +
        progress.fireRateLevel * 35 +
        progress.armyLevel * 50 +
        progress.healthLevel * 40;
  }

  int get _totalLevels {
    return progress.damageLevel +
        progress.fireRateLevel +
        progress.armyLevel +
        progress.healthLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF173E5F),
            Color(0xFF0B263B),
            Color(0xFF071823),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF2D739C),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFD738),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x88FFD738),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FFD738),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFFFD738),
                  size: 35,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL POWER',
                      style: TextStyle(
                        color: Color(0xFF8CBBD5),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$_power',
                      style: const TextStyle(
                        color: Color(0xFFFFD73C),
                        fontSize: 29,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
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
                  color: const Color(0x1837E888),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: const Color(0x6637E888),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF40E58D),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'READY',
                      style: TextStyle(
                        color: Color(0xFF40E58D),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _PowerInfo(
                  label: 'UPGRADE LEVELS',
                  value: '$_totalLevels / 80',
                  icon: Icons.upgrade_rounded,
                  color: const Color(0xFF42C7FF),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _PowerInfo(
                  label: 'STARTING ARMY',
                  value: '${progress.startingArmy}',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF37E888),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _PowerInfo(
                  label: 'ARMOR',
                  value: '${progress.maxHealth.round()} HP',
                  icon:
                  Icons.health_and_safety_rounded,
                  color: const Color(0xFFA76AFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PowerInfo extends StatelessWidget {
  const _PowerInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0x9E06131D),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFF27495D),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7190A4),
                    fontSize: 5.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
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
// SECTION
// ============================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4CCEFF),
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
// UPGRADE CARD
// ============================================================

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.value,
    required this.nextValue,
    required this.accent,
    required this.cost,
    required this.coins,
    required this.upgrading,
    required this.onUpgrade,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  final int level;

  final String value;
  final String nextValue;

  final Color accent;

  final int cost;
  final int coins;

  final bool upgrading;

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final bool maxed = level >= 20;
    final bool canAfford = coins >= cost;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xF20F2A40),
            Color(0xF2081724),
          ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: .48),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 11,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: accent.withValues(alpha: .14),
                  border: Border.all(
                    color: accent.withValues(alpha: .65),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 27,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF8DAEC2),
                        fontSize: 8,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF06111B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withValues(alpha: .25),
                  ),
                ),
                child: Text(
                  'LV.$level',
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _ValueBox(
                  label: 'CURRENT',
                  value: value,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 7),

              Icon(
                maxed
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                size: 17,
                color: maxed
                    ? const Color(0xFF40E58D)
                    : const Color(0xFF6F8DA1),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _ValueBox(
                  label: maxed ? 'MAXIMUM' : 'NEXT LEVEL',
                  value: maxed ? value : nextValue,
                  color: accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                'LEVEL $level',
                style: const TextStyle(
                  color: Color(0xFF718FA1),
                  fontSize: 6,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value:
                    (level / 20).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor:
                    const Color(0xFF020A10),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                      accent,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              const Text(
                '20',
                style: TextStyle(
                  color: Color(0xFF718FA1),
                  fontSize: 6,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          SizedBox(
            width: double.infinity,
            height: 47,
            child: FilledButton(
              onPressed: maxed || upgrading
                  ? null
                  : onUpgrade,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                disabledBackgroundColor:
                const Color(0xFF344652),
                foregroundColor:
                const Color(0xFF06111A),
                disabledForegroundColor:
                const Color(0xFF94A1A9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: upgrading
                  ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
                  : maxed
                  ? const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'MAX LEVEL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upgrade_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'UPGRADE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons
                        .monetization_on_rounded,
                    size: 16,
                    color: canAfford
                        ? const Color(
                      0xFFFFE36B,
                    )
                        : const Color(
                      0xFFFF867F,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$cost',
                    style: TextStyle(
                      color: canAfford
                          ? const Color(
                        0xFFFFE36B,
                      )
                          : const Color(
                        0xFFFF867F,
                      ),
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!maxed && !canAfford) ...[
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFFF867F),
                  size: 11,
                ),
                SizedBox(width: 4),
                Text(
                  'NOT ENOUGH COINS',
                  style: TextStyle(
                    color: Color(0xFFFF867F),
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// VALUE BOX
// ============================================================

class _ValueBox extends StatelessWidget {
  const _ValueBox({
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
      height: 49,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xB807141F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0x332E607C),
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7190A4),
              fontSize: 6,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
// TIP
// ============================================================

class _UpgradeTip extends StatelessWidget {
  const _UpgradeTip();

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
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0x1542C7FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF42C7FF),
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERMANENT POWER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'These upgrades strengthen your army in every mission.',
                  style: TextStyle(
                    color: Color(0xFF91AFC0),
                    fontSize: 8,
                    height: 1.25,
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