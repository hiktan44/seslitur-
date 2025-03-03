import UIKit
import CoreLocation
import Foundation
import AVFoundation

// Gerçek WebRTC kütüphanesini sadece Release modunda import et
#if !DEBUG
import WebRTC
#endif

// WebRTCService sınıfını direkt olarak import et
// WebRTCService.swift dosyası aynı modülde olduğu için özel bir import ifadesi gerekmez

// ... existing code ... 

@objc private func logoutTapped() {
    // Oturumdan çık
    if WebRTCService.shared.isSessionActive() {
        WebRTCService.shared.leaveSession { _, _ in
            // Çıkış yapılıyor, hata kontrol etmeye gerek yok
        }
    }
    
    // Kullanıcı verilerini temizle
    UserDefaults.standard.removeObject(forKey: "authToken")
    UserDefaults.standard.removeObject(forKey: "userId")
    UserDefaults.standard.removeObject(forKey: "userName")
    UserDefaults.standard.removeObject(forKey: "userRole")
    UserDefaults.standard.removeObject(forKey: "currentTourId")
    UserDefaults.standard.removeObject(forKey: "currentTourName")
}

private func connectToVoiceSession(_ session: VoiceSession) {
    // WebRTCService ile bağlantı kur
    WebRTCService.shared.connect(sessionId: session.id) { [weak self] result in
        guard let self = self else { return }
        
        DispatchQueue.main.async {
            switch result {
            case .success:
                self.updateVoiceSessionUI()
                self.showToast(message: "Sesli oturuma bağlanıldı!")
                
                // Mikrofonu varsayılan olarak aktif et
                WebRTCService.shared.setMicrophoneEnabled(true)
                
            case .failure(let error):
                self.showAlert(title: "Bağlantı Hatası", message: "Sesli oturuma bağlanırken bir hata oluştu: \(error.localizedDescription)")
                // Hata durumunda oturumu sonlandır
                self.endVoiceSession()
            }
        }
    }
}

private func disconnectFromVoiceSession() {
    // WebRTCService bağlantısını sonlandır
    WebRTCService.shared.disconnect()
    selectedSession = nil as VoiceSession?
}

// Yeni eklenen metod - Ses oturumu katılımcılarını görüntüler
private func showSessionParticipants() {
    let participants = WebRTCService.shared.getParticipants()
    
    if participants.isEmpty {
        showToast(message: "Oturumda katılımcı bulunmuyor")
        return
    }
    
    let alertController = UIAlertController(
        title: "Katılımcılar",
        message: "Sesli oturumdaki katılımcılar",
        preferredStyle: .actionSheet
    )
    
    // Katılımcıları ekle
    for (_, name) in participants {
        let action = UIAlertAction(title: name, style: .default) { _ in }
        alertController.addAction(action)
    }
    
    // İptal butonu
    alertController.addAction(UIAlertAction(title: "Kapat", style: .cancel))
    
    // iPad için popover ayarı
    if let popoverController = alertController.popoverPresentationController {
        popoverController.sourceView = view
        popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popoverController.permittedArrowDirections = []
    }
    
    present(alertController, animated: true)
}

// Mikrofon durumunu değiştir
@IBAction func toggleMicrophone(_ sender: UIButton) {
    let isEnabled = !WebRTCService.shared.isMicrophoneActive()
    WebRTCService.shared.setMicrophoneEnabled(isEnabled)
    updateMicrophoneButtonUI()
    
    // Kullanıcıya bilgilendirme
    showToast(message: isEnabled ? "Mikrofon açıldı" : "Mikrofon kapatıldı")
}

// Mikrofon butonunun görünümünü güncelle
private func updateMicrophoneButtonUI() {
    if let micButton = microphoneButton {
        let isEnabled = WebRTCService.shared.isMicrophoneActive()
        micButton.setImage(UIImage(systemName: isEnabled ? "mic.fill" : "mic.slash.fill"), for: .normal)
        micButton.tintColor = isEnabled ? .systemGreen : .systemRed
    }
} 