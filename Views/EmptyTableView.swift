//
//  emptyTableView.swift
//  Timers
//
//  Created by Danil Kurilo on 10.02.2020.
//  Copyright © 2020 Danil Kurilo. All rights reserved.
//

import UIKit

class EmptyTableView: UIView {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "emptyTableView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
