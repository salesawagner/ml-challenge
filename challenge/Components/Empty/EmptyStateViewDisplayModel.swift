//
//  EmptyStateViewDisplayModel.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

struct EmptyStateViewDisplayModel { // FIXME: Remvover?
    let iconName: String
    let title: String
    let message: String?
    let actionButtonTitle: String?
    let action: (() -> Void)?

    init(
        iconName: String = "tray",
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
