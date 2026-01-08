import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/mainbox_provider.dart';
import 'mainbox_add_page.dart';
import 'mainbox_edit_page.dart';
import 'mainbox_view_page.dart';

class MainBoxListPage extends ConsumerStatefulWidget {
  const MainBoxListPage({super.key});

  @override
  ConsumerState<MainBoxListPage> createState() => _MainBoxListPageState();
}

class _MainBoxListPageState extends ConsumerState<MainBoxListPage> {
  List<dynamic>? _cachedMainBox;

  @override
  Widget build(BuildContext context) {
    final mainBoxState = ref.watch(mainBoxAllProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        title: const Text("Main Box List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainBoxAddPage()),
              ).then((_) {
                // refresh data setelah add
                ref.invalidate(mainBoxAllProvider);
              });
            },
          ),
        ],
      ),
      body: mainBoxState.when(
        data: (list) {
          _cachedMainBox = list;
          if (list.isEmpty) {
            return const Center(child: Text("No Main Box available"));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final box = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(box.name),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainBoxViewPage(mainBox: box),
                          ),
                        );
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainBoxEditPage(mainBox: box),
                          ),
                        ).then((_) {
                          ref.invalidate(mainBoxAllProvider);
                        });
                      } else if (value == 'delete') {
                        final confirmed =
                            await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text(
                                      "Are you sure you want to delete this Main Box?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                            ) ??
                            false;

                        if (confirmed) {
                          await ref
                              .read(mainBoxDeleteProvider.notifier)
                              .delete(box.id);
                          ref.invalidate(mainBoxAllProvider);
                        }
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
        },
        loading:
            () =>
                _cachedMainBox != null
                    ? ListView.builder(
                      itemCount: _cachedMainBox!.length,
                      itemBuilder: (context, index) {
                        final box = _cachedMainBox![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(title: Text(box.name)),
                        );
                      },
                    )
                    : const Center(child: CircularProgressIndicator()),
        error:
            (e, _) =>
                _cachedMainBox != null
                    ? ListView.builder(
                      itemCount: _cachedMainBox!.length,
                      itemBuilder: (context, index) {
                        final box = _cachedMainBox![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(title: Text(box.name)),
                        );
                      },
                    )
                    : Center(
                      child: Text(
                        "Error: $e",
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
      ),
    );
  }
}
