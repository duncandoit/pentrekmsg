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
            print("Touched down at: \(location)")
            view.label.text = "Touch location: \(location)"
            
        case .moved(location: let location):
            print("Touch moved to: \(location)")
            view.label.text = "Touch location: \(location)"
            
        case .up(location: let location):
            print("Touch lifted up at: \(location)")
            view.label.text = "Touch location: \(location)"
        }
    }
}
