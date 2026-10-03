import SwiftUI

struct OfflineBannerView: View {
    let isOffline: Bool
    let onToggleSimulatedOffline: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isOffline ? "wifi.slash" : "wifi")
                .font(.subheadline.bold())
                .foregroundColor(isOffline ? .white : AppTheme.success)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isOffline ? "Offline Mode Active" : "Online Mode")
                    .font(.caption.bold())
                    .foregroundColor(isOffline ? .white : .primary)
                
                Text(isOffline ? "Showing locally cached courses" : "Connected to LearnFlow API")
                    .font(.caption2)
                    .foregroundColor(isOffline ? .white.opacity(0.85) : .secondary)
            }
            
            Spacer()
            
            Button(action: onToggleSimulatedOffline) {
                Text(isOffline ? "Go Online" : "Simulate Offline")
                    .font(.caption2.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isOffline ? Color.white.opacity(0.25) : AppTheme.primary.opacity(0.12))
                    .foregroundColor(isOffline ? .white : AppTheme.primary)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            isOffline ? AppTheme.warning : Color.gray.opacity(0.08)
        )
        .animation(.default, value: isOffline)
    }
}

#Preview {
    VStack(spacing: 10) {
        OfflineBannerView(isOffline: true, onToggleSimulatedOffline: {})
        OfflineBannerView(isOffline: false, onToggleSimulatedOffline: {})
    }
}
