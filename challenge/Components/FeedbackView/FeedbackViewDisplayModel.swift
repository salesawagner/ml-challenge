//
//  FeedbackViewDisplayModel.swift
//  challenge
//
//  Created by Wagner Sales on 04/12/25.
//

struct FeedbackViewDisplayModel {
    let title: String
    let message: String?
    let actionButtonTitle: String
    let action: () -> Void

    init(
        title: String,
        message: String? = nil,
        actionButtonTitle: String = "Tentar novamente", // FIXME: 
        action: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.actionButtonTitle = actionButtonTitle
        self.action = action
    }
}
