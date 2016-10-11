//
//  ContactUSViewController.swift
//  Simaspay
//
//  Created by Kendy Susantho on 9/23/16.
//  Copyright © 2016 Kendy Susantho. All rights reserved.
//

import UIKit

class ContactUSViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    var contactUsInfo = NSDictionary()
    var heightForCell = 45 as CGFloat
    let padding : CGFloat = 20
    
    static func initWithOwnNib() -> ContactUSViewController {
        let obj:ContactUSViewController = ContactUSViewController.init(nibName: String(describing: self), bundle: nil)
        return obj
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.showTitle(getString("ContactUsTitle"))
        self.showBackButton()
        
        tableView.backgroundColor = UIColor.white
        tableView.layer.cornerRadius = 5
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.init(hexString: color_border).cgColor
        tableView.clipsToBounds = true;
        scrollView.backgroundColor = UIColor.init(hexString: color_background)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int{
        return 3
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
       return heightForCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForCell
    }
 
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = UITableViewCell(style: .default, reuseIdentifier: "contactus")
        temp.selectionStyle = .gray
        
        let lblcontent = UILabel(frame: CGRect(x: padding, y: 0, width: tableView.frame.size.width - padding * 2, height: heightForCell))
        lblcontent.font = UIFont.boldSystemFont(ofSize: 16)
        DLog("\(contactUsInfo)")
        let contactInfoSting = contactUsInfo.value(forKey: "contactus") as! NSDictionary
        if indexPath.section == 0 {
            let size = 22 as CGFloat
            let imgPhone = UIImageView(frame: CGRect(x: lblcontent.frame.size.width , y: (heightForCell - size) / 2 , width: size, height: size))
            if indexPath.row == 0 {
                lblcontent.text = contactInfoSting.value(forKey: "mobilenumber_1") as! String?
            } else {
                lblcontent.text = contactInfoSting.value(forKey: "mobilenumber_2") as! String?
            }
            imgPhone.image = UIImage.init(named: "icon_Phone")
            temp.addSubview(imgPhone)
        } else if indexPath.section == 1 {
                lblcontent.text = contactInfoSting.value(forKey: "emailid") as! String?
        } else {
                lblcontent.text = contactInfoSting.value(forKey: "website") as! String?
        }
        temp.addUnderline(color: UIColor.init(hexString: color_border), coordinateX: padding)
        
        temp.contentView.insertSubview(lblcontent, at: 0)
        
        return temp
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerLabel = UILabel(frame: CGRect(x: padding, y: 0, width: tableView.frame.size.width, height: heightForCell))
       headerLabel.font = UIFont.boldSystemFont(ofSize: 13)
        if section == 0 {
            headerLabel.text = "Bank Sinarmas Care"
        } else if section == 1{
            headerLabel.text = "E-mail"
        } else {
            headerLabel.text = "Website"
        }
        
        let headerView = UIView()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
}
