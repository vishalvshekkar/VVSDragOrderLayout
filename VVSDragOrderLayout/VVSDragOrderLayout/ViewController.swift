//
//  ViewController.swift
//  VVSDragOrderLayout
//
//  Created by Vishal V Shekkar on 24/01/16.
//  Copyright © 2016 Vishal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var dragReorderCollectionView: UICollectionView!
    let dragReorderLayout = VVSDraggableLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragReorderCollectionView.setCollectionViewLayout(dragReorderLayout, animated: false)
        dragReorderLayout.setupPlaceHoldersInView(holderView)
    }



}

