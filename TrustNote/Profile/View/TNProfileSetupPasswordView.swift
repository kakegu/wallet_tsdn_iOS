//
//  TNProfileSetupPasswordView.swift
//  TrustNote
//
//  Created by zenghailong on 2018/6/1.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

import UIKit

protocol TNProfileSetupPasswordViewDelegate: NSObjectProtocol {
    
    func inputDidChanged(_ isValid: Bool)
}

class TNProfileSetupPasswordView: UIView {
    
    weak var delegate: TNProfileSetupPasswordViewDelegate?
    
    @IBOutlet weak var passwordRuleImgView: UIImageView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var originLine: UIView!
    @IBOutlet weak var newTextField: UITextField!
    @IBOutlet weak var newLine: UIView!
    @IBOutlet weak var passwdRuleLabel: UILabel!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var confirmLine: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswdClearBtn: UIButton!
    @IBOutlet weak var confirmPasswdClearBtn: UIButton!
    
    @IBOutlet weak var originPasswdClearBtn: UIButton!
    @IBOutlet weak var ruleLabelLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var confirmLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var originLineHeightConstraint: NSLayoutConstraint!
    
    lazy var passwordSecurityView: TNPasswordSecurityView = {
        let passwordSecurityView = TNPasswordSecurityView.passwordSecurityView()
        passwordSecurityView.isHidden = true
        return passwordSecurityView
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        originTextField.placeholder = "Please enter your old password".localized
        newTextField.placeholder = "Please enter your new password".localized
        confirmTextField.placeholder = "Please re-confirm your password".localized
        passwdRuleLabel.text = "Password.passwordLengthValid".localized
        errorLabel.text = "Password.checkInput".localized
        
        newPasswordView.addSubview(passwordSecurityView)
        passwordSecurityView.snp.makeConstraints { (make) in
            make.top.equalTo(newLine.snp.bottom).offset(9)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        originTextField.addTarget(self, action: #selector(TNProfileSetupPasswordView.textInputDidChange(_:)), for: .editingChanged)
        originTextField.delegate = self
        confirmTextField.addTarget(self, action: #selector(TNProfileSetupPasswordView.textInputDidChange(_:)), for: .editingChanged)
        confirmTextField.delegate = self
        newTextField.addTarget(self, action: #selector(TNProfileSetupPasswordView.textInputDidChange(_:)), for: .editingChanged)
        newTextField.delegate = self
    }
}

extension TNProfileSetupPasswordView: TNNibLoadable {
    
    class func profileSetupPasswordView() -> TNProfileSetupPasswordView {
        
        return TNProfileSetupPasswordView.loadViewFromNib()
    }
}

extension TNProfileSetupPasswordView {
    
    @IBAction func clearNewPasswordText(_ sender: Any) {
        newTextField.text = nil
        newPasswdClearBtn.isHidden = true
        passwordSecurityView.isHidden = true
        delegate?.inputDidChanged(false)
        passwordRuleImgView.isHidden = true
        passwdRuleLabel.textColor = UIColor.hexColor(rgbValue: 0xBBBBBB)
        ruleLabelLeftMargin.constant = 0
    }
    
    @IBAction func clearConfirmText(_ sender: Any) {
        confirmTextField.text = nil
        confirmPasswdClearBtn.isHidden = true
        delegate?.inputDidChanged(false)
        if !errorView.isHidden {
            errorView.isHidden = true
        }
    }
    
    @IBAction func clearOriginPasswordText(_ sender: Any) {
        originTextField.text = nil
        originPasswdClearBtn.isHidden = true
        delegate?.inputDidChanged(false)
    }
    
    @objc func textInputDidChange(_ textField: UITextField) {
        if !(originTextField.text?.isEmpty)! && !(newTextField.text?.isEmpty)! && !(confirmTextField.text?.isEmpty)! {
            delegate?.inputDidChanged(true)
        } else {
            delegate?.inputDidChanged(false)
        }
        
        if textField == newTextField {
            newPasswdClearBtn.isHidden = (newTextField.text?.length)! > 0 ? false : true
            if (textField.text?.length)! > 0 {
                passwordSecurityView.isHidden = false
                if String.isOnlyNumber(str: textField.text!) || String.isAllLetter(str: textField.text!) || String.isAllSpecialCharacter(str: textField.text!) {
                    passwordSecurityView.level = .weak
                } else if String.containsNumAndLetterAndSpecialCharacter(str: textField.text!) {
                    passwordSecurityView.level = .strong
                } else {
                    passwordSecurityView.level = .middle
                }
            } else {
                passwordSecurityView.isHidden = true
                passwdRuleLabel.textColor = UIColor.hexColor(rgbValue: 0xBBBBBB)
                ruleLabelLeftMargin.constant = 0
            }
        }
        if textField == confirmTextField {
            confirmPasswdClearBtn.isHidden = (confirmTextField.text?.length)! > 0 ? false : true
        }
        
        if textField == originTextField {
            originPasswdClearBtn.isHidden = (originTextField.text?.length)! > 0 ? false : true
        }
    }
}

extension TNProfileSetupPasswordView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == originTextField {
            originLine.backgroundColor = kGlobalColor
            originLineHeightConstraint.constant = 2.0
            if (textField.text?.count)! > 0 {
                originPasswdClearBtn.isHidden = false
            }
        }
        if textField == newTextField {
            newLine.backgroundColor = kGlobalColor
            newLineHeightConstraint.constant = 2.0
            if !passwordRuleImgView.isHidden {
                passwordRuleImgView.isHidden = true
                passwdRuleLabel.textColor = UIColor.hexColor(rgbValue: 0xBBBBBB)
                ruleLabelLeftMargin.constant = 0
            }
            if (textField.text?.count)! > 0 {
                newPasswdClearBtn.isHidden = false
            }
        }
        if textField == confirmTextField {
            confirmLine.backgroundColor = kGlobalColor
            confirmLineHeightConstraint.constant = 2.0
            if !errorView.isHidden {
                errorView.isHidden = true
            }
            if (textField.text?.count)! > 0 {
                confirmPasswdClearBtn.isHidden = false
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == originTextField {
            originLine.backgroundColor = kLineViewColor
            originLineHeightConstraint.constant = 1.0
            originPasswdClearBtn.isHidden = true
        }
        if textField == newTextField {
            newLine.backgroundColor = kLineViewColor
            newLineHeightConstraint.constant = 1.0
            newPasswdClearBtn.isHidden = true
        }
        if textField == confirmTextField {
            confirmLine.backgroundColor = kLineViewColor
            confirmLineHeightConstraint.constant = 1.0
            confirmPasswdClearBtn.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if String.isChineseCharacters(str: string) && string.count != 0 {
            return false
        }
        if string == " " {
            return false
        }
        return true
    }
}
