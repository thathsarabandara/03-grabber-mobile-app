import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../services/ai_service.dart';
import '../../../widgets/custom_button.dart';

class AiControlScreen extends StatefulWidget {
  const AiControlScreen({super.key});

  @override
  State<AiControlScreen> createState() => _AiControlScreenState();
}

class _AiControlScreenState extends State<AiControlScreen> {
  final AiService _aiService = AiService();
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final tasks = await _aiService.getTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  Future<void> _toggleTask(String taskId, String status) async {
    try {
      if (status == 'active') {
        await _aiService.stopTask(taskId);
      } else {
        await _aiService.startTask(taskId);
      }
      await _fetchTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _startAll() async {
    try {
      await _aiService.startAllTasks();
      await _fetchTasks();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _stopAll() async {
    try {
      await _aiService.stopAllTasks();
      await _fetchTasks();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showFaceRegistrationDialog() async {
    final TextEditingController nameController = TextEditingController();
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Register Face'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Operator Name'),
                    ),
                    const SizedBox(height: 16),
                    if (selectedImage != null)
                      Text('Image Selected: ${selectedImage!.name}')
                    else
                      const Text('No image selected'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await picker.pickImage(source: ImageSource.camera);
                            if (picked != null) {
                              setDialogState(() => selectedImage = picked);
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              setDialogState(() => selectedImage = picked);
                            }
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Gallery'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Image are required')));
                      return;
                    }
                    Navigator.pop(context);
                    try {
                      await _aiService.registerFace(nameController.text, selectedImage!);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Face Registered!')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: const Text('Register'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI Task Orchestrator', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTasks),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : RefreshIndicator(
              onRefresh: _fetchTasks,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _startAll,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start All'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                        ElevatedButton.icon(
                          onPressed: _stopAll,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop All'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final isActive = task['status'] == 'active';
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Idle',
                                        style: TextStyle(
                                          color: isActive ? Colors.green : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Accuracy: ${task['accuracy']} | Latency: ${task['latency']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _toggleTask(task['id'], task['status']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isActive ? Colors.red.shade50 : Colors.blue.shade50,
                                          foregroundColor: isActive ? Colors.red : Colors.blue,
                                          elevation: 0,
                                        ),
                                        child: Text(isActive ? 'Deactivate' : 'Activate'),
                                      ),
                                    ),
                                    if (task['id'] == 'face-rec') ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _showFaceRegistrationDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black87,
                                            elevation: 0,
                                            side: BorderSide(color: Colors.grey.shade300)
                                          ),
                                          icon: const Icon(Icons.person_add, size: 16),
                                          label: const Text('Register'),
                                        ),
                                      )
                                    ]
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
