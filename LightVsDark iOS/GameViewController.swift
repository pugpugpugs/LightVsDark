//
//  GameViewController.swift
//  LightVsDark iOS
//
//  Created by chris on 12/30/25.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let skView = self.view as? SKView else { return }
        
//        let scene = StartScene(size: skView.bounds.size)
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var shouldAutorotate: Bool { return true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone { return .allButUpsideDown }
        else { return .all }
    }

    override var prefersStatusBarHidden: Bool { return true }
}

