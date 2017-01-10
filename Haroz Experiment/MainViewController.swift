//
//  MainViewController.swift
//  Haroz Experiment
//
//  Created by 寿 斌 on 19/10/2016.
//  Copyright © 2016 Engyokun. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let sectionNumber = 1
    let cellNumberInRow = 8
    let cellNumber = 64
    let colors: [UIColor] = [UIColor.blue, UIColor.cyan, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.red, UIColor.purple, UIColor.gray]
    var chosenColors: [UIColor] = [UIColor.green]
    var colorMap: [Int] = []
    var specialColor: UIColor = UIColor.black
    var specialIndex: Int = -1
    var loopMode = false
    var loopTestCount: Int = 0
    var useTimeDatas: [Double] = []
    var showSpecial: Int = 1
    let tempCount: Int = 20
    var correctCount: Int = 0
    
    @IBOutlet weak var colorPad: UICollectionView!
    @IBOutlet weak var colorCounter: UISlider!

    @IBOutlet weak var groupedSwitch: UISwitch!
    @IBOutlet weak var OddballSwitch: UISwitch!
    
    @IBOutlet weak var timeUsed: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    var startDate: Date = Date.init()
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    let face: String = "😱"
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorMap = Array.init(repeating: 0, count: cellNumber)
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorPad.layer.shadowColor = UIColor.black.cgColor
        colorPad.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        colorPad.layer.shadowRadius = 1
        colorPad.layer.shadowOpacity = 1.0
    }
    
    //MARK: - Collection View Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = colorPad.frame.width / CGFloat(cellNumberInRow) - 1
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        if indexPath.row == specialIndex && showSpecial == 1{
            cell.backgroundColor = specialColor
        } else {
            if groupedSwitch.isOn {
                cell.backgroundColor = chosenColors[colorMap[indexPath.row]]
            }else {
                let index = Int(arc4random_uniform(UInt32(chosenColors.count)))
                cell.backgroundColor = chosenColors[index]
            }
        }
        cell.titleLabel.text = ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: CollectionViewCell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        if cell.titleLabel.text == face {
            cell.titleLabel.text = String(indexPath.row)
        } else {
            cell.titleLabel.text = face
        }
    }
    
    //MARK: - Custom Functions
    
    
    func initColorPicker() {
        var temp = Array.init(colors)
        var tempColors: [UIColor] = []
        var flag = false
        for _ in 1...Int(colorCounter.value + 1) {
            let index = Int(arc4random_uniform(UInt32(temp.count)))
            if !flag {
                specialColor = temp[index]
                temp.remove(at: Int(index))
                specialIndex = Int(arc4random_uniform(UInt32(cellNumber)))
                flag = !flag
                continue
            }
            tempColors.append(temp[index])
            temp.remove(at: Int(index))
        }
        chosenColors = tempColors
    }
    func showTimeUsed() -> Double {
        return Date.init().timeIntervalSince(startDate)
    }
    
    func reportData() -> Void {
        var allTime: Double = 0
        for thisTime in 0..<useTimeDatas.count {
            allTime += useTimeDatas[thisTime]
        }
        let avgTime = allTime / Double(useTimeDatas.count)
        let alert: UIAlertController = UIAlertController.init(title: "Data",
                                                              message: String("Test Times: " + String(loopTestCount) + "\nAvg Time: " + String.init(format: "%.f", avgTime * 1000) + "ms\nCorrect: " + String(correctCount) + " times"),
                                                              preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - IBAction
    
    @IBAction func endPick(_ sender: AnyObject) {
        colorCounter.value = Float(round(colorCounter.value))
    }
    
    @IBAction func findBlock(_ sender: UIButton) {
        if showSpecial == 1 {
            correctCount += 1
        }
        doneFindBlock()
    }
    
    @IBAction func notFindBlock(_ sender: UIButton) {
        if showSpecial == 0 {
            correctCount += 1
        }
        doneFindBlock()
    }
    
    func doneFindBlock() -> Void {
        let useTime = showTimeUsed()
        timeUsed.text = String.init(format: "%.fms", useTime * 1000)
        yesButton.isEnabled = false
        noButton.isEnabled = false
        if loopMode {
            loopTestCount += 1
            loopTest(startButton)
            useTimeDatas.append(useTime)
        }
    }
    
    @IBAction func stopLoop() {
        loopMode = false
        yesButton.isEnabled = false
        noButton.isEnabled = false
        reportData()
    }
    
    @IBAction func startTest(_ sender: UIBarButtonItem) {
        if groupedSwitch.isOn {
            let groupMap = GroupMap.init(cellNumberInRow, inType: Int(colorCounter.value))
            colorMap = groupMap.creatMap()
        }
        showSpecial = Int(arc4random_uniform(UInt32(2)))
        initColorPicker()
        
        
        performSegue(withIdentifier: "startTest", sender: sender)
        
        colorPad.reloadData()
        startDate = Date.init(timeIntervalSinceNow: 1)
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    @IBAction func loopTest(_ sender: UIBarButtonItem) {
        if !loopMode {
            loopMode = true
            loopTestCount = 0
            correctCount = 0
            useTimeDatas = []
        }
        if  loopTestCount < tempCount {
            timeLeft.text = String(String(tempCount - loopTestCount) + " times left")
            startTest(startButton)
        } else {
            stopLoop()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startTest" {
            let ViewController = segue.destination as! ReadyView
            if !OddballSwitch.isOn {
                ViewController.chosenColor = specialColor
            }
        }
    }
}
