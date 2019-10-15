//
//  ViewController.swift
//  CardStack
//
//  Created by Zhou Hao on 11/3/17.
//  Copyright © 2017 Zhou Hao. All rights reserved.
//

import UIKit
import WOWCardStackView

class ViewController: UIViewController {

    @IBOutlet weak var cardStackView: CardStackView!
    var orderNo: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardStackView.dataSource = self
        cardStackView.delegate = self        
    }
    
    func createCard(order: Int) -> MyCard {
        let card = MyCard(id: order)
        card.id = order
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = UIFont(name: "Arial", size: 28)
        label.text = "\(order)"
        label.textAlignment = .center
        label.textColor = UIColor.white
        card.addSubview(label)
        card.backgroundColor = UIColor.red
        card.borderWidth = 1.0
        card.borderColor = UIColor.lightGray
        card.isShadowed = true
        return card
    }

}


extension ViewController: CardStackViewDataSource {
    
    func nextCard(in: CardStackView) -> CardView? {
        if orderNo < 4 {
            orderNo += 1
        } else {
            orderNo = 1
        }
        
        let card = createCard(order: orderNo)
        return card
    }
    
    func cardStackView(_ cardStackView: CardStackView, cardAt index: Int) -> CardView {
        return createCard(order: index)
    }
    
    func numOfCardInStackView(_ cardStackView: CardStackView) -> Int {
        return 3
    }
}


extension ViewController: CardStackViewDelegate {
    
    public func cardStackView(_: CardStackView, didSelect card: CardView) {
           if let card = card as? MyCard {
               print("Clicked: \(card.id)")
               
               if let details = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
                   details.id = card.id
                   self.navigationController?.pushViewController(details, animated: true)
               }
           }
       }
}
