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

func make_path(_ pts: [CGPoint]) -> CGPath {

    func mid(_ a:CGPoint, _ b:CGPoint) -> CGPoint {
        return CGPointMake((a.x + b.x) / 2,
                           (a.y + b.y) / 2)
    }

    let w = 20.0;
    let path = CGMutablePath()
    let n = pts.count
    if n == 0 {
        return path
    }

    if n == 1 {
        path.addEllipse(in:CGRect(origin:pts[0], size:CGSize(width:w, height:w)))
    } else if n == 2 {
        path.move(to: pts[0])
        path.addLine(to: pts[1])
    } else {
        path.move(to: pts[0])
        for i in 1...n-2 {
            path.addQuadCurve(to: mid(pts[i], pts[i+1]), control: pts[i])
        }
        path.addQuadCurve(to: pts[n-1], control: pts[n-2])
    }
    return path

}
class PentrekView: UIView
{
    let label = UILabel()
    private let button = UIButton(type: .system)
    weak var viewDelegate: PentrekViewDelegate?

    private var m_paths: [CGPath] = []
    private var m_array: [CGPoint] = []

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        let path = make_path(m_array)
        ctx.saveGState()
        ctx.setStrokeColor(CGColor(red:0, green:0, blue:1, alpha:1))
        ctx.addPath(path)
        ctx.setLineWidth(20)
        ctx.setLineCap(CGLineCap.round)
        ctx.strokePath()
        ctx.restoreGState()

    }
    #if false
    override func draw(_ layer: CALayer, in ctx: CGContext) {
//        UIGraphicsPushContext(ctx);

        let path = make_path(m_array)
        ctx.saveGState()
        ctx.setStrokeColor(CGColor(red:1, green:0, blue:0, alpha:1))
        ctx.addPath(path)
        ctx.setLineWidth(20)
        ctx.strokePath()
        ctx.restoreGState()

//        UIGraphicsPopContext()
    }
    #endif

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

        m_array.removeAll();
        m_array.append(point);
        self.setNeedsDisplay()
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.moved(location: point))

        m_array.append(point);
        self.setNeedsDisplay()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.up(location: point))

        m_array.append(point);
        self.setNeedsDisplay()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let point = touches.first!.location(in: self)
        handleTouch(.up(location: point))

        m_array.removeAll();
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
