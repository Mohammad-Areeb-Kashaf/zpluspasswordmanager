import 'package:get/get.dart';

/// LoadingController manages the global loading state of the application.
/// It provides a centralized way to show/hide loading overlays across different screens.
class LoadingController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  /// Shows the loading overlay
  void startLoading() {
    _isLoading.value = true;
  }

  /// Hides the loading overlay
  void stopLoading() {
    _isLoading.value = false;
  }

  /// Executes a function while showing the loading overlay
  /// Returns the result of the function
  Future<T> wrapLoading<T>(Future<T> Function() func) async {
    try {
      startLoading();
      return await func();
    } finally {
      stopLoading();
    }
  }
}
