import SwiftUI

struct CourseDetailView: View {
    @StateObject var viewModel: CourseDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                        Text("Dashboard")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(AppTheme.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Course Title & Info Header Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text(viewModel.course.title)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .foregroundColor(AppTheme.primary)
                            Text("Instructor: \(viewModel.course.instructor)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Summary Stats Grid
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Overall Progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.course.progress)%")
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Completed Lessons")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.completedLessonsCount) of \(viewModel.totalLessonsCount)")
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.success)
                            }
                        }
                        
                        ProgressBar(progress: Double(viewModel.course.progress), height: 10, showLabel: false)
                    }
                    .padding(20)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    
                    // Lessons List Header
                    HStack {
                        Text("Course Syllabus & Lessons")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Tap to Toggle")
                            .font(.caption)
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.horizontal, 20)
                    
                    // Lessons List
                    VStack(spacing: 10) {
                        ForEach(viewModel.course.lessons) { lesson in
                            LessonRowView(
                                lesson: lesson,
                                onToggle: {
                                    viewModel.toggleLesson(lesson)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
