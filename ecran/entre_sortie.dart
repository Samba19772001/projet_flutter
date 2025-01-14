import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter une transaction (entrée ou sortie)
  Future<void> addTransaction(String medicamentId, String type, int quantite,
      String utilisateur, String description) async {
    final medicamentRef =
        _firestore.collection('medicaments').doc(medicamentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(medicamentRef);
      if (!snapshot.exists) {
        throw Exception("Médicament introuvable !");
      }

      final currentQuantite = snapshot['quantite'] as int;
      final newQuantite = (type == 'entrée')
          ? currentQuantite + quantite
          : currentQuantite - quantite;

      if (newQuantite < 0) {
        throw Exception("La quantité ne peut pas être négative !");
      }

      // Mise à jour de la quantité
      transaction.update(medicamentRef, {'quantite': newQuantite});

      // Ajouter la transaction
      final transactionRef = _firestore.collection('transactions').doc();
      transaction.set(transactionRef, {
        'medicament_id': medicamentId,
        'type': type,
        'quantite': quantite,
        'date': DateTime.now(),
        'utilisateur': utilisateur,
        'description': description,
      });
    });
  }

  // Générer un rapport des transactions
  void generateReport() async {
    final querySnapshot = await _firestore.collection('transactions').get();
    for (var doc in querySnapshot.docs) {
      print("Transaction : ${doc.data()}");
    }
  }

  // Boîte de dialogue pour ajouter une transaction
  void _showTransactionDialog(BuildContext context, String medicamentId) {
    final TextEditingController _quantiteController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    String type = 'entrée';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: type,
                items: [
                  DropdownMenuItem(
                      value: 'entrée', child: Text('Approvisionnement')),
                  DropdownMenuItem(value: 'sortie', child: Text('Vente')),
                ],
                onChanged: (value) {
                  type = value ?? 'entrée';
                },
              ),
              TextField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantité'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                final quantite = int.tryParse(_quantiteController.text) ?? 0;
                final description = _descriptionController.text;
                if (quantite > 0 && description.isNotEmpty) {
                  addTransaction(medicamentId, type, quantite,
                      'admin@example.com', description);
                }
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Liste des médicaments
  Widget buildMedicamentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('medicaments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final medicaments = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: medicaments.length,
          itemBuilder: (context, index) {
            final medicament = medicaments[index];
            final quantite = medicament['quantite'] as int;
            final prix = medicament['prix'] as int;

            return ListTile(
              title: Text("${medicament['nom']} - ${prix / 100} €"),
              subtitle: Text('Quantité : $quantite'),
              trailing: quantite < 100
                  ? Text(
                      'Faible',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  : null,
              onTap: () {
                _showTransactionDialog(context, medicament.id);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Entrées et Sorties'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: generateReport,
          ),
        ],
      ),
      body: buildMedicamentsList(),
    );
  }
}
