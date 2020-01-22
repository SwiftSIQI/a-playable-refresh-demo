//
//  GameViewController.swift
//  GameOnRefreshDemo
//
//  Created by SketchK on 2019/11/29.
//  Copyright © 2019 SketchK. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var gameRefreshView: GameView!
    
    override func viewDidLoad() {
        setupContent()
        
        let scrollView = self.view as! UIScrollView
        gameRefreshView = GameView(host: scrollView, hostDelegate: self)
        self.view.addSubview(gameRefreshView)
    }
    
    func setupContent() {
        let image = UIImage.init(named: "home")
        let size: CGSize = view.frame.size
        guard let imageSize = image?.size else {
            return
        }
        let scale: CGFloat = imageSize.width / size.width
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: imageSize.height/scale))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        let scrollView = self.view as! UIScrollView
        scrollView.backgroundColor = UIColor.init(displayP3Red: 244/255,
                                                  green: 188/255,
                                                  blue: 27/255,
                                                  alpha: 1)
        scrollView.contentSize = imageView.frame.size
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.addSubview(imageView)
        scrollView.delegate = self
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}


extension GameViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gameRefreshView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        gameRefreshView.scrollViewWillEndDragging(scrollView,
                                                  withVelocity: velocity,
                                                  targetContentOffset: targetContentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gameRefreshView.scrollViewWillBeginDragging(scrollView)
    }
}

extension GameViewController: GameViewToRefreshDelegate{
    func gameViewDidRefresh(_ refresh: GameView) {
        let when = DispatchTime.now() + Double(Int64(NSEC_PER_SEC * 3)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: when,
                                      execute: { () -> Void in
                                        self.gameRefreshView.endRefreshing()
        })
        
    }
}
