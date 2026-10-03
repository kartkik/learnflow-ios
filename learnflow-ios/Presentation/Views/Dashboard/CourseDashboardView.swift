import SwiftUI

struct CourseDashboardView: View {
    @StateObject var viewModel: CourseDashboardViewModel
    let onSelectCourse: (Course) -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Offline Status Banner
            OfflineBannerView(
                isOffline: viewModel.isOfflineMode,
                onToggleSimulatedOffline: {
                    viewModel.toggleSimulatedOffline()
                }
            )
            
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(viewModel.userName)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.logout()
                    onLogout()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body.bold())
                        .foregroundColor(AppTheme.danger)
                        .padding(10)
                        .background(AppTheme.danger.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Content Body based on ViewState
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Enrolled Courses")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    switch viewModel.state {
                    case .loading:
                        ShimmerLoadingView()
                            .padding(.horizontal, 20)
                            
                    case .success(let courses):
                        VStack(spacing: 16) {
                            ForEach(courses) { course in
                                CourseCardView(
                                    course: course,
                                    onContinueTap: {
                                        onSelectCourse(course)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                    case .empty:
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No courses available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Button("Refresh") {
                                viewModel.loadCourses(forceRefresh: true)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, minHeight: 250)
                        
                    case .failure(let errorMsg):
                        VStack(spacing: 16) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(AppTheme.danger)
                            Text("Failed to Load Courses")
                                .font(.headline)
                            Text(errorMsg)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: {
                                viewModel.loadCourses(forceRefresh: true)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Retry API Request")
                                }
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 280)
                        
                    case .idle:
                        EmptyView()
                    }
                }
                .padding(.bottom, 30)
            }
            .refreshable {
                viewModel.loadCourses(forceRefresh: true)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear {
            viewModel.loadCourses(forceRefresh: false)
        }
    }
}
