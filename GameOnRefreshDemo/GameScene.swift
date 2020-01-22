//
//  GameScene.swift
//  GameOnRefreshDemo
//
//  Created by SketchK on 2019/11/29.
//  Copyright © 2019 SketchK. All rights reserved.
//

import SpriteKit

protocol GameOverDelegate: class {
    func gameOverIn(_ gameScene : GameScene)

}

class GameScene: SKScene {
    
    lazy var hero = { () -> SKSpriteNode in
        let scale: CGFloat = 15
        let hero = SKSpriteNode(imageNamed: "hero1")
        hero.scale(to: CGSize(width: hero.size.width/scale, height: hero.size.height/scale))
        hero.anchorPoint = CGPoint(x: 0.5, y: 0)
        hero.name = "hero"
        hero.position = CGPoint(x: size.width/2, y: 18)
        hero.zPosition = 100
        return hero
    }()
    
    var contentCreated = false
    let heroAnimation: SKAction
    let heroMovePointsPerSec: CGFloat = 300
    var dt: TimeInterval = 0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastUpdateTime: TimeInterval = 0
    var enemyDestroyed = 0
    var isBegin = false
    
    var lastTouchLocation: CGPoint?
    weak var gameOverDelegate: GameOverDelegate?

    // MARK: 生命周期相关
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "hero\(i)"))
        }
        textures.append(textures[0])
        textures.append(textures[3])
        textures.append(textures[2])
        textures.append(textures[1])
        heroAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        playableRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        scaleMode = .aspectFit
        if !contentCreated {
            let background = SKSpriteNode(imageNamed: "background")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x:0, y: -30)
            background.name = "background"
            let scale = background.size.width / size.width
            background.scale(to: CGSize(width: size.width, height: background.size.height/scale))
            background.alpha = 0.8
            background.zPosition = -1
            addChild(background)

            addChild(hero)
            contentCreated = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCheckHero()
        boundsCheckHero()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    // MARK: - 手势处理相关(通过手势确定 velocity)
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveHeroToward(location: touchLocation)
    }
    
    func moveHeroToward(location: CGPoint) {
        // 这里只转换了手势的 x 方向信息, 丢弃了 y 方向的信息
        let offset = location.x - hero.position.x
        let direction = CGPoint(x: offset, y: 0).normalized()
        if(isBegin == false || direction.x.isNaN || direction.y.isNaN) {
            return
        }
        print("touch location = \(location), hero postion = \(hero.position)")

        velocity = direction * heroMovePointsPerSec
    }
    
    // MARK: - 处理小团移动
    func moveCheckHero(){
        if let lastTouchLocation = lastTouchLocation {
            let diff = lastTouchLocation - hero.position
            if diff.x <= heroMovePointsPerSec * CGFloat(dt) {
                hero.position.x = lastTouchLocation.x
                velocity = CGPoint.zero
            } else {
                move(sprite: hero, velocity: velocity)
            }
        }
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
         let amountToMove = velocity * CGFloat(dt)
         sprite.position += amountToMove
     }
    
    // MARK: - 产生红包
    func spawnEnemy()  {
        let scale: CGFloat = 1.3
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        enemy.scale(to: CGSize(width: enemy.size.width / scale, height:  enemy.size.height / scale))
        enemy.position = CGPoint(
             x: CGFloat.random(
                min: playableRect.minX + enemy.size.width/2,
                max: playableRect.maxX - enemy.size.width/2),
             y: size.height)
        addChild(enemy)
        
        // 左右转动的动画
        enemy.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        // 动画组时长 1s
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        // 缩放的动画
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        // 动画组时长 1s
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        // 一次完整的左右转动+缩放的动画组
        let animationOnceGroup = SKAction.group([fullWiggle, fullScale])
        // 无限重复动画组
        let animationGroup = SKAction.repeat(animationOnceGroup, count: 5)
        
        // 移动的动画
        let actualDuration = CGFloat.random(min: 2.0, max: 4.0)
        let actionMove = SKAction.moveBy(x: 0, y: -(size.height + enemy.size.height), duration: Double( actualDuration))
        
        let actionGroup = SKAction.group([actionMove, animationGroup])
        let actionRemove = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([actionGroup, actionRemove]))
    }
    
    // MARK: - 碰撞相关
    func boundsCheckHero() {
        let bottomLeft = CGPoint(x: hero.size.width/2, y: playableRect.minY)
        let topRight = CGPoint(x: size.width - hero.size.width, y: playableRect.maxY)
        
        if hero.position.x <= bottomLeft.x {
            hero.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if hero.position.x >= topRight.x {
            hero.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if hero.position.y <= bottomLeft.y {
            hero.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if hero.position.y >= topRight.y {
            hero.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func checkCollisions() {
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { (node, _) in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 10, dy: 10).intersects(self.hero.frame){
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            heroHit(enemy: enemy)
        }
    }
    
    func heroHit(enemy: SKSpriteNode) {
        let removeAction = SKAction.removeFromParent()
        enemy.run(removeAction)
        enemyDestroyed += 1
        gameOverCheck()
    }
    
    // MARK: - 游戏结束逻辑
    func gameOverCheck() {
        // 游戏结束的条件
        if(enemyDestroyed == 5) {
            if let delegate = self.gameOverDelegate {
                delegate.gameOverIn(self)
            }
        }
    }
    
    // MARK: - 其他方法
    func startHeroAnimation() {
        if hero.action(forKey: "animation") == nil {
            hero.run(SKAction.repeatForever(heroAnimation), withKey: "animation")
        }
    }
    
    func reset(){
        isBegin = false
        // 清除红包数量
        enemyDestroyed = 0
        // 清除 action
        removeAction(forKey: "spawnEnemy")
        // 清除现有的红包
        var enemyArray: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { (node, _) in
            let enemy = node as! SKSpriteNode
            enemyArray.append(enemy)
        }
        for enemy in enemyArray {
            enemy.removeFromParent()
        }
    }
    
    func start() {
        isBegin = true
        hero.position = CGPoint(x: size.width/2, y: 18)
        startHeroAnimation()
        // 启动红包雨
        run(SKAction.repeatForever(
            SKAction.sequence(
                [SKAction.run(){ [weak self] in
                    self?.spawnEnemy()
                    },
                 SKAction.wait(forDuration:1.0)]
            )), withKey: "spawnEnemy")
    }

}
