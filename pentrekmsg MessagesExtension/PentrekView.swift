//
//  PentrekView.swift
//  pentrekmsg
//
//  Created by Zachary Duncan on 4/23/25.
//

import UIKit

protocol PentrekViewDelegate: AnyObject
{
    func pentrekView(_ view: PentrekView, didReceiveTouchEvent touch: UITouch)
    func pentrekViewDidRequestSticker(_ view: PentrekView, image: UIImage)
}

class PentrekView: UIView
{
    let label = UILabel()
    weak var viewDelegate: PentrekViewDelegate?

    //private var paths: [CGPath] = []
    private var points: [CGPoint] = []

#if true
    override func draw(_ rect: CGRect)
    {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let path = path(fromPoints: points)
        ctx.saveGState()
        ctx.setStrokeColor(CGColor(red:0, green:0, blue:1, alpha:1))
        ctx.addPath(path)
        ctx.setLineWidth(20)
        ctx.setLineCap(CGLineCap.round)
        ctx.strokePath()
        ctx.restoreGState()

    }
#else
    override func draw(_ layer: CALayer, in ctx: CGContext)
    {
//        UIGraphicsPushContext(ctx);

        let path = path(fromPoints: points)
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
    }
    
    private func setupLabel()
    {
        label.text = "Touch Position"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @objc func handleRequestSticker()
    {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
        viewDelegate?.pentrekViewDidRequestSticker(self, image: image)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouch(touches.first)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouch(touches.first)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouch(touches.first)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        handleTouch(touches.first)
    }
    
    private func handleTouch(_ touch: UITouch?)
    {
        guard let touch = touch else { return }
        guard let viewDelegate else { return }
        
        viewDelegate.pentrekView(self, didReceiveTouchEvent: touch)
        
        if touch.phase == .began
        {
            points.removeAll()
        }
        
        points.append(touch.location(in: self))
        self.setNeedsDisplay()
    }
    
    func path(fromPoints pts: [CGPoint]) -> CGPath
    {

        func mid(_ a:CGPoint, _ b:CGPoint) -> CGPoint
        {
            return CGPointMake((a.x + b.x) / 2, (a.y + b.y) / 2)
        }

        let w = 20.0
        let path = CGMutablePath()
        let n = pts.count
        
        if n == 0
        {
            return path
        }

        if n == 1
        {
            path.addEllipse(in:CGRect(origin:pts[0], size:CGSize(width:w, height:w)))
        }
        else if n == 2
        {
            path.move(to: pts[0])
            path.addLine(to: pts[1])
        }
        else
        {
            path.move(to: pts[0])
            for i in 1...n-2
            {
                path.addQuadCurve(to: mid(pts[i], pts[i+1]), control: pts[i])
            }
            path.addQuadCurve(to: pts[n-1], control: pts[n-2])
        }
        
        return path
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
