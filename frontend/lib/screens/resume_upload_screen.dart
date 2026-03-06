import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  static const route = '/resume-upload';

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  String? _status;
  bool _loading = false;

  Future<void> _pickAndUpload() async {
    final api = context.read<ApiService>();
    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _status = 'No file selected');
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _status = 'Unable to read selected file');
        return;
      }

      await api.uploadFile(
        path: '/resume/upload',
        field: 'file',
        bytes: bytes,
        filename: file.name,
      );

      setState(() => _status = 'Resume uploaded successfully');
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resume')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload PDF or DOCX resume'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _pickAndUpload,
              child: const Text('Choose File & Upload'),
            ),
            const SizedBox(height: 12),
            if (_loading) const CircularProgressIndicator(),
            if (_status != null) Text(_status!),
          ],
        ),
      ),
    );
  }
}
