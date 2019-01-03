//
//  MyAnnotation.swift
//  tryMapKit
//
//  Created by Bigyo on 20/11/2016.
//  Copyright © 2016 Bigyo. All rights reserved.
//

import Foundation
import MapKit

public class MyAnnotation : MKAnnotationView  {
    var rectangoView:UIView!; //長方形
    var lblTitle:UILabel!;//Title
    var lblIcon:UILabel!;//圓形icon
    var circleView:UIView!; //原型view
    var triangle:UIView!; //三角形
    var DrawView:UIView!;//整個客製座標的畫布
    
//    public override init(frame: CGRect) {
//        super.init(frame: frame);
//    }
    
    public override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier);
        
        print("init")
        
        //先把每個圖層間的關係建立好,例如圓形跟title都在大大的長方形裡面,所以先add進去
        lblTitle = UILabel();
        lblIcon = UILabel();
        rectangoView = UIView();
        circleView = UIView();
        
        circleView.addSubview(lblIcon);
        rectangoView.addSubview(lblTitle)
        rectangoView.addSubview(circleView);
        
        //畫出三角形遮罩
        //原理：將遮罩蓋到長方形上面,他會將不再這個框框範圍內的都過濾掉,就可以跑出三角形了
        let path:UIBezierPath = UIBezierPath ();
        path.move(to: CGPoint(x: 0, y: 0));
        path.addLine(to: CGPoint(x: 10, y: 10));
        path.addLine(to: CGPoint(x: 20, y: 0));
        path.addLine(to: CGPoint(x: 0, y: 0));
        
        let masklayer:CAShapeLayer = CAShapeLayer ();//遮罩
        masklayer.path = path.cgPath;
        //遮罩遮出三角型
        triangle = UIView(frame: CGRect(x: 22, y: 28, width: 20, height: 20));
        triangle.layer.mask = masklayer;
        
        DrawView = UIView();
        DrawView.addSubview(rectangoView);
        DrawView.addSubview(triangle);
        
        self.addSubview(DrawView);
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
    }
    
    public func DrawCustomerView() {
        print("DrawCustomerView")
        //Title
        lblTitle.text = "5200萬";
        lblTitle.textColor = UIColor.white;
        lblTitle.font = UIFont.systemFont(ofSize: 12);
        lblTitle.sizeToFit();
        
        //大大的長方形
        rectangoView.frame = CGRect(x: 0, y: 0, width: lblTitle.frame.width + 30, height: 28);//整體
        rectangoView.backgroundColor =  UIColor(red: 0.208, green:0.596 , blue: 0.859, alpha: 1);
        rectangoView.layer.cornerRadius = 3;//設定圓角
        
        //“icon”圓型小字
        lblIcon.font = UIFont.systemFont(ofSize: 11);
        lblIcon.font = UIFont.boldSystemFont(ofSize: 14);
        lblIcon.text = "成";
        lblIcon.textColor = rectangoView.backgroundColor;
        lblIcon.sizeToFit();
        lblIcon.center = CGPoint (x: 10, y: 10);
        
        //圓形
        circleView.frame = CGRect(x: 2, y: 4, width: 20, height: 20);//圓形標籤
        circleView.backgroundColor = UIColor.white;
        circleView.layer.cornerRadius = 10;
        circleView.alpha = 1;
        
        //畫三角形
        triangle.backgroundColor =  UIColor(red: 0.208, green:0.596 , blue: 0.859, alpha: 1);
        //rectangoView.Transform 旋轉
        
        DrawView.frame = CGRect(x: 0, y: 0, width:triangle.frame.width,height: 48);
    }
}
