import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GestionMedicamentsPage extends StatefulWidget {
  @override
  _GestionMedicamentsPageState createState() => _GestionMedicamentsPageState();
}

class _GestionMedicamentsPageState extends State<GestionMedicamentsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dateFabrication;
  DateTime? _datePeremption;
  File? _image;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addMedicament() async {
    if (_formKey.currentState!.validate() && _image != null) {
      // Uploader l'image dans Firebase Storage
      String imagePath = 'medicaments_images/${_nomController.text}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(imagePath);
      await storageRef.putFile(_image!);
      String imageUrl = await storageRef.getDownloadURL();

      // Ajouter les données dans Firestore
      await FirebaseFirestore.instance.collection('medicaments').add({
        'nom': _nomController.text,
        'quantite': int.parse(_quantiteController.text),
        'description': _descriptionController.text,
        'photoUrl': imageUrl,
        'dateFabrication': _dateFabrication,
        'datePeremption': _datePeremption,
      });

      // Réinitialiser le formulaire
      setState(() {
        _nomController.clear();
        _quantiteController.clear();
        _descriptionController.clear();
        _dateFabrication = null;
        _datePeremption = null;
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Médicament ajouté avec succès !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Médicaments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du médicament'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _quantiteController,
                decoration: InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextButton(
                onPressed: () async {
                  _dateFabrication = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  setState(() {});
                },
                child: Text(_dateFabrication == null
                    ? 'Sélectionner la date de fabrication'
                    : 'Fabrication : ${_dateFabrication.toString().split(' ')[0]}'),
              ),
              TextButton(
                onPressed: () async {
                  _datePeremption = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  setState(() {});
                },
                child: Text(_datePeremption == null
                    ? 'Sélectionner la date de péremption'
                    : 'Péremption : ${_datePeremption.toString().split(' ')[0]}'),
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text(_image == null
                    ? 'Choisir une image'
                    : 'Image sélectionnée'),
              ),
              ElevatedButton(
                onPressed: _addMedicament,
                child: Text('Ajouter le médicament'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
