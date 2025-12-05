//
//  ErrorViewDisplayModel.swift
//  challenge
//
//  Created by Wagner Sales on 03/12/25.
//

struct ErrorViewDisplayModel {
    let title: String
    let message: String?
    let iconName: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    let secondaryButtonTitle: String?
    let secondaryAction: (() -> Void)?

    init(
        title: String,
        message: String? = nil,
        iconName: String = "exclamationmark.triangle",
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.iconName = iconName
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryAction = secondaryAction
    }
}
