import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "OPENAI_API_KEY") ?? ""
    
    var body: some View {
        VStack {
            TextField("Enter OpenAI API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
                UserDefaults.standard.set(self.apiKey, forKey: "OPENAI_API_KEY")
                print("API Key saved: \(self.apiKey)")
            }
            .padding()
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
