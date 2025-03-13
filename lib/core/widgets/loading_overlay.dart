import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zpluspasswordmanager/core/controllers/loading_controller.dart';

/// LoadingOverlay is a widget that shows a loading indicator over its child content
/// when the loading state is true.
class LoadingOverlayWidget extends StatelessWidget {
  final Widget child;
  final _loadingController = Get.find<LoadingController>();

  LoadingOverlayWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Obx(() {
          if (!_loadingController.isLoading) {
            return const SizedBox.shrink();
          }

          return Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }),
      ],
    );
  }
}
