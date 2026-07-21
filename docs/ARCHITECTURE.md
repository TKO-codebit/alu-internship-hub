# ALUhub — System Architecture

## Problem statement

ALU students often struggle to secure internships at large organizations, while student founders on campus need affordable talent in software, design, marketing, operations, and research. **ALUhub** bridges this gap with a verified, ALU-specific marketplace.

## High-level architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  Screens (Material 3) ◄──► BLoC / Cubit ◄──► UI Widgets     │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                      Domain / Data Layer                     │
│              Repositories (abstract Firebase I/O)            │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                        Firebase Backend                      │
│   Auth │ Firestore (real-time streams) │ FCM (notifications)│
└─────────────────────────────────────────────────────────────┘
```

## State management — BLoC / Cubit

| Feature | Pattern | Why |
|---------|---------|-----|
| Authentication | `AuthBloc` | Multi-step flows, session persistence, role routing |
| Opportunities feed | `OpportunityBloc` | Stream subscription, search/filter side effects |
| Applications | `ApplicationCubit` | Simpler CRUD + status updates |
| Bookmarks | `BookmarkCubit` | Toggle state with optimistic UI |
| Startup verification | `StartupCubit` | Admin approval workflow |

**Why BLoC:** Clear separation of UI and business logic, easy to demo state propagation during evaluation, and testable with `bloc_test`.

## User roles

| Role | Capabilities |
|------|--------------|
| **Student** | Browse verified opportunities, apply, track applications, bookmark, manage portfolio |
| **Startup founder** | Create startup profile (pending verification), post opportunities, review applicants |
| **Admin** | Verify ALU startups, reject invalid profiles |

## Firestore schema

### `users/{userId}`
```json
{
  "email": "student@alu.edu",
  "fullName": "Jane Doe",
  "role": "student",
  "campus": "Kigali",
  "skills": ["Flutter", "UI Design"],
  "bio": "...",
  "portfolioUrl": "https://...",
  "photoUrl": null,
  "createdAt": "Timestamp"
}
```

### `startups/{startupId}`
```json
{
  "ownerId": "uid",
  "name": "EcoTrack Rwanda",
  "description": "...",
  "sector": "Climate Tech",
  "campus": "Kigali",
  "teamSize": 4,
  "verificationStatus": "pending | approved | rejected",
  "verifiedAt": "Timestamp | null",
  "logoUrl": null
}
```

### `opportunities/{id}`
```json
{
  "startupId": "...",
  "startupName": "EcoTrack Rwanda",
  "title": "Mobile Developer Intern",
  "description": "...",
  "category": "Software Development",
  "skillsRequired": ["Flutter", "Firebase"],
  "locationType": "hybrid",
  "campus": "Kigali",
  "durationWeeks": 8,
  "isActive": true,
  "createdAt": "Timestamp"
}
```

### `applications/{id}`
```json
{
  "opportunityId": "...",
  "studentId": "...",
  "studentName": "...",
  "startupId": "...",
  "coverLetter": "...",
  "status": "submitted | reviewing | accepted | rejected",
  "appliedAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

## Real-time updates

- Opportunity feed: `snapshots()` stream on `opportunities` where `isActive == true`
- Application tracking: stream filtered by `studentId` or `startupId`
- Notifications: subcollection stream per user

## Scalability considerations

- Composite indexes for `(isActive, createdAt)` and `(startupId, status)` queries
- Denormalized `startupName` on opportunities to avoid N+1 reads on list screens
- Pagination via `startAfterDocument` (future improvement)
- Security rules enforce role-based access at the database layer

## Folder structure

```
lib/
├── app.dart
├── main.dart
├── core/
├── data/
│   ├── models/
│   └── repositories/
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── shell/
│   ├── opportunities/
│   ├── applications/
│   ├── startups/
│   ├── profile/
│   ├── bookmarks/
│   ├── notifications/
│   └── admin/
└── firebase/
```
