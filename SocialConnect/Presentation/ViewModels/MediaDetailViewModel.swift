import Foundation
import Combine

@MainActor
final class MediaDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var media: Media?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let mediaService: MediaService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(mediaService: MediaService = MediaService()) {
        self.mediaService = mediaService
    }

    // MARK: - Public Methods

    func fetchMediaDetails(for mediaId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedMedia = try await mediaService.fetchMediaDetails(mediaId: mediaId)
            media = fetchedMedia
        } catch {
            handleError(error)
        }
    }

    func toggleFavorite() async {
        guard let media = media else { return }

        do {
            let updatedMedia = try await mediaService.updateFavoriteStatus(mediaId: media.id, isFavorite: !media.isFavorite)
            self.media = updatedMedia
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Methods

    private func handleError(_ error: Error) {
        errorMessage = "An error occurred: \(error.localizedDescription)"
    }
}
