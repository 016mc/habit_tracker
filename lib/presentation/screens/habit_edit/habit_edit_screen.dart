import 'package:flutter/material.dart';
import '../../../data/models/habit_model.dart';

/// 习惯编辑/创建页面（极简版）
class HabitEditScreen extends StatefulWidget {
  final Habit? habit;
  final String userId;
  final ValueChanged<Habit>? onSave;

  const HabitEditScreen({
    super.key,
    this.habit,
    required this.userId,
    this.onSave,
  });

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  late TextEditingController _nameController;
  String _name = '';

  bool get _isEditing => widget.habit != null;
  bool get _isFormValid => _name.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController = TextEditingController(text: widget.habit!.name);
      _name = widget.habit!.name;
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_isFormValid) return;
    
    final habit = Habit(
      userId: widget.userId,
      name: _name.trim(),
    );
    
    widget.onSave?.call(habit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑习惯' : '新建习惯'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('习惯名称'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '例如：每天喝8杯水',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _name = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormValid ? _save : null,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
