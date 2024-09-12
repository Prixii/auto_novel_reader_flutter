import 'package:auto_novel_reader_flutter/model/enums.dart';
import 'package:flutter/material.dart';

class TimeoutInfoContainer extends StatelessWidget {
  const TimeoutInfoContainer(
      {super.key,
      required this.child,
      required this.status,
      this.onRetry,
      this.message});

  final Function()? onRetry;
  final String? message;
  final Widget child;
  final LoadingStatus? status;

  @override
  Widget build(BuildContext context) {
    if (status == null) return child;

    switch (status) {
      case null:
        return child;
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.failed:
      case LoadingStatus.serverError:
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请求超时'),
            Text(message ??
                ((status == LoadingStatus.serverError) ? '服务器错误' : '请检查网络连接')),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text('重试'),
              ),
          ],
        ));
    }
  }
}
