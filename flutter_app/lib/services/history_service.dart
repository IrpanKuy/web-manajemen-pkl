import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../data/models/absensi_model.dart';
import '../data/models/jurnal_model.dart';
import 'package:logger/logger.dart';

class HistoryService {
  final DioClient _dioClient = DioClient();
  final Logger _logger = Logger();

  Future<Map<String, dynamic>> getAbsensiHistory({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dioClient.dio.get(
        '/absensi/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        final summaryJson = response.data['summary'];

        final absensis = list.map((e) => Absensi.fromJson(e)).toList();
        final summary = AbsensiSummary.fromJson(summaryJson);

        return {
          'data': absensis,
          'summary': summary,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil data absensi');
      }
    } on DioException catch (e) {
       _logger.e(e);
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan koneksi');
    }
  }

  Future<Map<String, dynamic>> getJurnalHistory({int? month, int? year}) async {
    try {
       final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dioClient.dio.get(
        '/jurnal',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        final summaryJson = response.data['summary'];

        final jurnals = list.map((e) => Jurnal.fromJson(e)).toList();
        final summary = JurnalSummary.fromJson(summaryJson);

        return {
          'data': jurnals,
          'summary': summary,
        };
      } else {
         throw Exception(response.data['message'] ?? 'Gagal mengambil data jurnal');
      }
    } on DioException catch (e) {
      _logger.e(e);
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan koneksi');
    }
  }
}
