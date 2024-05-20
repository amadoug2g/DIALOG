import Foundation

class Env {
    static func getAPIKey() -> String? {
        let apiKey = UserDefaults.standard.string(forKey: "OPENAI_API_KEY")
        if let key = apiKey {
            print("API key retrieved from UserDefaults: \(key)")
        } else {
            print("API key not found in UserDefaults")
        }
        return apiKey
    }
}
