//
//  ReusableView.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        "\(String(describing: self))Identifier"
    }
}
