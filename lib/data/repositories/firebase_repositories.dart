import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/application_model.dart';
import '../data/models/opportunity_model.dart';
import '../data/models/startup_model.dart';
import '../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required String campus,
    List<String> skills = const [],
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final profile = UserModel(
      id: uid,
      email: email.trim(),
      fullName: fullName.trim(),
      role: role,
      campus: campus,
      skills: skills,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(profile.toMap());
    return profile;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      throw FirebaseAuthException(code: 'profile-missing', message: 'User profile not found.');
    }
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }
}

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<StartupModel>> watchStartups({VerificationStatus? status}) {
    Query<Map<String, dynamic>> query = _firestore.collection('startups');
    if (status != null) {
      query = query.where('verificationStatus', isEqualTo: status.value);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StartupModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<StartupModel?> getStartupByOwner(String ownerId) async {
    final snapshot = await _firestore
        .collection('startups')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return StartupModel.fromMap(doc.id, doc.data());
  }

  Future<StartupModel> createStartup(StartupModel startup) async {
    final doc = _firestore.collection('startups').doc();
    final model = StartupModel(
      id: doc.id,
      ownerId: startup.ownerId,
      name: startup.name,
      description: startup.description,
      sector: startup.sector,
      campus: startup.campus,
      teamSize: startup.teamSize,
      verificationStatus: VerificationStatus.pending,
      createdAt: DateTime.now(),
    );
    await doc.set(model.toMap());
    return model;
  }

  Future<void> updateVerification({
    required String startupId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    await _firestore.collection('startups').doc(startupId).update({
      'verificationStatus': status.value,
      'verifiedAt': status == VerificationStatus.approved
          ? Timestamp.fromDate(DateTime.now())
          : null,
      'rejectionReason': rejectionReason,
    });
  }
}

class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<OpportunityModel>> watchActiveOpportunities({
    String? category,
    String? campus,
    String? searchQuery,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('opportunities')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      var items = snapshot.docs
          .map((doc) => OpportunityModel.fromMap(doc.id, doc.data()))
          .toList();

      if (category != null && category.isNotEmpty && category != 'All') {
        items = items.where((item) => item.category == category).toList();
      }
      if (campus != null && campus.isNotEmpty && campus != 'All') {
        items = items.where((item) => item.campus == campus).toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        items = items
            .where(
              (item) =>
                  item.title.toLowerCase().contains(q) ||
                  item.startupName.toLowerCase().contains(q) ||
                  item.skillsRequired.any((skill) => skill.toLowerCase().contains(q)),
            )
            .toList();
      }
      return items;
    });
  }

  Stream<List<OpportunityModel>> watchStartupOpportunities(String startupId) {
    return _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OpportunityModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<OpportunityModel> createOpportunity(OpportunityModel opportunity) async {
    final doc = _firestore.collection('opportunities').doc();
    final model = OpportunityModel(
      id: doc.id,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      title: opportunity.title,
      description: opportunity.description,
      category: opportunity.category,
      skillsRequired: opportunity.skillsRequired,
      locationType: opportunity.locationType,
      campus: opportunity.campus,
      durationWeeks: opportunity.durationWeeks,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await doc.set(model.toMap());
    return model;
  }

  Future<void> toggleActive(String opportunityId, bool isActive) async {
    await _firestore.collection('opportunities').doc(opportunityId).update({
      'isActive': isActive,
    });
  }

  Future<OpportunityModel?> getById(String id) async {
    final doc = await _firestore.collection('opportunities').doc(id).get();
    if (!doc.exists) return null;
    return OpportunityModel.fromMap(doc.id, doc.data()!);
  }
}

class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ApplicationModel>> watchStudentApplications(String studentId) {
    return _firestore
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<ApplicationModel>> watchStartupApplications(String startupId) {
    return _firestore
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<bool> hasApplied({
    required String studentId,
    required String opportunityId,
  }) async {
    final snapshot = await _firestore
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<ApplicationModel> submitApplication(ApplicationModel application) async {
    final doc = _firestore.collection('applications').doc();
    final model = ApplicationModel(
      id: doc.id,
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      studentId: application.studentId,
      studentName: application.studentName,
      startupId: application.startupId,
      startupName: application.startupName,
      coverLetter: application.coverLetter,
      status: ApplicationStatus.submitted,
      appliedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(model.toMap());
    await _createNotification(
      userId: application.startupId,
      title: 'New application received',
      body: '${application.studentName} applied for ${application.opportunityTitle}',
      relatedId: model.id,
    );
    return model;
  }

  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
    required String studentId,
    required String opportunityTitle,
  }) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': status.value,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    await _createNotification(
      userId: studentId,
      title: 'Application update',
      body: 'Your application for $opportunityTitle is now ${status.label}',
      relatedId: applicationId,
    );
  }

  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    String? relatedId,
  }) async {
    final doc = _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc();
    await doc.set({
      'title': title,
      'body': body,
      'isRead': false,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

class BookmarkRepository {
  BookmarkRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<Set<String>> watchBookmarkIds(String userId) {
    return _firestore
        .collection('bookmarks')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<void> toggleBookmark({
    required String userId,
    required String opportunityId,
    required bool isBookmarked,
  }) async {
    final ref = _firestore
        .collection('bookmarks')
        .doc(userId)
        .collection('items')
        .doc(opportunityId);
    if (isBookmarked) {
      await ref.delete();
    } else {
      await ref.set({'createdAt': Timestamp.fromDate(DateTime.now())});
    }
  }
}

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AppNotificationModel>> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotificationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
