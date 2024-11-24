//
//  SeatsSelectionViewController.swift
//  Movies
//
//  Created by Preeten Dali on 22/11/24.
//

import UIKit

class SeatsSelectionViewController: UIViewController {
    
    @IBOutlet var seatButtons: [UIButton]!
    @IBOutlet weak var checkoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSeats()
    }
    
    func setupSeats() {
        for button in seatButtons {
            button.layer.cornerRadius = 4
            button.backgroundColor = .systemGreen
        }
    }
    
    @IBAction func seatTapped(_ sender: UIButton) {
        if sender.backgroundColor == UIColor.systemGreen {
            sender.backgroundColor = UIColor.systemGray
        } else if sender.backgroundColor == UIColor.systemGray {
            sender.backgroundColor = UIColor.systemGreen
        }
    }
    
    @IBAction func checkoutTapped(_ sender: UIButton) {
        let selectedSeatsCount = seatButtons.filter { $0.backgroundColor == UIColor.systemGray }.count
        showToast(message: "You have selected \(selectedSeatsCount) seats.")
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let maxWidth = view.frame.size.width * 0.8
        let textSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        let width = min(textSize.width + 20, maxWidth)
        let height = textSize.height + 10
        
        toastLabel.frame = CGRect(x: (view.frame.size.width - width) / 2,
                                  y: view.frame.size.height - 100,
                                  width: width,
                                  height: height)
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseIn, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
    
}
