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
        view.backgroundColor = .systemBackground
        setupViews()
    }
    
    private func setupViews() {
        let sendButton = UIButton(type: .system)
        let stackView = UIStackView()
        let pentrekView = PentrekView(frame: view.bounds)
        
        pentrekView.viewDelegate = self
        pentrekView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pentrekView)
        
        sendButton.setTitle("Send Sticker", for: .normal)
        sendButton.addTarget(pentrekView, action: #selector(pentrekView.handleRequestSticker), for: .touchUpInside)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(pentrekView)
        stackView.addArrangedSubview(sendButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            pentrekView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension PentrekViewController: PentrekViewDelegate
{
    func pentrekViewDidRequestSticker(_ view: PentrekView, image: UIImage)
    {
        messagesDelegate?.sendSticker(from: image)
    }
    
    func pentrekView(_ view: PentrekView, didReceiveTouchEvent touch: UITouch)
    {
        //switch touch.phase {
        //case .began:
        //    print("Began at: (\(Int(touch.location(in: view).x)),\(Int(touch.location(in: view).y)))")
        //
        //case .moved:
        //    print(view.label.text = "Moved to: (\(Int(touch.location(in: view).x)),\(Int(touch.location(in: view).y)))")
        //
        //case .ended, .cancelled:
        //    print(view.label.text = "Ended at (\(Int(touch.location(in: view).x)),\(Int(touch.location(in: view).y)))")
        //
        //default:
        //    break
        //}
    }
}
