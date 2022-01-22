import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ordel/local_storage.dart';

class FirebaseClient {
  final FirebaseAnalyticsObserver _observer;

  List<DateTime> _callsTimeStamps = [];

  bool get isPossibleInfiniteLoop {
    _callsTimeStamps.add(DateTime.now());
    _callsTimeStamps = _callsTimeStamps
        .where((t) =>
            t.isAfter(DateTime.now().subtract(const Duration(seconds: 60))))
        .toList();
    print(
        "------------------${_callsTimeStamps.length} calls in last minute firebase---------------------");
    //kanske behöver göra exception för när vi kör mot eemulator/mock här. kan vi kolla på _firestore för att avgöra det?
    //om mock/emulator så tillåt ett högre antal?
    return _callsTimeStamps.length > 100;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final LocalStorage _localStorage;

  FirebaseClient(this._observer, this._localStorage);
  // CloudFunctions _functions = CloudFunctions.instance;
  // PushNotificationService _notificationService;
  auth.User? _user;
  // String _fcmToken;

  // String get fcmToken => _fcmToken;

  // FieldValue.increment(value)
  // FieldValue.serverTimestamp()

  Future<void> init() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client init---------------------");
    // _firestore ??= FirebaseFirestore.instance;
    // _auth ??= auth.FirebaseAuth.instance;

    // _notificationService = PushNotificationService();
    // _notificationService.initialize();
    // _fcmToken = await _notificationService.token;
    _user = _auth.currentUser!;
  }

  // Future<List<UserPrediction>> getUserPredictions() async {
  //   if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
  //   print(
  //       "------------------firebase_client getUserPredictions---------------------");
  //   CollectionReference predictionsCollection =
  //       _firestore.collection('predictions');

  //   Query hasAccess = predictionsCollection.where('uid', isEqualTo: _user.uid);

  //   List<QuerySnapshot> snapshots = await Future.wait([hasAccess.get()]);

  //   List<UserPrediction> predictions = [];

  //   for (QuerySnapshot snapshot in snapshots) {
  //     predictions
  //         .addAll(snapshot.docs.map((x) => UserPrediction.fromJson(x.data())));
  //   }
  //   return predictions;
  // }

  // Future<void> createUserPrediction(UserPrediction prediction) async {
  //   if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
  //   print(
  //       "------------------firebase_client createUserPrediction---------------------");

  //   prediction.uid ??= _user.uid;
  //   await _firestore
  //       .collection('predictions')
  //       .doc("${prediction.id}${_user.uid}")
  //       .set(prediction.toJson());
  //   // await _firestore.collection('predictions').add(prediction.toJson());
  // }
}
