//
//  EntriesCell.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class EntriesCell: UITableViewCell {

    @IBOutlet var entryName: UILabel!
    @IBOutlet var entryComment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
