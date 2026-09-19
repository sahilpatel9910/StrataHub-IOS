import Foundation
import UIKit

@Observable
final class MaintenanceDetailViewModel {
    let requestId: String

    var isLoading = true
    var errorMessage: String?
    var request: MaintenanceRequestDetail?

    var newComment = ""
    var isSubmittingComment = false

    var isUploadingPhoto = false
    var uploadErrorMessage: String?

    init(requestId: String) {
        self.requestId = requestId
    }

    private struct IDInput: Encodable { let id: String }
    private struct CommentInput: Encodable { let maintenanceRequestId: String; let content: String }
    private struct AddImageInput: Encodable { let maintenanceRequestId: String; let storagePath: String }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            request = try await TRPCClient.query("maintenance.getById", input: IDInput(id: requestId))
        } catch {
            errorMessage = (error as? TRPCError)?.message ?? "Couldn't load this request."
        }
        isLoading = false
    }

    func submitComment() async {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSubmittingComment = true
        defer { isSubmittingComment = false }
        do {
            try await TRPCClient.mutate("maintenance.addComment", input: CommentInput(maintenanceRequestId: requestId, content: trimmed))
            newComment = ""
            await load()
        } catch {
            errorMessage = (error as? TRPCError)?.message ?? "Couldn't post your comment."
        }
    }

    func uploadPhoto(image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        isUploadingPhoto = true
        uploadErrorMessage = nil
        defer { isUploadingPhoto = false }
        do {
            let signed = try await StorageUploader.requestSignedUploadURL(
                routePath: "api/storage/maintenance-upload-url",
                body: ["filename": "photo.jpg", "contentType": "image/jpeg", "maintenanceRequestId": requestId]
            )
            try await StorageUploader.upload(bucket: "maintenance", data: data, contentType: "image/jpeg", signedUpload: signed)
            try await TRPCClient.mutate("maintenance.addImage", input: AddImageInput(maintenanceRequestId: requestId, storagePath: signed.path))
            await load()
        } catch let error as TRPCError {
            uploadErrorMessage = error.message
        } catch let error as StorageUploaderError {
            uploadErrorMessage = error.errorDescription
        } catch {
            uploadErrorMessage = "Couldn't upload photo."
        }
    }
}
