//
//  UICollectionViewExtensions.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

import UIKit

extension UICollectionView {
    func showEmptyState(with displayModel: FeedbackViewDisplayModel) {
        let emptyStateView = FeedbackView()
        emptyStateView.configure(with: displayModel)
        backgroundView = emptyStateView
    }

    func hideEmptyState() {
        backgroundView = nil
    }
}
