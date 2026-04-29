import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:env_report_app/data/models/models.dart';
import 'package:env_report_app/constants/constants.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(ReportInitial());

  final ImagePicker _imagePicker = ImagePicker();
  ReportModel _currentReport = ReportModel();
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));

  List<Map<String, dynamic>> parks = [];
  List<Map<String, dynamic>> notificationTypes = [];

  // Get current report
  ReportModel get currentReport => _currentReport;

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          emit(ReportImageError('يرجى منح إذن الكاميرا'));
          return;
        }
      }
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Str = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64Str';
        _currentReport = _currentReport.copyWith(imagePath: dataUrl);
        emit(ReportImageSelected(dataUrl));
      }
    } catch (e) {
      emit(ReportImageError('فشل اختيار الصورة من الكاميرا'));
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          emit(ReportImageError('يرجى منح إذن الوصول للصور'));
          return;
        }
      }
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Str = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64Str';
        _currentReport = _currentReport.copyWith(imagePath: dataUrl);
        emit(ReportImageSelected(dataUrl));
      }
    } catch (e) {
      emit(ReportImageError('فشل اختيار الصورة من المعرض'));
    }
  }

  // Update park selection
  void updatePark(String? park) {
    _currentReport = _currentReport.copyWith(park: park);
    emit(ReportUpdated(_currentReport));
  }

  // Update report type
  void updateReportType(String? reportType) {
    _currentReport = _currentReport.copyWith(reportType: reportType);
    emit(ReportUpdated(_currentReport));
  }

  // Update notes
  void updateNotes(String notes) {
    _currentReport = _currentReport.copyWith(notes: notes);
    emit(ReportUpdated(_currentReport));
  }

  // Update phone
  void updatePhone(String phone) {
    _currentReport = _currentReport.copyWith(phone: phone);
    emit(ReportUpdated(_currentReport));
  }

  // Validate form
  bool validateForm() {
    if (_currentReport.imagePath == null || _currentReport.imagePath!.isEmpty) {
      emit(ReportValidationError(AppStrings.errorSelectImage));
      return false;
    }
    if (_currentReport.park == null || _currentReport.park!.isEmpty) {
      emit(ReportValidationError(AppStrings.errorSelectPark));
      return false;
    }
    if (_currentReport.reportType == null ||
        _currentReport.reportType!.isEmpty) {
      emit(ReportValidationError(AppStrings.errorSelectReportType));
      return false;
    }
    if (_currentReport.notes == null || _currentReport.notes!.isEmpty) {
      emit(ReportValidationError(AppStrings.errorEnterNotes));
      return false;
    }
    if (_currentReport.phone == null || _currentReport.phone!.isEmpty) {
      emit(ReportValidationError(AppStrings.errorEnterPhone));
      return false;
    }

    // Validate phone format (Saudi number: 9 digits starting with 5)
    if (!_isValidSaudiPhone(_currentReport.phone!)) {
      emit(ReportValidationError(AppStrings.invalidPhoneError));
      return false;
    }

    return true;
  }

  // Validate Saudi phone number
  bool _isValidSaudiPhone(String phone) {
    // Use the provided Saudi regex (converted from C# to Dart)
    final pattern =
        r'^(\+|00|0)(9665|9661|9669|5)(5|0|3|6|4|9|1|8|7|2)([0-9]{7})$';
    final reg = RegExp(pattern);
    return reg.hasMatch(phone);
  }

  // Submit report (UI only, API integration will be done later with Dio)
  Future<void> submitReport() async {
    if (!validateForm()) {
      return;
    }

    try {
      emit(ReportSubmitting());

      // Prepare form data
      final formData = FormData();

      // File handling: support data URI or file path
      int? fileBytesLength;
      if (_currentReport.imagePath != null) {
        final path = _currentReport.imagePath!;
        if (path.startsWith('data:')) {
          final base64Str = path.split(',').last;
          final bytes = base64Decode(base64Str);
          fileBytesLength = bytes.length;
          formData.files.add(
            MapEntry(
              'File',
              MultipartFile.fromBytes(
                bytes,
                filename: 'upload.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        }
      }

      // Map park and types to IDs if available (UI may supply id or name)
      String? parkId = _currentReport.park;
      String? typeId = _currentReport.reportType; // may be id or name

      String? resolvedParkId;
      if (parkId != null && parkId.isNotEmpty) {
        final byId = parks.firstWhere(
          (e) => e['id']?.toString() == parkId,
          orElse: () => {},
        );
        if (byId.isNotEmpty) {
          resolvedParkId = byId['id']?.toString();
        } else {
          final byName = parks.firstWhere(
            (e) => e['name']?.toString() == parkId,
            orElse: () => {},
          );
          if (byName.isNotEmpty)
            resolvedParkId = byName['id']?.toString();
          else
            resolvedParkId = parkId;
        }
      }

      String? resolvedTypeId;
      if (typeId != null && typeId.isNotEmpty) {
        final byId = notificationTypes.firstWhere(
          (e) => e['id']?.toString() == typeId,
          orElse: () => {},
        );
        if (byId.isNotEmpty) {
          resolvedTypeId = byId['id']?.toString();
        } else {
          final byName = notificationTypes.firstWhere(
            (e) => e['name']?.toString() == typeId,
            orElse: () => {},
          );
          if (byName.isNotEmpty)
            resolvedTypeId = byName['id']?.toString();
          else
            resolvedTypeId = typeId;
        }
      }

      formData.fields
        ..add(MapEntry('ParkId', resolvedParkId ?? ''))
        ..add(MapEntry('NotificationStatusId', '1'))
        ..add(MapEntry('NotificationTypeId', resolvedTypeId ?? '1'))
        ..add(MapEntry('PhoneNumber', _currentReport.phone ?? ''))
        ..add(MapEntry('Notes', _currentReport.notes ?? ''));

      final resp = await _dio.post(
        '/api/Notifications/Create',
        data: formData,
        options: Options(
          headers: {'Accept': 'text/plain, application/json, text/json'},
        ),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        if (data is Map && data['success'] == true) {
          final message =
              data['message']?.toString() ?? 'تم اضافة البلاغ بنجاح';
          emit(ReportSuccess(message));
        } else {
          emit(ReportError(data['message']?.toString() ?? 'خطأ في الخادم'));
        }
      } else {
        emit(ReportError('خطأ في الاتصال: ${resp.statusCode}'));
      }
    } on DioException catch (dioErr) {
      final resp = dioErr.response;
      final serverMessage = resp?.data ?? dioErr.message;

      emit(ReportError('خطأ في إرسال البلاغ: ${serverMessage.toString()}'));
    } catch (e) {
      emit(ReportError('حدث خطأ أثناء إرسال البلاغ'));
    }
  }

  Future<void> fetchParks() async {
    try {
      emit(ReportLoading());
      final resp = await _dio.get('/api/LookUps/DDLPark');
      if (resp.statusCode == 200 &&
          resp.data is Map &&
          resp.data['success'] == true) {
        final List resources = resp.data['resource'] ?? [];
        parks = resources
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList();
        emit(ReportUpdated(_currentReport));
      } else {
        emit(ReportError('فشل استرجاع المتنزهات'));
      }
    } catch (e) {
      emit(ReportError('فشل استرجاع المتنزهات'));
    }
  }

  Future<void> fetchNotificationTypes() async {
    try {
      emit(ReportLoading());
      final resp = await _dio.get('/api/LookUps/DDLNotificationType');
      if (resp.statusCode == 200 &&
          resp.data is Map &&
          resp.data['success'] == true) {
        final List resources = resp.data['resource'] ?? [];
        notificationTypes = resources
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList();
        emit(ReportUpdated(_currentReport));
      } else {
        emit(ReportError('فشل استرجاع انواع البلاغ'));
      }
    } catch (e) {
      emit(ReportError('فشل استرجاع انواع البلاغ'));
    }
  }

  // Reset form
  void resetForm() {
    _currentReport = ReportModel();
    emit(ReportReset());
    emit(ReportInitial());
  }
}
