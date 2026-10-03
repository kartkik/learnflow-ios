import SwiftUI

struct LessonRowView: View {
    let lesson: Lesson
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Checkbox icon
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(lesson.isCompleted ? AppTheme.success : Color.gray.opacity(0.5))
                
                Text(lesson.title)
                    .font(.body)
                    .foregroundColor(lesson.isCompleted ? .primary : .secondary)
                    .strikethrough(lesson.isCompleted, color: Color.secondary.opacity(0.4))
                
                Spacer()
                
                // Status badge
                HStack(spacing: 4) {
                    Text(lesson.isCompleted ? "✓ Completed" : "○ Pending")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(lesson.isCompleted ? AppTheme.success : Color.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    lesson.isCompleted ? AppTheme.success.opacity(0.12) : Color.gray.opacity(0.1)
                )
                .cornerRadius(8)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        LessonRowView(lesson: Lesson(id: 1, title: "Introduction & Setup", isCompleted: true), onToggle: {})
        LessonRowView(lesson: Lesson(id: 2, title: "Variables & Data Types", isCompleted: false), onToggle: {})
    }
    .padding()
    .background(AppTheme.background)
}
