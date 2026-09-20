import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'levels/level_catalog.dart';
import 'progression/game_progress.dart';
import 'progression/level_progress.dart';
import 'progression/selected_level.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({
    super.key,
    required this.gameScreenBuilder,
  });

  final WidgetBuilder gameScreenBuilder;

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen>
    with SingleTickerProviderStateMixin {
  final LevelProgress levelProgress = LevelProgress.instance;
  final GameProgress gameProgress = GameProgress.instance;

  late final AnimationController _pulseController;

  bool _loading = true;
  bool _startingBattle = false;

  int _selectedLevel = 1;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..repeat(reverse: true);

    _loadProgress();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    await Future.wait([
      levelProgress.load(),
      gameProgress.load(),
    ]);

    if (!mounted) return;

    final highest = levelProgress.highestUnlockedLevel.clamp(
      1,
      LevelCatalog.totalLevels,
    );

    setState(() {
      _loading = false;

      if (!levelProgress.isLevelUnlocked(_selectedLevel)) {
        _selectedLevel = highest;
      } else if (_selectedLevel == 1 && highest > 1) {
        _selectedLevel = highest;
      }
    });
  }

  LevelDefinition get _selectedMission {
    return LevelCatalog.getLevel(_selectedLevel);
  }

  int get _completedLevels {
    int completed = 0;

    for (final level in LevelCatalog.levels) {
      if (levelProgress.isLevelCompleted(level.level)) {
        completed++;
      }
    }

    return completed;
  }

  int get _totalStars {
    int stars = 0;

    for (final level in LevelCatalog.levels) {
      stars += levelProgress.starsForLevel(level.level);
    }

    return stars;
  }

  Future<void> _startSelectedLevel() async {
    if (_startingBattle) return;

    if (!levelProgress.isLevelUnlocked(_selectedLevel)) {
      return;
    }

    setState(() {
      _startingBattle = true;
    });

    SelectedLevel.select(_selectedLevel);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: widget.gameScreenBuilder,
      ),
    );

    if (!mounted) return;

    setState(() {
      _startingBattle = false;
    });

    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B11),
      body: SafeArea(
        child: _loading
            ? const _CampaignLoadingView()
            : Column(
          children: [
            _buildHeader(),
            _buildChapterBar(),
            Expanded(
              child: _buildCampaignMap(),
            ),
            _buildMissionPanel(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 5),
      padding: const EdgeInsets.symmetric(horizontal: 9),
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
          _HeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CAMPAIGN',
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
                  'DESERT FRONTIER',
                  style: TextStyle(
                    color: Color(0xFF6ECDF7),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),

          _CoinDisplay(
            value: gameProgress.coins,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHAPTER BAR
  // ============================================================

  Widget _buildChapterBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0E3452),
            Color(0xFF0A253B),
          ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF2B6D96),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_rounded,
            color: Color(0xFFFFC82F),
            size: 22,
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHAPTER 1 • DESERT FRONTIER',
                  style: TextStyle(
                    color: Color(0xFFFFD239),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .35,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '15 TACTICAL OPERATIONS',
                  style: TextStyle(
                    color: Color(0xFF72A9C8),
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          _ChapterStat(
            icon: Icons.check_circle_rounded,
            value: '$_completedLevels/15',
            color: const Color(0xFF53E58C),
          ),

          const SizedBox(width: 7),

          _ChapterStat(
            icon: Icons.star_rounded,
            value: '$_totalStars/45',
            color: const Color(0xFFFFC82F),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAMPAIGN MAP
  // ============================================================

  Widget _buildCampaignMap() {
    const mapHeight = 1710.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF263D4D),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final points = _createLevelPositions(
                  constraints.maxWidth,
                  mapHeight,
                );

                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CampaignMapPainter(
                          points: points,
                        ),
                      ),
                    ),

                    // ----------------------------------------------------
                    // REGION LABELS
                    // ----------------------------------------------------

                    const Positioned(
                      left: 13,
                      bottom: 405,
                      child: _RegionLabel(
                        icon: Icons.flag_rounded,
                        title: 'DESERT OUTPOST',
                        subtitle: 'FRONT LINE',
                        color: Color(0xFF50D4FF),
                      ),
                    ),

                    const Positioned(
                      right: 12,
                      bottom: 840,
                      child: _RegionLabel(
                        icon: Icons.local_fire_department_rounded,
                        title: 'WAR ZONE',
                        subtitle: 'HIGH RISK',
                        color: Color(0xFFFF9D3A),
                      ),
                    ),

                    const Positioned(
                      left: 13,
                      top: 420,
                      child: _RegionLabel(
                        icon: Icons.security_rounded,
                        title: 'FORTRESS SECTOR',
                        subtitle: 'ELITE ENEMIES',
                        color: Color(0xFFA768FF),
                      ),
                    ),

                    const Positioned(
                      right: 12,
                      top: 70,
                      child: _RegionLabel(
                        icon: Icons.warning_rounded,
                        title: 'WARDEN DOMAIN',
                        subtitle: 'EXTREME DANGER',
                        color: Color(0xFFFF5148),
                      ),
                    ),

                    // ----------------------------------------------------
                    // LEVEL NODES
                    // ----------------------------------------------------

                    for (
                    int index = 0;
                    index < LevelCatalog.levels.length;
                    index++
                    )
                      _buildLevelNode(
                        definition: LevelCatalog.levels[index],
                        position: points[index],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Offset> _createLevelPositions(
      double width,
      double height,
      ) {
    final center = width / 2;
    final left = width * .27;
    final right = width * .73;

    return [
      Offset(center, height - 95),
      Offset(right, height - 205),
      Offset(center, height - 315),
      Offset(left, height - 425),
      Offset(center, height - 545),

      Offset(right, height - 665),
      Offset(center, height - 775),
      Offset(left, height - 885),
      Offset(center, height - 995),
      Offset(right, height - 1115),

      Offset(center, height - 1235),
      Offset(left, height - 1345),
      Offset(center, height - 1455),
      Offset(right, height - 1560),
      Offset(center, height - 1655),
    ];
  }

  // ============================================================
  // LEVEL NODE
  // ============================================================

  Widget _buildLevelNode({
    required LevelDefinition definition,
    required Offset position,
  }) {
    final unlocked = levelProgress.isLevelUnlocked(
      definition.level,
    );

    final completed = levelProgress.isLevelCompleted(
      definition.level,
    );

    final stars = levelProgress.starsForLevel(
      definition.level,
    );

    final selected = definition.level == _selectedLevel;
    final boss = definition.bossLevel;

    final nodeSize = boss ? 88.0 : 72.0;

    return Positioned(
      left: position.dx - nodeSize / 2,
      top: position.dy - nodeSize / 2,
      child: GestureDetector(
        onTap: () {
          if (!unlocked) {
            _showLockedMessage(definition.level);
            return;
          }

          setState(() {
            _selectedLevel = definition.level;
          });
        },
        child: SizedBox(
          width: nodeSize,
          height: nodeSize + 39,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = selected
                      ? 1 + (_pulseController.value * .055)
                      : 1.0;

                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (selected)
                          Container(
                            width: nodeSize + 13,
                            height: nodeSize + 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFD23D),
                                width: 2.3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xAAFFC229),
                                  blurRadius: 22,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),

                        Container(
                          width: nodeSize,
                          height: nodeSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: unlocked
                                ? RadialGradient(
                              center: const Alignment(
                                -.25,
                                -.35,
                              ),
                              radius: .95,
                              colors: [
                                Colors.white.withValues(
                                  alpha: .32,
                                ),
                                definition.accent,
                                definition.accent.withValues(
                                  alpha: .55,
                                ),
                                const Color(0xFF0B1520),
                              ],
                            )
                                : const RadialGradient(
                              colors: [
                                Color(0xFF53606A),
                                Color(0xFF2A353E),
                                Color(0xFF10171D),
                              ],
                            ),
                            border: Border.all(
                              color: unlocked
                                  ? Colors.white.withValues(alpha: .72)
                                  : const Color(0xFF69747E),
                              width: boss ? 3 : 2,
                            ),
                            boxShadow: unlocked
                                ? [
                              BoxShadow(
                                color:
                                definition.accent.withValues(
                                  alpha: .38,
                                ),
                                blurRadius: 17,
                              ),
                            ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (boss)
                                Positioned(
                                  top: 7,
                                  child: Icon(
                                    Icons.warning_rounded,
                                    color: unlocked
                                        ? const Color(0xFFFFD84A)
                                        : const Color(0xFF929BA2),
                                    size: 15,
                                  ),
                                ),

                              Icon(
                                unlocked
                                    ? definition.icon
                                    : Icons.lock_rounded,
                                color: unlocked
                                    ? Colors.white
                                    : const Color(0xFFA7B0B6),
                                size: boss ? 34 : 29,
                              ),

                              Positioned(
                                bottom: boss ? 7 : 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xD7070C11),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${definition.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (completed)
                          const Positioned(
                            left: -2,
                            top: -2,
                            child: _CompletedBadge(),
                          ),

                        if (boss)
                          Positioned(
                            right: -3,
                            bottom: -2,
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD72F2F),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFF8175),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.dangerous_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 3),

              if (completed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                        (index) {
                      return Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: index < stars
                            ? const Color(0xFFFFCD31)
                            : const Color(0xFF4C565E),
                      );
                    },
                  ),
                )
              else
                Text(
                  unlocked ? 'READY' : 'LOCKED',
                  style: TextStyle(
                    color: unlocked
                        ? definition.accent
                        : const Color(0xFF78848C),
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedMessage(int level) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        backgroundColor: const Color(0xFF102535),
        content: Row(
          children: [
            const Icon(
              Icons.lock_rounded,
              color: Color(0xFFFFC82F),
              size: 19,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Complete Level ${level - 1} to unlock this operation.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MISSION PANEL
  // ============================================================

  Widget _buildMissionPanel() {
    final mission = _selectedMission;

    final unlocked = levelProgress.isLevelUnlocked(
      mission.level,
    );

    final stars = levelProgress.starsForLevel(
      mission.level,
    );

    final completed = levelProgress.isLevelCompleted(
      mission.level,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 5, 8, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF153B59),
            Color(0xFF0A253A),
            Color(0xFF071722),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: mission.accent.withValues(alpha: .60),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mission.accent.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: mission.accent,
                  ),
                ),
                child: Icon(
                  mission.icon,
                  color: mission.accent,
                  size: 27,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'LEVEL ${mission.level}',
                          style: TextStyle(
                            color: mission.accent,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),

                        if (completed) ...[
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF51E482),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Color(0xFF51E482),
                              fontSize: 6,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),

                    Text(
                      mission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      mission.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF90B0C4),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ),

              if (mission.bossLevel)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFB81923),
                        Color(0xFF6C1117),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF6159),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'BOSS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .8,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _MissionStat(
                  label: 'DIFFICULTY',
                  value: '${mission.difficulty}/10',
                  icon: Icons.bolt_rounded,
                  color: _difficultyColor(
                    mission.difficulty,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _MissionStat(
                  label: 'REWARD',
                  value: '${mission.reward}',
                  icon: Icons.monetization_on_rounded,
                  color: const Color(0xFFFFCD32),
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _MissionStat(
                  label: 'RATING',
                  value: completed ? '$stars / 3' : '—',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFC72C),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0x99030C14),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: const Color(0x332D6C91),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  unlocked
                      ? Icons.assignment_rounded
                      : Icons.lock_rounded,
                  color: unlocked
                      ? mission.accent
                      : const Color(0xFF7D8991),
                  size: 15,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    unlocked
                        ? mission.description
                        : 'Complete the previous operation to unlock this mission.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CB6C6),
                      fontSize: 8,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: unlocked && !_startingBattle
                  ? _startSelectedLevel
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFB913),
                disabledBackgroundColor: const Color(0xFF3C464D),
                foregroundColor: const Color(0xFF162637),
                disabledForegroundColor: const Color(0xFF929BA1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                  side: BorderSide(
                    color: unlocked
                        ? const Color(0xFFFFE16B)
                        : const Color(0xFF616A70),
                    width: 2,
                  ),
                ),
                elevation: unlocked ? 8 : 0,
                shadowColor: const Color(0x99FF9900),
              ),
              child: _startingBattle
                  ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF162637),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked
                        ? Icons.play_arrow_rounded
                        : Icons.lock_rounded,
                    size: 24,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    !unlocked
                        ? 'LOCKED'
                        : completed
                        ? 'REPLAY BATTLE'
                        : mission.bossLevel
                        ? 'START BOSS BATTLE'
                        : 'START BATTLE',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
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

  Color _difficultyColor(int difficulty) {
    if (difficulty >= 8) {
      return const Color(0xFFFF5148);
    }

    if (difficulty >= 5) {
      return const Color(0xFFFFA536);
    }

    return const Color(0xFF51E482);
  }
}

// ============================================================
// LOADING
// ============================================================

class _CampaignLoadingView extends StatelessWidget {
  const _CampaignLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFFFFC82F),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'LOADING CAMPAIGN...',
            style: TextStyle(
              color: Color(0xFF8EB4C9),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HEADER BUTTON
// ============================================================

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COIN DISPLAY
// ============================================================

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
// CHAPTER STAT
// ============================================================

class _ChapterStat extends StatelessWidget {
  const _ChapterStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0x77040F17),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMPLETED BADGE
// ============================================================

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF1C9B57),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF82FFB7),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5518FF80),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}

// ============================================================
// REGION LABEL
// ============================================================

class _RegionLabel extends StatelessWidget {
  const _RegionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xC3071016),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: .55),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),

          const SizedBox(width: 6),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF95A5AE),
                  fontSize: 6,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
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
// MISSION STAT
// ============================================================

class _MissionStat extends StatelessWidget {
  const _MissionStat({
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
      height: 43,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xA907141E),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFF29495D),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7691A1),
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
// CAMPAIGN MAP PAINTER
// ============================================================

class _CampaignMapPainter extends CustomPainter {
  const _CampaignMapPainter({
    required this.points,
  });

  final List<Offset> points;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final rect = Offset.zero & size;

    // ==========================================================
    // DESERT BASE
    // ==========================================================

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3B211B),
            Color(0xFF60351F),
            Color(0xFF8D4E29),
            Color(0xFFB66C35),
            Color(0xFF8E4C29),
          ],
        ).createShader(rect),
    );

    // ==========================================================
    // DESERT LIGHT
    // ==========================================================

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, .15),
          radius: 1,
          colors: [
            Color(0x2AFFD66E),
            Colors.transparent,
            Color(0x9906090B),
          ],
          stops: [
            0,
            .55,
            1,
          ],
        ).createShader(rect),
    );

    // ==========================================================
    // SIDE CLIFFS
    // ==========================================================

    final cliffLight = Paint()
      ..color = const Color(0xFF844B2B);

    final cliffDark = Paint()
      ..color = const Color(0xFF4F2D22);

    for (int i = 0; i < 13; i++) {
      final y = 30.0 + i * 137;
      final amount = 38.0 + (i % 4) * 8;

      canvas.drawOval(
        Rect.fromLTWH(
          -28,
          y,
          amount + 58,
          72,
        ),
        i.isEven ? cliffLight : cliffDark,
      );

      canvas.drawOval(
        Rect.fromLTWH(
          size.width - amount - 28,
          y + 50,
          amount + 57,
          78,
        ),
        i.isEven ? cliffDark : cliffLight,
      );
    }

    // ==========================================================
    // ROAD
    // ==========================================================

    if (points.length >= 2) {
      final road = Path();

      road.moveTo(
        points.first.dx,
        points.first.dy,
      );

      for (int i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final current = points[i];

        final middleY =
            (previous.dy + current.dy) / 2;

        road.cubicTo(
          previous.dx,
          middleY,
          current.dx,
          middleY,
          current.dx,
          current.dy,
        );
      }

      // Outer shadow.
      canvas.drawPath(
        road,
        Paint()
          ..color = const Color(0xCC161413)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 39
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Road border.
      canvas.drawPath(
        road,
        Paint()
          ..color = const Color(0xFF34312E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 31
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Road surface.
      canvas.drawPath(
        road,
        Paint()
          ..color = const Color(0xFF5D5851)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 25
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Road highlight.
      canvas.drawPath(
        road,
        Paint()
          ..color = const Color(0x44FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );

      // Center tactical line.
      canvas.drawPath(
        road,
        Paint()
          ..color = const Color(0xFFD8B05C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // ==========================================================
    // NODE SHADOWS
    // ==========================================================

    for (final point in points) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            point.dx,
            point.dy + 24,
          ),
          width: 72,
          height: 20,
        ),
        Paint()
          ..color = Colors.black.withValues(
            alpha: .27,
          ),
      );
    }

    // ==========================================================
    // DESERT DETAILS
    // ==========================================================

    final random = math.Random(92);

    for (int i = 0; i < 90; i++) {
      final x =
          random.nextDouble() * size.width;

      final y =
          random.nextDouble() * size.height;

      final radius =
          1.3 + random.nextDouble() * 4;

      final color = i.isEven
          ? const Color(0x6650251A)
          : const Color(0x556C4124);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = color,
      );
    }

    // ==========================================================
    // SMALL TACTICAL MARKERS
    // ==========================================================

    final markerPaint = Paint()
      ..color = const Color(0x3359CFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 7; i++) {
      final x = 35.0 + (i % 2) * (size.width - 70);
      final y = 180.0 + i * 215;

      canvas.drawCircle(
        Offset(x, y),
        7,
        markerPaint,
      );

      canvas.drawLine(
        Offset(x - 10, y),
        Offset(x + 10, y),
        markerPaint,
      );

      canvas.drawLine(
        Offset(x, y - 10),
        Offset(x, y + 10),
        markerPaint,
      );
    }

    // ==========================================================
    // VIGNETTE
    // ==========================================================

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: .92,
          colors: [
            Colors.transparent,
            Color(0xB001070B),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(
      covariant _CampaignMapPainter oldDelegate,
      ) {
    return false;
  }
}