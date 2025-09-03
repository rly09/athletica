import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/page_transition.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedState;
  String? selectedSport;
  DateTime? selectedDob;
  bool isLoading = false;

  final List<String> states = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
    "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand",
    "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur",
    "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
    "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
    "Uttar Pradesh", "Uttarakhand", "West Bengal", "Delhi", "J&K", "Ladakh"
  ];

  final List<String> sports = [
    "Cricket", "Football", "Hockey", "Basketball", "Volleyball",
    "Badminton", "Tennis", "Table Tennis", "Athletics", "Swimming",
    "Kabaddi", "Wrestling", "Boxing", "Archery", "Shooting",
    "Weightlifting", "Cycling", "Gymnastics", "Golf", "Chess",
    "Squash", "Handball", "Kho-Kho", "Rugby", "Martial Arts"
  ];

  Future<void> _pickDob() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDob = picked;
        dobController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = response.user;
      if (user != null) {
        // Insert profile row
        await Supabase.instance.client.from("profiles").insert({
          "id": user.id,
          "name": "${firstNameController.text} ${surnameController.text}",
          "dob": selectedDob?.toIso8601String(),
          "state": selectedState,
          "sport": selectedSport,
          "phone": phoneController.text.trim(),
        });

        // Navigate to Dashboard
        Navigator.of(context).pushReplacement(
          PageTransitions.createSlideFadeRoute(const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed. Try again.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> googleSignUp() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google,);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Check if profile exists
        final existing = await Supabase.instance.client
            .from("profiles")
            .select()
            .eq("id", user.id)
            .maybeSingle();

        if (existing == null) {
          await Supabase.instance.client.from("profiles").insert({
            "id": user.id,
            "name": user.userMetadata?["full_name"] ?? "Unknown",
            "dob": null,
            "state": "",
            "sport": "",
            "phone": "",
          });
        }

        Navigator.of(context).pushReplacement(
          PageTransitions.createSlideFadeRoute(const DashboardScreen()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void navigateToLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF312E81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Lottie.asset("assets/animations/signup.json", height: 180),
                const SizedBox(height: 20),
                Text(
                  "Create Your Athletica Account 🏆",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // First Name + Surname
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameController,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) =>
                        v!.isEmpty ? "First Name is required" : null,
                        decoration: _inputDecoration("First Name", Icons.person),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: surnameController,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) =>
                        v!.isEmpty ? "Surname is required" : null,
                        decoration: _inputDecoration("Surname", Icons.person),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // DOB
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  onTap: _pickDob,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v!.isEmpty ? "DOB is required" : null,
                  decoration: _inputDecoration("Date of Birth", Icons.cake),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email is required";
                    if (!v.contains("@")) return "Enter a valid email";
                    return null;
                  },
                  decoration: _inputDecoration("Email", Icons.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration:
                  _inputDecoration("Phone Number (Optional)", Icons.phone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password is required";
                    if (v.length < 6) return "Password must be 6+ chars";
                    return null;
                  },
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.lock),
                ),
                const SizedBox(height: 16),

                // State
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.indigo[800],
                  value: selectedState,
                  items: states
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedState = val),
                  validator: (v) => v == null ? "Select a state" : null,
                  decoration: _inputDecoration("Select State", Icons.map),
                ),
                const SizedBox(height: 16),

                // Sport
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.indigo[800],
                  value: selectedSport,
                  items: sports
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedSport = val),
                  validator: (v) => v == null ? "Select a sport" : null,
                  decoration: _inputDecoration("Select Sport", Icons.sports),
                ),
                const SizedBox(height: 24),

                // Signup Button
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: signUp,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 18),

                // Google SignUp
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: googleSignUp,
                  icon: Image.asset("assets/icons/google.png", height: 24),
                  label: const Text(
                    "Sign Up with Google",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Already have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
