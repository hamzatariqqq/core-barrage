
import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_manager.dart';

import 'campaign_screen.dart';
import 'heroes_screen.dart';
import 'upgrades_screen.dart';
import 'weapons_screen.dart';
import 'progression/game_progress.dart';
import 'widgets/home_action_sheets.dart';
import 'widgets/home_animation_layer.dart';


import 'vehicles_screen.dart';

class CoreBarrageHomeScreen extends StatefulWidget {
const CoreBarrageHomeScreen({
super.key,
required this.gameScreenBuilder,
});

final WidgetBuilder gameScreenBuilder;

static const background = Color(0xFF030912);
static const panel = Color(0xF20A1A2B);
static const panelLight = Color(0xFF123552);

static const cyan = Color(0xFF20C6FF);
static const gold = Color(0xFFFFC524);
static const orange = Color(0xFFFF8D0A);
static const purple = Color(0xFFD14DFF);
static const red = Color(0xFFFF4B45);

@override
State<CoreBarrageHomeScreen> createState() =>
_CoreBarrageHomeScreenState();
}

class _CoreBarrageHomeScreenState extends State<CoreBarrageHomeScreen> {
  final GameProgress _progress = GameProgress.instance;
  final AdManager _ads = AdManager.instance;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  bool _rewardAdOpening = false;

  @override
  void initState() {
    super.initState();

    _ads.preloadAds();
    _loadBanner();
  }

  void _loadBanner() {
    final banner = _ads.createBannerAd(
      onLoaded: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _bannerLoaded = true;
        });
      },
      onFailed: (error) {
        if (!mounted) {
          return;
        }

        setState(() {
          _bannerLoaded = false;
        });
      },
    );

    _bannerAd = banner;
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: CoreBarrageHomeScreen.background,
body: SafeArea(
child: Stack(
children: [
const Positioned.fill(
child: _HomeBackground(),
),

const Positioned.fill(
child: HomeAnimationLayer(),
),

Positioned.fill(
child: IgnorePointer(
child: DecoratedBox(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.black.withValues(alpha: 0.08),
Colors.transparent,
const Color(0xFF020811)
    .withValues(alpha: 0.42),
const Color(0xFF020811)
    .withValues(alpha: 0.92),
],
stops: const [
0.0,
0.42,
0.73,
1.0,
],
),
),
),
),
),

Column(
children: [
Padding(
padding: const EdgeInsets.fromLTRB(
12,
8,
12,
0,
),
child: HomeEntranceAnimation(
delay: const Duration(milliseconds: 70),
offset: const Offset(0, -0.06),
child: _CommanderHeader(
coins: _progress.coins,
),
),
),

Expanded(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
  padding: const EdgeInsets.fromLTRB(
    12,
    8,
    12,
    165,
  ),
child: Column(
children: [
const Align(
alignment: Alignment.centerLeft,
child: HomeEntranceAnimation(
delay: Duration(milliseconds: 140),
offset: Offset(-0.06, 0),
child: _PowerCard(),
),
),

const SizedBox(height: 2),

HomeEntranceAnimation(
delay: const Duration(milliseconds: 220),
child: _HeroShowcase(
onDailyReward: _openDailyReward,
onLuckySpin: _openLuckySpin,
onMissions: _openMissions,
onShop: _openShop,
),
),

const SizedBox(height: 2),

HomeEntranceAnimation(
delay: const Duration(milliseconds: 330),
child: HomePlayPulseAnimation(
child: _PlayButton(
onPressed: _openCampaign,
),
),
),

const SizedBox(height: 8),

const HomeEntranceAnimation(
delay: Duration(milliseconds: 390),
child: _CurrentMissionCard(),
),

const SizedBox(height: 12),

  const HomeEntranceAnimation(
    delay: Duration(milliseconds: 460),
    child: _BattlePassCard(),
  ),

  const SizedBox(height: 12),

  HomeEntranceAnimation(
    delay: const Duration(milliseconds: 500),
    child: _FreeCoinsAdButton(
      loading: _rewardAdOpening,
      onPressed: _watchAdForCoins,
    ),
  ),
],
),
),
),
],
),

  if (_bannerLoaded && _bannerAd != null)
    Positioned(
      left: 0,
      right: 0,
      bottom: 82,
      child: Container(
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        color: const Color(0xFF030912),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(
            ad: _bannerAd!,
          ),
        ),
      ),
    ),

  Align(
    alignment: Alignment.bottomCenter,
    child: HomeEntranceAnimation(
      delay: const Duration(milliseconds: 520),
      offset: const Offset(0, 0.10),
      child: _BottomNavigation(
        onWeapons: _openWeapons,
        onHeroes: _openHeroes,
        onVehicles: _openVehicles,
        onUpgrades: _openUpgrades,
      ),
    ),
  ),
],
),
),
);
}

Future<void> _openCampaign() async {
await Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => CampaignScreen(
gameScreenBuilder: widget.gameScreenBuilder,
),
),
);

_refresh();
}

  void _watchAdForCoins() {
    if (_rewardAdOpening) {
      return;
    }

    if (!_ads.isRewardedReady) {
      _ads.loadRewarded();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Ad is loading. Try again in a moment.',
            ),
          ),
        );

      return;
    }

    setState(() {
      _rewardAdOpening = true;
    });

    bool rewardGranted = false;

    _ads.showRewarded(
      onRewardEarned: () {
        if (rewardGranted) {
          return;
        }

        rewardGranted = true;

        _grantAdCoins();
      },
      onClosed: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _rewardAdOpening = false;
        });
      },
    );
  }

  Future<void> _grantAdCoins() async {
    await _progress.addCoins(100);

    if (!mounted) {
      return;
    }

    setState(() {});

    _showPremiumRewardNotification(
      title: 'AD REWARD',
      message: '+100 COINS',
      icon: Icons.smart_display_rounded,
      accent: CoreBarrageHomeScreen.gold,
    );
  }

Future<void> _openWeapons() async {
await Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => const WeaponsScreen(),
),
);

_refresh();
}

Future<void> _openHeroes() async {
await Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => const HeroesScreen(),
),
);

_refresh();
}

Future<void> _openVehicles() async {
await Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => const VehiclesScreen(),
),
);

_refresh();
}
Future<void> _openUpgrades() async {
await Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => const UpgradesScreen(),
),
);

_refresh();
}

Future<void> _openDailyReward() async {
final claimed =
await HomeActionSheets.showDailyReward(context);

if (!mounted) return;

if (claimed) {
setState(() {});

_showPremiumRewardNotification(
title: 'DAILY REWARD',
message: '+300 COINS',
icon: Icons.monetization_on_rounded,
accent: CoreBarrageHomeScreen.gold,
);
}
}

Future<void> _openLuckySpin() async {
final rewarded =
await HomeActionSheets.showLuckySpin(context);

if (!mounted) return;

if (rewarded) {
setState(() {});

_showPremiumRewardNotification(
title: 'LUCKY SPIN',
message: 'REWARD COLLECTED',
icon: Icons.casino_rounded,
accent: CoreBarrageHomeScreen.purple,
);
}
}

void _openMissions() {
HomeActionSheets.showMissions(context);
}

Future<void> _openShop() async {
await HomeActionSheets.showShop(context);

if (!mounted) return;
_refresh();
}

void _showPremiumRewardNotification({
required String title,
required String message,
required IconData icon,
required Color accent,
}) {
ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
elevation: 0,
behavior: SnackBarBehavior.floating,
backgroundColor: Colors.transparent,
margin: const EdgeInsets.fromLTRB(16, 0, 16, 94),
padding: EdgeInsets.zero,
duration: const Duration(milliseconds: 2300),
content: TweenAnimationBuilder<double>(
tween: Tween(begin: 0, end: 1),
duration: const Duration(milliseconds: 420),
curve: Curves.easeOutBack,
builder: (context, value, child) {
return Transform.translate(
offset: Offset(0, 30 * (1 - value)),
child: Transform.scale(
scale: 0.92 + (value * 0.08),
child: Opacity(
opacity: value.clamp(0.0, 1.0),
child: child,
),
),
);
},
child: Container(
height: 72,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(18),
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Color(0xFA17364A),
Color(0xFA081722),
],
),
border: Border.all(
color: accent.withValues(alpha: 0.85),
width: 1.4,
),
boxShadow: [
BoxShadow(
color: accent.withValues(alpha: 0.24),
blurRadius: 20,
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
left: 30,
right: 30,
child: Container(
height: 2,
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [
Colors.transparent,
accent,
Colors.transparent,
],
),
),
),
),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 13),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: accent.withValues(alpha: 0.12),
border: Border.all(
color: accent.withValues(alpha: 0.75),
),
boxShadow: [
BoxShadow(
color: accent.withValues(alpha: 0.25),
blurRadius: 12,
),
],
),
child: Icon(
icon,
color: accent,
size: 26,
),
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
letterSpacing: 1.3,
),
),
const SizedBox(height: 4),
Text(
message,
style: TextStyle(
color: accent,
fontSize: 17,
fontWeight: FontWeight.w900,
letterSpacing: .5,
shadows: [
Shadow(
color: accent.withValues(alpha: .45),
blurRadius: 9,
),
],
),
),
],
),
),
Icon(
Icons.check_circle_rounded,
color: accent,
size: 25,
),
],
),
),
Positioned(
left: 15,
right: 15,
bottom: 5,
child: TweenAnimationBuilder<double>(
tween: Tween(begin: 1, end: 0),
duration: const Duration(milliseconds: 2100),
builder: (context, value, child) {
return ClipRRect(
borderRadius: BorderRadius.circular(20),
child: LinearProgressIndicator(
value: value,
minHeight: 2,
backgroundColor:
Colors.white.withValues(alpha: .06),
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

void _refresh() {
if (!mounted) return;
setState(() {});
}
}

// ============================================================
// BACKGROUND
// ============================================================

class _HomeBackground extends StatelessWidget {
const _HomeBackground();

@override
Widget build(BuildContext context) {
return Image.asset(
'assets/images/ui/home/hangar_bg.png',
fit: BoxFit.cover,
alignment: Alignment.topCenter,
filterQuality: FilterQuality.high,
errorBuilder: (
context,
error,
stackTrace,
) {
return const DecoratedBox(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Color(0xFF123B5B),
Color(0xFF082238),
Color(0xFF030912),
],
),
),
);
},
);
}
}

// ============================================================
// COMMANDER
// ============================================================

class _CommanderHeader extends StatelessWidget {
const _CommanderHeader({
required this.coins,
});

final int coins;

@override
Widget build(BuildContext context) {
return Container(
height: 86,
padding: const EdgeInsets.fromLTRB(
8,
8,
9,
8,
),
decoration: _premiumPanel(
radius: 18,
borderColor: const Color(0xFF477894),
),
child: Row(
children: [
Stack(
clipBehavior: Clip.none,
children: [
Container(
width: 66,
height: 66,
clipBehavior: Clip.antiAlias,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: CoreBarrageHomeScreen.cyan,
width: 2.5,
),
boxShadow: const [
BoxShadow(
color: Color(0x6620C6FF),
blurRadius: 13,
),
],
),
child: Image.asset(
'assets/images/ui/home/commander.png',
fit: BoxFit.cover,
alignment: Alignment.topCenter,
errorBuilder: (
context,
error,
stackTrace,
) {
return Container(
color: const Color(0xFF174665),
child: const Icon(
Icons.person_rounded,
color: Color(0xFF8DE5FF),
size: 46,
),
);
},
),
),

Positioned(
left: -5,
bottom: -5,
child: Container(
width: 25,
height: 25,
alignment: Alignment.center,
decoration: BoxDecoration(
color: const Color(0xFF088DEB),
shape: BoxShape.circle,
border: Border.all(
color: const Color(0xFF62DCFF),
width: 2,
),
),
child: const Text(
'8',
style: TextStyle(
color: Colors.white,
fontSize: 11,
fontWeight: FontWeight.w900,
),
),
),
),
],
),

const SizedBox(width: 11),

Expanded(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'COMMANDER',
style: TextStyle(
color: Colors.white,
fontSize: 15,
fontWeight: FontWeight.w900,
letterSpacing: 0.25,
),
),

const SizedBox(height: 6),

const Row(
children: [
Text(
'XP',
style: TextStyle(
color: Color(0xFF99BBD1),
fontSize: 9,
fontWeight: FontWeight.w900,
),
),

SizedBox(width: 9),

HomeAnimatedNumber(
value: 2350,
suffix: ' / 4,500',
style: TextStyle(
color: Color(0xFFB3C7D3),
fontSize: 9,
fontWeight: FontWeight.w800,
),
),
],
),

const SizedBox(height: 5),

const HomeAnimatedProgressBar(
progress: 2350 / 4500,
height: 7,
backgroundColor: Color(0xFF020A10),
fillColor: CoreBarrageHomeScreen.cyan,
),
],
),
),

const SizedBox(width: 8),

Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
_CurrencyChip(
icon: Icons.monetization_on_rounded,
value: coins,
accent: CoreBarrageHomeScreen.gold,
),

const SizedBox(height: 7),

const _CurrencyChip(
icon: Icons.diamond_rounded,
value: 180,
accent: CoreBarrageHomeScreen.purple,
),
],
),
],
),
);
}
}

// ============================================================
// CURRENCY
// ============================================================

class _CurrencyChip extends StatelessWidget {
const _CurrencyChip({
required this.icon,
required this.value,
required this.accent,
});

final IconData icon;
final int value;
final Color accent;

@override
Widget build(BuildContext context) {
return Container(
width: 78,
height: 29,
padding: const EdgeInsets.symmetric(
horizontal: 6,
),
decoration: BoxDecoration(
color: const Color(0xF0071019),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: accent.withValues(alpha: 0.55),
),
boxShadow: [
BoxShadow(
color: accent.withValues(alpha: 0.08),
blurRadius: 8,
),
],
),
child: Row(
children: [
Icon(
icon,
color: accent,
size: 17,
),

const SizedBox(width: 4),

Expanded(
child: HomeAnimatedNumber(
value: value,
style: const TextStyle(
color: Colors.white,
fontSize: 9,
fontWeight: FontWeight.w900,
),
),
),
],
),
);
}
}

// ============================================================
// POWER
// ============================================================

class _PowerCard extends StatelessWidget {
const _PowerCard();

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.fromLTRB(
11,
8,
18,
9,
),
decoration: _premiumPanel(
radius: 14,
borderColor: const Color(0xFF3A647D),
),
child: const Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'POWER',
style: TextStyle(
color: Color(0xFF9DB8C8),
fontSize: 8,
fontWeight: FontWeight.w900,
),
),

SizedBox(height: 2),

Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.bolt_rounded,
color: CoreBarrageHomeScreen.gold,
size: 22,
),

SizedBox(width: 2),

HomeAnimatedNumber(
value: 1250,
style: TextStyle(
color: CoreBarrageHomeScreen.gold,
fontSize: 22,
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
// HERO SHOWCASE
// ============================================================

class _HeroShowcase extends StatelessWidget {
const _HeroShowcase({
required this.onDailyReward,
required this.onLuckySpin,
required this.onMissions,
required this.onShop,
});

final VoidCallback onDailyReward;
final VoidCallback onLuckySpin;
final VoidCallback onMissions;
final VoidCallback onShop;

@override
Widget build(BuildContext context) {
return SizedBox(
height: 350,
child: Stack(
alignment: Alignment.center,
clipBehavior: Clip.none,
children: [
Positioned(
top: 37,
child: Container(
width: 250,
height: 235,
decoration: const BoxDecoration(
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Color(0x5520BFFF),
blurRadius: 70,
spreadRadius: 10,
),
],
),
),
),

Positioned(
top: 243,
child: Container(
width: 225,
height: 47,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(100),
gradient: const RadialGradient(
colors: [
Color(0x9939C9FF),
Color(0x55217FC2),
Colors.transparent,
],
),
border: Border.all(
color: const Color(0x883ACBFF),
),
boxShadow: const [
BoxShadow(
color: Color(0x3320C6FF),
blurRadius: 22,
spreadRadius: 3,
),
],
),
),
),

const Positioned(
left: 55,
bottom: 38,
child: HomeSoldierIdleAnimation(
child: _SoldierAsset(
flip: false,
),
),
),

const Positioned(
right: 55,
bottom: 38,
child: HomeSoldierIdleAnimation(
reverse: true,
child: _SoldierAsset(
flip: true,
),
),
),

Positioned(
top: 6,
child: SizedBox(
width: 295,
height: 292,
child: HomeTankIdleAnimation(
child: Image.asset(
'assets/images/ui/home/tank_showcase.png',
fit: BoxFit.contain,
filterQuality: FilterQuality.high,
errorBuilder: (
context,
error,
stackTrace,
) {
return Padding(
padding: const EdgeInsets.all(32),
child: Image.asset(
'assets/images/player/vehicle/blue_vehicle.png',
fit: BoxFit.contain,
filterQuality: FilterQuality.high,
),
);
},
),
),
),
),

Positioned(
left: 0,
top: 60,
child: _SideActionButton(
icon: Icons.card_giftcard_rounded,
text: 'DAILY\nREWARD',
accent: CoreBarrageHomeScreen.gold,
showBadge: true,
onTap: onDailyReward,
),
),

Positioned(
left: 0,
bottom: 45,
child: _SideActionButton(
icon: Icons.casino_rounded,
text: 'LUCKY\nSPIN',
accent: CoreBarrageHomeScreen.purple,
onTap: onLuckySpin,
),
),

Positioned(
right: 0,
top: 60,
child: _SideActionButton(
icon: Icons.track_changes_rounded,
text: 'MISSIONS',
accent: CoreBarrageHomeScreen.red,
showBadge: true,
onTap: onMissions,
),
),

Positioned(
right: 0,
bottom: 45,
child: _SideActionButton(
icon: Icons.shopping_cart_rounded,
text: 'SHOP',
accent: CoreBarrageHomeScreen.gold,
showBadge: true,
onTap: onShop,
),
),

const Positioned(
bottom: 4,
child: Text(
'THUNDER CANNON  •  LEVEL 1',
style: TextStyle(
color: Color(0xFF67D8FF),
fontSize: 8,
fontWeight: FontWeight.w900,
letterSpacing: 1.2,
),
),
),
],
),
);
}
}

// ============================================================
// SOLDIER
// ============================================================

class _SoldierAsset extends StatelessWidget {
const _SoldierAsset({
required this.flip,
});

final bool flip;

@override
Widget build(BuildContext context) {
Widget child = SizedBox(
width: 67,
height: 78,
child: Image.asset(
'assets/images/ui/home/home_soldier.png',
fit: BoxFit.contain,
filterQuality: FilterQuality.high,
errorBuilder: (
context,
error,
stackTrace,
) {
return const SizedBox.shrink();
},
),
);

if (flip) {
child = Transform.flip(
flipX: true,
child: child,
);
}

return child;
}
}

// ============================================================
// SIDE ACTION BUTTON
// ============================================================

class _SideActionButton extends StatelessWidget {
const _SideActionButton({
required this.icon,
required this.text,
required this.accent,
required this.onTap,
this.showBadge = false,
});

final IconData icon;
final String text;
final Color accent;
final VoidCallback onTap;
final bool showBadge;

@override
Widget build(BuildContext context) {
return HomePressAnimation(
onTap: onTap,
child: Stack(
clipBehavior: Clip.none,
children: [
Container(
width: 74,
height: 81,
decoration: BoxDecoration(
gradient: const LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Color(0xF21A3850),
Color(0xF0081521),
],
),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: accent.withValues(alpha: 0.80),
width: 1.5,
),
boxShadow: [
BoxShadow(
color: accent.withValues(alpha: 0.12),
blurRadius: 12,
),
const BoxShadow(
color: Colors.black54,
blurRadius: 8,
offset: Offset(0, 5),
),
],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
icon,
color: accent,
size: 28,
),

const SizedBox(height: 6),

Text(
text,
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.white,
fontSize: 8,
height: 1.05,
fontWeight: FontWeight.w900,
),
),
],
),
),

if (showBadge)
Positioned(
right: -5,
top: -6,
child: HomeBadgePulseAnimation(
child: Container(
width: 21,
height: 21,
alignment: Alignment.center,
decoration: BoxDecoration(
color: CoreBarrageHomeScreen.red,
shape: BoxShape.circle,
border: Border.all(
color: Colors.white,
width: 1.3,
),
boxShadow: const [
BoxShadow(
color: Color(0x99FF4B45),
blurRadius: 8,
),
],
),
child: const Text(
'!',
style: TextStyle(
color: Colors.white,
fontSize: 11,
fontWeight: FontWeight.w900,
),
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
// PLAY BUTTON
// ============================================================
class _FreeCoinsAdButton extends StatelessWidget {
  const _FreeCoinsAdButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123E55),
            Color(0xFF071B29),
          ],
        ),
        border: Border.all(
          color: CoreBarrageHomeScreen.cyan,
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3320C6FF),
            blurRadius: 14,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_display_rounded,
                  color: CoreBarrageHomeScreen.cyan,
                  size: 27,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loading
                        ? 'OPENING AD...'
                        : 'WATCH AD  •  FREE COINS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                ),
                const Icon(
                  Icons.monetization_on_rounded,
                  color: CoreBarrageHomeScreen.gold,
                  size: 22,
                ),
                const SizedBox(width: 5),
                const Text(
                  '+100',
                  style: TextStyle(
                    color: CoreBarrageHomeScreen.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

class _PlayButton extends StatelessWidget {
const _PlayButton({
required this.onPressed,
});

final VoidCallback onPressed;

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
height: 66,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(17),
gradient: const LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Color(0xFFFFE96A),
CoreBarrageHomeScreen.gold,
CoreBarrageHomeScreen.orange,
],
),
border: Border.all(
color: const Color(0xFFFFF298),
width: 2.2,
),
boxShadow: const [
BoxShadow(
color: Color(0x99FF9800),
blurRadius: 20,
offset: Offset(0, 7),
),
BoxShadow(
color: Color(0x55FFC524),
blurRadius: 30,
spreadRadius: 2,
),
],
),
child: Material(
color: Colors.transparent,
child: InkWell(
onTap: onPressed,
borderRadius: BorderRadius.circular(17),
splashColor: Colors.white.withValues(alpha: 0.22),
highlightColor: Colors.white.withValues(alpha: 0.10),
child: const Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
'❯❯',
style: TextStyle(
color: Color(0xFFFFF0A0),
fontSize: 24,
fontWeight: FontWeight.w900,
),
),

SizedBox(width: 15),

Text(
'PLAY',
style: TextStyle(
color: Color(0xFF102640),
fontSize: 29,
fontWeight: FontWeight.w900,
letterSpacing: 1.4,
),
),

SizedBox(width: 15),

Text(
'❮❮',
style: TextStyle(
color: Color(0xFFFFF0A0),
fontSize: 24,
fontWeight: FontWeight.w900,
),
),
],
),
),
),
);
}
}

// ============================================================
// CURRENT MISSION
// ============================================================

class _CurrentMissionCard extends StatelessWidget {
const _CurrentMissionCard();

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 13,
vertical: 9,
),
decoration: BoxDecoration(
color: const Color(0xF0081827),
borderRadius: BorderRadius.circular(13),
border: Border.all(
color: const Color(0xFF335B73),
),
boxShadow: const [
BoxShadow(
color: Colors.black26,
blurRadius: 8,
offset: Offset(0, 4),
),
],
),
child: const Row(
children: [
ContainerMissionIcon(),

SizedBox(width: 10),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'CURRENT MISSION',
style: TextStyle(
color: Color(0xFF83A9BE),
fontSize: 7,
fontWeight: FontWeight.w900,
letterSpacing: 0.8,
),
),

SizedBox(height: 2),

Text(
'LEVEL 1  •  FIRST ASSAULT',
style: TextStyle(
color: CoreBarrageHomeScreen.gold,
fontSize: 10,
fontWeight: FontWeight.w900,
letterSpacing: 0.5,
),
),
],
),
),

Icon(
Icons.chevron_right_rounded,
color: Color(0xFF75DFFF),
size: 23,
),
],
),
);
}
}

class ContainerMissionIcon extends StatelessWidget {
const ContainerMissionIcon({
super.key,
});

@override
Widget build(BuildContext context) {
return Container(
width: 35,
height: 35,
decoration: BoxDecoration(
color: const Color(0xFF102C40),
borderRadius: BorderRadius.circular(10),
border: Border.all(
color: CoreBarrageHomeScreen.cyan.withValues(alpha: 0.55),
),
),
child: const Icon(
Icons.flag_rounded,
color: CoreBarrageHomeScreen.cyan,
size: 19,
),
);
}
}

// ============================================================
// BATTLE PASS
// ============================================================

class _BattlePassCard extends StatelessWidget {
const _BattlePassCard();

@override
Widget build(BuildContext context) {
return Container(
height: 82,
padding: const EdgeInsets.symmetric(
horizontal: 13,
),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(18),
gradient: const LinearGradient(
begin: Alignment.centerLeft,
end: Alignment.centerRight,
colors: [
Color(0xFF6829CD),
Color(0xFF3A118F),
Color(0xFF21065E),
],
),
border: Border.all(
color: const Color(0xFFA66AFF),
width: 1.7,
),
boxShadow: const [
BoxShadow(
color: Colors.black45,
blurRadius: 12,
offset: Offset(0, 6),
),
BoxShadow(
color: Color(0x332C00A0),
blurRadius: 18,
),
],
),
child: Row(
children: [
const Icon(
Icons.workspace_premium_rounded,
color: CoreBarrageHomeScreen.gold,
size: 45,
),

const SizedBox(width: 11),

Expanded(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Row(
children: [
Text(
'BATTLE PASS',
style: TextStyle(
color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w900,
),
),

Spacer(),

Text(
'46%',
style: TextStyle(
color: Color(0xFFFFDE63),
fontSize: 9,
fontWeight: FontWeight.w900,
),
),
],
),

const Text(
'SEASON 1',
style: TextStyle(
color: Color(0xFFD7C5FF),
fontSize: 8,
fontWeight: FontWeight.w700,
),
),

const SizedBox(height: 7),

const HomeAnimatedProgressBar(
progress: 0.46,
height: 8,
backgroundColor: Color(0xFF16063C),
fillColor: CoreBarrageHomeScreen.gold,
),
],
),
),

const SizedBox(width: 13),

const Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
'TIER',
style: TextStyle(
color: Color(0xFFD7C5FF),
fontSize: 7,
fontWeight: FontWeight.w800,
),
),

HomeAnimatedNumber(
value: 12,
style: TextStyle(
color: Colors.white,
fontSize: 20,
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
// BOTTOM NAVIGATION
// ============================================================

class _BottomNavigation extends StatelessWidget {
const _BottomNavigation({
required this.onWeapons,
required this.onHeroes,
required this.onVehicles,
required this.onUpgrades,
});

final VoidCallback onWeapons;
final VoidCallback onHeroes;
final VoidCallback onVehicles;
final VoidCallback onUpgrades;

@override
Widget build(BuildContext context) {
return Container(
height: 82,
decoration: const BoxDecoration(
color: Color(0xFC05131F),
border: Border(
top: BorderSide(
color: Color(0xFF2A5068),
),
),
boxShadow: [
BoxShadow(
color: Colors.black54,
blurRadius: 14,
offset: Offset(0, -4),
),
],
),
child: Row(
children: [
const Expanded(
child: _NavigationItem(
icon: Icons.home_rounded,
text: 'HOME',
selected: true,
),
),
Expanded(
child: _NavigationItem(
icon: Icons.gps_fixed_rounded,
text: 'WEAPONS',
onTap: onWeapons,
),
),
Expanded(
child: _NavigationItem(
icon: Icons.groups_rounded,
text: 'HEROES',
onTap: onHeroes,
),
),
Expanded(
child: _NavigationItem(
icon: Icons.directions_car_filled_rounded,
text: 'VEHICLES',
onTap: onVehicles,
),
),
Expanded(
child: _NavigationItem(
icon: Icons.upgrade_rounded,
text: 'UPGRADES',
onTap: onUpgrades,
),
),
],
),
);
}
}

class _NavigationItem extends StatelessWidget {
const _NavigationItem({
required this.icon,
required this.text,
this.selected = false,
this.onTap,
});

final IconData icon;
final String text;
final bool selected;
final VoidCallback? onTap;

@override
Widget build(BuildContext context) {
final color = selected
? CoreBarrageHomeScreen.cyan
    : const Color(0xFF899BA8);

final content = Stack(
alignment: Alignment.center,
children: [
if (selected)
const Positioned(
top: 0,
child: SizedBox(
width: 38,
height: 3,
child: DecoratedBox(
decoration: BoxDecoration(
color: CoreBarrageHomeScreen.cyan,
boxShadow: [
BoxShadow(
color: Color(0xAA20C6FF),
blurRadius: 9,
),
],
),
),
),
),

Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
icon,
color: color,
size: selected ? 27 : 25,
),

const SizedBox(height: 4),

Text(
text,
style: TextStyle(
color: color,
fontSize: 7,
fontWeight: FontWeight.w900,
),
),
],
),
],
);

if (onTap == null) {
return content;
}

return HomePressAnimation(
onTap: onTap!,
child: content,
);
}
}

// ============================================================
// SHARED PANEL
// ============================================================

BoxDecoration _premiumPanel({
required double radius,
required Color borderColor,
}) {
return BoxDecoration(
borderRadius: BorderRadius.circular(radius),
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
CoreBarrageHomeScreen.panelLight,
CoreBarrageHomeScreen.panel,
Color(0xF205111B),
],
),
border: Border.all(
color: borderColor,
width: 1.3,
),
boxShadow: const [
BoxShadow(
color: Colors.black45,
blurRadius: 12,
offset: Offset(0, 5),
),
],
);
}
