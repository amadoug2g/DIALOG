import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFile: URL?
    @State private var transcription: String = "Transcription will appear here."
    @State private var showingSettings = false
    private let transcriptionService = TranscriptionService()

    var body: some View {
        VStack {
            if let selectedFile = selectedFile {
                Text("Selected File: \(selectedFile.lastPathComponent)")
            } else {
                Text("No file selected")
            }
            
            Button("Select Audio File") {
                selectFile()
            }
            .padding()
            
            Button("Transcribe") {
                if let selectedFile = selectedFile {
                    transcribe(fileURL: selectedFile)
                }
            }
            .padding()
            
            Button("Settings") {
                showingSettings = true
            }
            .padding()
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            
            Text(transcription)
                .padding()
        }
        .padding()
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType.audio,
            UTType.mp3,
            UTType.mpeg4Audio
        ]
        panel.begin { response in
            if response == .OK {
                self.selectedFile = panel.url
            }
        }
    }

    private func transcribe(fileURL: URL) {
        self.transcription = "Transcribing..."
        transcriptionService.transcribeAudio(fileURL: fileURL) { result in
            DispatchQueue.main.async {
                self.transcription = result ?? "Failed to transcribe"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
