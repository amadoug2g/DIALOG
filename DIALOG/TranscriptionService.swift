import Foundation

class TranscriptionService {
    private let apiKey: String?

    init() {
        self.apiKey = Env.getAPIKey()
        if let key = self.apiKey {
            print("API key set in TranscriptionService: \(key)")
        } else {
            print("No API key found in TranscriptionService")
        }
    }

    func transcribeAudio(fileURL: URL, completion: @escaping (String?) -> Void) {
        guard let apiKey = apiKey else {
            completion("API key not found.")
            return
        }

        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createBody(boundary: boundary, fileURL: fileURL)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Network error: \(error.localizedDescription)")
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("No data received from server.")
                print("No data received from server.")
                return
            }
            
            // Print the response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
            // Attempt to parse the JSON response
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Print the parsed JSON for debugging
                    print("Parsed JSON: \(responseJSON)")
                    
                    if let text = responseJSON["text"] as? String {
                        completion(text)
                    } else {
                        completion("Transcription not found in response.")
                        print("Transcription not found in response.")
                    }
                } else {
                    completion("Failed to parse transcription: invalid JSON format.")
                    print("Failed to parse transcription: invalid JSON format.")
                }
            } catch {
                completion("Failed to parse transcription: \(error.localizedDescription)")
                print("Failed to parse transcription: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func createBody(boundary: String, fileURL: URL) -> Data {
        var body = Data()
        let filename = fileURL.lastPathComponent
        let mimetype = "audio/mp3" // Adjust MIME type if necessary
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        
        if let fileData = try? Data(contentsOf: fileURL) {
            body.append(fileData)
        }
        
        body.append("\r\n")
        
        let parameters = [
            "timestamp_granularities[]": "word",
            "model": "whisper-1",
            "response_format": "verbose_json"
        ]
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
