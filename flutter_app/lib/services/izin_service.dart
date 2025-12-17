import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../data/models/izin_model.dart';
import 'package:logger/logger.dart';

class IzinService {
  final DioClient _dioClient = DioClient();
  final Logger _logger = Logger();

  Future<List<Izin>> getIzinHistory({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dioClient.dio.get(
        '/izin',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((e) => Izin.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengambil data izin');
      }
    } on DioException catch (e) {
      _logger.e(e);
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan koneksi');
    }
  }

  Future<void> submitIzin({
    required String tglMulai,
    required String tglSelesai,
    required String keterangan,
    File? bukti,
  }) async {
    try {
      final formData = FormData.fromMap({
        'tgl_mulai': tglMulai,
        'tgl_selesai': tglSelesai,
        'keterangan': keterangan,
        if (bukti != null)
          'bukti': await MultipartFile.fromFile(
            bukti.path,
            filename: bukti.path.split('/').last,
          ),
      });

      final response = await _dioClient.dio.post(
        '/izin',
        data: formData,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
         throw Exception(response.data['message'] ?? 'Gagal mengajukan izin');
      }
    } on DioException catch (e) {
       _logger.e(e);
       throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat upload');
    }
  }

  Future<void> cancelIzin(int id) async {
    try {
      final response = await _dioClient.dio.delete('/izin/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Gagal membatalkan izin');
      }
    } on DioException catch (e) {
      _logger.e(e);
      throw Exception(e.response?.data['message'] ?? 'Gagal membatalkan izin');
    }
  }
}
