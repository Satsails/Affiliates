import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _referralController = TextEditingController();
  final _paymentTypeController = TextEditingController();
  int _sats = 0;

  @override
  void initState() {
    super.initState();
    _loadUserOptions();
  }

  Future<void> _loadUserOptions() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        _addressController.text = data['address'] ?? '';
        _sats = data['sats'] ?? 0;
        _referralController.text = data['referralId'] ?? '';
        _paymentTypeController.text = data['paymentType'] ?? '';
      }
      setState(() {});
    }
  }

  Future<void> _saveUserOptions() async {
    if (_formKey.currentState?.validate() ?? false) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'address': _addressController.text,
        'sats': _sats,
        'referralId': _referralController.text,
        'paymentType': _paymentTypeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Options saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                'Sats: $_sats',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _referralController,
                decoration: const InputDecoration(
                  labelText: 'Referral ID',
                ),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your referral ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _paymentTypeController,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your payment type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveUserOptions,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
