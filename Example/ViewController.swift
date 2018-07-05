//
//  ViewController.swift
//  Example
//
//  Created by Illusion on 2018/7/5.
//  Copyright © 2018年 Illusion. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        let urls = ["https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2437461586,2088419162&fm=27&gp=0.jpg", "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1730683201,2031013173&fm=27&gp=0.jpg", "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2219945528,2506368580&fm=27&gp=0.jpg", "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2813160690,3273584349&fm=27&gp=0.jpg"]
        let scrollView = EMCycleScrollView(frame: frame, imageUrls: urls) { (index) in
            print("第\(index)张图片点击回调")
        }
        view.addSubview(scrollView)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

