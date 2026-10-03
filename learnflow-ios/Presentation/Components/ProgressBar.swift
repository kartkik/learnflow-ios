import SwiftUI

struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0 or percentage 0..100
    var height: CGFloat = 8
    var showLabel: Bool = true
    
    private var normalizedProgress: Double {
        let value = progress > 1.0 ? progress / 100.0 : progress
        return min(max(value, 0.0), 1.0)
    }
    
    private var percentageText: String {
        return "\(Int(normalizedProgress * 100))%"
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            if showLabel {
                Text(percentageText)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: height)
                    
                    Capsule()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: geometry.size.width * CGFloat(normalizedProgress), height: height)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: normalizedProgress)
                }
            }
            .frame(height: height)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.65)
        ProgressBar(progress: 25.0)
        ProgressBar(progress: 100.0, height: 12)
    }
    .padding()
}
