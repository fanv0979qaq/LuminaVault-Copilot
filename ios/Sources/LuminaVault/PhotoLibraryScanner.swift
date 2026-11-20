import Foundation
import Photos

public enum AssetExportRole: String, Codable, Sendable {
    case original
    case editedRendered
    case livePhotoStill
    case livePhotoVideo
    case adjustmentData
}

public struct AssetExportManifest: Codable, Sendable {
    public let localAssetIdentifier: String
    public let mediaType: String
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let creationDate: Date?
    public let modificationDate: Date?
    public let locationLatitude: Double?
    public let locationLongitude: Double?
    public let livePhoto: Bool
    public let resourceRoles: [String]
}

public final class PhotoLibraryScanner {
    public init() {}

    public func authorizationStatus() -> PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    public func requestAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status)
            }
        }
    }

    public func scanAssets() -> [AssetExportManifest] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(with: options)
        var manifests: [AssetExportManifest] = []

        result.enumerateObjects { asset, _, _ in
            let live = asset.mediaSubtypes.contains(.photoLive)
            let location = asset.location?.coordinate
            manifests.append(AssetExportManifest(
                localAssetIdentifier: asset.localIdentifier,
                mediaType: asset.mediaType == .video ? "video" : "image",
                pixelWidth: asset.pixelWidth,
                pixelHeight: asset.pixelHeight,
                creationDate: asset.creationDate,
                modificationDate: asset.modificationDate,
                locationLatitude: location?.latitude,
                locationLongitude: location?.longitude,
                livePhoto: live,
                resourceRoles: live
                    ? [AssetExportRole.original.rawValue,
                       AssetExportRole.livePhotoStill.rawValue,
                       AssetExportRole.livePhotoVideo.rawValue,
                       AssetExportRole.adjustmentData.rawValue]
                    : [AssetExportRole.original.rawValue,
                       AssetExportRole.editedRendered.rawValue,
                       AssetExportRole.adjustmentData.rawValue]
            ))
        }
        return manifests
    }
}
