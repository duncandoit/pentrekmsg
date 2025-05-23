//
//  Toolbar.swift
//  pentrekmsg MessagesExtension
//
//  Created by Zachary Duncan on 4/30/25.
//

import SwiftUI

/// State object for the visual identity of toolbar items
struct ToolModModel: Identifiable
{
    let id = UUID()
    var title: String = "Tool"
    var icon: String = "paperplane.fill"
    var color: Color = .blue
    var size: CGFloat = 45
}

/// Bridging object for the state and behavior of toolbar items
final class ToolModViewModel: ObservableObject, Identifiable
{
    let id = UUID()
    let model: ToolModModel
    let action: () -> Void

    init(model: ToolModModel, action: @escaping () -> Void)
    {
        self.model = model
        self.action = action
    }
}

/// Bridging object maintaining state and behavior of a toolbar
final class ToolbarViewModel: ObservableObject
{
    @Published var modViewModels: [ToolModViewModel] = []

    init(modViewModels: [ToolModViewModel])
    {
        self.modViewModels = modViewModels
    }
}

/// Main SwiftUI View for the toolbar
struct ToolbarView: View
{
    enum Axis
    {
        case horizontal, vertical
    }

    @ObservedObject var viewModel: ToolbarViewModel
    let axis: Axis
    let spacing: CGFloat
    private let color: Color = .white

    init(
        viewModel: ToolbarViewModel,
        axis: Axis = .vertical,
        spacing: CGFloat = 16
    ) {
        self.viewModel = viewModel
        self.axis = axis
        self.spacing = spacing
    }

    var body: some View
    {
        Group
        {
            if axis == .horizontal
            {
                HStack(spacing: spacing)
                {
                    Spacer()
                    ForEach(viewModel.modViewModels) { modVM in
                        formattedMod(for: modVM)
                    }
                    Spacer()
                }
            }
            else
            {
                VStack(spacing: spacing)
                {
                    Spacer()
                    ForEach(viewModel.modViewModels) { modVM in
                        formattedMod(for: modVM)
                    }
                    Spacer()
                }
            }
        }
        .background(color)
        .cornerRadius(8)
    }

    @ViewBuilder
    private func formattedMod(for modVM: ToolModViewModel) -> some View
    {
        let model = modVM.model
        Button(action: modVM.action)
        {
            VStack
            {
                ZStack
                {
                    Circle()
                        .fill(model.color)
                        .frame(width: model.size, height: model.size)
                        .shadow(color: model.color.opacity(0.3), radius: 10, x: 0, y: 5)

                    Image(systemName: model.icon)
                        .foregroundColor(.white)
                        .font(.system(size: model.size / 2))
                }

                Text(model.title)
                    .foregroundColor(.black)
                    .font(.system(size: model.size / 4))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(model.title)
    }
}
