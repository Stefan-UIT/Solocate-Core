//
//  SignatureViewController.swift
//  DMSDriver
//
//  Created by MrJ on 2/12/19.
//  Copyright © 2019 SeldatInc. All rights reserved.
//

import UIKit

protocol SignatureViewControllerDelegate:AnyObject {
    func signatureViewController(view:SignatureViewController, didCompletedSignature signature:AttachFileModel?, signName:String?);
}

class SignatureViewController: BaseViewController {

    @IBOutlet weak var signHereButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var btnOK: UIButton?
    @IBOutlet weak var btnClear: UIButton?
    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var signatureImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    weak var delegate:SignatureViewControllerDelegate?
    
    var order:Order?
    var isFromOrderDetail = false
    var validationSubmit:Bool = false{
        didSet{
            updateUI()
        }
    }
    
    var signName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validationSubmit = false
        signatureView?.delegate = self
        self.fd_interactivePopDisabled = true
        self.nameTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fd_interactivePopDisabled = false
        App().statusBarView?.backgroundColor = AppColor.white
    }
    
    // MARK: Function
     override func updateUI() {
        btnOK?.alpha = validationSubmit ? 1 : 0.3
        btnOK?.isUserInteractionEnabled = validationSubmit
        btnClear?.alpha = validationSubmit ? 1 : 0.3
        btnClear?.isUserInteractionEnabled = validationSubmit
        navigationController?.navigationBar.barTintColor = AppColor.background
        App().statusBarView?.backgroundColor = AppColor.background
        
        if isFromOrderDetail || order?.isRequireSign() == true {
            skipButton.setTitle("back".localized, for: .normal)
        }else {
            skipButton.setTitle("skip".localized, for: .normal)
        }
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
        handleComplationSignature()
        handleGoBackAction()
    }

    @IBAction func skipButtonAction(_ sender: UIButton) {
        if isFromOrderDetail == true ||
            order?.isRequireSign() == true {
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

fileprivate extension SignatureViewController {
    func handleComplationSignature()  {
        let rect = signatureView?.frame ?? CGRect.zero
        guard signatureView.signLayer != nil else {
            showAlertView("Signature is not empty.")
            return
        }
        
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        signatureView?.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard  let image = img, let data = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let signatureFile: AttachFileModel = AttachFileModel()
        signatureFile.name = "Signature_\(order?.id ?? 0)"
        signatureFile.type = ".png"
        signatureFile.typeFile = "SIG"
        signatureFile.mimeType = "image/png"
        signatureFile.contentFile = data
        signatureFile.param = "files[0]"
        
        
        delegate?.signatureViewController(view: self, didCompletedSignature: signatureFile, signName: signName)
    }
    
    func handleSkipAction() {
        delegate?.signatureViewController(view: self, didCompletedSignature: nil, signName: nil)
        handleGoBackAction()
    }
    
    func handleGoBackAction() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SignatureViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            signName = textField.text
        }
    }
}

