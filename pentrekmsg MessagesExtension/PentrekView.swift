//
//  PentrekView.swift
//  pentrekmsg
//
//  Created by Zachary Duncan on 4/23/25.
//

import SwiftUI

/// State object that determines how the PentrekView draws
struct ToolModel
{
    enum Mode
    {
        case line, erase, smear
    }
    
    enum Color
    {
        case red, green, blue
    }
    
    var mode: ToolModel.Mode = .line
    var color: ToolModel.Color = .blue
    var strokeWidth: CGFloat = 20
    var alpha: CGFloat = 1
    
    func cgColor() -> CGColor
    {
        return CGColor(
            red: color == .red ? 1 : 0,
            green:color == .green ? 1 : 0,
            blue: color == .blue ? 1 : 0,
            alpha: alpha
        )
    }
}

protocol PentrekViewDelegate: AnyObject
{
    func pentrekView(_ view: PentrekView, didReceiveTouchEvent touch: UITouch)
    func pentrekViewDidRequestSticker(_ view: PentrekView, image: UIImage)
}

/// Main canvas object for drawing
class PentrekView: UIView
{
    weak var viewDelegate: PentrekViewDelegate?

    private var toolModel = ToolModel()
    private var points: [CGPoint] = []
    //private var paths: [CGPath] = []
    
    override func didMoveToSuperview()
    {
        backgroundColor = .systemGray6
    }

#if true
    override func draw(_ rect: CGRect)
    {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let path = path(fromPoints: points)
        ctx.saveGState()
        ctx.setStrokeColor(toolModel.cgColor())
        ctx.addPath(path)
        ctx.setLineWidth(toolModel.strokeWidth)
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
        ctx.setStrokeColor(toolConfig.cgColor())
        ctx.addPath(path)
        ctx.setLineWidth(toolConfig.strokeWidth)
        ctx.strokePath()
        ctx.restoreGState()

//        UIGraphicsPopContext()
    }
#endif
    
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
    
    func updateTool(_ changes: @escaping (inout ToolModel) -> Void)
    {
        DispatchQueue.main.async
        {
            changes(&self.toolModel)
            self.setNeedsDisplay()
        }
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
        if touch.phase == .began
        {
            points.removeAll()
        }
        
        points.append(touch.location(in: self))
        self.setNeedsDisplay()
        
        guard let viewDelegate else { return }
        viewDelegate.pentrekView(self, didReceiveTouchEvent: touch)
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

/// Wrapper object for displaying PentrekView in SwiftUI
struct PentrekViewRepresentable: UIViewRepresentable
{
    weak var pentrekView: PentrekView?
    weak var viewDelegate: PentrekViewDelegate?
    
    init(pentrekView: PentrekView) {
        self.pentrekView = pentrekView
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator()
    }

    func makeUIView(context: Context) -> PentrekView
    {
        let view = pentrekView ?? PentrekView()
        return view
    }

    func updateUIView(_ uiView: PentrekView, context: Context)
    {
    }
}
