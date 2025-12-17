import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../utils/show_snackbar.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();

  bool _carregantDades = true;

  @override
  void initState() {
    super.initState();
    _carregaDadesUsuari();
  }

  Future<void> _carregaDadesUsuari() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _carregantDades = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('usuaris')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nomController.text = data['nom'] ?? '';
      }
    }
    catch (e) {
      print('Error carregant dades: $e');
      showSnackBar(context, 'Error carregant dades del perfil.');
    }
    finally {
      setState(() => _carregantDades = false);
    }
  }

  Future<void> _desaDades() async {
    if (!_formKey.currentState!.validate()) return;

    final dades = {
      'nom': _nomController.text,
      'actualitzat': DateTime.now(),
    };

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showSnackBar(context, 'Cap usuari loguejat');
        return;
      }

      final String userId = user.uid;

      await FirebaseFirestore.instance
          .collection('usuaris')
          .doc(userId)
          .set(dades, SetOptions(merge: true));

      showSnackBar(context, 'Dades guardades amb èxit!');
    }
    catch (e) {
      showSnackBar(context, 'Error en desar les dades: $e');
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Perfil', style: AppStyles.appBarText),
      ),
      body: _carregantDades
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppStyles.sizedBoxHeight20,
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _nomController,
                      style: const TextStyle(color: Colors.blue),
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        labelStyle: const TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Introdueix un nom' : null,
                    ),
                    AppStyles.sizedBoxHeight40,
                    ElevatedButton(
                      onPressed: _desaDades,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 44),
                        maximumSize: const Size(200, 44),
                      ),
                      child: const Text('Desar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }
}