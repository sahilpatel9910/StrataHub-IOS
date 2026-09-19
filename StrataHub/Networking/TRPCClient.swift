import Foundation

struct TRPCError: Error, LocalizedError {
    let code: String
    let message: String

    var errorDescription: String? { message }

    static let unauthorizedCode = "UNAUTHORIZED"
}

private struct InputEnvelope<T: Encodable>: Encodable {
    let json: T
}

private struct EmptyOutput: Decodable {}

private struct SuccessEnvelope<T: Decodable>: Decodable {
    struct Result: Decodable {
        struct Data: Decodable {
            let json: T
        }
        let data: Data
    }
    let result: Result
}

/// tRPC v11 wraps the *entire* error object through the superjson transformer,
/// so the actual TRPCError code lives at error.json.data.code, not error.data.code.
private struct ErrorEnvelope: Decodable {
    struct Wrapper: Decodable {
        struct Payload: Decodable {
            struct ErrorData: Decodable {
                let code: String
                let httpStatus: Int?
            }
            let message: String
            let data: ErrorData?
        }
        let json: Payload
    }
    let error: Wrapper
}

enum TRPCClient {
    /// Swap to "http://localhost:3000" (with an ATS exception) for local dev against `npm run dev`.
    static var baseURL = URL(string: "https://stratahub-six.vercel.app")!

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = isoFractionalFormatter.date(from: string) { return date }
            if let date = isoFormatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(string)")
        }
        return decoder
    }()

    private static let isoFormatter = ISO8601DateFormatter()
    private static let isoFractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    // MARK: - Queries

    static func query<Output: Decodable>(_ path: String) async throws -> Output {
        try await performQuery(path, inputJSON: nil)
    }

    static func query<Input: Encodable, Output: Decodable>(_ path: String, input: Input) async throws -> Output {
        let data = try encoder.encode(InputEnvelope(json: input))
        let inputJSON = String(data: data, encoding: .utf8)
        return try await performQuery(path, inputJSON: inputJSON)
    }

    // MARK: - Mutations

    static func mutate<Input: Encodable, Output: Decodable>(_ path: String, input: Input) async throws -> Output {
        let body = try encoder.encode(InputEnvelope(json: input))
        return try await performMutation(path, body: body)
    }

    static func mutate<Input: Encodable>(_ path: String, input: Input) async throws {
        let _: EmptyOutput = try await mutate(path, input: input)
    }

    // MARK: - Transport

    private static func performQuery<Output: Decodable>(_ path: String, inputJSON: String?) async throws -> Output {
        var components = URLComponents(url: baseURL.appendingPathComponent("api/trpc/\(path)"), resolvingAgainstBaseURL: false)!
        if let inputJSON {
            components.queryItems = [URLQueryItem(name: "input", value: inputJSON)]
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        return try await send(request)
    }

    private static func performMutation<Output: Decodable>(_ path: String, body: Data) async throws -> Output {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/trpc/\(path)"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return try await send(request)
    }

    private static func send<Output: Decodable>(_ request: URLRequest) async throws -> Output {
        var request = request
        if let token = try? await SupabaseManager.shared.validAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw TRPCError(code: "TRANSPORT", message: "No HTTP response received")
        }

        if (200..<300).contains(http.statusCode) {
            let envelope = try decoder.decode(SuccessEnvelope<Output>.self, from: data)
            return envelope.result.data.json
        }

        if let errorEnvelope = try? decoder.decode(ErrorEnvelope.self, from: data) {
            let code = errorEnvelope.error.json.data?.code ?? "UNKNOWN"
            if code == TRPCError.unauthorizedCode {
                await SupabaseManager.shared.signOut()
            }
            throw TRPCError(code: code, message: errorEnvelope.error.json.message)
        }

        throw TRPCError(code: "HTTP_\(http.statusCode)", message: "Request failed with status \(http.statusCode)")
    }
}
