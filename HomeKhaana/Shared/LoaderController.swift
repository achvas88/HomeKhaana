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
        lblIndicator.textColor = UIColor.gray
        lblIndicator.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        lblIndicator.textAlignment = .center
        
        //setup indicator
        indActivityIndicator.hidesWhenStopped = true
        indActivityIndicator.style = .gray
        indActivityIndicator.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        indActivityIndicator.widthAnchor.constraint(equalToConstant: 45.0).isActive = true

        //setup stack
        stkContainer.axis = .vertical
        stkContainer.addArrangedSubview(indActivityIndicator)
        stkContainer.addArrangedSubview(lblIndicator)
        stkContainer.addBackground(color: UIColor(white: 1, alpha: 0.7))
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
        //let appDel = UIApplication.shared.delegate as! AppDelegate
        //let holdingView = appDel.window!.rootViewController!.view!
        
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
