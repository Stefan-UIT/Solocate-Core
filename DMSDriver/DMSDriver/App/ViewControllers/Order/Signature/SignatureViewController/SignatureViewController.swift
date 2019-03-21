//
//  SignatureViewController.swift
//  DMSDriver
//
//  Created by MrJ on 2/12/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

class SignatureViewController: BaseViewController {

    @IBOutlet weak var signHereButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var btnOK: UIButton?
    @IBOutlet weak var btnClear: UIButton?
    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var signatureImageView: UIImageView!
    
    var validationSubmit:Bool = false{
        didSet{
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validationSubmit = false
        signatureView?.delegate = self
        self.fd_interactivePopDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fd_interactivePopDisabled = false
    }

    
    // MARK: Function
     override func updateUI() {
        btnOK?.alpha = validationSubmit ? 1 : 0.3
        btnOK?.isUserInteractionEnabled = validationSubmit
        btnClear?.alpha = validationSubmit ? 1 : 0.3
        btnClear?.isUserInteractionEnabled = validationSubmit
        navigationController?.navigationBar.barTintColor = AppColor.background
        App().statusBarView?.backgroundColor = AppColor.background
    }
    
    private func handleSkipAction() {
        let addNoteView = AddNoteView()
        addNoteView.showViewInWindow()
    }
    
    private func handleGoBackAction() {
        navigationController?.popViewController(animated: true)
    }

    
    // MARK: - Action
    @IBAction func signHereButtonAction(_ sender: UIButton) {
        sender.isHidden = true
        signatureView.setStrokeColor(.white)
    }
    
    @IBAction func onbtnClickClear(_ sender: UIButton) {
        validationSubmit = false
        signatureView?.sign?.removeAllPoints()
        signatureView?.signLayer?.path = nil
        signatureView?.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
    @IBAction func okButtonAction(_ sender: UIButton) {
        let _ = signatureView.frame
        guard signatureView.signLayer != nil else {
            showAlertView("Signature is not empty.")
            return
        }
        
        let addNoteView = AddNoteView()
        addNoteView.delegate = self
        addNoteView.showViewInWindow()
        
    }

    @IBAction func skipButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            handleGoBackAction()
        } else {
            handleSkipAction()
        }
    }
}


//MARK: - SignatureViewDelegate
extension SignatureViewController:SignatureViewDelegate{
    func touchesMoved(_ sign: UIBezierPath?, _ signLayer: CAShapeLayer?) {
        self.validationSubmit = (sign != nil)
    }
}


//MARK: - AddNoteViewDelegate
extension SignatureViewController: AddNoteViewDelegate {
    func addNoteView(_ view: AddNoteView, _ note: String) {
        view.removeFromSuperview()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

