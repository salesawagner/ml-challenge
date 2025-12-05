//
//  FeedbackViewDisplayModel.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

protocol FeedbackViewShowable: AnyObject {
    func showEmptyState(with displayModel: FeedbackViewDisplayModel)
    func hideEmptyState()
}

struct FeedbackViewDisplayModel {
    let iconName: String
    let title: String
    let message: String?
    let actionButtonTitle: String?
    let action: (() -> Void)?

    init(
        iconName: String = "exclamationmark.triangle",
        title: String,
        message: String? = nil,
        actionButtonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.message = message
        self.actionButtonTitle = actionButtonTitle
        self.action = action
    }
}
