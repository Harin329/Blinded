//
//  OverlayScene.swift
//  Blinded-SK
//
//  Created by Harin Wu on 2020-12-27.
//

import Foundation
import SpriteKit

class OverlayScene: SKScene {
    var hsDelegate:highScoreDelegate?
    
    var adView: SKView?
    var parentScene: GameScene!
    var pauseNode: SKSpriteNode!
    var scoreNode: SKLabelNode!
    
    var youNode: SKSpriteNode!
    var answerNode: SKSpriteNode!
    
    var resumeNode: SKLabelNode!
    var restartNode: SKLabelNode!
    var menuNode: SKLabelNode!
    var finalScoreNode: SKLabelNode!
    
    var score = 0 {
        didSet {
            self.scoreNode.text = "Score: \(self.score)"
        }
    }
    
    var life = 2
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
        
        let spriteSize = size.width/12
        self.pauseNode = SKSpriteNode(imageNamed: "Pause Button")
        self.pauseNode.name = "Pause"
        self.pauseNode.size = CGSize(width: spriteSize, height: spriteSize)
        self.pauseNode.position = CGPoint(x: spriteSize + 8, y: spriteSize + 8)
        
        self.scoreNode = SKLabelNode(text: "Score: 0")
        self.scoreNode.fontColor = UIColor.white
        self.scoreNode.fontSize = 24
        self.scoreNode.position = CGPoint(x: size.width/2, y: self.pauseNode.position.y - 9)
        
        self.addChild(self.pauseNode)
        self.addChild(self.scoreNode)
        
        
        self.resumeNode = SKLabelNode(text: "Resume")
        self.resumeNode.name = "Resume"
        self.resumeNode.fontColor = UIColor.white
        self.resumeNode.fontSize = 24
        self.resumeNode.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        
        self.youNode = SKSpriteNode(imageNamed: "ArrowRed")
        self.youNode.size = CGSize(width: spriteSize, height: spriteSize)
        self.youNode.position = CGPoint(x: size.width/2 - 30, y: size.height/2 + 100)
        
        self.answerNode = SKSpriteNode(imageNamed: "ArrowGreen")
        self.answerNode.size = CGSize(width: spriteSize, height: spriteSize)
        self.answerNode.position = CGPoint(x: size.width/2 + 30, y: size.height/2 + 100)
        
        self.restartNode = SKLabelNode(text: "Restart")
        self.restartNode.name = "Restart"
        self.restartNode.fontColor = UIColor.white
        self.restartNode.fontSize = 24
        self.restartNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        self.menuNode = SKLabelNode(text: "Main Menu")
        self.menuNode.name = "Menu"
        self.menuNode.fontColor = UIColor.white
        self.menuNode.fontSize = 24
        self.menuNode.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        
        self.finalScoreNode = SKLabelNode(text: "Score: 0")
        self.finalScoreNode.fontColor = UIColor.white
        self.finalScoreNode.fontSize = 24
        self.finalScoreNode.position = CGPoint(x: size.width/2, y: size.height/2 + 150)
        
        self.addChild(self.youNode)
        self.addChild(self.answerNode)
        self.addChild(self.resumeNode)
        self.addChild(self.restartNode)
        self.addChild(self.menuNode)
        self.addChild(self.finalScoreNode)
        
        self.youNode.isHidden = true
        self.answerNode.isHidden = true
        self.resumeNode.isHidden = true
        self.restartNode.isHidden = true
        self.menuNode.isHidden = true
        self.finalScoreNode.isHidden = true
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesEnded(_ presses: Set<UITouch>, with event: UIEvent?) {
        if let touch = presses.first {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            for node in tappedNodes {
                if let tappedButton = node as? SKLabelNode {
                    if tappedButton.name == "Restart" {
                        self.youNode.isHidden = true
                        self.answerNode.isHidden = true
                        self.resumeNode.isHidden = true
                        self.restartNode.isHidden = true
                        self.menuNode.isHidden = true
                        self.finalScoreNode.isHidden = true
                        self.pauseNode.isHidden = false
                        self.scoreNode.isHidden = false
                        life = 2
                        score = 0
                        timer = Timer.scheduledTimer(timeInterval: 3, target: parentScene!, selector: #selector(parentScene.cycleOnce(timer:)), userInfo: [], repeats: true)
                    } else if (tappedButton.name == "Menu") {
                        self.view?.removeFromSuperview()
                        hsDelegate?.newHighScore()
                    } else if (tappedButton.name == "Resume") {
                        self.resumeNode.isHidden = true
                        self.restartNode.isHidden = true
                        self.menuNode.isHidden = true
                        self.pauseNode.isHidden = false
                        timer = Timer.scheduledTimer(timeInterval: 3, target: parentScene!, selector: #selector(parentScene.cycleOnce(timer:)), userInfo: [], repeats: true)
                    }
                }
                
                if let tappedButton = node as? SKSpriteNode {
                    if tappedButton.name == "Pause" {
                        self.resumeNode.isHidden = false
                        self.restartNode.isHidden = false
                        self.menuNode.isHidden = false
                        self.pauseNode.isHidden = true
                        timer.invalidate()
                    }
                }
            }
        }
    }
}

protocol highScoreDelegate {
    func newHighScore()
}
