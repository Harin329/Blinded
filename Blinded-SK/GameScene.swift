//
//  GameScene.swift
//  Blinded-SK
//
//  Created by Harin Wu on 2020-12-23.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation
import GameKit
import GoogleMobileAds

@available(iOS 11.0, *)
class GameScene: SCNScene, CMHeadphoneMotionManagerDelegate, GADInterstitialDelegate {
    
    var parentVC: UIViewController?
    var interstitial: GADInterstitial!
    
    private let directions = [0, 45, 90, 135, 180, 225, 270, 315] // 0-359
    var overlay = OverlayScene(size: CGSize(width: 100, height: 100))
    
    let APP = CMHeadphoneMotionManager()
    var player: AVAudioPlayer?
    
    private var foe = 0
    private var relative = 0
    private var facing = 0
    
    
    // Yaw Range -3 to 3
    // +-3 -> 270, 0-90,-1.5 -> 0, 1.5 -> 180
    override init() {
        super.init()
        
        interstitial = createAndLoadInterstitial()
        
        APP.delegate = self
        
        foe = directions.randomElement()!
        print(foe)
        relative = foe
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(cycleOnce(timer:)), userInfo: [], repeats: true)
        
        guard APP.isDeviceMotionAvailable else { return }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            let yaw = motion.attitude.yaw
            
            var degree = ((yaw + 3)/6 * 360) - 90
            if (degree < 0) {
                degree += 360
            }
            
            self?.facing = Int(degree)
            
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func nearest(of: Int, options: [Int]) -> Int {
        var min = 1000
        var closest = of;
        
        for num in options {
            let diff = abs(num - of);
            
            if (diff < min) {
                min = diff;
                closest = num;
            }
        }
        return closest;
    }
    
    @objc func cycleOnce(timer: Timer!) {
        facing = nearest(of: facing, options: directions)
        
        if (facing > foe) {
            let seperation = facing - foe
            relative = 360 - (seperation - 90)
        } else if (facing < foe) {
            let seperation = foe - facing
            relative = seperation + 90
        }
        
        if (relative >= 360) {
            relative = relative - 360
        }
        
        if (relative < 0) {
            relative = 360 + relative
        }
        
        // Debug
        // print("You \(facing)")
        // print("Enemy \(foe)")
        // print("Relative \(relative)")
        
        if (facing == foe) {
            self.overlay.life = 2
            playSound(sound: "Correct")
            self.overlay.score += 1
            //            print(self.overlay.score)
            foe = directions.randomElement()!
        } else {
            if (self.overlay.life >= 1) {
                self.overlay.life -= 1
                let res = "Ninja-" + String(relative)
                playSound(sound: res)
            } else {
                playSound(sound: "Lost")
                timer.invalidate()
                self.overlay.pauseNode.isHidden = true
                self.overlay.scoreNode.isHidden = true
                self.overlay.youNode.isHidden = false
                self.overlay.answerNode.isHidden = false
                self.overlay.youNode.zRotation = (CGFloat(facing) - 90) * (CGFloat.pi/180)
                self.overlay.answerNode.zRotation = (CGFloat(foe) - 90) * (CGFloat.pi/180)
                self.overlay.restartNode.isHidden = false
                self.overlay.menuNode.isHidden = false
                self.overlay.finalScoreNode.text = "Final Score: \(self.overlay.score)"
                self.overlay.finalScoreNode.isHidden = false
                
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: parentVC!)
                } else {
                    // print("Ad wasn't ready")
                }
            }
        }
        
        let highScore = UserDefaults.standard.value(forKey: "highscore") as? Int ?? 0
        UserDefaults.standard.set(max(self.overlay.score, highScore), forKey: "highscore")
        
        GKLeaderboard.submitScore(self.overlay.score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [LEADERBOARD_ID]) { error in
            if (error != nil) {
                // print(error as Any)
            }
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1633693256297531/2415015394")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func playSound(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
        } catch let error {
            // print(error.localizedDescription)
        }
    }
    
}
