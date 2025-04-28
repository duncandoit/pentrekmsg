//
//  PentrekView.swift
//  pentrekmsg
//
//  Created by Zachary Duncan on 4/23/25.
//

import UIKit

protocol PentrekViewDelegate: AnyObject
{
    func pentrekView(_ view: PentrekView, didReceiveTouchEvent event: PentrekTouchEvent)
    func pentrekViewDidRequestSticker(_ view: PentrekView, image: UIImage)
}

class PentrekView: UIView
{
    let label = UILabel()
    private let button = UIButton(type: .system)
    weak var viewDelegate: PentrekViewDelegate?
    
    override func didMoveToSuperview()
    {
        backgroundColor = .systemGray6

        setupLabel()
        setupButton()
    }
    
    private func setupLabel()
    {
        label.text = "Touch Position"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupButton()
    {
        button.setTitle("Send as Sticker", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRequestSticker), for: .touchUpInside)
        addSubview(button)

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    @objc private func handleRequestSticker()
    {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
        viewDelegate?.pentrekViewDidRequestSticker(self, image: image)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.down(location: point))
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.moved(location: point))
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.up(location: point))
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.up(location: point))
    }
    
    private func handleTouch(_ event: PentrekTouchEvent)
    {
        guard let viewDelegate else { return }
        viewDelegate.pentrekView(self, didReceiveTouchEvent: event)
    }
}

extension PentrekView: UIGestureRecognizerDelegate
{
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        // Prevents other gestures
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer
        {
            let velocity = pan.velocity(in: self)
            // Restrict to horizontal swipes only
            return abs(velocity.y) < abs(velocity.x)
        }
        return true
    }
}

enum PentrekTouchEvent: Equatable
{
    case down(location: CGPoint)
    case moved(location: CGPoint)
    case up(location: CGPoint)
}
