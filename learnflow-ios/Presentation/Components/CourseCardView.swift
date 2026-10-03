import SwiftUI

struct CourseCardView: View {
    let course: Course
    let onContinueTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(course.instructor)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Lesson badge
                HStack(spacing: 4) {
                    Image(systemName: "book.fill")
                        .font(.caption2)
                    Text("\(course.lessonsCount) lessons")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(AppTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.primary.opacity(0.1))
                .clipShape(Capsule())
            }
            
            // Progress Section
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(course.progress)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.primary)
                }
                
                ProgressBar(progress: Double(course.progress), height: 8, showLabel: false)
            }
            
            Divider()
            
            // Action Button
            Button(action: onContinueTap) {
                HStack {
                    Text("Continue Course")
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .foregroundColor(AppTheme.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    CourseCardView(
        course: Course(
            id: 1,
            title: "Python Programming",
            instructor: "John Smith",
            progress: 65,
            lessonsCount: 20
        ),
        onContinueTap: {}
    )
    .padding()
    .background(AppTheme.background)
}
