//
//  GameViewController.swift
//  Blinded-SK
//
//  Created by Harin Wu on 2020-12-23.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion
import GameKit

public let LEADERBOARD_ID = "com.blinded"
public var timer = Timer()

class GameViewController: UIViewController, CMHeadphoneMotionManagerDelegate, GKGameCenterControllerDelegate, highScoreDelegate {
    @IBOutlet weak var Welcome: UILabel!
    @IBOutlet weak var Instruction: UILabel!
    @IBOutlet weak var HighScore: UILabel!
    @IBOutlet weak var AirpodMessage: UILabel!
    @IBOutlet weak var AirpodCheck: UILabel!
    @IBOutlet weak var Start: UIButton!
    @IBOutlet weak var Leaderboard: UIButton!
    @IBOutlet weak var Credit: UIButton!
    
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String()
    
    var highScore = 0
    
    let APP = CMHeadphoneMotionManager()
    
    var sceneView: SCNView!
    var spriteScene: OverlayScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        
        Start.layer.cornerRadius = 8
        Leaderboard.layer.cornerRadius = 8
        Credit.layer.cornerRadius = 8
        
        Instruction.setTyping(text: "You are blinded in a pitch dark room. You hear sounds around you. Admist your confusion, you realize the sounds back away if you face towards their direction. Survive for as long as you can, good luck!")
        
        
        APP.delegate = self
        
        guard APP.isDeviceMotionAvailable else { return }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            self?.AirpodCheck.text = "Airpod Detected!"
            self?.AirpodCheck.textColor = UIColor(displayP3Red: 0, green: 127, blue: 0, alpha: 1)
            self?.APP.stopDeviceMotionUpdates()
        })
        
        updateScore()
    }
    
    func updateScore() {
        highScore = UserDefaults.standard.value(forKey: "highscore") as? Int ?? 0
        self.HighScore.text = "High Score: \(highScore)"
    }
    
    func newHighScore() {
        updateScore()
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if ((ViewController) != nil) {
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                self.gcEnabled = true
                
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        self.gcDefaultLeaderboard = leaderboardIdentifer!
                    }
                    
                })
            } else {
                self.gcEnabled = false
                print("local player could not be authenticated")
                print(error!)
            }
        }
    }
    
    @IBAction func startPressed(_ sender: Any) {
        self.sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.spriteScene = OverlayScene(size: self.view.bounds.size)
        self.sceneView.overlaySKScene = self.spriteScene
        self.sceneView.backgroundColor = UIColor.black
        let gs = GameScene()
        gs.overlay = self.spriteScene
        gs.parentVC = self
        self.sceneView.scene = gs
        self.spriteScene.parentScene = gs
        self.spriteScene.hsDelegate = self
        self.view.addSubview(self.sceneView)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leaderboardPressed(_ sender: Any) {
        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.gameCenterDelegate = self
        present(gcVC, animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension UILabel {
    func setTyping(text: String, characterDelay: TimeInterval = 7.0) {
      self.text = ""
        
      let writingTask = DispatchWorkItem { [weak self] in
        text.forEach { char in
          DispatchQueue.main.async {
            self?.text?.append(char)
          }
          Thread.sleep(forTimeInterval: characterDelay/100)
        }
      }
        
      let queue: DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
      queue.asyncAfter(deadline: .now() + 0.05, execute: writingTask)
    }
}
