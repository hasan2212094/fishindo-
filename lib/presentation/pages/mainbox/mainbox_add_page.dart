import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fishindo_app/presentation/providers/mainbox_provider.dart';

class MainBoxAddPage extends ConsumerStatefulWidget {
  const MainBoxAddPage({super.key});

  @override
  ConsumerState<MainBoxAddPage> createState() => _MainBoxAddPageState();
}

class _MainBoxAddPageState extends ConsumerState<MainBoxAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(mainBoxCreateProvider);

    void addMainBox() async {
      if (_formKey.currentState!.validate()) {
        await ref
            .read(mainBoxCreateProvider.notifier)
            .create(nameController.text);
      }
    }

    ref.listen(mainBoxCreateProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add MainBox')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'MainBox Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addMainBox,
                child: const Text('Create'),
              ),
              if (addState.isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
