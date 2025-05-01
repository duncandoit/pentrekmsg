//
//  PentrekViewController.swift
//  pentrekmsg
//
//  Created by Zachary Duncan on 4/23/25.
//

import SwiftUI

class PentrekViewController: UIViewController
{
    weak var messagesDelegate: MessagesViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
    }
    
    private func setupViews()
    {
        let stackView = UIStackView()
        let pentrekView = PentrekView(frame: view.bounds)
        let sendButton = UIButton(type: .system)
        let toolbar = Toolbar(tools: [
            ToolButtonConfig(icon: "paintpalette.fill", title: "Color", action: {
                self.presentColorPicker(in: pentrekView)
            }),
            
            ToolButtonConfig(icon: "applepencil.and.scribble", title: "Stroke", action: {
                self.presentStrokeSlider(in: pentrekView)
            }),
        ])
        let toolbarController = UIHostingController(rootView: toolbar)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        pentrekView.viewDelegate = self
        pentrekView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pentrekView)
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.titleLabel?.textColor = .white
        sendButton.tintColor = .white
        sendButton.addTarget(pentrekView, action: #selector(pentrekView.handleRequestSticker), for: .touchUpInside)
        
        stackView.addArrangedSubview(toolbarController.view)
        stackView.addArrangedSubview(pentrekView)
        stackView.addArrangedSubview(sendButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            toolbarController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            toolbarController.view.widthAnchor.constraint(equalToConstant: 50),
            
            pentrekView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
    }
    
    private func presentColorPicker(in view: PentrekView)
    {
        view.modifyConfig { config in
            switch config.color
            {
            case .red:
                config.color = .green
            case .green:
                config.color = .blue
            case .blue:
                config.color = .red
            }
        }
    }
    
    private func presentStrokeSlider(in view: PentrekView)
    {
        view.modifyConfig { config in
            config.strokeWidth += 1
        }
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
