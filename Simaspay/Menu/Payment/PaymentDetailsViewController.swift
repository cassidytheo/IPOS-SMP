//
//  CashinViewController.swift
//  Simaspay
//
//  Created by Rajesh Pothuraju on 10/02/16.
//  Copyright © 2016 RAND Software Service (india) PVT LTD. All rights reserved.
//

import Foundation
import UIKit

class PaymentDetailsViewController: UIViewController
{
    var cashinScrollview: UIScrollView!
    var simasPayOptionType:SimasPayOptionType!
    
    var selectedBillerText:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Setor Tunai"
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 19)!,NSForegroundColorAttributeName:UIColor(netHex: Constants.NavigationTitleColor)]
        
        
        
        self.view.backgroundColor = UIColor(netHex: 0xF3F3F3)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        cashinScrollview = UIScrollView()
        cashinScrollview.translatesAutoresizingMaskIntoConstraints=false
        self.view.addSubview(cashinScrollview)
        
        
        
        var initialScrollViews = [String: UIView]()
        initialScrollViews["cashinScrollview"] = cashinScrollview
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cashinScrollview]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-64-[cashinScrollview]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
        
        
        
        
        let contentView = UIView()
        cashinScrollview.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        initialScrollViews["contentView"] = contentView
        
        cashinScrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(==cashinScrollview)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
        cashinScrollview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
        
        
        let topMargin = 20
        let labelFieldMArgin = 10
        let nextFieldMArgin = 20
        let textFieldHeight = 38
        let errorLabelWidth = 50
        let extraEndSpace = 30
        
        var vertical_constraints = "V:|-\(topMargin)-"
        
        var fieldNamesArray : [NSString] = []
        
        if (self.simasPayOptionType == SimasPayOptionType.SIMASPAY_PEMBAYARAN)
        {
            self.title = "Pembayaran"
            
            fieldNamesArray = ["Nama Produk","Nomor Handphone","mPIN"]
        }
        
        
        if (self.simasPayOptionType == SimasPayOptionType.SIMASPAY_PEMBELIAN)
        {
            self.title = "Pembelian"
            fieldNamesArray = ["Nama Produk","Nominal Pulsa","Nomor Handphone","mPIN"]
        }
        
        
        for i in 1...fieldNamesArray.count {
            
            let step1Label = UILabel()
            step1Label.text = "\(fieldNamesArray[i-1])"
            step1Label.font = UIFont(name:"HelveticaNeue-Medium", size:12.5)
            step1Label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(step1Label)
            
            let step1ErrorLabel = UILabel()
            step1ErrorLabel.text = "wajib diisi"
            step1ErrorLabel.textColor = UIColor(red: 204.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
            step1ErrorLabel.font = UIFont(name:"HelveticaNeue-Light", size:11)
            step1ErrorLabel.translatesAutoresizingMaskIntoConstraints = false
            step1ErrorLabel.hidden = true
            step1ErrorLabel.tag = 10+i
            contentView.addSubview(step1ErrorLabel)
            
            initialScrollViews["step1Label_\(i)"] = step1Label
            initialScrollViews["step1ErrorLabel_\(i)"] = step1ErrorLabel
            
            
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(topMargin)-[step1Label_\(i)]-0-[step1ErrorLabel_\(i)(\(errorLabelWidth))]-\(topMargin)-|", options: NSLayoutFormatOptions.AlignAllLastBaseline, metrics: nil, views: initialScrollViews))
            
            let step1TextField = UITextField(frame: CGRect.zero)
            step1TextField.backgroundColor = UIColor.whiteColor()
            step1TextField.enabled = true
            step1TextField.font =  UIFont(name:"HelveticaNeue-Light", size:12)
            step1TextField.translatesAutoresizingMaskIntoConstraints = false
            step1TextField.borderStyle = .None
            step1TextField.layer.cornerRadius = 5
            step1TextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
            contentView.addSubview(step1TextField)
            step1TextField.tag = 20+i
            
            let mobileNumberView = UIView(frame: CGRectMake(0, 0, 10, step1TextField.frame.height))
            step1TextField.leftView = mobileNumberView;
            step1TextField.leftViewMode = UITextFieldViewMode.Always
            initialScrollViews["step1TextField_\(i)"] = step1TextField
            
            if( i == 1)
            {
                step1TextField.text = self.selectedBillerText
                step1TextField.backgroundColor =  UIColor(netHex: Constants.TextFieldDisableBackcolor)
            }
            
            
            if (self.simasPayOptionType == SimasPayOptionType.SIMASPAY_PEMBAYARAN)
            {
                
                if( i == 2 || i == 3){
                    step1TextField.keyboardType = .NumberPad
                }
                
            }
            
            
            if (self.simasPayOptionType == SimasPayOptionType.SIMASPAY_PEMBELIAN)
            {
                if( i == 3 || i == 4){
                    step1TextField.keyboardType = .NumberPad
                }
                
                if( i == 2)
                {
                    step1TextField.placeholder = "Pilih"
                    let dropDownImage = UIImage(named: "btn-dropdown")
                    let dropDownButton = UIButton()
                    dropDownButton.frame = CGRect(x:0, y: (step1TextField.frame.height-10)/2, width: 16, height: 10)
                    dropDownButton.addTarget(self, action: "nominalAmountClicked:", forControlEvents: UIControlEvents.TouchUpInside)
                    dropDownButton.setBackgroundImage(dropDownImage, forState: UIControlState.Normal)
                    
                    let dropDownView = UIView(frame: CGRectMake(0, 0, 15+18, step1TextField.frame.height))
                    dropDownView.addSubview(dropDownButton)
                    step1TextField.rightView = dropDownView
                    step1TextField.rightViewMode = UITextFieldViewMode.Always
                    step1TextField.enabled = false
                }
                
            }
            
            
            
    
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(topMargin)-[step1TextField_\(i)]-\(topMargin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
            
            vertical_constraints  += "[step1Label_\(i)]-\(labelFieldMArgin)-[step1TextField_\(i)(\(textFieldHeight))]-\(nextFieldMArgin)-"
            
        }
        
        
        let step1FormAcceptBtn:UIButton = UIButton()
        step1FormAcceptBtn.backgroundColor = UIColor(netHex:0xCC0000)
        step1FormAcceptBtn.setTitle("Lanjut", forState: UIControlState.Normal)
        step1FormAcceptBtn.translatesAutoresizingMaskIntoConstraints = false
        step1FormAcceptBtn.titleLabel?.font = UIFont(name:"HelveticaNeue-Medium", size:20)
        step1FormAcceptBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        contentView.addSubview(step1FormAcceptBtn)
        step1FormAcceptBtn.addTarget(self, action: "cashInAcceptClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        initialScrollViews["step1FormAcceptBtn"] = step1FormAcceptBtn
        step1FormAcceptBtn.layer.cornerRadius = 5
        
        
        let buttonMargin = (self.view.frame.size.width-200)/2
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(\(buttonMargin))-[step1FormAcceptBtn]-(\(buttonMargin))-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
        
        vertical_constraints += "[step1FormAcceptBtn(50)]-\(extraEndSpace)-|"
        
        
        
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(vertical_constraints, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: initialScrollViews))
        
        
    }
    
    
    
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 219.0/255.0, green: 219.0/255.0, blue: 219.0/255.0, alpha: 0.5)
        UINavigationBar.appearance().tintColor = UIColor(red: 219.0/255.0, green: 219.0/255.0, blue: 219.0/255.0, alpha: 0.5)
        
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
        self.navigationController?.navigationBarHidden = false
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.frame = CGRectMake(0, 0, 15, 25)
        backButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setImage(UIImage(named: "btn-back"), forState: UIControlState.Normal)
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    
    func popToRoot(sender:UIBarButtonItem){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    @IBAction func cashInAcceptClicked(sender: UIButton)
    {
        var confirmationTitlesArray =  [NSString]()
        var confirmationValuesArray =  [NSString]()
        if (self.simasPayOptionType == SimasPayOptionType.SIMASPAY_PEMBAYARAN)
        {
            confirmationTitlesArray = ["Nama Produk","Nomor Handphone","Jumlah"]
            confirmationValuesArray = ["Isi Ulang Pulsa - Smartfren","08881234567","Rp 154.200"]
        }
        
        
        if (self.simasPayOptionType == SimasPayOptionType.SIMASPAY_PEMBELIAN)
        {
            confirmationTitlesArray = ["Nama Produk","Nominal Pulsa","Nomor Handphone"]
            confirmationValuesArray = ["Isi Ulang Pulsa - Smartfren","Rp 50.000","08881234567"]
        }

        
        let confirmationViewController = ConfirmationViewController()
        confirmationViewController.simasPayOptionType = self.simasPayOptionType
        confirmationViewController.confirmationTitlesArray = confirmationTitlesArray
        confirmationViewController.confirmationValuesArray = confirmationValuesArray
        self.navigationController!.pushViewController(confirmationViewController, animated: true)
    }
    
     @IBAction func nominalAmountClicked(sender: UIButton)
     {
        
     }
    
    
}