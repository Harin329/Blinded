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

            
//            if (yaw >= 0) {
//                // Left
//                if (yaw >= 1.5) {
//                    // Q3
//                    if (abs(yaw - 3) >= abs(yaw - 1.5)) {
////                        print("left")
//                        self?.facing = 180
//                        if (self?.foe == 0) {
//                            self?.relative = 90
//                        } else if (self?.foe == 90) {
//                            self?.relative = 180
//                        } else if (self?.foe == 180) {
//                            self?.relative = 270
//                        } else if (self?.foe == 270) {
//                            self?.relative = 0
//                        }
//                    } else {
////                        print("back")
//                        self?.facing = 270
//                        if (self?.foe == 0) {
//                            self?.relative = 180
//                        } else if (self?.foe == 90) {
//                            self?.relative = 270
//                        } else if (self?.foe == 180) {
//                            self?.relative = 0
//                        } else if (self?.foe == 270) {
//                            self?.relative = 90
//                        }
//                    }
//                } else {
//                    // Q2
//                    if (abs(yaw) >= abs(yaw - 1.5)) {
////                        print("left")
//                        self?.facing = 180
//                        if (self?.foe == 0) {
//                            self?.relative = 90
//                        } else if (self?.foe == 90) {
//                            self?.relative = 180
//                        } else if (self?.foe == 180) {
//                            self?.relative = 270
//                        } else if (self?.foe == 270) {
//                            self?.relative = 0
//                        }
//                    } else {
////                        print("front")
//                        self?.facing = 90
//                        if (self?.foe == 0) {
//                            self?.relative = 0
//                        } else if (self?.foe == 90) {
//                            self?.relative = 90
//                        } else if (self?.foe == 180) {
//                            self?.relative = 180
//                        } else if (self?.foe == 270) {
//                            self?.relative = 270
//                        }
//                    }
//                }
//            } else {
//                // Right
//                if (yaw >= -1.5) {
//                    // Q1
//                    if (abs(yaw) >= abs(yaw - 1.5)) {
////                        print("right")
//                        self?.facing = 0
//                        if (self?.foe == 0) {
//                            self?.relative = 270
//                        } else if (self?.foe == 90) {
//                            self?.relative = 0
//                        } else if (self?.foe == 180) {
//                            self?.relative = 90
//                        } else if (self?.foe == 270) {
//                            self?.relative = 180
//                        }
//                    } else {
////                        print("front")
//                        self?.facing = 90
//                        if (self?.foe == 0) {
//                            self?.relative = 0
//                        } else if (self?.foe == 90) {
//                            self?.relative = 90
//                        } else if (self?.foe == 180) {
//                            self?.relative = 180
//                        } else if (self?.foe == 270) {
//                            self?.relative = 270
//                        }
//                    }
//                } else {
//                    // Q4
//                    if (abs(yaw - 3) >= abs(yaw - 1.5)) {
////                        print("right")
//                        self?.facing = 0
//                        if (self?.foe == 0) {
//                            self?.relative = 270
//                        } else if (self?.foe == 90) {
//                            self?.relative = 0
//                        } else if (self?.foe == 180) {
//                            self?.relative = 90
//                        } else if (self?.foe == 270) {
//                            self?.relative = 180
//                        }
//                    } else {
////                        print("back")
//                        self?.facing = 270
//                        if (self?.foe == 0) {
//                            self?.relative = 180
//                        } else if (self?.foe == 90) {
//                            self?.relative = 270
//                        } else if (self?.foe == 180) {
//                            self?.relative = 0
//                        } else if (self?.foe == 270) {
//                            self?.relative = 90
//                        }
//                    }
//                }
//            }
            
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
        let seperation = facing - foe
        if (seperation > 90) {
            relative = 360 - (seperation - 90)
        } else if (seperation == 90) {
            relative = 0
        } else {
            relative = seperation
        }
        
        if (facing == foe) {
            self.overlay.life = 2
            playSound(sound: "Correct")
            self.overlay.score += 1
            print(self.overlay.score)
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
                self.overlay.restartNode.isHidden = false
                self.overlay.menuNode.isHidden = false
                self.overlay.finalScoreNode.text = "Final Score: \(self.overlay.score)"
                self.overlay.finalScoreNode.isHidden = false
                
                let highScore = UserDefaults.standard.value(forKey: "highscore") as? Int ?? 0
                UserDefaults.standard.set(max(self.overlay.score, highScore), forKey: "highscore")
                
                GKLeaderboard.submitScore(self.overlay.score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [LEADERBOARD_ID]) { error in
                    if (error != nil) {
                        print(error as Any)
                    }
                }
                
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: parentVC!)
                  } else {
                    print("Ad wasn't ready")
                  }
            }
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
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
            print(error.localizedDescription)
        }
    }
    
}
