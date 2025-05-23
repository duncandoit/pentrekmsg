//
//  PentrekMessageView.swift
//  pentrekmsg
//
//  Created by Zachary Duncan on 5/5/25.
//

import SwiftUI

final class PentrekMessageViewModel: ObservableObject
{
    @Published var modViewModels: [ToolModViewModel] = []
    @Published var toolModel: ToolModel
    weak var pentrekView: PentrekView?
    
    private let onSendSticker: (UIImage) -> Void

    init(
        pentrekView: PentrekView,
        toolModel: ToolModel = ToolModel(),
        onSendSticker: @escaping (UIImage) -> Void
    )
    {
        self.pentrekView = pentrekView
        self.toolModel = toolModel
        self.onSendSticker = onSendSticker
        setupMods()
    }

    private func setupMods()
    {
        modViewModels = [
            ToolModViewModel(
                model: ToolModModel(title: "Color", icon: "paintpalette.fill"),
                action: { [weak self] in self?.cycleColor() }
            ),
            ToolModViewModel(
                model: ToolModModel(title: "Stroke", icon: "applepencil.and.scribble"),
                action: { [weak self] in self?.increaseStroke() }
            )
        ]
    }
    
    func updateTool(_ changes: (inout ToolModel) -> Void)
    {
        changes(&toolModel)
        pentrekView?.updateTool { $0 = self.toolModel }
    }

    func cycleColor()
    {
        updateTool { model in
            switch model.color
            {
            case .red:
                model.color = .green
            case .green:
                model.color = .blue
            case .blue:
                model.color = .red
            }
        }
    }

    func increaseStroke()
    {
        updateTool { model in
            model.strokeWidth += 1
        }
    }

    func sendSticker()
    {
        guard let pentrekView else { return }
        let renderer = UIGraphicsImageRenderer(bounds: pentrekView.bounds)
        let image = renderer.image { ctx in
            pentrekView.layer.render(in: ctx.cgContext)
        }
        onSendSticker(image)
    }
}

struct PentrekMessageView: View
{
    @ObservedObject var viewModel: PentrekMessageViewModel
    
    init(viewModel: PentrekMessageViewModel)
    {
        self.viewModel = viewModel
    }

    var body: some View
    {
        HStack(alignment: .center, spacing: 5)
        {
            ToolbarView(viewModel: ToolbarViewModel(modViewModels: viewModel.modViewModels))
                .frame(width: 50)
            
            PentrekViewRepresentable(pentrekView: viewModel.pentrekView!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: { viewModel.sendSticker() }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .accessibilityLabel("Send Sticker")
            .frame(width: 50)
        }
        .padding(.horizontal, 5)
    }
}
