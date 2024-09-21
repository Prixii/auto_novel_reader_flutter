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

class RefreshList extends StatelessWidget {
  const RefreshList({
    super.key,
    required this.loadingStatus,
    required this.onRetry,
    required this.child,
    this.padding = const EdgeInsets.only(top: 48, left: 8, right: 8),
  });

  final LoadingStatus? loadingStatus;
  final Future<void> Function() onRetry;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            TimeoutInfoContainer(
              status: loadingStatus,
              onRetry: onRetry,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
