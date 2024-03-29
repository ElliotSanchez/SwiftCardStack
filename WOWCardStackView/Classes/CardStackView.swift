//
//  CardStackView.swift
//  CardStack
//
//  Created by Zhou Hao on 11/3/17.
//  Copyright © 2017 Zhou Hao. All rights reserved.
//

import UIKit

public protocol CardStackViewDataSource: class {
    func nextCard(in: CardStackView) -> CardView?
    func cardStackView(_ cardStackView: CardStackView, cardAt index: Int) -> CardView
    func numOfCardInStackView(_ cardStackView: CardStackView) -> Int
}

public protocol CardStackViewDelegate: class {
    func cardStackView(_: CardStackView, didSelect card: CardView)
}

@IBDesignable
public class CardStackView: UIView, CardViewDelegate {

    // MARK: - Properties
    public weak var dataSource: CardStackViewDataSource? { // TODO: add to dataSource in Inspector
        didSet {
            reloadData()
        }
    }
    
    public weak var delegate: CardStackViewDelegate?
    
    // MARK: - Private properties
    private var nib : UINib?
    
    // MARK: - Inspectable properties
    @IBInspectable
    public var offsetY: CGFloat = 0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var scaleFactor: Float = 0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    // MARK: - Public methods
    public func register(nib: UINib) {
        self.nib = nib
    }
    
    public func dequeueCardView() -> CardView {
        if let view = nib?.instantiate(withOwner: self, options: nil).first as? CardView {
            return view
        } else {
            return CardView()
        }
    }
    
    public func reloadData() {
        
        subviews.filter { $0.isKind(of: CardView.self) }.forEach { $0.removeFromSuperview() }
        
        if let dataSource = dataSource {
            let total = dataSource.numOfCardInStackView(self)
    
            var prevView: UIView?
            for i in 0..<total {
                let cardView = dataSource.cardStackView(self, cardAt: i)
                cardView.delegate = self
                if let prevView = prevView {
                    self.insertSubview(cardView, belowSubview: prevView)
                } else {
                    addSubview(cardView)
                }
                prevView = cardView
            }
            
            layoutIfNeeded()
        }
    }
    
    // MARK: - CardViewDelegate
    
    public func shouldRemoveCardView(_ cardView: CardView) {
        if let nextCard = dataSource?.nextCard(in: self) {
            nextCard.delegate = self
            // always in last
            insertSubview(nextCard, at: 0)
        }
    }
    
    public func cardViewDidSelected(_ cardView: CardView) {
        self.delegate?.cardStackView(self, didSelect: cardView)
    }
    
    // MARK: - Override
    override open func layoutSubviews() {
        // setup cards frame
        var index = 0
        let allCardViews = subviews.filter { $0.isKind(of: CardView.self) }
        for cardView in allCardViews.reversed() {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                cardView.frame = self.rectAt(index: index)
                index += 1
            }, completion: { (complete) in
            })
        }
    }
    
    // MARK: - Private methods
    private func rectAt(index: Int) -> CGRect {
        guard let dataSource = dataSource else { return CGRect.zero }
        
        let total = dataSource.numOfCardInStackView(self)
        let percentScaleBasedOnPosition = CGFloat(pow(scaleFactor, Float(index)))
        
        // xOffSetForCard
        let stackViewWidth = bounds.width
        let widthAdjustment = stackViewWidth * percentScaleBasedOnPosition
        let xOffsetForCard = ( stackViewWidth - widthAdjustment ) / 2.0
        
        // widthForCard
        let widthForCard = stackViewWidth * percentScaleBasedOnPosition
        
        // yOffsetForCard
        let stackViewHieght = bounds.height
        let offetOfAllBackgroundCards = CGFloat(total - 1) * offsetY
        let standardCardHeight = stackViewHieght - offetOfAllBackgroundCards
        let heightAdjustment = standardCardHeight * percentScaleBasedOnPosition
        let individualCardHeight = standardCardHeight - heightAdjustment
        let verticalStackShift = CGFloat(index)*offsetY
        let yOffsetForCard = individualCardHeight + verticalStackShift
        
        // heightForCard
        let heightForCard = standardCardHeight * percentScaleBasedOnPosition
        
        return CGRect(
            x: xOffsetForCard,
            y: yOffsetForCard,
            width: widthForCard,
            height: heightForCard
        )
    }
}
