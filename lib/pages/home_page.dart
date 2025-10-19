import 'package:auto_solutions/widgets/bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'mechanics_page.dart';
import 'spare_parts_page.dart';
import 'bookings_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedLanguage = 'English'; // Default language

  // Translation map for different languages
  final Map<String, Map<String, String>> _translations = {
    'English': {
      'home': 'Home',
      'whatWeOffer': 'What we offer',
      'featuredSpareParts': 'Featured Spare Parts',
      'searchHint': 'Search mechanics or parts...',
      'searchMechanics': 'Search Mechanics',
      'searchSpareParts': 'Search Spare Parts',
      'mechanicsTitle': 'Mechanics',
      'mechanicsSubtitle': 'Find experts near you',
      'sparePartsTitle': 'Products',
      'sparePartsSubtitle': 'Genuine products, fast\ndelivery',
      'towingServicesTitle': 'Towing Services',
      'towingServicesSubtitle': '24/7 roadside assistance',
      'emergencyHelpTitle': 'Emergency Help',
      'emergencyHelpSubtitle': 'Quick emergency support',
      'engineMaintenance': 'Engine Maintenance',
      'batteryReplacement': 'Battery Replacement',
      'engineOil': 'Engine Oil',
      'engineOilDesc': 'High-performance oil',
      'brakePads': 'Brake Pads',
      'brakePadsDesc': 'Durable brake pads',
      'mechanicsPage': 'Mechanics Page',
      'partsPage': 'Parts Page',
      'bookingsPage': 'Bookings',
      'profilePage': 'Profile',
      'contactUs': 'Contact Us',
      'buyNow': 'Buy Now',
      'bookingsTitle': 'Book a Service',
      'selectIssue': 'Select Vehicle Issue',
      'otherIssue': 'Other',
      'customIssue': 'Please describe your issue',
      'locationPlaceholder': 'Enter your location for service',
      'totalPrice': 'Total Price',
      'toBeDiscussed': 'To be discussed',
      'submitBooking': 'Submit Booking',
      'fullName': 'Full Name',
      'phoneNumber': 'Phone Number',
      'namePlaceholder': 'Enter your full name',
      'phonePlaceholder': 'Enter phone number with country code (e.g., +250)',
      'email': 'Email',
      'country': 'Country',
      'vehicleBrand': 'Vehicle Brand',
      'vehicleBrandPlaceholder': 'Enter vehicle brand (e.g., Toyota)',
      'towingServiceBooking': 'Book Towing Service',
      'pickupLocation': 'Pickup Location',
      'pickupLocationPlaceholder': 'Enter pickup location',
      'vehicleBrandModel': 'Vehicle Brand & Model',
      'vehicleMake': 'Select Make',
      'vehicleModel': 'Select Model',
      'carPlateNumber': 'Car Plate Number',
      'carPlatePlaceholder': 'Enter car plate number',
      'serviceType': 'Service Type',
      'selectServiceType': 'Select Service Type',
      'selectCurrency': 'Select Currency',
      'toBeDiscussed': 'To be discussed',
    },
    'Kinyarwanda': {
      'home': 'Ahabanza',
      'whatWeOffer': 'Ibyo dutanga',
      'recommendedMechanics': 'Abakanishi b’inzobere',
      'featuredSpareParts': 'Ibikoresho by’ibinyabiziga',
      'searchHint': 'Shakisha abakanishi cyangwa ibikoresho...',
      'searchMechanics': 'Shakisha Abakanishi',
      'searchSpareParts': 'Shakisha Ibikoresho',
      'mechanicsTitle': 'Abakanishi',
      'mechanicsSubtitle': 'Shakisha inzobere kuri Auto RevOp',
      'sparePartsTitle': 'Ibikoresho',
      'sparePartsSubtitle': 'Ibikoresho by’ibinyabiziga',
      'towingServicesTitle': 'Serivisi za breakdown',
      'towingServicesSubtitle': 'Ubufasha Kumuhanda 24/7',
      'emergencyHelpTitle': 'Ubufasha bwihutirwa',
      'emergencyHelpSubtitle': 'Guhabwa ubufasha bwihutirwa',
      'engineMaintenance': 'Gusuzuma Moteri',
      'batteryReplacement': 'Guhindura Batiri',
      'engineOil': 'Amavuta ya Moteri',
      'engineOilDesc': 'Amavuta y’umwimerere',
      'brakePads': 'Feri',
      'brakePadsDesc': 'Amaferi aramba',
      'mechanicsPage': 'Abakanishi',
      'partsPage': 'Ibikoresho',
      'bookingsPage': 'Gusaba',
      'profilePage': 'Umwirondoro',
      'contactUs': 'Duhamagare',
      'buyNow': 'Gura Nonaha',
      'bookingsTitle': 'Shyiraho Ubusabe',
      'selectIssue': 'Hitamo Ikibazo cy\'icyinyabiziga',
      'otherIssue': 'Ibindi',
      'customIssue': 'Sobanura ikibazo cyawe',
      'locationPlaceholder': 'Injiza aho uherereye',
      'totalPrice': 'Amafaranga Yose',
      'toBeDiscussed': 'Byaganirwaho',
      'submitBooking': 'Emeza Gusaba',
      'fullName': 'Izina ryose',
      'phoneNumber': 'Numero ya Telefoni',
      'namePlaceholder': 'Injiza izina ryawe ryose',
      'phonePlaceholder': 'Injiza numero ya telefoni (+250)',
      'email': 'Imeli',
      'country': 'Igihugu',
      'vehicleBrand': 'Ubwoko bw\'imodoka',
      'vehicleBrandPlaceholder': 'Injiza ubwoko bw\'imodoka yawe',
      'towingServiceBooking': 'Gusaba Serivisi ya Towing',
      'pickupLocation': 'Aho Uzakurwa',
      'pickupLocationPlaceholder': 'Andika aho uzakurwa',
      'vehicleBrandModel': 'Ubwoko bw’Imodoka & Model',
      'vehicleMake': 'Hitamo Ubwoko',
      'vehicleModel': 'Hitamo Model',
      'carPlateNumber': 'Numero ya Plake y’Imodoka',
      'carPlatePlaceholder': 'Andika numero ya plake y’imodoka',
      'serviceType': 'Ubwoko bw’Serivisi',
      'selectServiceType': 'Hitamo Ubwoko bw’Serivisi',
      'selectCurrency': 'Hitamo Ifaranga',
      'toBeDiscussed': 'Bizaganirwaho',
    },
    'Kiswahili': {
      'home': 'Nyumbani',
      'whatWeOffer': 'Tunachotoa',
      'recommendedMechanics': 'Fundi Waliopendekezwa',
      'featuredSpareParts': 'Sehemu za Ziada Zilizopendekezwa',
      'searchHint': 'Tafuta fundi au sehemu...',
      'searchMechanics': 'Tafuta Mafundi',
      'searchSpareParts': 'Tafuta Sehemu za Ziada',
      'mechanicsTitle': 'Fundi',
      'mechanicsSubtitle': 'Pata wataalamu karibu yako',
      'sparePartsTitle': 'Bidhaa',
      'sparePartsSubtitle': 'Sehemu za kweli, uwasilishaji wa haraka',
      'towingServicesTitle': 'Huduma za Kukokota',
      'towingServicesSubtitle': 'Usaidizi wa barabarani 24/7',
      'emergencyHelpTitle': 'Usaidizi wa Dharura',
      'emergencyHelpSubtitle': 'Msaada wa haraka wa dharura',
      'engineMaintenance': 'Matengenezo ya Injini',
      'batteryReplacement': 'Ubadilishaji wa Batri',
      'engineOil': 'Mafuta ya Injini',
      'engineOilDesc': 'Mafuta ya kiwango cha juu',
      'brakePads': 'Pedali za Breki',
      'brakePadsDesc': 'Pedali za breki za kudumu',
      'mechanicsPage': 'Ukurasa wa Fundi',
      'partsPage': 'Ukurasa wa Bidhaa',
      'bookingsPage': 'kuweka nafasi',
      'profilePage': 'Wasifu',
      'contactUs': 'Wasiliana Nasi',
      'buyNow': 'Nunua Sasa',
      'bookingsTitle': 'Weka Huduma',
      'selectIssue': 'Chagua Tatizo la Gari',
      'otherIssue': 'Zingine',
      'customIssue': 'Tafadhali Elezea Tatizo Lako',
      'locationPlaceholder': 'Ingiza eneo lako la huduma',
      'totalPrice': 'Bei ya Jumla',
      'toBeDiscussed': 'Itabainishwa Baadaye',
      'submitBooking': 'Wasilisha Kuhifadhi',
      'fullName': 'Jina Kamili',
      'phoneNumber': 'Namba ya Simu',
      'namePlaceholder': 'Ingiza jina lako kamili',
      'phonePlaceholder': 'Ingiza namba ya simu na nambari ya nchi (mfano, +254)',
      'email': 'Barua Pepe',
      'country': 'Nchi',
      'vehicleBrand': 'Aina ya Gari',
      'vehicleBrandPlaceholder': 'Ingiza aina ya gari lako',
      'towingServiceBooking': 'Jihifadhi Huduma ya Kukokota',
      'pickupLocation': 'Mahali pa Kuchukua',
      'pickupLocationPlaceholder': 'Ingiza mahali pa kuchukua',
      'vehicleBrandModel': 'Aina ya Gari & Modeli',
      'vehicleMake': 'Chagua Aina',
      'vehicleModel': 'Chagua Modeli',
      'carPlateNumber': 'Namba ya Plati ya Gari',
      'carPlatePlaceholder': 'Ingiza namba ya plati ya gari',
      'serviceType': 'Aina ya Huduma',
      'selectServiceType': 'Chagua Aina ya Huduma',
      'selectCurrency': 'Chagua Sarafu',
      'toBeDiscussed': 'Kutajadiliwa',
    },
    'French': {
      'home': 'Accueil',
      'whatWeOffer': 'Ce que nous offrons',
      'recommendedMechanics': 'Mécaniciens recommandés',
      'featuredSpareParts': 'Pièces détachées mises en avant',
      'searchHint': 'Rechercher des mécaniciens ou des pièces...',
      'searchMechanics': 'Rechercher des Mécaniciens',
      'searchSpareParts': 'Rechercher des Pièces',
      'mechanicsTitle': 'Mécaniciens',
      'mechanicsSubtitle': 'Trouver des experts près de chez vous',
      'sparePartsTitle': 'Produits',
      'sparePartsSubtitle': 'Produits authentiques, livraison rapide',
      'towingServicesTitle': 'Services de remorquage',
      'towingServicesSubtitle': 'Assistance routière 24/7',
      'emergencyHelpTitle': 'Aide d’urgence',
      'emergencyHelpSubtitle': 'Soutien d’urgence rapide',
      'engineMaintenance': 'Entretien du moteur',
      'batteryReplacement': 'Remplacement de batterie',
      'engineOil': 'Huile de moteur',
      'engineOilDesc': 'Huile haute performance',
      'brakePads': 'Plaquettes de frein',
      'brakePadsDesc': 'Plaquettes de frein durables',
      'mechanicsPage': 'Page des Mécaniciens',
      'partsPage': 'Page des Produits',
      'bookingsPage': 'Réservations',
      'profilePage': 'Profil',
      'contactUs': 'Contactez-nous',
      'buyNow': 'Acheter Maintenant',
      'bookingsTitle': 'Réserver un Service',
      'selectIssue': 'Sélectionner un Problème de Véhicule',
      'otherIssue': 'Autre',
      'customIssue': 'Veuillez décrire votre problème',
      'locationPlaceholder': 'Entrez votre emplacement pour le service',
      'totalPrice': 'Prix Total',
      'toBeDiscussed': 'À discuter',
      'submitBooking': 'Soumettre la Réservation',
      'fullName': 'Nom Complet',
      'phoneNumber': 'Numéro de Téléphone',
      'namePlaceholder': 'Entrez votre nom complet',
      'phonePlaceholder': 'Entrez le numéro avec code pays (ex. : +250)',
      'email': 'Email',
      'country': 'Pays',
      'vehicleBrand': 'Marque du Véhicule',
      'vehicleBrandPlaceholder': 'Entrez la marque de votre véhicule',
      'towingServiceBooking': 'Réserver un service de remorquage',
      'pickupLocation': 'Lieu de ramassage',
      'pickupLocationPlaceholder': 'Entrez le lieu de ramassage',
      'vehicleBrandModel': 'Marque & Modèle du véhicule',
      'vehicleMake': 'La marque',
      'vehicleModel': 'Le modèle',
      'carPlateNumber': 'Numéro de plaque d\'immatriculation',
      'carPlatePlaceholder': 'Entrez le numéro de plaque d\'immatriculation',
      'serviceType': 'Type de service',
      'selectServiceType': 'Sélectionner le type de service',
      'selectCurrency': 'Sélectionner la devise',
      'toBeDiscussed': 'À discuter',
    },
  };

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = _translations[_selectedLanguage] ?? _translations['English']!;

    final List<Widget> pages = [
      _buildHomeContent(t),
      MechanicsPage(translations: t),
      SparePartsPage(translations: t),
      BookingsPage(translations: t),
      ProfilePage(translations: t),
    ];

    return WillPopScope(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: t['searchHint'] ?? 'Search mechanics or parts...',
                prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
                suffixIcon: const Icon(CupertinoIcons.mic, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  t['whatWeOffer'] ?? 'What we offer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  t['featuredSpareParts'] ?? 'Featured Spare Parts',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
              onTap: () => _onItemTapped(1), // Navigate to Mechanics page
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCategoryCard(
              icon: CupertinoIcons.car_detailed,
              title: t['sparePartsTitle'] ?? 'Spare Parts',
              subtitle: t['sparePartsSubtitle'] ?? 'Genuine parts, fast\ndelivery',
              color: const Color(0xFF388E3C),
              onTap: () => _onItemTapped(2), // Navigate to Spare Parts page
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
              onTap: () => _onItemTapped(3), // Navigate to Bookings page (Towing Services)
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
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
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(image),
            ),
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
                  _translations[_selectedLanguage]![specialtyKey] ?? specialtyKey,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 16, color: Colors.amber),
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
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translations[_selectedLanguage]![nameKey] ?? nameKey,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _translations[_selectedLanguage]![descriptionKey] ?? descriptionKey,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 16, color: Colors.amber),
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