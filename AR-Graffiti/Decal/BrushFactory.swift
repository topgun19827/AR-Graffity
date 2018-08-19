//
//  Brush.swift
//  AR-Graffiti
//
//  Created by yoga on 2018/8/14.
//  Copyright © 2018年 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SpriteKit

class BrushFactory {
    static let shared = BrushFactory()
    let threepass:[SKTexture]
    let death:[SKTexture]
    let cat:[SKTexture]
    let twice:[SKTexture]
    let brainbox:[SKTexture]
    let taglist: [[SKTexture]]
    static let BASE_SIZE = CGSize(width: 0.1,
                                  height: 0.1)
    static let MIN_DISTANCE_SCALE:CGFloat = 0.2
    static let MAX_DISTANCE_SCALE:CGFloat = 0.8
    static let MIN_SCALE:CGFloat = 0.3
    static let MAX_SCALE:CGFloat = 1.0
    
    init() {
        death = (0...104).map({ SKTexture(imageNamed: "art.scnassets/death/frame_\($0)_delay-0.06s.png") })
        threepass = (0...20).map({ SKTexture(imageNamed: "art.scnassets/threepass/frame_\($0)_delay-0.03s.png") })
        cat = (0...160).map({ SKTexture(imageNamed: "art.scnassets/cat/frame_\($0)_delay-0.03s.png") })
        twice = (0...58).map({ SKTexture(imageNamed: "art.scnassets/twice/frame_\($0)_delay-0.03s.png") })
        brainbox = (0...117).map({ SKTexture(imageNamed: "art.scnassets/brainbox/frame_\($0)_delay-0.04s.png") })
        taglist = [death,threepass,cat,twice,brainbox,death,death]
    }
    
    static func brushSizeForDistance(distance: CGFloat) -> CGSize {
        if distance < MIN_DISTANCE_SCALE {

            return CGSize(width: BASE_SIZE.width * MIN_SCALE,
                          height: BASE_SIZE.height * MIN_SCALE)

        }

        if distance > MAX_DISTANCE_SCALE {

            return CGSize(width: BASE_SIZE.width * MAX_SCALE,
                          height: BASE_SIZE.height * MAX_SCALE)

        }

        let ratio = (distance - MIN_DISTANCE_SCALE) / (MAX_DISTANCE_SCALE - MIN_DISTANCE_SCALE)
        let scale = ratio * (MAX_SCALE - MIN_SCALE) + MIN_SCALE



        return CGSize(width: BASE_SIZE.width * scale,
                      height: BASE_SIZE.height * scale)
    }
    
    static func graffitiSize(distance: CGFloat) -> CGFloat {
        if distance < MIN_DISTANCE_SCALE {
            print("distance", distance)
            return CGFloat(BASE_SIZE.width * MIN_SCALE)
        }
        
        if distance > MAX_DISTANCE_SCALE {
            print("distance", distance)
            return CGFloat(BASE_SIZE.width * MAX_SCALE)
        }
        
        let ratio = (distance - MIN_DISTANCE_SCALE) / (MAX_DISTANCE_SCALE - MIN_DISTANCE_SCALE)
        let scale = ratio * (MAX_SCALE - MIN_SCALE) + MIN_SCALE
        print("distance", distance)
        
        return CGFloat(BASE_SIZE.width * scale)
    }
    
    func brushNode(color:UIColor, size:CGSize) -> SKSpriteNode {
//        let texture = textures[Int(arc4random_uniform(UInt32(textures.count)))]
        let testture = SKTexture(image: #imageLiteral(resourceName: "test"))
        let node = SKSpriteNode(texture: testture,
                            size: size)
        
        // for this the black in the brush images needs to be white.. :D
        node.colorBlendFactor = 1
        node.color = color
        return node
    }
    
    func gifNode(size:CGSize, number: Int) -> SKSpriteNode{
        var tags = [#imageLiteral(resourceName: "t1"),#imageLiteral(resourceName: "t2"),#imageLiteral(resourceName: "t3"),#imageLiteral(resourceName: "t4"),#imageLiteral(resourceName: "t5"),#imageLiteral(resourceName: "t1"),#imageLiteral(resourceName: "t1")]
        let testture = SKTexture(image: tags[number])
        let node = SKSpriteNode(texture: testture,
                                size: size)
        return node
    }
    
}
