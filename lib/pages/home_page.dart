import 'dart:io' show Platform;
import 'package:auto_revop/widgets/bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'mechanics_page.dart';
import 'spare_parts_page.dart';
import 'bookings_page.dart';
import 'profile_page.dart';
import 'translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedLanguage = 'English'; // Default language

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = translations[_selectedLanguage] ?? translations['English']!;

    final List<Widget> pages = [
      _buildHomeContent(t),
      MechanicsPage(translations: translations[_selectedLanguage] ?? translations['English']!),
      SparePartsPage(translations: translations[_selectedLanguage] ?? translations['English']!),
      BookingsPage(translations: translations[_selectedLanguage] ?? translations['English']!),
      ProfilePage(translations: translations[_selectedLanguage] ?? translations['English']!),
    ];

    return Platform.isIOS
        ? CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: t['home'] ?? 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.wrench),
                  label: t['mechanicsPage'] ?? 'Mechanics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.car_detailed),
                  label: t['partsPage'] ?? 'Parts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar),
                  label: t['bookingsPage'] ?? 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person),
                  label: t['profilePage'] ?? 'Profile',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return CupertinoTabView(
                builder: (context) {
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
                                  height: 200,
                                  color: CupertinoColors.systemBackground,
                                  child: CupertinoPicker(
                                    itemExtent: 32.0,
                                    onSelectedItemChanged: (int index) {
                                      setState(() {
                                        _selectedLanguage = [
                                          'English',
                                          'Kinyarwanda',
                                          'Kiswahili',
                                          'French',
                                        ][index];
                                      });
                                    },
                                    children: [
                                      Text('🇬🇧 English'),
                                      Text('🇷🇼 Kinyarwanda'),
                                      Text('🇰🇪 Kiswahili'),
                                      Text('🇫🇷 French'),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              _selectedLanguage,
                              style: TextStyle(
                                color: CupertinoColors.activeBlue,
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
                    child: pages[index],
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
                actions: [
                  Center(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.grey),
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      underline: Container(height: 2, color: const Color.fromRGBO(17, 131, 192, 1)),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                      },
                      items: <String>['English', 'Kinyarwanda', 'Kiswahili', 'French']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getFlagEmoji(value),
                              const SizedBox(width: 4),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
                translations: t,
              ),
            ),
          );
  }

  Widget _buildHomeContent(Map<String, String> t) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Add top padding to push content below the header
          SizedBox(height: Platform.isIOS ? 20 : 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Platform.isIOS
                ? CupertinoTextField(
                    placeholder:
                        t['searchHint'] ?? 'Search mechanics or parts...',
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
                      hintText:
                          t['searchHint'] ?? 'Search mechanics or parts...',
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
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  t['whatWeOffer'] ?? 'What we offer',
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
              _buildCategoryRow1(t),
              const SizedBox(height: 12),
              _buildCategoryRow2(t),
            ],
          ),
          const SizedBox(height: 20), // Add spacing after category cards
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  t['featuredProducts'] ?? 'Featured Products',
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
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
  }

  Widget _buildCategoryRow1(Map<String, String> t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryCard(
              icon: CupertinoIcons.wrench,
              title: t['mechanicsTitle'] ?? 'Mechanic Services',
              subtitle: t['mechanicsSubtitle'] ?? 'Find mechanical services near you',
              color: const Color(0xFF6A1D9A),
              onTap: () {
                if (Platform.isIOS) {
                  // For iOS CupertinoTabScaffold, we need to use a different approach
                  // Since CupertinoTabScaffold manages its own navigation, we can use Navigator.push
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => MechanicsPage(translations: translations[_selectedLanguage] ?? translations['English']!)),
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
              title: t['sparePartsTitle'] ?? 'Spare Parts',
              subtitle: t['sparePartsSubtitle'] ?? 'Genuine parts, fast\ndelivery',
              color: const Color(0xFF388E3C),
              onTap: () {
                if (Platform.isIOS) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => SparePartsPage(translations: translations[_selectedLanguage] ?? translations['English']!)),
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
  }

  Widget _buildCategoryRow2(Map<String, String> t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryCard(
              icon: CupertinoIcons.car,
              title: t['towingServicesTitle'] ?? 'Towing Services',
              subtitle: t['towingServicesSubtitle'] ?? '24/7 roadside assistance',
              color: const Color(0xFFF57C00),
              onTap: () {
                if (Platform.isIOS) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => BookingsPage(translations: translations[_selectedLanguage] ?? translations['English']!)),
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
              title: t['emergencyHelpTitle'] ?? 'Emergency Help',
              subtitle: t['emergencyHelpSubtitle'] ?? 'Quick emergency support',
              color: const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
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
                        translations[_selectedLanguage]![specialtyKey] ??
                            specialtyKey,
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
                  const Icon(
                    CupertinoIcons.arrow_right,
                    color: CupertinoColors.systemGrey,
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
                        translations[_selectedLanguage]![specialtyKey] ??
                            specialtyKey,
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
                  const Icon(CupertinoIcons.arrow_right, color: Colors.grey),
                ],
              ),
            ),
          );
  }

  Widget _buildSparePartCard({
    required String nameKey,
    required String descriptionKey,
    required double rating,
    required int reviews,
    required String image,
  }) {
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
                        translations[_selectedLanguage]![nameKey] ?? nameKey,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        translations[_selectedLanguage]![descriptionKey] ??
                            descriptionKey,
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
                  const Icon(
                    CupertinoIcons.arrow_right,
                    color: CupertinoColors.systemGrey,
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
                        translations[_selectedLanguage]![nameKey] ?? nameKey,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        translations[_selectedLanguage]![descriptionKey] ??
                            descriptionKey,
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
                  const Icon(CupertinoIcons.arrow_right, color: Colors.grey),
                ],
              ),
            ),
          );
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
