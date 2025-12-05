//
//  UIImageViewExtensions.swift
//  challenge
//
//  Created by Wagner Sales on 02/12/25.
//

import UIKit

extension UIImageView {
    private static var imageLoadingTaskKey: UInt8 = .zero

    private var imageLoadingTask: Task<Void, Never>? {
        get {
            objc_getAssociatedObject(self, &Self.imageLoadingTaskKey) as? Task<Void, Never>
        }
        set {
            objc_setAssociatedObject(self, &Self.imageLoadingTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func loadImage(from urlString: String?, placeholder: UIImage? = UIImage(systemName: "photo")) {
        cancelImageLoading()
        let imageCache = DependencyContainer.shared.imageCache

        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }

        if let cachedImage = imageCache.image(forKey: urlString) {
            self.image = cachedImage
            return
        }

        self.image = placeholder

        imageLoadingTask = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled, let image = UIImage(data: data) else {
                    return
                }

                imageCache.setImage(image, forKey: urlString)

                await MainActor.run {
                    UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) { [weak self] in
                        self?.image = image
                    }
                }
            } catch {
                return
            }
        }
    }

    func cancelImageLoading() {
        imageLoadingTask?.cancel()
        imageLoadingTask = nil
    }
}
