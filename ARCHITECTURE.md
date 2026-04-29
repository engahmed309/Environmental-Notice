# تطبيق بلاغ بيئي - Environmental Reports App

تطبيق موبايل لتقديم البلاغات البيئية والشكاوى في المتنزهات الوطنية بالمملكة العربية السعودية.

## المميزات الرئيسية 🎯

✅ **شاشة الرئيسية** - واجهة بسيطة وسهلة الاستخدام
✅ **تقديم البلاغات** - نموذج شامل لتقديم البلاغات
✅ **اختيار الصور** - من الكاميرا أو المعرض
✅ **اختيار المتنزهات** - قائمة منسدلة بجميع المتنزهات الوطنية
✅ **أنواع البلاغات** - خدمية، بيئية، أمن و سلامة
✅ **التحقق من البيانات** - التحقق من صحة جميع الحقول المطلوبة
✅ **شاشة النجاح** - تأكيد استقبال البلاغ مع رقم مرجعي
✅ **تصميم جميل** - واجهة متجاوبة وسهلة الاستخدام

## هيكل المشروع 📁

```
lib/
├── main.dart                          # نقطة الدخول الرئيسية
├── app/
│   ├── app.dart                       # تطبيق Flutter الرئيسي
│   └── theme/
│       └── app_theme.dart             # التصميم والألوان الموحدة
├── constants/
│   ├── app_colors.dart                # الألوان المستخدمة
│   ├── app_strings.dart               # النصوص والرسائل (عربي)
│   ├── app_constants.dart             # الثوابت (padding, border radius, etc)
│   ├── parks_data.dart                # بيانات المتنزهات والأنواع
│   └── constants.dart                 # ملف إعادة التصدير
├── data/
│   └── models/
│       ├── report_model.dart          # نموذج البلاغ
│       └── models.dart                # ملف إعادة التصدير
├── logic/
│   └── cubit/
│       ├── report_cubit.dart          # Cubit لإدارة حالة البلاغات
│       ├── report_state.dart          # الحالات المختلفة للبلاغات
│       └── cubit.dart                 # ملف إعادة التصدير
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart       # شاشة الرئيسية
│   │   ├── create_report/
│   │   │   └── create_report_screen.dart   # شاشة تقديم البلاغ
│   │   ├── success/
│   │   │   └── success_screen.dart    # شاشة النجاح
│   │   └── screens.dart               # ملف إعادة التصدير
│   └── widgets/
│       ├── custom_button.dart         # زر مخصص قابل لإعادة الاستخدام
│       ├── custom_text_field.dart     # حقل نصي مخصص
│       ├── custom_dropdown.dart       # قائمة منسدلة مخصصة
│       ├── image_picker_widget.dart   # أداة اختيار الصور
│       └── widgets.dart               # ملف إعادة التصدير
```

## بنية البلاغ (Report Model) 📋

```dart
class ReportModel {
  final String? id;           // رقم البلاغ (يتم تعيينه من الخادم)
  final String? imagePath;    // مسار الصورة المرفقة
  final String? park;         # المتنزه الوطني
  final String? reportType;   // نوع البلاغ (خدمية/بيئية/أمن و سلامة)
  final String? notes;        # الملاحظات والتفاصيل
  final String? phone;        # رقم الجوال السعودي
}
```

## إدارة الحالة (State Management) 🎮

يستخدم التطبيق **Cubit** من مكتبة `flutter_bloc` لإدارة حالة البلاغات:

### الحالات الرئيسية:
- `ReportInitial` - الحالة الأولية
- `ReportLoading` - جاري التحميل
- `ReportImageSelected` - تم اختيار صورة
- `ReportImageError` - خطأ في اختيار الصورة
- `ReportUpdated` - تم تحديث البلاغ
- `ReportValidationError` - خطأ في التحقق من الصحة
- `ReportSubmitting` - جاري إرسال البلاغ
- `ReportSuccess` - تم إرسال البلاغ بنجاح
- `ReportError` - خطأ في الإرسال
- `ReportReset` - إعادة تعيين البلاغ

## المتطلبات المقبولة 📝

جميع حقول البلاغ إجبارية:
- ✅ صورة واحدة (من الكاميرا أو المعرج)
- ✅ اختيار المتنزه
- ✅ نوع البلاغ
- ✅ الملاحظات (بحد أقصى 500 حرف)
- ✅ رقم الجوال السعودي (تنسيق: 05XXXXXXXXX أو +966 5XXXXXXXXX)

## الألوان والتصميم 🎨

```dart
Primary Color:    #2D7E3A (أخضر)
Secondary Color:  #1A7A5A (أخضر غامق)
Success Color:    #4CAF50 (أخضر فاتح)
Error Color:      #E53935 (أحمر)
Warning Color:    #FFA726 (برتقالي)
```

## الـ Dependencies 📦

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.4        # State Management
  image_picker: ^1.0.4        # اختيار الصور
  intl: ^0.19.0              # التحويل والترجمة
```

## الخطوات التالية 🚀

### للربط مع API (في المستقبل):
1. إضافة `dio` للـ HTTP requests
2. إنشاء Repository للتعامل مع البيانات
3. إضافة API calls في `report_cubit.dart` بدلاً من `Future.delayed`

### مثال بـ Dio:
```dart
// في submitReport()
final response = await _dio.post(
  '/api/reports',
  data: FormData.fromMap({
    'image': await MultipartFile.fromFile(report.imagePath!),
    'park': report.park,
    'reportType': report.reportType,
    'notes': report.notes,
    'phone': report.phone,
  }),
);
```

## النقاط المهمة 📌

✅ **Clean Code** - كود منظم وسهل الصيانة
✅ **Reusable Components** - مكونات قابلة لإعادة الاستخدام
✅ **Separation of Concerns** - فصل الاهتمامات والمسؤوليات
✅ **State Management** - باستخدام Cubit
✅ **Validation** - التحقق من البيانات على مستوى العميل
✅ **User Experience** - واجهة مستخدم سهلة وجميلة
✅ **Right-to-Left (RTL)** - دعم اللغة العربية

## التشغيل 🏃

```bash
# تثبيت المتطلبات
flutter pub get

# تشغيل التطبيق
flutter run

# بناء APK
flutter build apk

# بناء iOS
flutter build ios
```

## ملاحظات مهمة 💡

1. التطبيق حالياً يحاكي إرسال البلاغ بـ `Future.delayed` - لا يوجد ربط فعلي مع API
2. يمكن استخدام `image_picker` لاختيار الصور من الكاميرا أو المعرج
3. التحقق من صحة رقم الجوال السعودي يتم على مستوى العميل
4. جميع النصوص باللغة العربية ودعم RTL

## الملف الذي تم إنشاؤه ✨

تم إنشاء هيكل المشروع بالكامل مع:
- ✅ 3 شاشات رئيسية (Home, Create Report, Success)
- ✅ 4 widgets مخصصة قابلة لإعادة الاستخدام
- ✅ Cubit كامل لإدارة الحالة
- ✅ Model للبلاغات
- ✅ Constants و Colors منظمة
- ✅ Theme موحد وجميل
- ✅ دعم كامل للعربية

---

**تم إنشاء التطبيق بواسطة GitHub Copilot** ✨
