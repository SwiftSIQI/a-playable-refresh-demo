//
//  GameView.swift
//  GameOnRefreshDemo
//
//  Created by SketchK on 2019/11/30.
//  Copyright © 2019 SketchK. All rights reserved.
//

import SpriteKit

protocol GameViewToRefreshDelegate: class {
    func gameViewDidRefresh(_ refresh: GameView)
}

class GameView: SKView {
    
    lazy var startScene: StartScene = {
        let size = UIScreen.main.bounds.size
        let startScene = StartScene(size: CGSize(width:size.width,
                                                 height:self.gameViewHeight))
        
        return startScene
    }()
    
    lazy var gameScene: GameScene = {
        let size = UIScreen.main.bounds.size
        let gameScene = GameScene(size: CGSize(width:size.width,
                                               height:self.gameViewHeight))
        gameScene.gameOverDelegate = self
        gameScene.anchorPoint = CGPoint.zero
        self.host.panGestureRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
        return gameScene
    }()
    
    lazy var endScene: EndScene = {
        let size = UIScreen.main.bounds.size
        let endScene = EndScene(size: CGSize(width:size.width,
                                             height:self.gameViewHeight),
                                redPocketNumber: self.gameScene.enemyDestroyed)
        return endScene
    }()
    
    let gameBeginHeight: CGFloat = 250
    let gameViewHeight: CGFloat = 250
    let gameViewWidth: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    
    var isRefreshing = false
    var isDragging = false
    var isVisible = false

    unowned let host: UIScrollView
    unowned let hostDelegate: GameViewToRefreshDelegate

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(host: UIScrollView, hostDelegate: GameViewToRefreshDelegate) {
        self.host = host
        self.hostDelegate = hostDelegate
        let frame = CGRect(x: 0.0, y: -gameViewHeight,
                           width: gameViewWidth, height: gameViewHeight)
        super.init(frame: frame)
        
        showsFPS = true
        showsNodeCount = true
        ignoresSiblingOrder = true
        self.presentScene(self.startScene)
    }
        
    @objc func handleTap(recognizer: UIGestureRecognizer) {
        let viewLocation = self.host.panGestureRecognizer.location(in: gameScene.view)
        let touchLocation = gameScene.convertPoint(fromView: viewLocation)
        gameScene.sceneTouched(touchLocation: touchLocation)
    }
        
    func beginRefreshing()  {
        isRefreshing = true
        
        self.presentScene(self.gameScene)
        
        if self.host.contentOffset.y < -gameBeginHeight{
            self.startScene.descriptionLabelNode.text = "下拉刷新"
            self.gameScene.reset()
            self.gameScene.start()
        }
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.host.contentInset.top += self.gameViewHeight
                        
        }) { (_) in
            self.isVisible = true
        }
    }
    
    func endRefreshing() {
        if(!isDragging) && isVisible {
            self.isVisible = false
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseInOut,
                           animations: {
                            self.host.contentInset.top -= self.gameViewHeight
                            
            }) { (_) in
                self.isRefreshing = false
                self.presentScene(self.startScene)
            }
        } else {
            isRefreshing = false
        }
    }
}

extension GameView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging = false
        
        if !isRefreshing && scrollView.contentOffset.y + scrollView.contentInset.top < -gameBeginHeight {
            self.startScene.descriptionLabelNode.alpha = 0
            beginRefreshing()
            targetContentOffset.pointee.y = -scrollView.contentInset.top
            hostDelegate.gameViewDidRefresh(self)
        }
        
        if !isRefreshing {
           endRefreshing()
         }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.host.contentOffset.y == 0 {
            self.startScene.descriptionLabelNode.text = "下拉刷新"
            self.startScene.descriptionLabelNode.alpha = 1
        }
        if self.host.contentOffset.y < -(gameBeginHeight - 140){
            self.startScene.descriptionLabelNode.text = "刷新中"
            self.startScene.descriptionLabelNode.alpha = 1

        }
    }
    
}

extension GameView: GameOverDelegate {
    func gameOverIn(_ gameScene: GameScene) {
        self.presentScene(self.endScene)
        self.gameScene.reset()
    }
}
