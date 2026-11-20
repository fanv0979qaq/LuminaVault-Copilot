import Foundation

public struct UploadAssetRequest: Codable, Sendable {
    public let photoLibraryId: String
    public let localId: String
    public let kind: String
    public let sha256: String

    public init(photoLibraryId: String, localId: String, kind: String, sha256: String) {
        self.photoLibraryId = photoLibraryId
        self.localId = localId
        self.kind = kind
        self.sha256 = sha256
    }
}

public struct LuminaVaultError: Error, LocalizedError {
    public let message: String
    public var errorDescription: String? { message }
}

public final class LuminaVaultClient {
    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func health() async throws -> Bool {
        let (data, response) = try await session.data(from: baseURL.appendingPathComponent("health"))
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw LuminaVaultError(message: "Server health check failed")
        }
        return data.count > 0
    }

    public func uploadAsset(_ asset: UploadAssetRequest) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/v1/assets"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(asset)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw LuminaVaultError(message: "Asset upload failed")
        }
    }
}
