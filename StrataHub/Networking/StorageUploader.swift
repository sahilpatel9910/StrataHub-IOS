import Foundation
import Supabase

struct SignedUploadURLResponse: Decodable {
    let signedUrl: String
    let path: String
}

enum StorageUploaderError: Error, LocalizedError {
    case invalidSignedURL
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidSignedURL: return "The upload link was invalid."
        case .requestFailed(let message): return message
        }
    }
}

enum StorageUploader {
    /// Calls a plain StrataHub REST route (not tRPC — no superjson envelope) that returns
    /// a Supabase signed upload URL for the given bucket/target.
    static func requestSignedUploadURL(routePath: String, body: [String: String]) async throws -> SignedUploadURLResponse {
        var request = URLRequest(url: TRPCClient.baseURL.appendingPathComponent(routePath))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = try? await SupabaseManager.shared.validAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw StorageUploaderError.requestFailed("Could not get an upload link.")
        }
        return try JSONDecoder().decode(SignedUploadURLResponse.self, from: data)
    }

    /// Supabase's signed-upload endpoint expects multipart form data, so this goes through
    /// the SDK's storage client rather than a raw PUT of the image bytes.
    static func upload(bucket: String, data: Data, contentType: String, signedUpload: SignedUploadURLResponse) async throws {
        guard let signedURL = URL(string: signedUpload.signedUrl),
              let token = URLComponents(url: signedURL, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "token" })?.value else {
            throw StorageUploaderError.invalidSignedURL
        }

        try await SupabaseManager.shared.client.storage
            .from(bucket)
            .uploadToSignedURL(path: signedUpload.path, token: token, data: data, options: FileOptions(contentType: contentType))
    }
}
