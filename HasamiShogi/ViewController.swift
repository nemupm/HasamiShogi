//
//  ViewController.swift
//  HasamiShogi
//
//  Created by kiko on 2015/02/07.
//  Copyright (c) 2015年 nemupm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var banImageView: UIImageView!
    var kyokumen : Kyokumen!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        banImageView = UIImageView(frame: CGRect(
            x: 0, y: self.view.frame.maxY/2 - self.view.frame.maxX/2,
            width: self.view.frame.maxX, height: self.view.frame.maxX))
        banImageView.image = UIImage(named: "ban.png")
        self.view.addSubview(banImageView)
        kyokumen = Kyokumen(vc: self)
        for (i,array) in enumerate(kyokumen.board){
            for (j,value) in enumerate(array){
                if value == 1{
                    var koma = Koma()
                    koma.komaImageView = UIImageView(frame: CGRect(
                        x: kyokumen.getPositionX(j), y: kyokumen.getPositionY(i),
                        width: kyokumen.masuLength, height: kyokumen.masuLength))
                    kyokumen.komaArray.append(koma)
                    koma.komaImageView.image = UIImage(named: "koma_ho.png")
                    koma.komaImageView.userInteractionEnabled = true
                    koma.komaImageView.tag = kyokumen.komaArray.count - 1
                    koma.x = j
                    koma.y = i
                    koma.human = true
                    self.view.addSubview(koma.komaImageView)
                }else if value == 2{
                    var koma = Koma()
                    kyokumen.komaArray.append(koma)
                    koma.komaImageView = UIImageView(frame: CGRect(
                        x: kyokumen.getPositionX(j), y: kyokumen.getPositionY(i),
                        width: kyokumen.masuLength, height: kyokumen.masuLength))
                    kyokumen.komaArray.append(koma)
                    koma.komaImageView.image = UIImage(named: "koma_to_r.png")
                    koma.komaImageView.userInteractionEnabled = true
                    koma.komaImageView.tag = kyokumen.komaArray.count - 1
                    koma.x = j
                    koma.y = i
                    koma.human = false
                    self.view.addSubview(koma.komaImageView)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class Koma{
        var komaImageView: UIImageView!
        var x : Int!
        var y : Int!
        var human : Bool!
        var touched : Bool = false
        
        init(){
        }
    }
    
    class Kyokumen {
        // -1: outside, 0: nothing, 1: mine, 2: yours
        var board : [[Int]] = [
            [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
            [-1,2,2,2,2,2,2,2,2,2,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,0,0,0,0,0,0,0,0,0,-1],
            [-1,1,1,1,1,1,1,1,1,1,-1],
            [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]
        ]
        var position = CGPoint()
        var masuLength = CGFloat()
        var komaArray : [Koma] = []
        var masuBoard : [[UIImageView]] = []
        var masuList : [[Int]] = []
        var userAction : String = ""
        var selected : Int = -1
        var selectedKoma : [Int] = []
        var selectedMasu : [[Int]] = []
        var hoNum = 9
        var toNum = 9
        
        init(vc :ViewController){
            position = vc.banImageView.frame.origin
            masuLength = vc.banImageView.frame.width
                * ((640 - 2 * 40) / 640) / 9
            position.x += vc.banImageView.frame.width * (40 / 640)
            position.y += vc.banImageView!.frame.width * (40 / 640)
            for i in 0...11{
                var tmpMasuBoard = [UIImageView]()
                for j in 0...11{
                    var masu : UIImageView = UIImageView(frame: CGRect(
                        x: getPositionX(j), y: getPositionY(i),
                        width: masuLength, height: masuLength))
                    tmpMasuBoard.append(masu)
                    masu.userInteractionEnabled = true
                    masu.tag = -1
                    vc.view.addSubview(masu)
                }
                masuBoard.append(tmpMasuBoard)
            }
        }
        
        func getPositionX(i: Int) -> CGFloat{
            return position.x + masuLength * (CGFloat)(i - 1)
        }
        func getPositionY(j: Int) -> CGFloat{
            return position.y + masuLength * (CGFloat)(j - 1)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        if touch.view.tag == -1 || touch.view.tag == -2{
            // 選択アクション時に盤をタップした時
            if kyokumen.userAction == "select"{
                kyokumen.userAction = ""
                var koma = kyokumen.komaArray[kyokumen.selected]
                koma.komaImageView.image =
                    UIImage(named: koma.human == true ? "koma_ho.png" : "koma_to_r.png" )
                koma.touched = false
                for xy in kyokumen.selectedMasu{
                    var masu = kyokumen.masuBoard[xy[1]][xy[0]]
                    masu.image = UIImage()
                    masu.tag = -1
                }
                if touch.view.tag == -2{
                    koma.komaImageView.frame.origin = CGPoint()
                }
            }
            return
        }
        var koma = kyokumen.komaArray[touch.view.tag]
        koma.touched = !koma.touched
        //touch.view.frame.origin = CGPoint(x: 100, y: 100)
        if koma.touched == true{
            // 何もない時に駒をタップした時
            if kyokumen.userAction == ""{
                koma.komaImageView.image =
                    UIImage(named: koma.human == true ? "koma_ho_hover.png" : "koma_to_hover_r.png" )
                kyokumen.userAction = "select"
                kyokumen.selected = touch.view.tag
            }
            kyokumen.selectedKoma = [koma.y,koma.x]
            var masu = kyokumen.masuBoard[koma.y][koma.x]
            masu.image = UIImage(named: "masu_hover.png")
            masu.tag = -2
            kyokumen.selectedMasu.append([koma.x,koma.y])
            for (dx,dy) in [(1,0),(-1,0),(0,1),(0,-1)]{
                draw(koma.x+dx, y: koma.y+dy, dx: dx, dy: dy)
            }
        }
    }
    func draw(x: Int,y: Int,dx: Int,dy: Int){
        if kyokumen.board[y][x] != 0{
            return
        }
        var curMasu = kyokumen.masuBoard[y][x]
        curMasu.image = UIImage(named: "masu_hover.png")
        kyokumen.selectedMasu.append([x,y])
        draw(x+dx, y:y+dy, dx:dx, dy:dy)
    }
}