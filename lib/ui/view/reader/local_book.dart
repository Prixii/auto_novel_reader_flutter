import 'package:auto_novel_reader_flutter/ui/components/reader/book_list_tile.dart';
import 'package:auto_novel_reader_flutter/util/client_util.dart';
import 'package:flutter/material.dart';

class LocalBookView extends StatelessWidget {
  const LocalBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BookListTile(),
      const Center(child: Text('LocalBookView')),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                constraints: BoxConstraints(
                    maxHeight: screenSize.height - appBarHeight,
                    minHeight: screenSize.height * 0.7,
                    minWidth: screenSize.width),
                isScrollControlled: true,
                enableDrag: true,
                builder: (context) {
                  return const Text('data');
                },
              );
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ),
      )
    ]);
  }
}
