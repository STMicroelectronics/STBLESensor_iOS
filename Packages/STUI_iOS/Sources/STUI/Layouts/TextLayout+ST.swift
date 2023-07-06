//
//  TextLayout+ST.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension TextLayout {
    static let title: TextLayout = {
        return TextLayout(color: ColorLayout.text.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.title)
    }()
    
    static let largetitle: TextLayout = {
        return TextLayout(color: ColorLayout.text.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .center,
                          numberOfLines: 0,
                          font: FontLayout.regular).size(34.0)
    }()
    
    static let subtitle: TextLayout = {
        return TextLayout(color: ColorLayout.text.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.subtitle)
    }()
    
    static let text: TextLayout = {
        return TextLayout(color: ColorLayout.text.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.regular)
    }()

    static let info: TextLayout = {
        return TextLayout(color: ColorLayout.text.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.regular).size(13.0).weight(.light)
    }()
    
    static let infoBold: TextLayout = {
        return TextLayout(color: ColorLayout.text.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.bold).size(13.0).weight(.bold)
    }()

    static let tabItem: TextLayout = {
        return TextLayout(color: .white,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.regular).size(14.0)
    }()
    
    static let title2: TextLayout = {
        return TextLayout(color: ColorLayout.primary.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.bold)
    }()
    
    static let bold: TextLayout = {
        return TextLayout(color: ColorLayout.primary.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.bold).size(17.0)
    }()
    
    static let accentBold: TextLayout = {
        return TextLayout(color: ColorLayout.accent.auto,
                          backgroundColor: nil,
                          cornerRadius: nil,
                          borderColor: nil,
                          borderWith: nil,
                          alignment: .left,
                          numberOfLines: 0,
                          font: FontLayout.bold).size(17.0)
    }()
}
