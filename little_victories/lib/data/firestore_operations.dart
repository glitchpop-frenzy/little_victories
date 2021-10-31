import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference<Map<String, dynamic>> _victoriesCollection =
    firestore.collection('victories');
CollectionReference<Map<String, dynamic>> _usersCollection =
    firestore.collection('users');

/// START: Check if user exists.
Future<bool> isNewUser(User user) async {
  final QuerySnapshot<Object?> snapshot = await firestore
      .collection('users')
      .where('UserId', isEqualTo: user.uid)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return false;
  }

  return true;
}

/// END: Check if user exists.
/// START: Create User.
Future<bool> createUser(User user) async {
  final DateTime currentDateTime = DateTime.now();
  final String? token = await FirebaseMessaging.instance.getToken();

  _usersCollection.doc(user.uid).set(<String, dynamic>{
    'UserId': user.uid,
    'Email': user.email,
    'FCM-Token': token,
    'CreatedOn': currentDateTime
  });

  _usersCollection
      .doc(user.uid)
      .collection('topics')
      .doc(token)
      .set(<String, dynamic>{
    'encouragement': true,
    'news': true,
    'reminder': true
  }).then((_) {
    return true;
  });
  return false;
}

/// END: Create User
/// START: Add Little Victory
Future<bool> saveLittleVictory(User user, String victory, int category) async {
  final DateTime currentDateTime = DateTime.now();

  _victoriesCollection.add(<String, dynamic>{
    'UserId': user.uid,
    'Category': category,
    'Victory': victory,
    'IV': 'null',
    'CreatedOn': currentDateTime
  }).then((_) {
    return true;
  });
  return false;
}

/// START: Delete Little Victory
Future<bool> deleteLittleVictory(String docId) async {
  _victoriesCollection.doc(docId).delete().then((_) {
    return true;
  });
  return false;
}

/// START: Update Push Notification Preferences
//
// Future<bool> updatePushNotificationPreferences(User user, String topic, bool) async {
//
//   _usersCollection.doc(user.uid).collection("topics").doc(token).set({
//     'encouragement' : true,
//     'news' : true,
//     'reminder' : true
//   }).then((_){
//     return true;
//   });
//   return false;
// }

/// START: Delete User Account
Future<bool> deleteUserAccount(String userId) async {
  final QuerySnapshot<Object?> snapshot = await firestore
      .collection('users')
      .where('UserId', isEqualTo: userId)
      .get();
  final String docId = snapshot.docs[0].id;
  bool _isDeleted = false;
  try {
    await firestore.collection('users').doc(docId).delete();
    _isDeleted = true;
  } catch (e) {
    _isDeleted = false;
    print('error in deletion: $e');
  }
  // bool _accountDeleted = false;

  // if (_isDeleted) {
  //   try {
  //     await FirebaseAuth.instance.currentUser!.delete();
  //     _accountDeleted = true;
  //   } catch (e) {
  //     print('error in deletion of account: $e');
  //     _accountDeleted = false;
  //   }
  // }

  return _isDeleted;
} 

/// END : Delete User Account