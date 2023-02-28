//
//  File.swift
//  TrackerThresholdUtil
//
//  Created by Klaus Lanzarini on 16/11/20.
//

import Foundation
import Charts
import AssetTrackingDataModel

public class PillMarker: MarkerImage {
    private (set) var color: UIColor
    private (set) var font: UIFont
    private (set) var textColor: UIColor
    private var labelText: String = ""
    private var attrs: [NSAttributedString.Key: AnyObject]!
    
    public init(color: UIColor, font: UIFont, textColor: UIColor) {
        self.color = color
        self.font = font
        self.textColor = textColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attrs = [.font: font, .paragraphStyle: paragraphStyle, .foregroundColor: textColor, .baselineOffset: NSNumber(value: -4)]
        super.init()
    }
    
    public override func draw(context: CGContext, point: CGPoint) {
        // custom padding around text
        let labelWidth = labelText.size(withAttributes: attrs).width + 10
        // if you modify labelHeigh you will have to tweak baselineOffset in attrs
        let labelHeight = labelText.size(withAttributes: attrs).height + 4
        
        // place pill x origin above the marker
        var rectangle = CGRect(x: point.x, y: point.y, width: labelWidth, height: labelHeight)
        let spacing: CGFloat = 20
        rectangle.origin.y -= rectangle.height + spacing
        // if text crosses right border -> translate to the left
        let uiScreenWidth = UIScreen.main.bounds.width
        let leftSpace = uiScreenWidth - rectangle.origin.x - rectangle.size.width
        if (leftSpace < rectangle.size.width) {
            rectangle.origin.x = rectangle.origin.x - rectangle.size.width
        }
        // rounded rect
        let clipPath = UIBezierPath(roundedRect: rectangle, cornerRadius: 6.0).cgPath
        context.addPath(clipPath)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.closePath()
        context.drawPath(using: .fillStroke)
        
        // add the text
        labelText.draw(with: rectangle, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let dateString = DateFormatter.short.string(from: entry.x.date)
        labelText = "\(dateString): [\(entry.y.rounded(toPlaces: 1))]"
    }
}
