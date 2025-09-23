import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/tts_provider.dart';
import '../providers/user_provider.dart';

class VoiceCloningScreen extends StatefulWidget {
  const VoiceCloningScreen({super.key});

  @override
  State<VoiceCloningScreen> createState() => _VoiceCloningScreenState();
}

class _VoiceCloningScreenState extends State<VoiceCloningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _voiceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<File> _selectedFiles = [];
  bool _isUploading = false;
  final _filePathController = TextEditingController();

  @override
  void dispose() {
    _voiceNameController.dispose();
    _descriptionController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  // Direct file picker call - following best practices from troubleshooting guide
  Future<void> _pickAudioFiles() async {
    print('🎵 VoiceCloningScreen: Starting file picker...');
    
    try {
      // Call FilePicker directly from user interaction (button press)
      // This is the recommended approach from the troubleshooting guide
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Use FileType.any instead of FileType.audio for better compatibility
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );
      
      print('🎵 VoiceCloningScreen: FilePicker result: $result');

      if (result != null && result.files.isNotEmpty) {
        final validFiles = <File>[];
        
        for (final file in result.files) {
          if (file.path != null) {
            try {
              final fileObj = File(file.path!);
              if (await fileObj.exists()) {
                // Manual validation for audio files since we're using FileType.any
                final fileName = file.name.toLowerCase();
                if (fileName.endsWith('.mp3') || 
                    fileName.endsWith('.wav') || 
                    fileName.endsWith('.m4a') || 
                    fileName.endsWith('.aac') || 
                    fileName.endsWith('.flac') ||
                    fileName.endsWith('.ogg')) {
                  validFiles.add(fileObj);
                  print('🎵 VoiceCloningScreen: Added audio file: ${file.name}');
                } else {
                  print('🎵 VoiceCloningScreen: Skipped non-audio file: ${file.name}');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Skipped non-audio file: ${file.name}'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            } catch (fileError) {
              print('🎵 VoiceCloningScreen: Error processing file: $fileError');
            }
          }
        }
        
        if (validFiles.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(validFiles);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${validFiles.length} audio file(s)'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No valid audio files selected'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        print('🎵 VoiceCloningScreen: No files selected or result is null');
      }
    } catch (e, stackTrace) {
      print('🎵 VoiceCloningScreen: Error in _pickAudioFiles: $e');
      print('🎵 VoiceCloningScreen: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Manual Input',
              onPressed: _showManualInputDialog,
            ),
          ),
        );
      }
    }
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Audio File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the path to your audio file:'),
              const SizedBox(height: 16),
              TextField(
                controller: _filePathController,
                decoration: const InputDecoration(
                  hintText: 'e.g., /path/to/audio.mp3',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addFileByPath();
              },
              child: const Text('Add File'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _addMoreFiles() async {
    // Direct call to file picker for adding more files
    await _pickAudioFiles();
  }

  void _addFileByPath() {
    final filePath = _filePathController.text.trim();
    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a file path'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final file = File(filePath);
      if (file.existsSync()) {
        setState(() {
          _selectedFiles.add(file);
        });
        _filePathController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added file: ${file.path.split('/').last}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File does not exist at the specified path'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createVoiceClone() async {
    print('🎵 VoiceCloningScreen: Starting voice clone creation...');
    
    if (!_formKey.currentState!.validate()) {
      print('🎵 VoiceCloningScreen: Form validation failed');
      return;
    }

    if (_selectedFiles.isEmpty) {
      print('🎵 VoiceCloningScreen: No files selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one audio file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🎵 VoiceCloningScreen: Setting upload state to true');
    setState(() {
      _isUploading = true;
    });

    try {
      final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      print('🎵 VoiceCloningScreen: TTS Provider current user ID: ${ttsProvider.currentUserId}');
      print('🎵 VoiceCloningScreen: User Provider session token: ${userProvider.sessionToken != null ? "Present" : "Null"}');
      
      // Ensure TTS provider has user ID
      if (ttsProvider.currentUserId == null && userProvider.sessionToken != null) {
        print('🎵 VoiceCloningScreen: Setting TTS provider user ID');
        ttsProvider.setCurrentUserId(userProvider.sessionToken!);
      }

      print('🎵 VoiceCloningScreen: Calling createVoiceClone with ${_selectedFiles.length} files');
      print('🎵 VoiceCloningScreen: Voice name: ${_voiceNameController.text.trim()}');
      print('🎵 VoiceCloningScreen: Description: ${_descriptionController.text.trim()}');

      final response = await ttsProvider.createVoiceClone(
        voiceName: _voiceNameController.text.trim(),
        audioFiles: _selectedFiles,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      print('🎵 VoiceCloningScreen: Voice clone response: $response');

      if (response != null && mounted) {
        print('🎵 VoiceCloningScreen: Voice clone created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice clone created successfully! Status: ${response.status}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Clear form
        _voiceNameController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFiles.clear();
        });
      } else if (mounted) {
        final error = ttsProvider.error ?? 'Unknown error occurred';
        print('🎵 VoiceCloningScreen: Voice clone creation failed: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create voice clone: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🎵 VoiceCloningScreen: Exception in _createVoiceClone: $e');
      print('🎵 VoiceCloningScreen: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating voice clone: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        print('🎵 VoiceCloningScreen: Setting upload state to false');
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voice Clone'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<TTSProvider, UserProvider>(
        builder: (context, ttsProvider, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.record_voice_over,
                                color: Colors.purple.shade600,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Voice Cloning',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Upload audio files to create a custom voice clone. The system will analyze your voice and create a personalized TTS voice.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Voice Name Field
                  TextFormField(
                    controller: _voiceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Voice Name',
                      hintText: 'Enter a name for your voice clone',
                      prefixIcon: Icon(Icons.record_voice_over),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Voice name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Voice name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Describe your voice or add notes',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Audio Files Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.audio_file,
                                color: Colors.blue.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Audio Files',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Select audio files containing your voice. Use the file picker to browse files, or manually enter file paths if needed. Multiple files are recommended for better quality.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // File picker button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading ? null : _pickAudioFiles,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Select Audio Files'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          
                          // Add more files button (shown when files are already selected)
                          if (_selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isUploading ? null : _addMoreFiles,
                                icon: const Icon(Icons.add),
                                label: const Text('Add More Files'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Colors.blue),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                          
                          // Manual input button (fallback option)
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isUploading ? null : _showManualInputDialog,
                              icon: const Icon(Icons.edit),
                              label: const Text('Manual File Path'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          
                          // Selected files list
                          if (_selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Selected Files:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(_selectedFiles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.audio_file,
                                    color: Colors.blue.shade600,
                                  ),
                                  title: Text(
                                    file.path.split('/').last,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    '${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: _isUploading ? null : () {
                                      setState(() {
                                        _selectedFiles.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            }).toList()),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quota Information
                  if (ttsProvider.quota != null) ...[
                    Card(
                      elevation: 1,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Voice Clones: ${ttsProvider.quota!.voiceClonesUsed}/${ttsProvider.quota!.voiceClonesLimit} used',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Error Display
                  if (ttsProvider.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ttsProvider.error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            onPressed: () => ttsProvider.clearError(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Create Voice Clone Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _createVoiceClone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUploading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Creating Voice Clone...'),
                              ],
                            )
                          : const Text(
                              'Create Voice Clone',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
