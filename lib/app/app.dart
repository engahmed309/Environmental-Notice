import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:env_report_app/app/theme/app_theme.dart';
import 'package:env_report_app/constants/app_strings.dart';
import 'package:env_report_app/logic/cubit/cubit.dart';
import 'package:env_report_app/presentation/screens/screens.dart';

class EnvReportApp extends StatefulWidget {
  const EnvReportApp({super.key});

  @override
  State<EnvReportApp> createState() => _EnvReportAppState();
}

class _EnvReportAppState extends State<EnvReportApp> {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, animation) {
              final inAnim =
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  );
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: inAnim, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentScreenIndex),
              child: _buildScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return HomeScreen(onSubmitReportPressed: _onSubmitReportPressed);
      case 1:
        return CreateReportScreen(
          onSuccess: _onReportSuccess,
          onCancel: _onCancel,
        );
      case 2:
        return BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            if (state is ReportSuccess) {
              return SuccessScreen(
                message: state.message,
                onNewReport: _onNewReport,
                onHome: _onHome,
              );
            }
            return HomeScreen(onSubmitReportPressed: _onSubmitReportPressed);
          },
        );
      default:
        return HomeScreen(onSubmitReportPressed: _onSubmitReportPressed);
    }
  }

  void _onSubmitReportPressed() {
    setState(() => _currentScreenIndex = 1);
  }

  void _onCancel() {
    setState(() => _currentScreenIndex = 0);
  }

  void _onReportSuccess() {
    setState(() => _currentScreenIndex = 2);
  }

  void _onNewReport() {
    context.read<ReportCubit>().resetForm();
    setState(() => _currentScreenIndex = 1);
  }

  void _onHome() {
    context.read<ReportCubit>().resetForm();
    setState(() => _currentScreenIndex = 0);
  }
}
