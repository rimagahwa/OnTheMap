//
//  AnnotationsTableViewCell.swift
//  OnTheMap
//
//  Created by admin on 05/01/2019.
//  Copyright © 2019 Rima. All rights reserved.
//

import UIKit

class AnnotationsTableViewCell: UITableViewCell {

    @IBOutlet weak var pinImageView: UIImageView!
    
    @IBOutlet weak var pinStudentName: UILabel!
    
    @IBOutlet weak var pinMedia: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
