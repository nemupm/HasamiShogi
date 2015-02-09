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
        // 盤の生成
        banImageView = UIImageView(frame: CGRect(
            x: 0, y: self.view.frame.maxY/2 - self.view.frame.maxX/2,
            width: self.view.frame.maxX, height: self.view.frame.maxX))
        banImageView.image = UIImage(named: "ban.png")
        self.view.addSubview(banImageView)
        kyokumen = Kyokumen(vc: self)
        
        // それぞれの升に対して以下の操作を行う
        for (i,array) in enumerate(kyokumen.board){
            for (j,value) in enumerate(array){
                if value == 1{
                    // 自分側の駒の生成
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
                    // 相手側の駒の生成
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
    
    // 駒の画像や情報を管理するクラス
    class Koma{
        var komaImageView: UIImageView!
        var x : Int!
        var y : Int!
        var human : Bool!
        var touched : Bool = false
        
        init(){
        }
    }
    
    // 現在の局面の情報などを管理するクラス
    class Kyokumen {
        // -1: outside, 0: nothing, 1: mine, 2: yours
        // 本来の升範囲の外側に余分に-1をつけている（処理がしやすい）
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
        // TODO: この辺りの変数は大分無駄が多いので整理するべき
        var position = CGPoint() // 一番左上の升の座標
        var masuLength = CGFloat() // 1升の幅
        var komaArray : [Koma] = [] // 駒オブジェクトを格納する配列
        var masuBoard : [[UIImageView]] = []  // 升の画像オブジェクトを格納する二次元配列
        var masuList : [[Int]] = []
        var userAction : String = "" // 現在のユーザアクションを記憶する変数
        var selected : Int = -1 // 現在選択されている駒のタグを記憶する変数
        var selectedKoma : [Int] = [] // 現在選択されている駒の位置を記憶する配列
        var selectedMasu : [[Int]] = [] // 移動可能範囲の升（複数）の位置を記憶する配列
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
        
        // x軸で見て何番目の升かを指定するとx座標を返す
        func getPositionX(j: Int) -> CGFloat{
            return position.x + masuLength * (CGFloat)(j - 1)
        }
        // y軸で見て何番目の升かを指定するとy座標を返す
        func getPositionY(i: Int) -> CGFloat{
            return position.y + masuLength * (CGFloat)(i - 1)
        }
    }
    
    // タップした時に呼び出されるメソッド
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        if touch.view.tag == -1 || touch.view.tag == -2{
            // 選択アクション時に盤をタップした時
            if kyokumen.userAction == "select"{
                // 選択をキャンセルする
                kyokumen.userAction = ""
                var koma = kyokumen.komaArray[kyokumen.selected] // 選択されている駒
                //// 選択中の駒の画像を元に戻す
                koma.komaImageView.image =
                    UIImage(named: koma.human == true ? "koma_ho.png" : "koma_to_r.png" )
                koma.touched = false
                for xy in kyokumen.selectedMasu{
                    // 移動可能範囲のマスの画像を元に戻す
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
        // touch.view.tagを利用して、タップしたKomaオブジェクトを求めている
        var koma = kyokumen.komaArray[touch.view.tag] // タップされた駒
        koma.touched = !koma.touched
        if koma.touched == true{
            // 何もない時に駒をタップした時
            if kyokumen.userAction == ""{
                // 駒の画像を変更する
                koma.komaImageView.image =
                    UIImage(named: koma.human == true ? "koma_ho_hover.png" : "koma_to_hover_r.png" )
                kyokumen.userAction = "select"
                kyokumen.selected = touch.view.tag
            }
            // 選択した駒の位置を記憶する
            kyokumen.selectedKoma = [koma.y,koma.x]
            // 選択した駒が乗っている升の画像を変更する
            var masu = kyokumen.masuBoard[koma.y][koma.x]
            masu.image = UIImage(named: "masu_hover.png")
            masu.tag = -2
            kyokumen.selectedMasu.append([koma.x,koma.y])
            for (dx,dy) in [(1,0),(-1,0),(0,1),(0,-1)]{
                // 選択した駒が移動できる範囲の升の画像を全て変更する
                draw(koma.x+dx, y: koma.y+dy, dx: dx, dy: dy)
            }
        }
    }
    // 再帰的に升を塗っていく関数
    // (dx, dy)方向に探索していく
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