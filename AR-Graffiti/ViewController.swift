//
//  ViewController.swift
//  AR-Graffiti
//
//  Created by yoga on 2018/8/14.
//  Copyright © 2018年 Silicon.dk ApS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
//import SwiftyJSON
import DCAnimationKit
import AVFoundation
import AudioToolbox
import SpriteKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var planes = [UUID:Plane]() // 字典，存储场景中当前渲染的所有平面
    var photo = UIImage()
//    var points : [CGPoint] = [CGPoint]()
    var selectedButtonName : String = ""
    var pressButton : Int = 0
    let buttonArrray = ["wall", "spray", "tag", "camera", "delete", "snapshot"]
    var lastButtonName : String = "none"
    var currentStateDisplayed:String? = nil
//    var lineNumber : Int = 0
    
    var index : Int = 0
    var wallitems = ["0","1","2","3","4","5","6"]
    var wallcolors = [#imageLiteral(resourceName: "1w"),#imageLiteral(resourceName: "2w"),#imageLiteral(resourceName: "3w"),#imageLiteral(resourceName: "4w"),#imageLiteral(resourceName: "5w"),#imageLiteral(resourceName: "6w"),#imageLiteral(resourceName: "7w")]
    var spraycolors = [#imageLiteral(resourceName: "s1"),#imageLiteral(resourceName: "s2"),#imageLiteral(resourceName: "s3"),#imageLiteral(resourceName: "s4"),#imageLiteral(resourceName: "s5"),#imageLiteral(resourceName: "s6"),#imageLiteral(resourceName: "s7")]
    var tags = [#imageLiteral(resourceName: "death"),#imageLiteral(resourceName: "starwars"),#imageLiteral(resourceName: "cat"),#imageLiteral(resourceName: "twice"),#imageLiteral(resourceName: "brainbox"),#imageLiteral(resourceName: "death"),#imageLiteral(resourceName: "death")]
    var blank = [#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem")]
    var icons = [#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem"),#imageLiteral(resourceName: "blankitem")]
    var sprayNumber : Int = 2
    var colorNumber : Int = 1
    var tagNumber : Int = 0
    var wallupdated : Bool = true
    var isspray : Bool = false
    var touchbegan : Bool = false
    var screenturned : Bool = false
    var spraySound : AVAudioPlayer!
    var shakeit : AVAudioPlayer!
    
    var clear : UIColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    var white : UIColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
    var black : UIColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
    var orange : UIColor = UIColor(red:0.99, green:0.54, blue:0.31, alpha:1.00)
    var green : UIColor = UIColor(red:0.49, green:0.59, blue:0.36, alpha:1.00)
    var blue : UIColor = UIColor(red:0.26, green:0.59, blue:0.58, alpha:1.00)
    var red : UIColor = UIColor(red:0.98, green:0.28, blue:0.29, alpha:1.00)
    
    var walls = [(wallNode:SCNNode, wallStartPosition:SCNVector3, wallEndPosition:SCNVector3, wallId:String)]()
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var map: UIButton!
    @IBOutlet weak var wall: UIButton!
    @IBOutlet weak var spray: UIButton!
    @IBOutlet weak var tag: UIButton!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var snapshot: UIButton!
    @IBOutlet weak var subtable: UICollectionView!
    @IBOutlet weak var bar: UIStackView!
    @IBOutlet weak var statusColor: UIView!
    @IBOutlet weak var status: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        scene.physicsWorld.gravity = SCNVector3Zero
        sceneView.scene = scene
        
        sceneView.overlaySKScene = SKScene(size: view.frame.size)
        
        // with this we will stil get touches began..
        sceneView.overlaySKScene!.isUserInteractionEnabled = false
        
        subtable.alwaysBounceHorizontal = false
        subtable.delegate = self
        subtable.dataSource = self
        statusColor.layer.cornerRadius = 2
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        //添加通知，监听设备方向改变
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedRotation),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
        
    @objc func receivedRotation(){
        lastButtonName = "none"
        let device = UIDevice.current
        switch device.orientation{
        case .portrait:
//            面向设备保持垂直，Home键位于下部
            screenturned = false
        case .portraitUpsideDown:
//            面向设备保持垂直，Home键位于上部
            screenturned = false
        case .landscapeLeft:
//            "面向设备保持水平，Home键位于左侧"
            screenturned = true
        case .landscapeRight:
//            "面向设备保持水平，Home键位于右侧"
            screenturned = true
        case .faceUp:
//            "设备平放，Home键朝上"
            screenturned = false
        case .faceDown:
//            "设备平放，Home键朝下"
            screenturned = false
        case .unknown:
//            "方向未知"
            screenturned = false
//        default:
////           "方向未知"
//            screenturned = false
        }
    }
    
    func present(state:ARCamera.TrackingState) {
        var message : String
        var color : UIColor
        
        switch state {
        case .notAvailable:
            message = "Preparing"
            color = orange
        case .normal:
            message = "Stable"
            color = green
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                message = "Out of range"
                color = red
            case .initializing:
                message = "Initializing"
                color = orange
            case .insufficientFeatures:
                message = "Scanning"
                color = red
            case .relocalizing:
                message = "Relocalizing"
                color = orange
            }
        }
        
        if currentStateDisplayed != nil && currentStateDisplayed! == message { return }
        currentStateDisplayed = message
        status.text = currentStateDisplayed
        statusColor.backgroundColor = color
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .vertical
        configuration.isLightEstimationEnabled = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.overlaySKScene?.size = view.frame.size
    }
    
    @IBAction func snapshot(_ sender: UIButton){
        
        photo = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
        
        let alertController = UIAlertController(
        title: "Add to World", message: "Would you like to share your Grattifi", preferredStyle: .alert)
        alertController.addImage(image: photo)
        
        alertController.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Accept", style: .default, handler: nil))
        self.present(alertController, animated : true, completion: nil)
//        guard let currentFrame = sceneView.session.currentFrame else { return }
//        let plane = SCNPlane(width: photo.size.width/1000, height: photo.size.width/1000)
//        plane.firstMaterial?.diffuse.contents = photo
//        plane.firstMaterial?.lightingModel = .constant
//        let planeNode = SCNNode(geometry: plane)
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -0.2
//        let transform = matrix_multiply(currentFrame.camera.transform, translation)
//        planeNode.name = "photo"
//        planeNode.geometry?.firstMaterial?.isDoubleSided = true
//        planeNode.simdTransform = transform
//        planeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//        let forceVector = SCNVector3(planeNode.worldFront.x*1 ,planeNode.worldFront.y*1.2 ,planeNode.worldFront.z*1.5)
//        planeNode.physicsBody?.applyForce(forceVector, asImpulse: true)
//        sceneView.scene.rootNode.addChildNode(planeNode)
        
    }
    
    @IBAction func barPresseed(_ sender: UIButton){
        selectedButtonName = buttonArrray[sender.tag]
        print(selectedButtonName)
        pressButton = sender.tag
        
        if pressButton == 0{
            snapshot.isHidden = true
            wallupdated = true
            icons = wallcolors
            subtable.reloadData()
        }else{
            wallupdated = false
        }
        
        if pressButton == 1{
            snapshot.isHidden = true
            icons = spraycolors
            subtable.reloadData()
        }
        if pressButton == 2{
            snapshot.isHidden = true
            icons = tags
            subtable.reloadData()
        }
        if pressButton == 3{
            snapshot.isHidden = false
            icons = blank
            subtable.reloadData()
        }
        
        if lastButtonName == selectedButtonName{
            index = 1
        }else{
            index = 2
        }
        if lastButtonName == "none"{
            index = 0
        }
        
        
        switch index {
        case 0:
            if screenturned == false{
            UIView.animate(withDuration: 0.3, delay: 0, options: .layoutSubviews, animations: {self.subtable.center.y -= 50}, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .layoutSubviews, animations: {self.snapshot.center.y -= 50}, completion: nil)
            }else{
                UIView.animate(withDuration: 0.3, delay: 0, options: .layoutSubviews, animations: {self.subtable.center.x -= 50}, completion: nil)
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .layoutSubviews, animations: {self.snapshot.center.x -= 50}, completion: nil)
            }
            
            sender.bounce(nil)
            lastButtonName = selectedButtonName
            
        case 1:
            if screenturned == false{
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {self.subtable.center.y += 50}, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .layoutSubviews, animations: {self.snapshot.center.y += 50}, completion: nil)
            }else{
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {self.subtable.center.x += 50}, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .layoutSubviews, animations: {self.snapshot.center.x += 50}, completion: nil)
            }
            
            lastButtonName = "none"
        case 2:
            lastButtonName = selectedButtonName
        default:
            lastButtonName = selectedButtonName
        }
    }
        
        
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallitems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
            cell.cellicon.image = icons[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if pressButton == 0{
            colorNumber = indexPath.item
        }
        if pressButton == 1{
            sprayNumber = indexPath.item
        }
        if pressButton == 2{
            tagNumber = indexPath.item
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {self.subtable.center.y += 50}, completion: nil)
        
        lastButtonName = "none"
        print(indexPath.item)
    }

    
    private func anyPlaneFrom(location:CGPoint, usingExtent:Bool = true) -> (SCNNode, SCNVector3, ARPlaneAnchor)? {
        let results = sceneView.hitTest(location,
                                        types: usingExtent ? ARHitTestResult.ResultType.existingPlaneUsingExtent : ARHitTestResult.ResultType.existingPlane)
        
        guard results.count > 0,
            let anchor = results[0].anchor as? ARPlaneAnchor,
            let node = sceneView.node(for: anchor) else { return nil }
        
        return (node,
                SCNVector3Make(results[0].worldTransform.columns.3.x, results[0].worldTransform.columns.3.y, results[0].worldTransform.columns.3.z),
                anchor)
    }
    
    func createGIFAnimation(url:URL) -> CAKeyframeAnimation?{
        
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(src)
        
        // Total loop time
        var time : Float = 0
        
        // Arrays
        var framesArray = [AnyObject]()
        var tempTimesArray = [NSNumber]()
        
        // Loop
        for i in 0..<frameCount {
            
            // Frame default duration
            var frameDuration : Float = 0.1;
            
            let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
            guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
            guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
                else { return nil }
            
            // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
            if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                frameDuration = delayTimeUnclampedProp.floatValue
            }
            else{
                if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    frameDuration = delayTimeProp.floatValue
                }
            }
            
            // Make sure its not too small
            if frameDuration < 0.011 {
                frameDuration = 0.100;
            }
            
            // Add frame to array of frames
            if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
                tempTimesArray.append(NSNumber(value: frameDuration))
                framesArray.append(frame)
            }
            
            // Compile total loop time
            time = time + frameDuration
        }
        
        var timesArray = [NSNumber]()
        var base : Float = 0
        for duration in tempTimesArray {
            timesArray.append(NSNumber(value: base))
            base += ( duration.floatValue / time )
        }
        
        // From documentation of 'CAKeyframeAnimation':
        // the first value in the array must be 0.0 and the last value must be 1.0.
        // The array should have one more entry than appears in the values array.
        // For example, if there are two values, there should be three key times.
        timesArray.append(NSNumber(value: 1.0))
        
        // Create animation
        let animation = CAKeyframeAnimation(keyPath: "contents")
        
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = Float.greatestFiniteMagnitude;
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.values = framesArray
        animation.keyTimes = timesArray
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.calculationMode = kCAAnimationDiscrete
        
        return animation;
    }

    var lastPaint = Date()
    private func paint() {
        isspray = true
        var colorboard : [UIColor] = [clear,black,white,orange,green,blue,red]
        var frame: TimeInterval = 1.0
        let now = Date()
        if pressButton == 1{
            frame = 1.0/100.0
        }
        guard lastPaint + frame < now,
              let trackingTouch = trackingTouch,
              let povPosition = sceneView.pointOfView?.position else { return }
        lastPaint = now

        let location = trackingTouch.location(in: view)
        let results = sceneView.hitTest(location, options: [
            SCNHitTestOption.categoryBitMask: NodeCategory.wallNode.rawValue,
            SCNHitTestOption.firstFoundOnly: true
            ])

        // find "target" position..
        guard let wallNode = results.first?.node,
              let localCoordinates = results.first?.localCoordinates,
              let worldCoordinates = results.first?.worldCoordinates,
              let scene = wallNode.geometry?.firstMaterial?.diffuse.contents as? SKScene else {
                return
        }

//        print("woallNode", wallNode.worldPosition)


        let distance = povPosition.distance(vector: worldCoordinates)

        // this calculation works, however it is entirely specific to this particular geometry (scnplane) and the
        // coordinate system of the skscene.. also who knows, may not work in all cases :D
        let skPosition = CGPoint(x: CGFloat(localCoordinates.x) * WALL_TEXT_SIZE_MULP + scene.size.width * 0.5,
                                 y: -CGFloat(localCoordinates.y) * WALL_TEXT_SIZE_MULP + scene.size.height * 0.5)
        if pressButton == 2{
            let scnSize = BrushFactory.brushSizeForDistance(distance: CGFloat(distance))
            let skSize = CGSize(width: scnSize.width * WALL_TEXT_SIZE_MULP*6,
                                height: scnSize.height * WALL_TEXT_SIZE_MULP*6)
            let gifNode = BrushFactory.shared.gifNode(size: skSize,number: tagNumber)
            gifNode.position = skPosition
            gifNode.name = "gif\(tagNumber)"
            scene.addChild(gifNode)
            var time : [Double] = [0.06,0.03,0.03,0.03,0.04,0.06,0.06]
            scene.childNode(withName: "gif\(tagNumber)")?.run(SKAction.repeatForever(SKAction.animate(with: BrushFactory.shared.taglist[tagNumber], timePerFrame: time[tagNumber])))
        }
        
        if pressButton == 1{
        let scnSize = BrushFactory.brushSizeForDistance(distance: CGFloat(distance))

        let skSize = CGSize(width: scnSize.width * WALL_TEXT_SIZE_MULP,
                            height: scnSize.height * WALL_TEXT_SIZE_MULP)

        let color = colorboard[sprayNumber]
        let decalNode = BrushFactory.shared.brushNode(color: color,
                                                      size: skSize)

        //add spary annimation
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2

        
        if distance < 0.5 {
//            self.sceneView.scene.rootNode.enumerateChildNodes({(node, _) in
//                if node.name == "pointer"{
//                    node.removeFromParentNode()
//                }
//            })
            let sprayNode = SCNNode()
            sprayNode.name = "pointer"
            sprayNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
//            sprayNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//            sprayNode.physicsBody?.isAffectedByGravity = false
            let spray = SCNParticleSystem(named: "Spray.scnp", inDirectory: nil)
            spray?.particleColor = colorboard[sprayNumber]
            sprayNode.addParticleSystem(spray!)
            self.sceneView.scene.rootNode.addChildNode(sprayNode)
        }
        decalNode.position = skPosition
        scene.addChild(decalNode)
        }
    }

    
    
//    drawing lines that can't change linewith realtime
//    func grattifi(){
//        isspray = true
//        var colorboard : [UIColor] = [clear,black,white,orange,green,blue,red]
//        let now = Date()
//        guard lastPaint + 1.0/20.0 < now,
//            let trackingTouch = trackingTouch,
//            let povPosition = sceneView.pointOfView?.position else { return }
//        lastPaint = now
//
//        let location = trackingTouch.location(in: view)
//        let results = sceneView.hitTest(location, options: [
//            SCNHitTestOption.categoryBitMask: NodeCategory.wallNode.rawValue,
//            SCNHitTestOption.firstFoundOnly: true
//            ])
//
//        // find "target" position..
//        guard let wallNode = results.first?.node,
//            let localCoordinates = results.first?.localCoordinates,
//            let worldCoordinates = results.first?.worldCoordinates,
//            let scene = wallNode.geometry?.firstMaterial?.diffuse.contents as? SKScene else {
//                return
//        }
//
//        print("woallNode", wallNode.worldPosition)
//
//
//        let distance = povPosition.distance(vector: worldCoordinates)
//
//        // this calculation works, however it is entirely specific to this particular geometry (scnplane) and the
//        // coordinate system of the skscene.. also who knows, may not work in all cases :D
//        let skPosition = CGPoint(x: CGFloat(localCoordinates.x) * WALL_TEXT_SIZE_MULP + scene.size.width * 0.5,
//                                 y: -CGFloat(localCoordinates.y) * WALL_TEXT_SIZE_MULP + scene.size.height * 0.5)
//
//        let color = colorboard[sprayNumber]
//
//        if touchbegan == true{
//            points = [skPosition]
//        }else{
//            points.append(skPosition)
//        }
//
//        var line : String = "line"
//        line = "line" + String(lineNumber)
//        scene.enumerateChildNodes(withName: line, using: {node, stop in
//            node.removeFromParent()
//        })
//        let splineShapeNode = SKShapeNode(splinePoints: &points,
//                                          count: points.count)
////        splineShapeNode.strokeTexture = SKTexture(imageNamed: "test")
//        splineShapeNode.lineWidth = BrushFactory.graffitiSize(distance: CGFloat(distance))
//        print(splineShapeNode.lineWidth)
//        splineShapeNode.strokeColor = color
//        splineShapeNode.name = "line" + String(lineNumber)
//        scene.addChild(splineShapeNode)
//    }
    
    
    
    
    
    
    

    
    private var trackingTouch:UITouch?
    private func isInPaintRect(location:CGPoint) -> Bool {
        return true
    }
    private func isInPaintRect(touch:UITouch) -> Bool {
        let location = touch.location(in: view)
        return isInPaintRect(location: location)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        trackingTouch = touches.first
//        let point = trackingTouch?.location(in: view)
//        points.append(point!)
        touchbegan = true
        
        let path = Bundle.main.path(forResource: "spraySound.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            spraySound = try AVAudioPlayer(contentsOf: url)
            spraySound.numberOfLoops = -1
            spraySound.volume = 0.5
            spraySound.prepareToPlay()
            spraySound.play()
        } catch {
            print(error)
        }
        
    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first
//        let point = touch?.location(in: view)
////        points.append(point!)
////        print(point)
//        touchbegan = false
//
//    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let trackingTouch = trackingTouch,
            touches.contains(trackingTouch) else { return }
        self.trackingTouch = nil
        isspray = false
        spraySound.stop()
//        lineNumber = lineNumber + 1
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let trackingTouch = trackingTouch,
            touches.contains(trackingTouch) else { return }
        self.trackingTouch = nil
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        let path = Bundle.main.path(forResource: "shakeit.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            shakeit = try AVAudioPlayer(contentsOf: url)
            shakeit.numberOfLoops = -1
            shakeit.volume = 0.5
            shakeit.prepareToPlay()
            shakeit.play()
        } catch {
            print(error)
        }
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        shakeit.stop()
    }

    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//         grattifi()
        paint()
        
    }
    
    // MARK: - ARSessionObserver
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        present(state: camera.trackingState)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        if pressButton == 0{
            // 检测到新平面时创建 SceneKit 平面以实现 3D 视觉化
            let plane = Plane(withAnchor: anchor)
            planes[anchor.identifier] = plane
            node.addChildNode(plane)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = planes[anchor.identifier] else {
            return
        }
        // anchor 更新后也需要更新 3D 几何体。例如平面检测的高度和宽度可能会改变，所以需要更新 SceneKit 几何体以匹配
        if wallupdated{
        plane.update(anchor: anchor as! ARPlaneAnchor, colorNumber: colorNumber)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // 如果多个独立平面被发现共属某个大平面，此时会合并它们，并移除这些 node
        planes.removeValue(forKey: anchor.identifier)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}


