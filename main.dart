import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Médicaments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageGestionMedicaments(), // Page d'accueil
      routes: {
        '/gestion_entre_sortie': (context) =>
            PageGestionEntreSortie(), // Route vers la deuxième page
      },
    );
  }
}

class PageGestionMedicaments extends StatelessWidget {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController dateFabricationController =
      TextEditingController();
  final TextEditingController datePeremptionController =
      TextEditingController();

  Future<void> ajouterMedicament() async {
    await FirebaseFirestore.instance.collection('medicaments').add({
      'nom': nomController.text,
      'quantite': int.parse(quantiteController.text),
      'description': descriptionController.text,
      'prix': int.parse(prixController.text), // Prix en centimes
      'date_fabrication':
          Timestamp.fromDate(DateTime.parse(dateFabricationController.text)),
      'date_peremption':
          Timestamp.fromDate(DateTime.parse(datePeremptionController.text)),
    });

    // Réinitialiser les champs après ajout
    nomController.clear();
    quantiteController.clear();
    descriptionController.clear();
    prixController.clear();
    dateFabricationController.clear();
    datePeremptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Médicaments")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: "Nom du médicament")),
            TextField(
                controller: quantiteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantité")),
            TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description")),
            TextField(
                controller: prixController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Prix (en centimes)")),
            TextField(
                controller: dateFabricationController,
                decoration: InputDecoration(
                    labelText: "Date de fabrication (YYYY-MM-DD)")),
            TextField(
                controller: datePeremptionController,
                decoration: InputDecoration(
                    labelText: "Date de péremption (YYYY-MM-DD)")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: ajouterMedicament,
              child: Text("Ajouter Médicament"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context,
                    '/gestion_entre_sortie'); // Navigation vers la page de gestion des entrées/sorties
              },
              child: Text("Gérer les Entrées et Sorties"),
            ),
          ],
        ),
      ),
    );
  }
}

class PageGestionEntreSortie extends StatelessWidget {
  final TextEditingController medicamentIdController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();
  final TextEditingController typeController =
      TextEditingController(); // "entrée" ou "sortie"

  Future<void> ajouterTransaction() async {
    String medicamentId = medicamentIdController.text;
    String type = typeController.text; // "entrée" ou "sortie"
    int quantite = int.parse(quantiteController.text);

    // Ajouter la transaction à Firestore
    await FirebaseFirestore.instance.collection('transactions').add({
      'medicament_id': medicamentId,
      'type': type,
      'quantite': quantite,
      'date': Timestamp.now(),
      'utilisateur': 'admin@example.com', // Utilisateur actuel
      'description': 'Transaction de stock', // Description par défaut
    });

    // Réinitialiser les champs après ajout
    medicamentIdController.clear();
    quantiteController.clear();
    typeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Entrées et Sorties")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: medicamentIdController,
                decoration: InputDecoration(labelText: "ID du médicament")),
            TextField(
                controller: quantiteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantité")),
            TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: "Type (entrée/sortie)")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: ajouterTransaction,
              child: Text("Ajouter Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
