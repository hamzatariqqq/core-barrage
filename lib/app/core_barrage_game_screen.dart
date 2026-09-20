import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/core_barrage_game.dart';
import '../services/ad_manager.dart';
import 'progression/selected_level.dart';

// ============================================================
// CORE BARRAGE GAME SCREEN
// ============================================================

class CoreBarrageGameScreen extends StatefulWidget {
  const CoreBarrageGameScreen({
    super.key,
  });

  @override
  State<CoreBarrageGameScreen> createState() =>
      _CoreBarrageGameScreenState();
}

class _CoreBarrageGameScreenState
    extends State<CoreBarrageGameScreen> {
  late final CoreBarrageGame game;

  @override
  void initState() {
    super.initState();
    game = CoreBarrageGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071119),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // FLAME GAME
          // ======================================================

          GameWidget<CoreBarrageGame>(
            game: game,
            loadingBuilder: (context) {
              return const _DeployingScreen();
            },
            overlayBuilderMap: {
              'pause': (
                  BuildContext context,
                  CoreBarrageGame game,
                  ) {
                return PauseMenu(
                  game: game,
                );
              },

              'victory': (
                  BuildContext context,
                  CoreBarrageGame game,
                  ) {
                return _ResultAdGate(
                  game: game,
                  child: VictoryMenu(
                    game: game,
                  ),
                );
              },

              'defeat': (
                  BuildContext context,
                  CoreBarrageGame game,
                  ) {
                return _ResultAdGate(
                  game: game,
                  child: DefeatMenu(
                    game: game,
                  ),
                );
              },
            },
          ),

          // ======================================================
          // MOBILE TOUCH LAYER
          // ======================================================
          //
          // IMPORTANT:
          // These invisible Flutter controls sit ABOVE Flame.
          // This makes taps much more reliable on real phones.
          //

          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ------------------------------------------------
                // PAUSE
                // ------------------------------------------------

                Positioned(
                  left: 0,
                  top: 0,
                  width: 95,
                  height: 100,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      game.pauseGame();
                    },
                    child: const ColoredBox(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // ------------------------------------------------
                // MISSILE
                // ------------------------------------------------

                Positioned(
                  left: 0,
                  bottom: 0,
                  width: 125,
                  height: 135,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      game.activateMissile();
                    },
                    child: const ColoredBox(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // ------------------------------------------------
                // FREEZE
                // ------------------------------------------------

                Positioned(
                  right: 0,
                  bottom: 0,
                  width: 125,
                  height: 135,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      game.activateFreeze();
                    },
                    child: const ColoredBox(
                      color: Colors.transparent,
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
// RESULT AD GATE
// ============================================================

class _ResultAdGate extends StatefulWidget {
  const _ResultAdGate({
    required this.game,
    required this.child,
  });

  final CoreBarrageGame game;
  final Widget child;

  @override
  State<_ResultAdGate> createState() =>
      _ResultAdGateState();
}

class _ResultAdGateState
    extends State<_ResultAdGate> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _showResultAd();
      },
    );
  }

  void _showResultAd() {
    if (_handled) return;

    _handled = true;

    // Interstitial only after Levels 11–15.
    if (widget.game.currentLevel <= 10) {
      return;
    }

    AdManager.instance.showInterstitialAfterLevel(
      level: widget.game.currentLevel,
      onFinished: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ============================================================
// DEPLOYING SCREEN
// ============================================================

class _DeployingScreen extends StatelessWidget {
  const _DeployingScreen();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF061018),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF39CFFF),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'DEPLOYING...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.3,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'PREPARING BATTLEFIELD',
              style: TextStyle(
                color: Color(0xFF6F9EB7),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAUSE MENU
// ============================================================

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    required this.game,
  });

  final CoreBarrageGame game;

  @override
  Widget build(BuildContext context) {
    return _GameOverlay(
      accent: const Color(0xFF31CFFF),
      child: _GameDialog(
        accent: const Color(0xFF31CFFF),
        icon: Icons.pause_rounded,
        eyebrow: 'TACTICAL CONTROL',
        title: 'PAUSED',
        subtitle: 'BATTLEFIELD SYSTEMS ON HOLD',
        children: [
          _InfoCard(
            icon: Icons.shield_outlined,
            accent: const Color(0xFF31CFFF),
            title: 'MISSION ${game.currentLevel}',
            text: 'Your current battle progress is paused.',
          ),

          const SizedBox(height: 20),

          _MainButton(
            text: 'RESUME BATTLE',
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF078EF5),
            onPressed: game.resumeGame,
          ),

          const SizedBox(height: 11),

          _GameButton(
            text: 'RESTART LEVEL',
            icon: Icons.refresh_rounded,
            color: const Color(0xFFFF9A28),
            onPressed: game.restartFromPause,
          ),

          const SizedBox(height: 11),

          _GameButton(
            text: 'BACK TO HOME',
            icon: Icons.home_rounded,
            color: const Color(0xFF375567),
            onPressed: () {
              game.resumeEngine();

              Navigator.of(context).popUntil(
                    (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VICTORY MENU
// ============================================================

class VictoryMenu extends StatelessWidget {
  const VictoryMenu({
    super.key,
    required this.game,
  });

  final CoreBarrageGame game;

  @override
  Widget build(BuildContext context) {
    final campaignComplete =
        game.currentLevel >= 15;

    final nextLevel =
        game.currentLevel + 1;

    return _GameOverlay(
      accent: const Color(0xFF25D7FF),
      child: _GameDialog(
        accent: const Color(0xFF25D7FF),
        icon: campaignComplete
            ? Icons.military_tech_rounded
            : Icons.emoji_events_rounded,
        eyebrow: campaignComplete
            ? 'OPERATION COMPLETE'
            : 'MISSION ACCOMPLISHED',
        title: campaignComplete
            ? 'CAMPAIGN\nCOMPLETE'
            : 'VICTORY',
        subtitle: campaignComplete
            ? 'ALL 15 OPERATIONS CLEARED'
            : 'ENEMY FORCES NEUTRALIZED',
        children: [
          const _VictoryStars(),

          const SizedBox(height: 18),

          _RewardPanel(
            reward: game.victoryReward,
          ),

          const SizedBox(height: 18),

          if (!campaignComplete) ...[
            _MainButton(
              text: 'NEXT LEVEL  •  $nextLevel',
              icon: Icons.arrow_forward_rounded,
              color: const Color(0xFF20C86B),
              onPressed: () {
                SelectedLevel.select(
                  nextLevel,
                );

                game.overlays.remove(
                  'victory',
                );

                game.resumeEngine();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                    const CoreBarrageGameScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 11),
          ],

          _GameButton(
            text: 'PLAY AGAIN',
            icon: Icons.replay_rounded,
            color: const Color(0xFF078EF5),
            onPressed: game.restartLevel,
          ),

          const SizedBox(height: 11),

          _GameButton(
            text: 'BACK TO HOME',
            icon: Icons.home_rounded,
            color: const Color(0xFF375567),
            onPressed: () {
              game.resumeEngine();

              Navigator.of(context).popUntil(
                    (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DEFEAT MENU
// ============================================================

class DefeatMenu extends StatelessWidget {
  const DefeatMenu({
    super.key,
    required this.game,
  });

  final CoreBarrageGame game;

  @override
  Widget build(BuildContext context) {
    return _GameOverlay(
      accent: const Color(0xFFFF554D),
      child: _GameDialog(
        accent: const Color(0xFFFF554D),
        icon: Icons.warning_amber_rounded,
        eyebrow: 'COMBAT REPORT',
        title: 'MISSION\nFAILED',
        subtitle: 'YOUR SQUAD WAS OVERRUN',
        children: [
          _InfoCard(
            icon: Icons.shield_outlined,
            accent: const Color(0xFFFF554D),
            title: 'LEVEL ${game.currentLevel}',
            text:
            'Regroup, upgrade your squad and redeploy.',
          ),

          const SizedBox(height: 20),

          _MainButton(
            text: 'REDEPLOY',
            icon: Icons.refresh_rounded,
            color: const Color(0xFFFF574B),
            onPressed: game.restartLevel,
          ),

          const SizedBox(height: 11),

          _GameButton(
            text: 'BACK TO HOME',
            icon: Icons.home_rounded,
            color: const Color(0xFF375567),
            onPressed: () {
              game.resumeEngine();

              Navigator.of(context).popUntil(
                    (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OVERLAY BACKGROUND
// ============================================================

class _GameOverlay extends StatelessWidget {
  const _GameOverlay({
    required this.accent,
    required this.child,
  });

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.black.withValues(
                  alpha: .72,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center:
                    const Alignment(0, -.25),
                    radius: 1.1,
                    colors: [
                      accent.withValues(
                        alpha: .17,
                      ),
                      const Color(0xE607131B),
                      const Color(0xF503080D),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GAME DIALOG
// ============================================================

class _GameDialog extends StatelessWidget {
  const _GameDialog({
    required this.accent,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final Color accent;
  final IconData icon;

  final String eyebrow;
  final String title;
  final String subtitle;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 390,
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFA173444),
            Color(0xFD0A1B25),
            Color(0xFF050C12),
          ],
        ),
        borderRadius: BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color: accent.withValues(
            alpha: .65,
          ),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(
              alpha: .15,
            ),
            blurRadius: 35,
          ),
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 35,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 13),

          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(
                alpha: .10,
              ),
              border: Border.all(
                color: accent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(
                    alpha: .25,
                  ),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: accent,
              size: 40,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: .96,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent.withValues(
                alpha: .90,
              ),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          ...children,

          const SizedBox(height: 16),

          const Text(
            'CORE BARRAGE',
            style: TextStyle(
              color: Color(0xFF57798B),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO CARD
// ============================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0x99101F28),
        borderRadius: BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color: accent.withValues(
            alpha: .30,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: .10,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

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

                const SizedBox(height: 4),

                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF91AAB7),
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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
// VICTORY STARS
// ============================================================

class _VictoryStars extends StatelessWidget {
  const _VictoryStars();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Text(
          '★',
          style: TextStyle(
            color: Color(0xFFFFD632),
            fontSize: 34,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '★',
          style: TextStyle(
            color: Color(0xFFFFD632),
            fontSize: 51,
          ),
        ),
        SizedBox(width: 8),
        Text(
          '★',
          style: TextStyle(
            color: Color(0xFFFFD632),
            fontSize: 34,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// REWARD PANEL
// ============================================================

class _RewardPanel extends StatelessWidget {
  const _RewardPanel({
    required this.reward,
  });

  final int reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123749),
            Color(0xFF091D29),
          ],
        ),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: const Color(0xFF39738E),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'MISSION REWARD',
            style: TextStyle(
              color: Color(0xFF8DE6FF),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: Color(0xFFFFD63E),
                size: 32,
              ),

              const SizedBox(width: 9),

              Text(
                '+$reward',
                style: const TextStyle(
                  color: Color(0xFFFFD63E),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'COINS SECURED',
            style: TextStyle(
              color: Color(0xFF718F9F),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIMARY BUTTON
// ============================================================

class _MainButton extends StatelessWidget {
  const _MainButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 23,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECONDARY BUTTON
// ============================================================

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 21,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(
            alpha: .80,
          ),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
            side: BorderSide(
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}