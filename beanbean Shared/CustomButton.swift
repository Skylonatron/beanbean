//
//  CustomButton.swift
//  beanbean
//
//  Created by Skylar Jones on 7/27/24.
//

import SpriteKit

class CustomButton: SKSpriteNode {
    
    var action: (() -> Void)?

    init(color: UIColor, size: CGSize, action: @escaping () -> Void) {
        self.action = action
        super.init(texture: nil, color: color, size: size)
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.color = .gray  // Change color to indicate the button is pressed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.color = .blue  // Change color back to original
        action?()
    }
}
