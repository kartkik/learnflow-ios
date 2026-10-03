# LearnFlow — Learning Dashboard (iOS Mobile App)

A production-grade Learning Dashboard application built for iOS using **SwiftUI**, **Combine**, and **Clean Architecture + MVVM**.

---

## 📱 Features

- **Screen 1: Login**
  - Input validation (email format, password minimum length)
  - Interactive loading spinner & disabled inputs during network requests
  - Clear error states for invalid credentials
  - Quick auto-fill button for testing/evaluators
  - Secure session token persistence via Apple Keychain

- **Screen 2: Course Dashboard**
  - Course cards showing: Course Title, Instructor Name, Progress Bar %, Number of Lessons, and Action Button
  - Handles **Loading State** (Skeleton shimmer animation), **Success State**, **Empty State**, and **API Failure**
  - Pull-to-refresh & Logout capabilities
  - Live & Simulated **Offline Banner** ("Working Offline - Showing Cached Data")

- **Screen 3: Course Details**
  - Header showing course title, instructor, summary stats, and progress bar
  - Syllabus lesson list displaying completion status (`✓ Completed` / `○ Pending`)
  - **Interactive Lesson Toggle**: Toggling a lesson updates status instantly and dynamically recalculates course progress percentage across all views and local storage!

- **Offline Handling**
  - Cache-First Single Source of Truth Repository backed by **CoreData** (`CoreDataManager` & `CoreDataCourseLocalDataSource`)
  - Network state monitoring via `NWPathMonitor`
  - Persistence across app restarts and network dropouts
  - In-app **"Simulate Offline"** button for quick evaluator testing without disconnecting Mac Wi-Fi


---

## 🏗️ Technical Architecture & Design

### Architectural Pattern: Clean Architecture + MVVM

```
[ View (SwiftUI) ] <---> [ ViewModel (@ObservableObject) ]
                                    │
                                    ▼
                         [ Use Case (Domain Logic) ]
                                    │
                                    ▼
                        [ Repository Interface ]
                                    │
                                    ▼
                       [ Repository Implementation ]
                         │                       │
                         ▼                       ▼
              [ Remote Data Source ]   [ Local Cache Data Source ]
```

### Layer Breakdown
1. **Domain Layer**: Contains pure Swift Entities (`Course`, `Lesson`, `User`), Use Cases (`LoginUseCase`, `GetCoursesUseCase`, `ToggleLessonCompletionUseCase`), and Repository Interfaces. Completely decoupled from UI frameworks and third-party libraries.
2. **Data Layer**: Implements Repositories, Remote Data Sources (mock API latency & error simulation), Local Data Sources (`FileManager` + atomic `JSONEncoder` disk cache), and Keychain Storage.
3. **Presentation Layer**: Consists of SwiftUI Views, custom design components (`ProgressBar`, `CourseCardView`, `LessonRowView`, `ShimmerLoadingView`), and Combine-backed `ViewModels` maintaining state using `ViewState<T>`.

---

## 📑 Technical Assignment Q&A

### 1. Architecture
**Why did you choose your architecture?**
- **Separation of Concerns**: Business logic (progress calculation, authentication validation) is isolated in pure Domain entities and Use Cases, keeping ViewModels thin and Views strictly declarative.
- **Testability**: Protocol-oriented design allows mocking data sources, repositories, and network monitors in unit tests without touching network sockets or disk APIs.
- **Maintainability & Scalability**: Changes to the UI (e.g., swapping SwiftUI views) or Data Layer (e.g., migrating from JSON storage to CoreData/SQLite) do not affect domain business rules.

### 2. Offline Support
**How are you storing and loading offline data?**
- **CoreData Database Persistence**: Offline storage is implemented using **CoreData** via `CoreDataManager` (`NSPersistentContainer`) and `CoreDataCourseLocalDataSource`. Entities (`CDCourse` and `CDLesson`) manage course metadata and lesson completion statuses with a 1-to-many cascade relationship.
- **Single Source of Truth Repository**: `CourseRepository` checks CoreData for cached entities first. When online, it fetches remote data, merges completion statuses, and saves the updated managed objects to CoreData.
- **Network State Detection**: `NetworkMonitor` utilizes `NWPathMonitor` to track network changes in real time. If the app is offline (or simulated offline mode is toggled), the repository immediately serves cached courses from CoreData.
- **Persistent Offline Mutations**: When a user completes a lesson while offline, `ToggleLessonCompletionUseCase` updates the CoreData managed object context instantly and saves it to disk, ensuring progress is preserved across app relaunches.


### 3. Security
**Where would you store authentication tokens in a production application?**
- **Apple Keychain API**: Auth tokens are stored in the iOS Keychain (`kSecClassGenericPassword`) via `KeychainStorage`. Keychain encrypts data at rest using hardware-backed Secure Enclave protection.
- **Production Practices**:
  1. Store access tokens in Keychain and user profile state in encrypted memory.
  2. Implement **SSL Pinning** (using URLSession delegate / Security framework) to protect against Man-in-the-Middle (MITM) attacks.
  3. Enforce OAuth 2.0 with **PKCE** and short-lived JWT Access Tokens paired with Refresh Token Rotation.
  4. Clear Keychain tokens immediately on user logout or session revocation.

### 4. Scale
**If this application had 1 million users + hundreds of courses, mention 3–5 things you would improve:**
1. **Database Migration to SQLite / SwiftData**: Replace JSON file caching with `SQLite` or `SwiftData` featuring indexed fields (`course_id`, `user_id`, `completion_status`), relation mappings, and paginated queries (`LIMIT` / `OFFSET`).
2. **Cursor-Based API Pagination & Delta Syncing**: Implement cursor pagination for fetching courses and Delta Sync (`If-Modified-Since` HTTP headers / ETags) so only updated courses are fetched over the network.
3. **CDN & Image Caching**: Offload course media, videos, and thumbnails to a Global Content Delivery Network (Cloudflare / AWS CloudFront) and utilize `NSCache` for two-tier memory + disk image caching.
4. **Background Sync & Conflict Resolution**: Use `BGTaskScheduler` to queue offline progress updates and resolve server state conflicts using **CRDTs (Conflict-free Replicated Data Types)** or Server Timestamp Precedence.

### 5. Second Platform (Android Implementation)
**How would you implement the exact same application on Android?**
- **Language & UI Framework**: Kotlin with **Jetpack Compose** for declarative UI, implementing `Material3` design components.
- **Architecture**: Clean Architecture + MVVM using Android Architecture Components (`ViewModel`, `StateFlow`, `SharedFlow`).
- **Dependency Injection**: **Hilt** (or Koin) for injecting UseCases, Repositories, and DataSources into ViewModels.
- **Async Concurrency**: **Kotlin Coroutines** (`suspend` functions) and `Flow` for reactive, asynchronous data streams.
- **Networking**: **Retrofit 2** + **OkHttp 4** with Moshi or `kotlinx.serialization` for API requests and network logging interceptors.
- **Offline Storage**: **Room Database** (`@Entity`, `@Dao`, `@Repository`) with reactive `Flow<List<Course>>` emission for automatic UI updates on database mutation.
- **Security**: **EncryptedSharedPreferences** or **Android KeyStore API** for storing JWT auth tokens.

---

## 🧪 Unit Tests

The test suite in `LearnFlowUnitTests.swift` covers:
- **Progress Calculation**: Verifies progress % calculation logic for partial completed lessons (e.g. 2/4 = 50%) and edge cases.
- **Login Validation**: Tests email format regex, password length rules, and error state assignment in `LoginViewModel`.
- **Lesson Completion Toggle**: Verifies interactive lesson toggles and progress recalculation in `CourseDetailViewModel`.
- **Offline Repository Fallback**: Verifies `CourseRepository` serving cached data when offline.

---

## 🚀 Building & Running

1. Open `learnflow-ios.xcodeproj` in Xcode 16 or 17+.
2. Select target `learnflow-ios` and simulator (e.g. iPhone 17).
3. Press `Cmd + R` to build and run.
4. Press `Cmd + U` to execute unit tests.
