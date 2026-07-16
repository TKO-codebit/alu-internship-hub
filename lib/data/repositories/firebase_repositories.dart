import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/alu_email_policy.dart';
import '../models/application_model.dart';
import '../models/opportunity_model.dart';
import '../models/recommendation_model.dart';
import '../models/startup_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  void _assertAluEmail(String email) {
    if (!AluEmailPolicy.isAllowed(email)) {
      throw FirebaseAuthException(
        code: 'invalid-domain',
        message:
            'Only ALU school emails are allowed (${AluEmailPolicy.domainHint()}).',
      );
    }
  }

  void _assertRoleMatchesEmail(String email, UserRole role) {
    if (AluEmailPolicy.isFacilitatorDomain(email) && role != UserRole.facilitator) {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: '@${AppConstants.facilitatorDomain} accounts must register as facilitators.',
      );
    }
    if (AluEmailPolicy.isStudentDomain(email) &&
        role != UserRole.student &&
        role != UserRole.startup) {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: '@${AppConstants.studentDomain} accounts can be students or startup founders.',
      );
    }
  }

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
    final normalizedEmail = email.trim().toLowerCase();
    _assertAluEmail(normalizedEmail);
    _assertRoleMatchesEmail(normalizedEmail, role);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final uid = credential.user!.uid;
    final profile = UserModel(
      id: uid,
      email: normalizedEmail,
      fullName: fullName.trim(),
      role: role,
      campus: campus,
      skills: skills,
      authProvider: 'email',
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(profile.toMap());
    return profile;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _assertAluEmail(normalizedEmail);

    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      throw FirebaseAuthException(
        code: 'profile-missing',
        message: 'User profile not found.',
      );
    }
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<UserModel> signInWithGoogle({
    required UserRole role,
    required String campus,
    List<String> skills = const [],
  }) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'google-cancelled', message: 'Sign-in cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;
    final email = (firebaseUser.email ?? '').trim().toLowerCase();

    _assertAluEmail(email);

    final existing = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (existing.exists) {
      return UserModel.fromMap(existing.id, existing.data()!);
    }

    _assertRoleMatchesEmail(email, role);

    final profile = UserModel(
      id: firebaseUser.uid,
      email: email,
      fullName: firebaseUser.displayName ?? email.split('@').first,
      role: AluEmailPolicy.lockedRoleForEmail(email) ?? role,
      campus: campus,
      skills: skills,
      photoUrl: firebaseUser.photoURL,
      authProvider: 'google',
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(firebaseUser.uid).set(profile.toMap());
    return profile;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> updateProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<List<UserModel>> getFacilitators() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.facilitator.value)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList();
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
    final query = _firestore
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

    final startupDoc = await _firestore.collection('startups').doc(application.startupId).get();
    final ownerId = startupDoc.data()?['ownerId'] as String?;
    if (ownerId != null) {
      await _createNotification(
        userId: ownerId,
        title: 'New application received',
        body: '${application.studentName} applied for ${application.opportunityTitle}',
        relatedId: model.id,
      );
    }
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

class RecommendationRepository {
  RecommendationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<RecommendationModel>> watchStudentRecommendations(String studentId) {
    return _firestore
        .collection('recommendations')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecommendationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<RecommendationModel>> watchFacilitatorRecommendations(
    String facilitatorId,
  ) {
    return _firestore
        .collection('recommendations')
        .where('facilitatorId', isEqualTo: facilitatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecommendationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<RecommendationModel> requestRecommendation({
    required UserModel student,
    required UserModel facilitator,
    required String purpose,
    required String message,
  }) async {
    final doc = _firestore.collection('recommendations').doc();
    final model = RecommendationModel(
      id: doc.id,
      studentId: student.id,
      studentName: student.fullName,
      facilitatorId: facilitator.id,
      facilitatorName: facilitator.fullName,
      purpose: purpose,
      message: message,
      status: RecommendationStatus.pending,
      linkedInUrl: student.linkedInUrl,
      githubUrl: student.githubUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(model.toMap());

    await _createNotification(
      userId: facilitator.id,
      title: 'Recommendation request',
      body: '${student.fullName} requested a recommendation for $purpose',
      relatedId: model.id,
    );
    return model;
  }

  Future<void> respondToRecommendation({
    required String recommendationId,
    required String studentId,
    required RecommendationStatus status,
    String? recommendationText,
  }) async {
    await _firestore.collection('recommendations').doc(recommendationId).update({
      'status': status.value,
      'recommendationText': recommendationText,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final label = status == RecommendationStatus.completed
        ? 'completed'
        : status == RecommendationStatus.declined
            ? 'declined'
            : 'updated';

    await _createNotification(
      userId: studentId,
      title: 'Recommendation $label',
      body: status == RecommendationStatus.completed
          ? 'Your facilitator submitted a recommendation.'
          : 'Your recommendation request was declined.',
      relatedId: recommendationId,
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
