import 'package:flutter/material.dart';
import 'package:flutter_app/ui/auth/login.dart';
import 'package:flutter_app/ui/home_page.dart';
import 'package:flutter_app/ui/rekap_jurnal.dart';
import 'package:flutter_app/ui/rekap_absensi.dart';
import 'package:flutter_app/ui/ganti_pembimbing.dart';
import 'package:flutter_app/ui/tempatPkl/cari_instansi.dart';
import 'package:flutter_app/ui/tempatPkl/detail_instansi.dart';
import 'package:flutter_app/ui/tempatPkl/status_lamaran.dart';

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
        '/cari_instansi': (context) => const CariInstansi(),
        '/detail_instansi': (context) => const DetailInstansi(),
        '/status_lamaran': (context) => const StatusLamaran(),
      },
      // home: Login(),
    );
  }
}
