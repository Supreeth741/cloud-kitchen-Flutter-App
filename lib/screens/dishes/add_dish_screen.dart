import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';

class AddDishScreen extends StatefulWidget {
  const AddDishScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddDishScreenState createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = 'veg';
  File? _selectedImage;

  Future<void> _submitDish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final token = await ApiService.getToken();
    if (token == null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await ApiService().addDish(
      _titleController.text,
      _descriptionController.text,
      _category,
      _selectedImage!,
      token,
    );

    if (response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dish added successfully!')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add dish: ${response.body}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Dish')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['veg', 'non-veg']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : Placeholder(
                      fallbackHeight: 150,
                      child: Center(child: Text('Image')),
                    ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitDish,
                child: Text('Add Dish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}