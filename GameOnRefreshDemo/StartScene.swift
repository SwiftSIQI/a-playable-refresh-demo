//
//  StartScene.swift
//  GameOnRefreshDemo
//
//  Created by SketchK on 2019/11/30.
//  Copyright © 2019 SketchK. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    
    var contentCreated = false

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.white
    }
    
    lazy var startLabelNode: SKLabelNode = {
        let startNode = SKLabelNode(text: "向下拖动, 别松手, 据说有惊喜哦 !")
        startNode.fontColor = SKColor.init(displayP3Red: 37/255,
                                           green: 15/255,
                                           blue: 7/255,
                                           alpha: 1)
        startNode.fontSize = 30
        startNode.fontName = "WenYue-XinQingNianTi-W8-J"
        startNode.position = CGPoint(x: self.frame.midX,
                                     y: self.frame.midY + 10)
        startNode.name = "start"
        
        return startNode
    }()
    
    lazy var descriptionLabelNode: SKLabelNode = {
        let descriptionNode = SKLabelNode(text: "下拉刷新")
        descriptionNode.fontColor = SKColor.init(displayP3Red: 37/255,
                                                 green: 15/255,
                                                 blue: 7/255,
                                                 alpha: 1)
        descriptionNode.fontName = "WenYue-XinQingNianTi-W8-J"
        descriptionNode.fontSize = 17
        descriptionNode.position = CGPoint(x: self.frame.midX,
                                           y: self.frame.midY - 100)
        descriptionNode.name = "description"
        
        return descriptionNode
    }()
    
    lazy var background: SKSpriteNode = {
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x:0, y: -30)
        background.name = "background"
        let scale = background.size.width / size.width
        background.scale(to: CGSize(width: size.width,
                                    height: background.size.height/scale))
        background.alpha = 0.8
        background.zPosition = -1
        return background
    }()
    
    override func didMove(to view: SKView) {
        if !contentCreated {
            scaleMode = .aspectFit
            addChild(background)
            addChild(startLabelNode)
            addChild(descriptionLabelNode)
           contentCreated = true
         }
    }
}
