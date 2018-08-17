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
import SwiftyJSON
import DCAnimationKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var planes = [UUID:Plane]() // 字典，存储场景中当前渲染的所有平面
    var selectedButtonName : String = ""
    var pressButton : Int = 0
    let buttonArrray = ["wall", "spray", "tag", "camera", "delete"]
    var lastButtonName : String = "none"
    var currentStateDisplayed:String? = nil
    
    var index : Int = 0
    var wallitems = ["0","1","2","3","4","5","6"]
    var wallcolors = [#imageLiteral(resourceName: "1w"),#imageLiteral(resourceName: "2w"),#imageLiteral(resourceName: "3w"),#imageLiteral(resourceName: "4w"),#imageLiteral(resourceName: "5w"),#imageLiteral(resourceName: "6w"),#imageLiteral(resourceName: "7w")]
    var spraycolors = [#imageLiteral(resourceName: "s1"),#imageLiteral(resourceName: "s2"),#imageLiteral(resourceName: "s3"),#imageLiteral(resourceName: "s4"),#imageLiteral(resourceName: "s5"),#imageLiteral(resourceName: "s6"),#imageLiteral(resourceName: "s7")]
    var icons = [#imageLiteral(resourceName: "1w"),#imageLiteral(resourceName: "2w"),#imageLiteral(resourceName: "3w"),#imageLiteral(resourceName: "4w"),#imageLiteral(resourceName: "5w"),#imageLiteral(resourceName: "6w"),#imageLiteral(resourceName: "7w")]
    var sprayNumber : Int = 2
    var colorNumber : Int = 1
    var wallupdated : Bool = true
    var isspray : Bool = false
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
    @IBOutlet weak var subtable: UICollectionView!
    @IBOutlet weak var bar: UIStackView!
    @IBOutlet weak var statusColor: UIView!
    @IBOutlet weak var status: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.overlaySKScene = SKScene(size: view.frame.size)
        
        // with this we will stil get touches began..
        sceneView.overlaySKScene!.isUserInteractionEnabled = false
        
        subtable.alwaysBounceHorizontal = false
        subtable.delegate = self
        subtable.dataSource = self
        statusColor.layer.cornerRadius = 2
        
        
        
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
    
    @IBAction func barPresseed(_ sender: UIButton){
        selectedButtonName = buttonArrray[sender.tag]
        print(selectedButtonName)
        pressButton = sender.tag
        
        if pressButton == 0{
            wallupdated = true
            icons = wallcolors
            subtable.reloadData()
        }else{
            wallupdated = false
        }
        
        if pressButton == 1{
            icons = spraycolors
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
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .layoutSubviews, animations: {self.subtable.center.y -= 50}, completion: nil)
            sender.bounce(nil)
            choosen(selectedButton: selectedButtonName)
            lastButtonName = selectedButtonName
        case 1:
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {self.subtable.center.y += 50}, completion: nil)
            
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
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {self.subtable.center.y += 50}, completion: nil)
        
        lastButtonName = "none"
        print(indexPath.item)
    }

    func choosen(selectedButton : String){
        if selectedButton == "wall"{
            print(subtable.numberOfSections)
            print(subtable.numberOfItems(inSection: 0))
           
            
        }
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
    
    

    var lastPaint = Date()
    private func paint() {
        isspray = true
        var colorboard : [UIColor] = [clear,black,white,orange,green,blue,red]
        let now = Date()
        guard lastPaint + 1.0/100.0 < now,
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
        
        print("woallNode", wallNode.worldPosition)
        
        
        let distance = povPosition.distance(vector: worldCoordinates)
        
        // this calculation works, however it is entirely specific to this particular geometry (scnplane) and the
        // coordinate system of the skscene.. also who knows, may not work in all cases :D
        let skPosition = CGPoint(x: CGFloat(localCoordinates.x) * WALL_TEXT_SIZE_MULP + scene.size.width * 0.5,
                                 y: -CGFloat(localCoordinates.y) * WALL_TEXT_SIZE_MULP + scene.size.height * 0.5)
        
        let scnSize = BrushFactory.brushSizeForDistance(distance: CGFloat(distance))
        
        let skSize = CGSize(width: scnSize.width * WALL_TEXT_SIZE_MULP,
                            height: scnSize.height * WALL_TEXT_SIZE_MULP)
        
        let color = colorboard[sprayNumber]
        let decalNode = BrushFactory.shared.brushNode(color: color,
                                                      size: skSize)
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        
        //add spary annimation
        if distance < 0.5 {
            let sprayNode = SCNNode()
            sprayNode.name = "pointer"
            sprayNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
            sprayNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            sprayNode.physicsBody?.isAffectedByGravity = false
            let spray = SCNParticleSystem(named: "Spray.scnp", inDirectory: nil)
            spray?.particleColor = colorboard[sprayNumber]
            sprayNode.addParticleSystem(spray!)
            self.sceneView.scene.rootNode.addChildNode(sprayNode)
        }
        
        decalNode.position = skPosition
        scene.addChild(decalNode)
    }
    

    
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
        trackingTouch=touches.first
        print(isspray)
        
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
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let trackingTouch = trackingTouch,
            touches.contains(trackingTouch) else { return }
        self.trackingTouch = nil
        isspray = false
        print(isspray)
        spraySound.stop()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let trackingTouch = trackingTouch,
            touches.contains(trackingTouch) else { return }
        self.trackingTouch = nil
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        print("shake")
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
        print("end")
        shakeit.stop()
    }

    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
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
         print(anchor.identifier)
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


