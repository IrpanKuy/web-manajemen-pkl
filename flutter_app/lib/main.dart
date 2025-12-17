import 'package:flutter/material.dart';
import 'package:flutter_app/ui/auth/login.dart';
import 'package:flutter_app/ui/homePage/home_page.dart';
import 'package:flutter_app/ui/rekap_jurnal.dart';
import 'package:flutter_app/ui/rekap_absensi.dart';
import 'package:flutter_app/ui/ganti_pembimbing.dart';
import 'package:flutter_app/ui/tempatPkl/detail_mitra.dart';
import 'package:flutter_app/ui/lamaran.dart';
import 'package:flutter_app/ui/tempatPkl/pencarian_mitra/pencarian_mitra.dart';
import 'package:flutter_app/ui/izin/rekap_izin.dart';
import 'package:flutter_app/ui/izin/form_izin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/login',

      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => const HomePage(),
        '/rekap_jurnal': (context) => const RekapJurnal(),
        '/rekap_absensi': (context) => const RekapAbsensi(),
        '/ganti_pembimbing': (context) => const GantiPembimbing(),
        '/pencarian_instansi': (context) => const PencarianMitraPage(),
        '/detail_mitra': (context) => const DetailMitra(),
        '/lamaran': (context) => const StatusLamaran(),
        '/rekap_izin': (context) => const RekapIzin(),
        '/form_izin': (context) => const FormIzin(),
      },
      // home: Login(),
    );
  }
}
