//
//  ConfirmationViewController.swift
//  Simaspay
//
//  Created by Dimo on 10/4/16.
//  Copyright © 2016 Kendy Susantho. All rights reserved.
//

import UIKit

class ConfirmationViewController: BaseViewController, UIAlertViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet var btnTrue: BaseButton!
    @IBOutlet var btnFalse: BaseButton!
    @IBOutlet var viewContentConfirmation: UIView!
    @IBOutlet var constraintViewContent: NSLayoutConstraint!
    
    
    var btnResandOTP: BaseButton!
    var tfOTP: BaseTextField!
    
    //Timer for OTP resend button
    var timerCount = 60
    var clock:Timer!
    var lblTimer: BaseLabel!
    
    var MDNString:String! = ""
    var otpString:String! = ""
    
    //Dictionary for show data registration
    var data: NSDictionary!
    
    //Dictionary Req OTP
    var dictForRequestOTP: NSDictionary!
    
    //Dictionary send ORP
    var dictForAcceptedOTP: NSDictionary!
    
    //Value to set background navigation
    var useNavigation: Bool = true
    
    var alertController = UIAlertController()
    
    static func initWithOwnNib() -> ConfirmationViewController {
        let obj:ConfirmationViewController = ConfirmationViewController.init(nibName: String(describing: self), bundle: nil)
        return obj
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!useNavigation) {
            self.viewNavigation.backgroundColor = UIColor.clear
            self.showBackButton(subMenu: false)
        } else {
            self.showBackButton()
        }
        self.showTitle(getString("ConfirmationTitle"))
        
        self.view.backgroundColor = UIColor.init(hexString: color_background)

        DLog("\(data)")
        self.viewContentConfirmation.layer.cornerRadius = 5.0;
        self.viewContentConfirmation.layer.borderColor = UIColor.init(hexString: color_border).cgColor
        self.viewContentConfirmation.layer.borderWidth = 0.5
        self.viewContentConfirmation.clipsToBounds = true;
        
        self.btnTrue.updateButtonType1()
        self.btnTrue.setTitle(getString("ConfirmationButtonTrue"), for: .normal)
        self.btnFalse.updateButtonType3()
        self.btnFalse.setTitle(getString("ConfirmationButtonFalse"), for: .normal)
        btnTrue.addTarget(self, action: #selector(ConfirmationViewController.buttonStatus) , for: .touchUpInside)
        btnFalse.addTarget(self, action: #selector(ConfirmationViewController.cancel), for: .touchUpInside)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ActivationPinViewController.didOTPCancel), name: NSNotification.Name(rawValue: "didOTPCancel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ActivationPinViewController.didOTPOK), name: NSNotification.Name(rawValue: "didOTPOK"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didOTPCancel"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didOTPOK"), object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Programmatically UI
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let padding:CGFloat = 16
        let sizeRect = UIScreen.main.applicationFrame
        let width    = sizeRect.size.width - 2 * 25
        let heightContent:CGFloat = 15
        let heightTitleContent:CGFloat = 15
        let margin:CGFloat = 10
        var y:CGFloat = 16
        
        
        let lblTitle = BaseLabel.init(frame: CGRect(x: padding, y: y, width: width - 2 * padding, height: heightTitleContent))
        lblTitle.font = UIFont.boldSystemFont(ofSize: 14)
        lblTitle.text = data.value(forKey: "title") as? String
        viewContentConfirmation.addSubview(lblTitle)
        y += heightTitleContent + 10
        
        
        let arrayContent = data.value(forKey: "content")
        for content in arrayContent as! Array<[String : String]> {
            for list in content {
                let key = list.key
                let Value = list.value
                
                if key == "-" {
                    let lblValue = BaseLabel.init(frame: CGRect(x: padding, y: y, width: width - 2 * padding, height: 90))
                    lblValue.font = UIFont.systemFont(ofSize: 13)
                    lblValue.numberOfLines = 0
                    lblValue.lineBreakMode = .byWordWrapping
                    lblValue.text = Value
                    viewContentConfirmation.addSubview(lblValue)
                    y += 90 + margin
                } else {
                    
                    let lblKey = BaseLabel.init(frame: CGRect(x: padding, y: y, width: width - 2 * padding, height: heightContent))
                    lblKey.font = UIFont.boldSystemFont(ofSize: 13)
                    lblKey.text = key
                    viewContentConfirmation.addSubview(lblKey)
                    y += heightContent
                    
                    let lblValue = BaseLabel.init(frame: CGRect(x: padding, y: y, width: width - 2 * padding, height: heightContent))
                    lblValue.font = UIFont.systemFont(ofSize: 13)
                    lblValue.text = Value
                    viewContentConfirmation.addSubview(lblValue)
                    y += heightContent + margin
                }
                
            }
        }
        
        if let contentFooterDica = data.value(forKey: "footer") {
            let contentFooterDic = contentFooterDica as! NSDictionary
            if contentFooterDic.allKeys.count != 0 {
                let line = CALayer()
                line.frame = CGRect(x: padding, y: y, width: width - 2 * padding, height: 1)
                line.backgroundColor = UIColor.init(hexString: color_line_gray).cgColor
                viewContentConfirmation.layer.addSublayer(line)
                
                y += margin
                for list in contentFooterDic {
                    let key = list.key as! String
                    let Value = list.value as! String
                    
                    let lblKey = BaseLabel.init(frame: CGRect(x: padding, y: y, width: width - 2 * padding, height: heightContent))
                    lblKey.font = UIFont.boldSystemFont(ofSize: 13)
                    lblKey.text = key
                    viewContentConfirmation.addSubview(lblKey)
                    y += heightContent
                    
                    let lblValue = BaseLabel.init(frame: CGRect(x: padding, y: y, width: width - 2 * padding, height: heightContent))
                    lblValue.font = UIFont.systemFont(ofSize: 13)
                    lblValue.text = Value
                    viewContentConfirmation.addSubview(lblValue)
                    y += heightContent + margin
                }
            }
        }
        let height = y + margin
        self.constraintViewContent.constant = height
    }
    
    //MARK: Action cancel
    func cancel()  {
        navigationController?.popViewController(animated: true)
    }
    
    
    //function true button
    func buttonStatus()  {
        self.requestOTP()
        self.showOTP()
    }
    
    func resendTheOTP() {
        self.requestOTP()
        timerCount = 60
        lblTimer.text = "01:00"
        lblTimer.isHidden = false
        btnResandOTP.isHidden = true
       
    }
    
    //MARK: Action button for OTP alert
    func didOTPCancel() {
        DLog("cancel");
        clock.invalidate()
        
    }
    
    func didOTPOK() {
        DLog("OK");
        clock.invalidate()
        self.sendOTP(OTP: self.otpString)
        
    }
    
    //MARK: Count down timer
    func countDown(){
        if (timerCount > 0) {
            timerCount -= 1
            lblTimer.text = "00:\(timerCount)"
        } else {
            self.alertController.dismiss(animated: true, completion: {
                DIMOAlertView.showAlert(withTitle: getString("titleEndOtp"), message: getString("messageEndOtp"), cancelButtonTitle: getString("AlertCloseButtonText"))
            })
            clock.invalidate()
//            lblTimer.isHidden = true
//            btnResandOTP.isHidden = false
        }
    }
    
    //MARK Action button to resand OTP
    func resendOTP()  {
        clock = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ConfirmationViewController.resendOTP), userInfo: nil, repeats: true)
        
    }

    
    //MARK: Show OTP Alert
    func showOTP()  {
        timerCount = 60
        alertController = UIAlertController(title: getString("ConfirmationOTPMessageTitle") + "\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let temp = UIView(frame: CGRect(x: 0, y: 40, width: 270, height: 100))
        let MDNString = ("\(getNormalisedMDN(dictForAcceptedOTP.value(forKey: SOURCEMDN) as! NSString))")
        let messageString = String(format: getString("ConfirmationOTPMessage"), MDNString)
        let messageAlert = UILabel(frame: CGRect(x: 10, y: 10, width: temp.frame.size.width - 20, height: 60))
        messageAlert.font = UIFont.systemFont(ofSize: 13)
        messageAlert.textAlignment = .center
        messageAlert.numberOfLines = 4
        messageAlert.text = messageString as String
        
        clock = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ActivationPinViewController.countDown), userInfo: nil, repeats: true)
        
        btnResandOTP = BaseButton(frame: CGRect(x: 0, y: messageAlert.bounds.origin.y + messageAlert.bounds.size.height, width: temp.frame.size.width, height: 35))
        btnResandOTP.setTitle(getString("ConfirmationOTPResendButton"), for: .normal)
        btnResandOTP.setTitleColor(UIColor.init(hexString: color_btn_alert), for: .normal)
        btnResandOTP.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btnResandOTP.titleLabel?.textAlignment = .center
        btnResandOTP.addTarget(self, action: #selector(self.resendTheOTP), for: .touchUpInside)
        btnResandOTP.isHidden = true
        
        lblTimer = BaseLabel(frame: CGRect(x: 0, y: messageAlert.bounds.origin.y + messageAlert.bounds.size.height + 10, width: temp.frame.size.width, height: 15))
        lblTimer.textAlignment = .center
        lblTimer.font = UIFont.systemFont(ofSize: 12)
        lblTimer.text = "01:00"
        
        
        temp.addSubview(btnResandOTP)
        temp.addSubview(lblTimer)
        temp.addSubview(messageAlert)
        
        alertController.view.addSubview(temp)
        let cancelAction = UIAlertAction(title:"Cancel",
                                         style: .default) { (action) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didOTPCancel"), object: nil)
        }

        let okAction = UIAlertAction(title:"Ok", style: .cancel) { (action) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didOTPOK"), object: nil)
        }
    
        
        alertController.addTextField { (textField) -> Void in
            textField.layer.borderColor = UIColor.init(hexString: color_border).cgColor
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = true
            textField.placeholder = getString("ConfirmationOTPTextFieldPlaceholder")
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(sender:)),
                                for: .editingChanged)
            textField.delegate = self
            textField.tag = 10
            
        }
        
        okAction.isEnabled = false
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(self.alertController, animated: true, completion:{})
            self.alertController.view.endEditing(true)
        }
        // showOTPWith(title: getString("ConfirmationOTPMessageTitle"), view: temp)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField.tag == 10 {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            self.otpString = newString as String!
            return newString.length <= maxLength
        } else {
            return true
        }
    }
    
    func alertTextFieldDidChange(sender : UITextField) {
        guard let alertController = self.presentedViewController as? UIAlertController,
            let otp = sender.text,
            let submitAction = alertController.actions.last else {
            return
        }
        submitAction.isEnabled = otp.characters.count == 4
    }
    
    //MARK: Request OTP
    func requestOTP() {
        DLog("\(dictForRequestOTP)")
        DMBProgressHUD.showAdded(to: self.view, animated: true)
        DIMOAPIManager .callAPI(withParameters: (dictForRequestOTP ) as! [AnyHashable : Any]!) { (dict, err) in
            DMBProgressHUD .hideAllHUDs(for: self.view, animated: true)
            let dictionary = NSDictionary(dictionary: dict!)
            
            
            if (err != nil) {
                let error = err! as NSError
                if (error.userInfo.count != 0 && error.userInfo["error"] != nil) {
                    DIMOAlertView.showAlert(withTitle: "", message: error.userInfo["error"] as! String, cancelButtonTitle: getString("AlertCloseButtonText"))
                } else {
                    DIMOAlertView.showAlert(withTitle: "", message: error.localizedDescription, cancelButtonTitle: getString("AlertCloseButtonText"))
                }
                return
            }
            
            if (dictionary.allKeys.count == 0) {
                DIMOAlertView.showAlert(withTitle: nil, message: String("ErrorMessageRequestFailed"), cancelButtonTitle: getString("AlertCloseButtonText"))
            } else {
                let responseDict = dictionary as NSDictionary
                DLog("\(responseDict)")
                
                
            }
        }
    }
    
    //MARK: Send OTP
    func sendOTP(OTP: String) {
        var message = ""
        if (!DIMOAPIManager.isInternetConnectionExist()){
            message = getString("LoginMessageNotConnectServer")
        }
        
        if (message.characters.count > 0) {
            DIMOAlertView.showAlert(withTitle: "", message: message, cancelButtonTitle: getString("AlertCloseButtonText"))
            return
        }
        
        DLog("\(OTP)")
        let dict = NSMutableDictionary()
        let temp = NSMutableDictionary(dictionary: dict);
        temp.addEntries(from: dictForAcceptedOTP as! [AnyHashable : Any])
        
        if ((temp.value(forKey: MFAOTP)) != nil) {
            temp[MFAOTP] = simasPayRSAencryption(OTP)
        } else {
            temp[ACTIVATION_OTP] = simasPayRSAencryption(OTP)
        }
        dictForAcceptedOTP = temp as NSDictionary
        DMBProgressHUD.showAdded(to: self.view, animated: true)
        
        var sessionCheck = false
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        for vc in viewControllers {
            if (vc.isKind(of: HomeViewController.self)) {
                sessionCheck = true
                
            }
        }
        
        
        DIMOAPIManager .callAPI(withParameters: dictForAcceptedOTP as! [AnyHashable : Any]!, withSessionCheck:sessionCheck) { (dict, err) in
            DMBProgressHUD .hideAllHUDs(for: self.view, animated: true)
            let dictionary = NSDictionary(dictionary: dict!)
            
            
            if (err != nil) {
                let error = err! as NSError
                if (error.userInfo.count != 0 && error.userInfo["error"] != nil) {
                    DIMOAlertView.showAlert(withTitle: "", message: error.userInfo["error"] as! String, cancelButtonTitle: getString("AlertCloseButtonText"))
                } else {
                    DIMOAlertView.showAlert(withTitle: "", message: error.localizedDescription, cancelButtonTitle: getString("AlertCloseButtonText"))
                }
                return
            }
            
            if (dictionary.allKeys.count == 0) {
                DIMOAlertView.showAlert(withTitle: nil, message: String("ErrorMessageRequestFailed"), cancelButtonTitle: getString("AlertCloseButtonText"))
            } else {
                let responseDict = dictionary as NSDictionary
                DLog("\(responseDict)")
                let messagecode  = responseDict.value(forKeyPath: "message.code") as! String
                let messageText  = responseDict.value(forKeyPath: "message.text") as! String
                
                if (messagecode == SIMASPAY_REGISTRATION__EMONEY_SUCCESS_CODE){
                    let vc = ActivationSuccessViewController.initWithMessageInfo(message: getString("RegistrationLabelInfoSuccessMessage"), title: getString("RegistrationLabelInfoSuccess"))
                    self.navigationController?.pushViewController(vc, animated: false)
                
                } else if (messagecode == SIMASPAY_CONFIRM_TRANSFER_TO__EMONEY_SUCCESS_CODE || messagecode == SIMASPAY_BANK_TRANSFER_TO__EMONEY_SUCCESS_CODE ||
                    messagecode == SIMASPAY_EMONEY_TO_BSIM ||
                    messagecode == SIMASPAY_EMONEY_TO_UNSUBCRIBER ||
                    messagecode == SIMASPAY_TRANSFER_UANGKU_CONFIRM_SUCCESSCODE ||
                    messagecode == SIMASPAY_CASH_WITH_DRAWAL_SUCCESSCODE ||
                    messagecode == SIMASPAY_PURCHASE_SUCCESCODE ||
                    messagecode == SIMASPAY_PAYMENT_SUCCESSCODE) {
                    let vc = SuccesConfirmationController.initWithOwnNib()
                    vc.data = self.data
                    vc.idTran =  responseDict.value(forKeyPath: "sctlID.text") as! String
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if (messagecode == "631") {
                    DIMOAlertView.showNormalTitle(nil, message: messageText, alert: UIAlertViewStyle.default, clickedButtonAtIndexCallback: { (index, alertview) in
                        if index == 0 {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "forceLogout"), object: nil)
                        }
                    }, cancelButtonTitle: "OK")
                } else {
                    DIMOAlertView.showNormalTitle("Error", message: messageText, alert: UIAlertViewStyle.default, clickedButtonAtIndexCallback: { (index, alert) in
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                        for vc in viewControllers {
                            if (vc.isKind(of: RegisterEMoneyViewController.self)) {
                                self.navigationController!.popToViewController(vc, animated: true);
                                return
                            } else if(vc.isKind(of: HomeViewController.self)) {
                                self.navigationController!.popToViewController(vc, animated: true);
                                return
                            }
                        }
                    }, cancelButtonTitle: "OK")
                    // self.navigationController!.popToRootViewController(animated: true)
                    // return
                }
                
                
            }
        }
        
    }
    
    
    
}
