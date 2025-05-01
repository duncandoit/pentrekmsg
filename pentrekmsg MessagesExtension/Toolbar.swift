//
//  Toolbar.swift
//  pentrekmsg MessagesExtension
//
//  Created by Zachary Duncan on 4/30/25.
//

import SwiftUI

struct ToolButtonConfig: Identifiable
{
    let id = UUID()
    var icon: String = "paperplane.fill"
    var title: String = "Tool"
    var color: Color = .blue
    var size: CGFloat = 45
    var action: () -> Void
}

struct Toolbar: View
{
    enum Axis
    {
        case horizontal, vertical
    }

    let tools: [ToolButtonConfig]
    let axis: Axis
    let spacing: CGFloat
    
    private let color: Color = .white

    init(
        tools: [ToolButtonConfig],
        axis: Axis = .vertical,
        spacing: CGFloat = 16
    ) {
        self.tools = tools
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
                    ForEach(tools) { config in
                        formattedTool(for: config)
                    }
                    Spacer()
                }
            }
            else
            {
                VStack(spacing: spacing)
                {
                    Spacer()
                    ForEach(tools) { config in
                        formattedTool(for: config)
                    }
                    Spacer()
                }
            }
        }
        .background(color)
        .cornerRadius(8)
    }

    @ViewBuilder
    private func formattedTool(for config: ToolButtonConfig) -> some View
    {
        Button(action: config.action)
        {
            VStack
            {
                ZStack
                {
                    Circle()
                        .fill(config.color)
                        .frame(width: config.size, height: config.size)
                        .shadow(color: config.color.opacity(0.3), radius: 10, x: 0, y: 5)

                    Image(systemName: config.icon)
                        .foregroundColor(.white)
                        .font(.system(size: config.size / 2))
                }
                
                Label(config.title, systemImage: "")
                    .foregroundColor(.black)
                    .font(.system(size: config.size / 4))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(config.title)
    }
}
