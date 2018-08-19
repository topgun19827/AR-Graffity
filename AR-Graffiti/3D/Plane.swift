//
//  Plane.swift
//  AR-Graffiti
//
//  Created by yoga on 2018/8/14.
//  Copyright © 2018年 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import ARKit
import UIKit

let WALL_TEXT_SIZE_MULP:CGFloat = 1500
class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    var clear : UIColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    var white : UIColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
    var black : UIColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
    var orange : UIColor = UIColor(red:0.99, green:0.54, blue:0.31, alpha:1.00)
    var green : UIColor = UIColor(red:0.49, green:0.59, blue:0.36, alpha:1.00)
    var blue : UIColor = UIColor(red:0.26, green:0.59, blue:0.58, alpha:1.00)
    var red : UIColor = UIColor(red:0.98, green:0.28, blue:0.29, alpha:1.00)
    init(withAnchor anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
//        print("anchor.x",anchor.extent.x)
//        print("anchor.z",anchor.extent.z)
        
        
        let mat = SCNMaterial()
        // we use a spritekit scene so we can draw decals on it..
        let scene = SKScene()
        scene.backgroundColor = UIColor(displayP3Red: 0.51, green: 0.51, blue: 0.51, alpha: 0.5)
        scene.size = CGSize(width: planeGeometry.width * WALL_TEXT_SIZE_MULP,
                            height: planeGeometry.height * WALL_TEXT_SIZE_MULP)
        
//        print("scene.w",scene.size.width)
//        print("scene.h",scene.size.height)
        
        mat.diffuse.contents = scene
        mat.writesToDepthBuffer = true
        mat.isDoubleSided = true
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        // SceneKit 里的平面默认是垂直的，所以需要旋转90度来匹配 ARKit 中的平面
        planeNode.transform = SCNMatrix4MakeRotation(Float(.pi / 2.0), 1.0, 0.0, 0.0)
        planeNode.geometry?.firstMaterial = mat
        addChildNode(planeNode)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor, colorNumber : Int) {
        var colorboard : [UIColor] = [clear,black,white,orange,green,blue,red]
        // 随着用户移动，平面 plane 的 范围 extend 和 位置 location 可能会更新。
        // 需要更新 3D 几何体来匹配 plane 的新参数。

        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        
        // plane 刚创建时中心点 center 为 0,0,0，node transform 包含了变换参数。
        // plane 更新后变换没变但 center 更新了，所以需要更新 3D 几何体的位置
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
//        let scene = planeGeometry?.firstMaterial?.diffuse.contents as? SKScene
//        scene?.backgroundColor = colorboard[colorNumber]
//        scene?.size = CGSize(width: planeGeometry.width * WALL_TEXT_SIZE_MULP,
//                            height: planeGeometry.height * WALL_TEXT_SIZE_MULP)
        
        
        
        let mat = SCNMaterial()
        // we use a spritekit scene so we can draw decals on it..
        let scene = SKScene()
        scene.backgroundColor = colorboard[colorNumber]
        scene.size = CGSize(width: planeGeometry.width * WALL_TEXT_SIZE_MULP,
                            height: planeGeometry.height * WALL_TEXT_SIZE_MULP)
        
//        print("scene.w",scene.size.width)
//        print("scene.h",scene.size.height)
        
        mat.diffuse.contents = scene
        mat.writesToDepthBuffer = true
        mat.isDoubleSided = true
        planeGeometry.firstMaterial = mat
        
    }
    
//    class func node(from:SCNVector3,
//                    to:SCNVector3) -> SCNNode {
//        let distance = from.distance(vector: to)
//
//        let wall = SCNPlane(width: CGFloat(distance),
//                            height: HEIGHT)
//        wall.firstMaterial = wallMaterial()
//        let node = SCNNode(geometry: wall)
//        node.categoryBitMask = NodeCategory.wallNode.rawValue
//
//        // always render before the beachballs
//        node.renderingOrder = -10
//
//        // get center point
//        node.position = SCNVector3(from.x + (to.x - from.x) * 0.5,
//                                   from.y + Float(HEIGHT) * 0.5,
//                                   from.z + (to.z - from.z) * 0.5)
//
//        // orientation of the wall is fairly simple. we only need to orient it around the y axis,
//        // and the angle is calculated with 2d math.. now this calculation does not factor in the position of the
//        // camera, and so if you move the cursor right relative to the starting position the
//        // wall will be oriented away from the camera (in this app the wall material is set as double sided so you will not notice)
//        // - obviously if you want to render something on the walls, this issue will need to be resolved.
//        node.eulerAngles = SCNVector3(0,
//                                      -atan2(to.x - node.position.x, from.z - node.position.z) - Float.pi * 0.5,
//                                      0)
//        //node.castsShadow = false
//
//        return node
//    }
}

