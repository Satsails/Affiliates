import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _referralController = TextEditingController();
  int _sats = 0;
  String _referralId = '';
  bool _isReferralIdSet = false;

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
        _referralId = data['referralId'] ?? '';
        _isReferralIdSet = _referralId.isNotEmpty;
      }
      setState(() {});
    }
  }

  Future<void> _saveUserOptions() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        Map<String, dynamic> updatedData = {
          'address': _addressController.text,
        };
        if (!_isReferralIdSet && _referralController.text.isNotEmpty) {
          // Check if the referral ID already exists
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('referralId', isEqualTo: _referralController.text)
              .get();
          if (querySnapshot.docs.isNotEmpty) {
            // If the referral ID already exists, show an error message and return
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This referral ID already exists.')),
            );
            return;
          }
          updatedData['referralId'] = _referralController.text;
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).set(updatedData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Options saved successfully')),
        );
        context.go('/home');

        setState(() {
          _loadUserOptions();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('User Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Amount due to receive: $_sats',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Registered Liquid Address:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (_isReferralIdSet)
                Text(
                  'Your Referral ID: $_referralId',
                  style: const TextStyle(fontSize: 16.0),
                )
              else
                TextFormField(
                  controller: _referralController,
                  decoration: const InputDecoration(
                    labelText: 'Referral ID',
                  ),
                  maxLength: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your referral ID';
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
