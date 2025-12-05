//
//  ViewCoding.swift
//  challenge
//
//  Created by Wagner Sales on 01/12/25.
//

protocol ViewCoding {
    func setupView()
    func configure()
    func buildHierarchy()
    func buildConstraints()
}

extension ViewCoding {
    func setupView() {
        configure()
        buildHierarchy()
        buildConstraints()
    }

    // Make Optional
    func configure() {}
    func buildHierarchy() {}
    func buildConstraints() {}
}
