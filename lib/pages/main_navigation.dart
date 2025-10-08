import 'package:dairykhata/pages/add_record_bottom_sheet.dart';
import 'package:dairykhata/pages/home_page.dart';
import 'package:dairykhata/pages/insights_page.dart';
import 'package:dairykhata/pages/settings_page.dart';
import 'package:dairykhata/pages/view_records_page.dart';
import 'package:dairykhata/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const notchRadius = 28.0; // Radius for the button bulge
    final notchCenterX = size.width / 2;

    // Start from top left
    path.moveTo(0, 0);
    path.lineTo(notchCenterX - notchRadius, 0);

    // Create the curved bulge (like button pushing up from inside)
    path.arcToPoint(
      Offset(notchCenterX + notchRadius, 0),
      radius: const Radius.circular(notchRadius),
      clockwise: true, // Creates downward curve (bulge effect)
    );

    // Continue to top right
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const ViewRecordsPage(),
    const InsightsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddRecordPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const AddRecordBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('images/dairybook.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _pages[_selectedIndex],
            // Bottom Navigation Bar (solid, no curve)
            Positioned(
              bottom: ResponsiveUtils.getNavBarPadding(context).bottom,
              left: ResponsiveUtils.getNavBarPadding(context).left,
              right: ResponsiveUtils.getNavBarPadding(context).right,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      spreadRadius: 2,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Home
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(0),
                        child: Container(
                          height: 70,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.home,
                                color: _selectedIndex == 0
                                    ? const Color(0xff113370)
                                    : Colors.grey,
                              ),
                              Text(
                                'Home',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedIndex == 0
                                      ? const Color(0xff113370)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Records
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(1),
                        child: Container(
                          height: 70,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.list,
                                color: _selectedIndex == 1
                                    ? const Color(0xff113370)
                                    : Colors.grey,
                              ),
                              Text(
                                'Records',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedIndex == 1
                                      ? const Color(0xff113370)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Spacer for button
                    const SizedBox(width: 80),
                    // Insights
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(2),
                        child: Container(
                          height: 70,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insights,
                                color: _selectedIndex == 2
                                    ? const Color(0xff113370)
                                    : Colors.grey,
                              ),
                              Text(
                                'Insights',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedIndex == 2
                                      ? const Color(0xff113370)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Settings
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(3),
                        child: Container(
                          height: 70,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings,
                                color: _selectedIndex == 3
                                    ? const Color(0xff113370)
                                    : Colors.grey,
                              ),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedIndex == 3
                                      ? const Color(0xff113370)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Custom Add Button - positioned at the curved protrusion
            Positioned(
              bottom: ResponsiveUtils.getNavBarPadding(context).bottom + 25,
              left: ResponsiveUtils.getFabLeftPosition(context, 56),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff113370), Color(0xff0e2a62)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff113370).withValues(alpha: 0.4),
                      spreadRadius: 3,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onAddRecordPressed,
                    borderRadius: BorderRadius.circular(28),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
