//
//  NFCCard.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//
import SwiftUI
import STUI



public struct NFCCard<Content: View>: View {
    @State private var isExpanded: Bool = false
    private var nfcCardType: NFCCardType
    private let onWriteToNFC: (() -> Void)?
    private let content: Content
    
    public init(nfcCardType: NFCCardType, onWriteToNFC: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.nfcCardType = nfcCardType
        self.content = content()
        self.onWriteToNFC = onWriteToNFC
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                Image(systemName: self.nfcCardType.getImageName())
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(SUIColorLayout.primary.color)
                
                Spacer()
                
                Text(self.nfcCardType.getShortDescription()).font(.title2).bold()
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(SUIColorLayout.primary.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .onTapGesture {
                withAnimation(.easeInOut(duration: nfcCardType == .nfcVCard ?  0.5 :  0.25)) {
                    self.isExpanded.toggle()
                }
            }
            
            
            if isExpanded {
                VStack (alignment: .center, spacing: 8){
                    Divider().padding(.horizontal, 8)
                    
                    content
                    
                }.transition(.opacity.combined(with: .scale(scale: 1, anchor: .top)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .padding(8)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
