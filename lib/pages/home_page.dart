import 'dart:io' show Platform;
import 'package:auto_revop/widgets/bottom_nav_bar.dart';
import 'package:auto_revop/widgets/cart_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mechanics_page.dart';
import 'spare_parts_page.dart';
import 'bookings_page.dart';
import 'profile_page.dart';
import 'detailing_page.dart';
import '../providers/translation_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLanguageName = localeProvider.currentLanguageName;

    final List<Widget> pages = [
      _buildHomeContent(),
      MechanicsPage(),
      SparePartsPage(),
      BookingsPage(),
      ProfilePage(),
    ];

    return Platform.isIOS
        ? CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: localeProvider.translate('home'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.wrench),
                  label: localeProvider.translate('mechanicsPage'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.car_detailed),
                  label: localeProvider.translate('partsPage'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar),
                  label: localeProvider.translate('bookingsPage'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person),
                  label: localeProvider.translate('profilePage'),
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoTabView(
                builder: (context) {
                  return Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      final currentLanguageName = localeProvider.currentLanguageName;
                      return CupertinoPageScaffold(
                        navigationBar: CupertinoNavigationBar(
                          middle: Text(
                            'Auto RevOp🔧',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label,
                            ),
                          ),
                          leading: const CartIconButton(),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                              ), // Add spacing between title and language selector
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) => Container(
                                      height: 250,
                                      color: CupertinoColors.systemBackground,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 50,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: CupertinoColors.separator,
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                Text(
                                                  'Select Language',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: CupertinoColors.label,
                                                  ),
                                                ),
                                                const SizedBox(width: 60), // Balance the layout
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 44.0,
                                              onSelectedItemChanged: (int index) async {
                                                final selectedLangCode = LocaleProvider.supportedLanguages[index];
                                                final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                                                await localeProvider.setLocale(selectedLangCode);
                                                // Provider will notify listeners automatically
                                              },
                                              children: LocaleProvider.supportedLanguages.map((langCode) {
                                                final localeProvider = Provider.of<LocaleProvider>(context);
                                                final isSelected = localeProvider.locale.languageCode == langCode;
                                                final langName = localeProvider.getLanguageName(langCode);
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        _getFlagEmojiForCode(langCode),
                                                        style: const TextStyle(fontSize: 20),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        langName,
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.label,
                                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                        ),
                                                      ),
                                                      if (isSelected) ...[
                                                        const Spacer(),
                                                        Icon(
                                                          CupertinoIcons.checkmark,
                                                          color: CupertinoColors.activeBlue,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  currentLanguageName,
                                  style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: CupertinoColors.systemGrey,
                                backgroundImage: AssetImage(
                                  'assets/profile_image.png',
                                ),
                              ),
                            ],
                          ),
                        ),
                        backgroundColor: CupertinoColors.white, // force white
                        child: Container(
                          color: CupertinoColors.white,
                          child: pages[index],
                        ),
                      );
                    },
                  );
                },
              );
            },
          )
        : WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Auto RevOp🔧',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                centerTitle: false,
                leading: const CartIconButton(),
                actions: [
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      final currentLanguageName = localeProvider.currentLanguageName;
                      return Center(
                        child: DropdownButton<String>(
                          value: currentLanguageName,
                          icon: const Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.grey),
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          underline: Container(height: 2, color: const Color.fromRGBO(17, 131, 192, 1)),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                              final langCode = LocaleProvider.supportedLanguages.firstWhere(
                                (code) => localeProvider.getLanguageName(code) == newValue,
                                orElse: () => 'en',
                              );
                              localeProvider.setLocale(langCode);
                            }
                          },
                          items: LocaleProvider.supportedLanguages
                              .map<DropdownMenuItem<String>>((String langCode) {
                            final localeProvider = Provider.of<LocaleProvider>(context);
                            final langName = localeProvider.getLanguageName(langCode);
                            final isSelected = localeProvider.locale.languageCode == langCode;
                            return DropdownMenuItem<String>(
                              value: langName,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_getFlagEmojiForCode(langCode)),
                                  const SizedBox(width: 4),
                                  Text(langName),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.check,
                                      color: Theme.of(context).primaryColor,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/profile_image.png'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: pages[_currentIndex],
              bottomNavigationBar: BottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onItemTapped,
              ),
            ),
          );
  }

  Widget _buildHomeContent() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Add smooth scrolling physics
          child: Column(
            children: [
              // Add top padding to push content below the header
              SizedBox(height: Platform.isIOS ? 20 : 16),
              /*
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Platform.isIOS
                    ? CupertinoTextField(
                        placeholder: localeProvider.translate('searchHint'),
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(
                            CupertinoIcons.search,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        suffix: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            CupertinoIcons.mic,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      )
                    : TextField(
                        decoration: InputDecoration(
                          hintText: localeProvider.translate('searchHint'),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon: const Icon(
                            CupertinoIcons.mic,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
              ),
              */
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      localeProvider.translate('whatWeOffer'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Platform.isIOS
                            ? CupertinoColors.label
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildCategoryRow1(),
                  const SizedBox(height: 12),
                  _buildCategoryRow2(),
                ],
              ),
              const SizedBox(height: 20), // Add spacing after category cards
              const SizedBox(height: 12), // Reset spacing for better layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      localeProvider.translate('featuredProducts'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Platform.isIOS
                            ? CupertinoColors.label
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150, // Reset to reasonable height
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(), // Better scrolling physics
                  children: [
                    _buildSparePartCard(
                      nameKey: 'engineOil',
                      descriptionKey: 'engineOilDesc',
                      rating: 4.7,
                      reviews: 85,
                      image: 'assets/engine_oil.png',
                    ),
                    const SizedBox(width: 12),
                    _buildSparePartCard(
                      nameKey: 'brakePads',
                      descriptionKey: 'brakePadsDesc',
                      rating: 4.6,
                      reviews: 62,
                      image: 'assets/brake_pads.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow1() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  icon: CupertinoIcons.wrench,
                  title: localeProvider.translate('mechanicsTitle'),
                  subtitle: localeProvider.translate('mechanicsSubtitle'),
                  color: const Color(0xFF6A1D9A),
                  onTap: () {
                    if (Platform.isIOS) {
                      // For iOS CupertinoTabScaffold, we need to use a different approach
                      // Since CupertinoTabScaffold manages its own navigation, we can use Navigator.push
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => MechanicsPage()),
                      );
                    } else {
                      _onItemTapped(1);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  icon: CupertinoIcons.car_detailed,
                  title: localeProvider.translate('sparePartsTitle'),
                  subtitle: localeProvider.translate('sparePartsSubtitle'),
                  color: const Color(0xFF388E3C),
                  onTap: () {
                    if (Platform.isIOS) {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) => SparePartsPage()),
                      );
                    } else {
                      _onItemTapped(2);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow2() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      icon: CupertinoIcons.car,
                      title: localeProvider.translate('towingServicesTitle'),
                      subtitle: localeProvider.translate('towingServicesSubtitle'),
                      color: const Color(0xFFF57C00),
                      onTap: () {
                        if (Platform.isIOS) {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (context) => BookingsPage()),
                          );
                        } else {
                          _onItemTapped(3);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      icon: CupertinoIcons.exclamationmark_shield,
                      title: localeProvider.translate('emergencyHelpTitle'),
                      subtitle: localeProvider.translate('emergencyHelpSubtitle'),
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      icon: CupertinoIcons.sparkles,
                      title: localeProvider.translate('detailingServicesTitle'),
                      subtitle: localeProvider.translate('detailingServicesSubtitle'),
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        if (Platform.isIOS) {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (context) => const DetailingPage()),
                          );
                        } else {
                          Navigator.of(context).pushNamed('/detailing');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(), // Empty space for future services
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Platform.isIOS
                      ? CupertinoColors.label
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Platform.isIOS
                      ? CupertinoColors.secondaryLabel
                      : Colors.black54,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(CupertinoIcons.location, size: 20, color: color),
                  if (onTap != null)
                    Icon(CupertinoIcons.arrow_right, size: 20, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMechanicCard({
    required String name,
    required String specialtyKey,
    required double rating,
    required int reviews,
    required String image,
  }) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Platform.isIOS
            ? Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label,
                            ),
                          ),
                          Text(
                            localeProvider.translate(specialtyKey),
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($reviews reviews)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            localeProvider.translate(specialtyKey),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($reviews reviews)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }

  Widget _buildSparePartCard({
    required String nameKey,
    required String descriptionKey,
    required double rating,
    required int reviews,
    required String image,
  }) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return GestureDetector(
          onTap: () {
            if (Platform.isIOS) {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => SparePartsPage()),
              );
            } else {
              _onItemTapped(2);
            }
          },
          child: Platform.isIOS
              ? Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localeProvider.translate(nameKey),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.label,
                              ),
                            ),
                            Text(
                              localeProvider.translate(descriptionKey),
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.star_fill,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating ($reviews reviews)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 30, backgroundImage: AssetImage(image)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localeProvider.translate(nameKey),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              localeProvider.translate(descriptionKey),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.star_fill,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating ($reviews reviews)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  String _getFlagEmojiForCode(String langCode) {
    switch (langCode) {
      case 'en':
        return '🇬🇧';
      case 'rw':
        return '🇷🇼';
      case 'sw':
        return '🇰🇪';
      case 'fr':
        return '🇫🇷';
      default:
        return '🇺🇳';
    }
  }

  Widget _getFlagEmoji(String language) {
    switch (language) {
      case 'English':
        return const Text('🇬🇧');
      case 'Kinyarwanda':
        return const Text('🇷🇼');
      case 'Kiswahili':
        return const Text('🇰🇪');
      case 'French':
        return const Text('🇫🇷');
      default:
        return const Text('🇺🇳');
    }
  }
}

