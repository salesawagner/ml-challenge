//
//  UIViewExtensions.swift
//  challenge
//
//  Created by Wagner Sales
//

import UIKit

extension UIView {
    private func addSubviewIfNeeded(to view: UIView) {
        guard superview != view else {
            return
        }

        if superview != nil {
            removeFromSuperview()
        }

        view.addSubview(self)
    }
}

// MARK: Constraints Helper

extension UIView {
    @discardableResult
    func fill(on view: UIView, insets: UIEdgeInsets = .zero, useSafeArea: Bool = false) -> [NSLayoutConstraint] {
        addSubviewIfNeeded(to: view)
        translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint]

        if useSafeArea {
            constraints = fillSafeArea(on: view, insets: insets)
        } else {
            constraints = fillDirect(on: view, insets: insets)
        }

        return constraints
    }

    @discardableResult
    private func fillSafeArea(on view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
        ]

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    private func fillDirect(on view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ]

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func center(on view: UIView, offset: CGPoint = .zero) -> [NSLayoutConstraint] {
        addSubviewIfNeeded(to: view)
        translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.x),
            centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.y)
        ]

        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}

// MARK: - Shadow Helpers

extension UIView {
    func applyShadow(elevation: ShadowElevation) {
        layer.shadowColor = Colors.shadowColor(elevation: elevation).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowRadius = elevation.radius
        layer.shadowOffset = elevation.offset
        layer.masksToBounds = false
    }

    func removeShadow() {
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
    }
}
