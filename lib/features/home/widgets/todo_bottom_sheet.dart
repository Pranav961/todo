import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';

class TodoBottomSheet extends StatefulWidget {
  final TodoModel? todo;

  const TodoBottomSheet({super.key, this.todo});

  @override
  State<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends State<TodoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _minController;
  late TextEditingController _secController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descController = TextEditingController(
      text: widget.todo?.description ?? '',
    );

    int initialMin = 0;
    int initialSec = 0;
    if (widget.todo != null) {
      initialMin = widget.todo!.totalTimeInSeconds ~/ 60;
      initialSec = widget.todo!.totalTimeInSeconds % 60;
    }
    _minController = TextEditingController(
      text: initialMin > 0 ? initialMin.toString() : '',
    );
    _secController = TextEditingController(
      text: initialSec > 0 ? initialSec.toString() : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final desc = _descController.text.trim();
      final minutes = int.tryParse(_minController.text) ?? 0;
      final seconds = int.tryParse(_secController.text) ?? 0;

      final totalSeconds = (minutes * 60) + seconds;

      final provider = Provider.of<TodoProvider>(context, listen: false);

      if (widget.todo == null) {
        provider.addTodo(title, desc, totalSeconds);
      } else {
        provider.updateTodoData(widget.todo!.id, title, desc, totalSeconds);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.todo == null ? 'Add TODO' : 'Edit TODO',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                      decoration: const InputDecoration(
                        labelText: 'Minutes (max 5)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          if (_secController.text.isEmpty) {
                            return 'Enter time';
                          }
                          return null;
                        }
                        final mins = int.tryParse(value) ?? 0;
                        if (mins > 5) return 'Max 5 mins';
                        if (mins == 5 &&
                            (_secController.text.isNotEmpty &&
                                _secController.text != '0')) {
                          return 'Exceeds 5 mins';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _secController,
                      decoration: const InputDecoration(
                        labelText: 'Seconds',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final secs = int.tryParse(value) ?? 0;
                          if (secs >= 60) return 'Max 59';
                        }
                        final mins = int.tryParse(_minController.text) ?? 0;
                        final secs = int.tryParse(value ?? '') ?? 0;
                        if (mins == 0 && secs == 0) return 'Time cannot be 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
