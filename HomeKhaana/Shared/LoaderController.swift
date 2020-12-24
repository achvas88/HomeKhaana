//
//  LoaderController.swift
//  HomeKhaana
//
//  Created by Achyuthan Vasanth on 9/2/18.
//  Copyright © 2018 Achyuthan Vasanth. All rights reserved.
//

import UIKit

class LoaderController: NSObject {
    
    static let sharedInstance = LoaderController()
    private let indActivityIndicator = UIActivityIndicatorView()
    private let lblIndicator = UILabel()
    private let stkContainer = UIStackView()
    
    override init() {
        super.init()
        self.oneTimeSetup()
    }
    
    private func oneTimeSetup()
    {
        //setup text
        if #available(iOS 13.0, *) {
            lblIndicator.textColor = UIColor.secondaryLabel
        } else {
            lblIndicator.textColor = UIColor.systemGray
        }
        lblIndicator.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        lblIndicator.textAlignment = .center
        
        //setup indicator
        indActivityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            indActivityIndicator.style = .medium
        } else {
            indActivityIndicator.style = .white
        }
        indActivityIndicator.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        indActivityIndicator.widthAnchor.constraint(equalToConstant: 45.0).isActive = true

        //setup stack
        stkContainer.axis = .vertical
        stkContainer.addArrangedSubview(indActivityIndicator)
        stkContainer.addArrangedSubview(lblIndicator)
        if #available(iOS 13.0, *) {
            stkContainer.addBackground(color: UIColor.secondarySystemBackground)
        } else {
            stkContainer.addBackground(color: UIColor.systemGray)
        }
        stkContainer.distribution = .fillProportionally;
        stkContainer.alignment = .center;
        stkContainer.spacing = 0;
        stkContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - Private Methods -
    private func setupLoader(indicatorText: String, holdingView: UIView) {
        removeLoader()
        lblIndicator.widthAnchor.constraint(equalToConstant: holdingView.frame.width).isActive = true
        lblIndicator.text = indicatorText
    }
    
    private func postSetupLoader(holdingView: UIView) {
        stkContainer.centerXAnchor.constraint(equalTo: holdingView.centerXAnchor).isActive = true
        stkContainer.centerYAnchor.constraint(equalTo: holdingView.centerYAnchor).isActive = true
    }
    
    //MARK: - Public Methods -
    func showLoader(indicatorText: String, holdingView: UIView) {
        setupLoader(indicatorText: indicatorText, holdingView: holdingView)
        
        DispatchQueue.main.async {
            self.stkContainer.center = holdingView.center
            self.indActivityIndicator.startAnimating()
            holdingView.addSubview(self.stkContainer)
            self.postSetupLoader(holdingView: holdingView)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.indActivityIndicator.stopAnimating()
            self.stkContainer.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func updateTitle(title: String)
    {
        self.lblIndicator.text = title
    }
}
