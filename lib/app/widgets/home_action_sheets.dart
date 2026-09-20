import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../progression/game_progress.dart';

class HomeActionSheets {
  HomeActionSheets._();

  static const String _dailyRewardKey =
      'core_barrage_daily_reward_date';

  static const String _luckySpinKey =
      'core_barrage_lucky_spin_date';

  // ============================================================
  // DAILY REWARD
  // ============================================================

  static Future<bool> showDailyReward(
      BuildContext context,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastClaim = prefs.getString(_dailyRewardKey);

    final available = lastClaim != today;

    if (!context.mounted) return false;

    final claimed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) {
        return _DailyRewardSheet(
          available: available,
        );
      },
    );

    if (claimed != true || !available) {
      return false;
    }

    await GameProgress.instance.addCoins(300);
    await prefs.setString(_dailyRewardKey, today);

    return true;
  }

  // ============================================================
  // LUCKY SPIN
  // ============================================================

  static Future<bool> showLuckySpin(
      BuildContext context,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastSpin = prefs.getString(_luckySpinKey);

    final available = lastSpin != today;

    if (!context.mounted) return false;

    final reward = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) {
        return _LuckySpinSheet(
          available: available,
        );
      },
    );

    if (reward == null || reward <= 0 || !available) {
      return false;
    }

    await GameProgress.instance.addCoins(reward);
    await prefs.setString(_luckySpinKey, today);

    return true;
  }

  // ============================================================
  // MISSIONS
  // ============================================================

  static Future<void> showMissions(
      BuildContext context,
      ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) => const _MissionsSheet(),
    );
  }

  // ============================================================
  // SHOP
  // ============================================================

  static Future<void> showShop(
      BuildContext context,
      ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (_) => const _ShopSheet(),
    );
  }

  static String _todayKey() {
    final now = DateTime.now();

    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }
}

// ============================================================
// DAILY REWARD
// ============================================================

class _DailyRewardSheet extends StatelessWidget {
  const _DailyRewardSheet({
    required this.available,
  });

  final bool available;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'DAILY REWARD',
      subtitle: available
          ? 'Your commander reward is ready.'
          : 'Today\'s reward has already been collected.',
      icon: Icons.card_giftcard_rounded,
      accent: const Color(0xFFFFC524),
      child: Column(
        children: [
          const SizedBox(height: 8),

          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0x66FFC524),
                  Color(0x221B6D92),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: const Color(0x88FFC524),
              ),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFFFD84D),
              size: 68,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            '+300 COINS',
            style: TextStyle(
              color: Color(0xFFFFD84D),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            available
                ? 'Free reward available today'
                : 'Come back tomorrow for another reward',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CB7C8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 22),

          _PrimaryActionButton(
            text: available ? 'CLAIM REWARD' : 'CLAIMED',
            icon: available
                ? Icons.card_giftcard_rounded
                : Icons.check_circle_rounded,
            enabled: available,
            accent: const Color(0xFFFFC524),
            onTap: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MISSIONS
// ============================================================

class _MissionsSheet extends StatelessWidget {
  const _MissionsSheet();

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'MISSIONS',
      subtitle: 'Commander objectives',
      icon: Icons.track_changes_rounded,
      accent: const Color(0xFFFF4B45),
      child: Column(
        children: [
          const SizedBox(height: 5),

          const _MissionBoardItem(
            icon: Icons.sports_esports_rounded,
            title: 'BATTLE MISSION',
            description: 'Complete a battlefield operation.',
            reward: '+150',
          ),

          const SizedBox(height: 10),

          const _MissionBoardItem(
            icon: Icons.groups_rounded,
            title: 'ARMY MISSION',
            description: 'Build a powerful army during battle.',
            reward: '+200',
          ),

          const SizedBox(height: 10),

          const _MissionBoardItem(
            icon: Icons.gps_fixed_rounded,
            title: 'COMBAT MISSION',
            description: 'Destroy enemy forces in combat.',
            reward: '+250',
          ),

          const SizedBox(height: 17),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xAA071521),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFF31546B),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF64D7FF),
                  size: 19,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Mission progress tracking is coming with the full mission system.',
                    style: TextStyle(
                      color: Color(0xFFA8C2D2),
                      fontSize: 10,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
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

class _MissionBoardItem extends StatelessWidget {
  const _MissionBoardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.reward,
  });

  final IconData icon;
  final String title;
  final String description;
  final String reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xF2143045),
            Color(0xF2071622),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF355C73),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF102D42),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x774ACFFF),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF54D4FF),
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF91ACBC),
                    fontSize: 9,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: Color(0xFFFFC524),
                size: 19,
              ),

              const SizedBox(height: 2),

              Text(
                reward,
                style: const TextStyle(
                  color: Color(0xFFFFD95C),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LUCKY SPIN
// ============================================================

class _LuckySpinSheet extends StatefulWidget {
  const _LuckySpinSheet({
    required this.available,
  });

  final bool available;

  @override
  State<_LuckySpinSheet> createState() =>
      _LuckySpinSheetState();
}

class _LuckySpinSheetState extends State<_LuckySpinSheet>
    with SingleTickerProviderStateMixin {
  static const rewards = <int>[
    100,
    150,
    200,
    250,
    300,
    500,
  ];

  late final AnimationController _controller;

  int? _reward;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (!widget.available || _spinning) return;

    setState(() {
      _spinning = true;
      _reward = null;
    });

    _controller.reset();
    await _controller.forward();

    if (!mounted) return;

    final reward =
    rewards[math.Random().nextInt(rewards.length)];

    setState(() {
      _reward = reward;
      _spinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'LUCKY SPIN',
      subtitle: widget.available
          ? 'One free spin available today.'
          : 'Today\'s free spin has already been used.',
      icon: Icons.casino_rounded,
      accent: const Color(0xFFD14DFF),
      child: Column(
        children: [
          const SizedBox(height: 6),

          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final turns =
                  Curves.easeOutCubic.transform(
                    _controller.value,
                  ) *
                      5.0;

              return Transform.rotate(
                angle: turns * math.pi * 2,
                child: child,
              );
            },
            child: Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFFD14DFF),
                    Color(0xFF5E2BEA),
                    Color(0xFF20C6FF),
                    Color(0xFFFFC524),
                    Color(0xFFFF6C3A),
                    Color(0xFFD14DFF),
                  ],
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66D14DFF),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF091B2A),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFFFD84D),
                  size: 58,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_reward != null)
            Text(
              'YOU WON $_reward COINS!',
              style: const TextStyle(
                color: Color(0xFFFFD84D),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            )
          else
            Text(
              widget.available
                  ? '100 • 150 • 200 • 250 • 300 • 500'
                  : 'COME BACK TOMORROW',
              style: const TextStyle(
                color: Color(0xFFABC2D1),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),

          const SizedBox(height: 20),

          if (_reward != null)
            _PrimaryActionButton(
              text: 'COLLECT $_reward COINS',
              icon: Icons.monetization_on_rounded,
              accent: const Color(0xFFFFC524),
              onTap: () {
                Navigator.of(context).pop(_reward);
              },
            )
          else
            _PrimaryActionButton(
              text: _spinning
                  ? 'SPINNING...'
                  : widget.available
                  ? 'FREE SPIN'
                  : 'USED TODAY',
              icon: Icons.casino_rounded,
              enabled: widget.available && !_spinning,
              accent: const Color(0xFFD14DFF),
              onTap: _spin,
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SHOP
// ============================================================

class _ShopSheet extends StatefulWidget {
  const _ShopSheet();

  @override
  State<_ShopSheet> createState() => _ShopSheetState();
}

class _ShopSheetState extends State<_ShopSheet> {
  final GameProgress _progress = GameProgress.instance;

  Future<void> _upgradeDamage() async {
    if (_progress.damageLevel >= 20) {
      _showMessage('Weapon Damage is already MAX level.');
      return;
    }

    final success = await _progress.upgradeDamage();

    if (!mounted) return;

    if (success) {
      setState(() {});
      _showMessage('Weapon Damage upgraded!');
    } else {
      _showMessage('Not enough coins.');
    }
  }

  Future<void> _upgradeFireRate() async {
    if (_progress.fireRateLevel >= 20) {
      _showMessage('Fire Rate is already MAX level.');
      return;
    }

    final success = await _progress.upgradeFireRate();

    if (!mounted) return;

    if (success) {
      setState(() {});
      _showMessage('Fire Rate upgraded!');
    } else {
      _showMessage('Not enough coins.');
    }
  }

  Future<void> _upgradeArmy() async {
    if (_progress.armyLevel >= 20) {
      _showMessage('Starting Army is already MAX level.');
      return;
    }

    final success = await _progress.upgradeArmy();

    if (!mounted) return;

    if (success) {
      setState(() {});
      _showMessage('Starting Army upgraded!');
    } else {
      _showMessage('Not enough coins.');
    }
  }

  Future<void> _upgradeHealth() async {
    if (_progress.healthLevel >= 20) {
      _showMessage('Vehicle Health is already MAX level.');
      return;
    }

    final success = await _progress.upgradeHealth();

    if (!mounted) return;

    if (success) {
      setState(() {});
      _showMessage('Vehicle Health upgraded!');
    } else {
      _showMessage('Not enough coins.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final bool isError = message == 'Not enough coins.';
    final bool isMax = message.contains('MAX level');

    final Color accent = isError
        ? const Color(0xFFFF4B45)
        : isMax
        ? const Color(0xFF20C6FF)
        : const Color(0xFFFFC524);

    final IconData icon = isError
        ? Icons.error_outline_rounded
        : isMax
        ? Icons.workspace_premium_rounded
        : Icons.upgrade_rounded;

    final String title = isError
        ? 'UPGRADE FAILED'
        : isMax
        ? 'MAX LEVEL'
        : 'UPGRADE COMPLETE';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          padding: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2200),
          content: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 26 * (1 - value)),
                child: Transform.scale(
                  scale: 0.94 + (value * 0.06),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFA17364A), Color(0xFA081722)],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.82),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 14,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 28,
                    right: 28,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, accent, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.12),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.72),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.22),
                                blurRadius: 11,
                              ),
                            ],
                          ),
                          child: Icon(icon, color: accent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Color(0xFF9EB9C8),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      color: accent.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isError
                              ? Icons.close_rounded
                              : Icons.check_circle_rounded,
                          color: accent,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 5,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1, end: 0),
                      duration: const Duration(milliseconds: 2000),
                      builder: (context, value, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 2,
                            backgroundColor:
                            Colors.white.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'ARMORY SHOP',
      subtitle: 'Permanent commander upgrades',
      icon: Icons.shopping_cart_rounded,
      accent: const Color(0xFFFFC524),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF071521),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0x88FFC524),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFFFC524),
              size: 17,
            ),

            const SizedBox(width: 4),

            Text(
              '${_progress.coins}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          _UpgradeShopItem(
            icon: Icons.gps_fixed_rounded,
            title: 'WEAPON DAMAGE',
            description: 'Increase projectile damage.',
            level: _progress.damageLevel,
            cost: _progress.damageUpgradeCost(),
            isMax: _progress.damageLevel >= 20,
            accent: const Color(0xFFFF5D52),
            onTap: _upgradeDamage,
          ),

          const SizedBox(height: 10),

          _UpgradeShopItem(
            icon: Icons.speed_rounded,
            title: 'FIRE RATE',
            description: 'Increase weapon firing speed.',
            level: _progress.fireRateLevel,
            cost: _progress.fireRateUpgradeCost(),
            isMax: _progress.fireRateLevel >= 20,
            accent: const Color(0xFFFFC524),
            onTap: _upgradeFireRate,
          ),

          const SizedBox(height: 10),

          _UpgradeShopItem(
            icon: Icons.groups_rounded,
            title: 'STARTING ARMY',
            description: 'Begin missions with more troops.',
            level: _progress.armyLevel,
            cost: _progress.armyUpgradeCost(),
            isMax: _progress.armyLevel >= 20,
            accent: const Color(0xFF20C6FF),
            onTap: _upgradeArmy,
          ),

          const SizedBox(height: 10),

          _UpgradeShopItem(
            icon: Icons.favorite_rounded,
            title: 'VEHICLE HEALTH',
            description: 'Increase battlefield durability.',
            level: _progress.healthLevel,
            cost: _progress.healthUpgradeCost(),
            isMax: _progress.healthLevel >= 20,
            accent: const Color(0xFF52E59A),
            onTap: _upgradeHealth,
          ),
        ],
      ),
    );
  }
}

class _UpgradeShopItem extends StatelessWidget {
  const _UpgradeShopItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.level,
    required this.cost,
    required this.isMax,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final int level;
  final int cost;
  final bool isMax;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xF2143045),
            Color(0xF2071622),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: accent.withValues(alpha: 0.55),
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 25,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  isMax ? 'LEVEL $level • MAX' : 'LEVEL $level',
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8EA9B9),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isMax ? null : onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMax
                      ? const Color(0xFF26333B)
                      : const Color(0xFF0D2535),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isMax
                        ? const Color(0xFF4B5C66)
                        : const Color(0x88FFC524),
                  ),
                ),
                child: isMax
                    ? const Text(
                  'MAX',
                  style: TextStyle(
                    color: Color(0xFF9CB0BB),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                )
                    : Column(
                  children: [
                    const Text(
                      'UPGRADE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Color(0xFFFFC524),
                          size: 14,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          '$cost',
                          style: const TextStyle(
                            color: Color(0xFFFFD84D),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON SHEET
// ============================================================

class _SheetShell extends StatelessWidget {
  const _SheetShell({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF07131F),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(27),
          ),
          border: Border(
            top: BorderSide(
              color: Color(0xFF37627C),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 28,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            11,
            18,
            24,
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF4B6575),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.60),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: accent,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF91AEBF),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],

                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF9EB5C3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRIMARY ACTION BUTTON
// ============================================================

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = enabled
        ? accent
        : const Color(0xFF52616B);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  effectiveAccent.withValues(alpha: 0.95),
                  effectiveAccent.withValues(alpha: 0.62),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: effectiveAccent.withValues(alpha: 0.90),
              ),
              boxShadow: enabled
                  ? [
                BoxShadow(
                  color:
                  effectiveAccent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 21,
                ),

                const SizedBox(width: 9),

                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
