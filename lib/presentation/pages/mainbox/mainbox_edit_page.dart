import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/data/models/mainbox_model.dart';
import 'package:fishindo_app/presentation/providers/mainbox_provider.dart';

class MainBoxEditPage extends ConsumerStatefulWidget {
  final MainBoxModel mainBox;
  const MainBoxEditPage({super.key, required this.mainBox});

  @override
  ConsumerState<MainBoxEditPage> createState() => _MainBoxEditPageState();
}

class _MainBoxEditPageState extends ConsumerState<MainBoxEditPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.mainBox.name);
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(mainBoxUpdateProvider);

    void updateMainBox() async {
      if (nameController.text.isNotEmpty) {
        await ref
            .read(mainBoxUpdateProvider.notifier)
            .update(widget.mainBox.id, nameController.text);
      }
    }

    ref.listen(mainBoxUpdateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit MainBox')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'MainBox Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateMainBox,
              child: const Text('Update'),
            ),
            if (updateState.isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
