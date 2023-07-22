//
//  CompassCanvas.swift
//  Radventure
//
//  Created by Can Duru on 22.07.2023.
//

//MARK: Import
import Foundation
import UIKit

class CanvasView: UIView {

    //MARK: Set Up
    var halfFrameWidth: CGFloat=0
    var fullFrameWidth: CGFloat=0
    let needleBottomWidth: CGFloat=8.0
    var needleLength: CGFloat=0
    
    //MARK: Drawing Function
    override func draw(_ rect: CGRect){
            
        halfFrameWidth=self.bounds.width/2
        fullFrameWidth=self.bounds.width
        needleLength = halfFrameWidth*0.3
        
        createNeedle()
    }
    
    //MARK: Needle Drawing
    func createNeedle(){
        
        
        //MARK: Upper Needle Draw Constraints
        let upperNeedle = UIBezierPath()
        upperNeedle.move(to: CGPoint(x: halfFrameWidth-needleBottomWidth, y: halfFrameWidth))
        upperNeedle.addLine(to: CGPoint(x: halfFrameWidth, y: needleLength))
        upperNeedle.addLine(to: CGPoint(x: halfFrameWidth + needleBottomWidth, y: halfFrameWidth))
        upperNeedle.close()
        UIColor.red.setFill()
        upperNeedle.fill()
        
        //MARK: Bottom Needle Drawing Constraints
        let bottomNeedle = UIBezierPath()
        bottomNeedle.move(to: CGPoint(x: halfFrameWidth-needleBottomWidth, y: halfFrameWidth))
        bottomNeedle.addLine(to: CGPoint(x: halfFrameWidth, y: fullFrameWidth-needleLength))
        bottomNeedle.addLine(to: CGPoint(x: halfFrameWidth + needleBottomWidth, y: halfFrameWidth))
        bottomNeedle.close()
        UIColor.white.setFill()
        bottomNeedle.fill()
        
    }

}
