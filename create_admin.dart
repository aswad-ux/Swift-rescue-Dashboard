import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  print('Loading environment...');
  await dotenv.load(fileName: ".env");

  print('Initializing Supabase...');
  final supabase = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
  );

  print('Attempting to create admin account...');
  try {
    final response = await supabase.auth.signUp(
      email: 'admin@swiftrescue.co.za',
      password: 'admin',
    );
    
    if (response.user != null) {
      print('SUCCESS! Admin account created.');
      print('User ID: ${response.user!.id}');
      print('NOTE: If you have "Confirm Email" enabled in Supabase, you MUST click the link sent to admin@swiftrescue.co.za before you can log in.');
    } else {
      print('Sign up completed, but user object is null. (Check Supabase logs)');
    }
  } on AuthException catch (e) {
    print('Auth Error: ${e.message}');
  } catch (e) {
    print('Unexpected Error: $e');
  }
  
  exit(0);
}
