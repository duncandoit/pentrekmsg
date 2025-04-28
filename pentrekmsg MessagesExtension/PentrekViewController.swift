//
//  PentrekViewController.swift
//  pentrekmsg
//
//  Created by Zachary Duncan on 4/23/25.
//

import UIKit

class PentrekViewController: UIViewController
{
    weak var messagesDelegate: MessagesViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white

        let pentrekView = PentrekView(frame: view.bounds)
        pentrekView.viewDelegate = self
        pentrekView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pentrekView)
    }
}

extension PentrekViewController: PentrekViewDelegate
{
    func pentrekViewDidRequestSticker(_ view: PentrekView, image: UIImage)
    {
        messagesDelegate?.sendSticker(from: image)
    }
    
    func pentrekView(_ view: PentrekView, didReceiveTouchEvent event: PentrekTouchEvent)
    {
        switch event
        {
        case .down(location: let location):
            view.label.text = "Touched down at: (\(Int(location.x)),\(Int(location.y)))"
            
        case .moved(location: let location):
            view.label.text = "Touch moved to: (\(Int(location.x)),\(Int(location.y)))"
            
        case .up(location: let location):
            view.label.text = "Touch lifted up at (\(Int(location.x)),\(Int(location.y)))"
        }
    }
}
