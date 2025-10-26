// lib/presentation/screens/account.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../injection_container.dart';
import '../providers/auth_provider.dart'; // <-- GEÄNDERT
import '../providers/home_provider.dart';

// ==========================================================
// CONSTANTS
// ==========================================================
const Color kBackgroundColor = Color(0xFFF2F6FC);
const Color kPrimaryColor = Color(0xFF2666DE);
const Color kTextColor = Color(0xFF6F7EA8);
const Color kCardColor = Colors.white;

// ==========================================================
// MAIN WIDGET: ProfileScreen (JETZT STATEFUL)
// ==========================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Benutzerprofildaten abrufen, wenn der Bildschirm initialisiert wird
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchUserProfile();
    });
  }

  /// Handles user logout by clearing stored tokens and navigating to the login screen.
  Future<void> _logout(BuildContext context) async {
    final storage = getIt<FlutterSecureStorage>();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verwenden Sie verschachtelte Consumer, um Daten von beiden Providern abzurufen
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Raum- und Gerätedaten von HomeProvider berechnen
        final totalRooms = homeProvider.rooms.length;
        final totalDevices = homeProvider.rooms
            .fold<int>(0, (sum, room) => sum + room.devices.length);

        return Consumer<AuthProvider>(
          // Benutzerdaten von AuthProvider abrufen
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            final profileState = authProvider.profileState;

            return Scaffold(
              backgroundColor: kBackgroundColor,
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // ========================================================
                    // HEADER: Logout Button
                    // ========================================================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Image.asset('assets/icons/exit.png',
                                  color: kPrimaryColor),
                              onPressed: () => _logout(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ========================================================
                    // AVATAR UND NAME (AKTUALISIERT)
                    // ========================================================
                    const SizedBox(height: 20),
                    _buildAvatar(),
                    const SizedBox(height: 15),

                    // Lade-, Erfolgs- oder Fehlerzustand für Benutzerinformationen anzeigen
                    if (profileState == ViewState.Loading)
                      const CircularProgressIndicator(),
                    if (profileState == ViewState.Success && user != null)
                      Column(
                        children: [
                          Text(
                            user.name, // Benutzername anzeigen
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF6F7EA8),
                              fontSize: 22,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email, // Benutzer-E-Mail anzeigen
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9DB2CE),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    if (profileState == ViewState.Error)
                      const Text(
                        "Failed to load profile",
                        style: TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 30),

                    // ========================================================
                    // INFO CARDS GRID
                    // ========================================================
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildInfoCard(totalDevices.toString(), 'Devices'),
                            _buildInfoCard(totalRooms.toString(), 'Rooms'),
                            _buildInfoCard('93 kWh', 'Electricty usage'),
                            _buildInfoCard('1', 'Alerts'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // HELPER WIDGETS (UNVERÄNDERT)
  // ==========================================================
  Widget _buildInfoCard(String value, String label) {
    return Container(
      decoration: ShapeDecoration(
        color: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19.02),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C3880F6),
            blurRadius: 30.43,
            offset: Offset(0, 10.46),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 32,
              fontFamily: 'Inter',
              height: 0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: kTextColor,
              fontSize: 20,
              fontFamily: 'Inter',
              height: 0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110.31,
          height: 110.31,
          decoration: const ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.00, -1.00),
              end: Alignment(0, 1),
              colors: [Color(0xFFDEEFFF), Color(0xFFBCDEFF)],
            ),
            shape: OvalBorder(),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.54,
              height: 32.54,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: OvalBorder(),
              ),
            ),
            const SizedBox(height: 4.96),
            Container(
              width: 49.64,
              height: 18.75,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: OvalBorder(),
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 29.78,
            height: 29.78,
            decoration: const ShapeDecoration(
              color: Color(0xFFE5EAF0),
              shape: OvalBorder(
                side: BorderSide(width: 1.10, color: Colors.white),
              ),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: kTextColor,
            ),
          ),
        ),
      ],
    );
  }
}