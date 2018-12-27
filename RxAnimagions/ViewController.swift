//
//  ViewController.swift
//  RxAnimagions
//
//  Created by ashlesberg on 10/12/2018.
//  Copyright © 2018 ashlesberg. All rights reserved.
//

import UIKit
import RxSwift
class ViewController: UIViewController {
    
    var animataableView: UIView = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50) )
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animataableView.backgroundColor = .red
        self.view.addSubview(animataableView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animataableView
            .performAnimation(RotationAnimation(angle: .pi/2))
            .performAnimation(MoveAnimation(newCoordinates: CGPoint(x: 100, y: 100)))
            .performAnimation(RotationAnimation(angle: .pi / 2.0))
            .subscribe()
            .disposed(by: disposeBag)
        

        class Foo {
            var bar: Observable<String>
            
            init(symbol: String) {
                bar  = Observable.from(["1","2","3"]).map { symbol +  $0 }
            }
        }
        
        Observable.from(["a","b","c"])
        .map { Foo(symbol: $0) }
        .flatMap { $0.bar }
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)

        Observable.from(["a","b","c"])
        .map { Foo(symbol: $0) }
        .concatMap { $0.bar }
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    }
    
    
}

extension Observable where E == UIView {
    func performAnimation(_ animation: Animation) -> Observable<UIView> {
        return self.flatMap { $0.performAnimation(animation)}
    }
}
//TODO: make generic
protocol Animation {
    //FIXME: unfortunatly we dont have option to use immutability. I think so...
    func transformView(_ view: UIView)
}

class RotationAnimation: Animation {
    
    private let angle: CGFloat
    
    init(angle: CGFloat) {
        self.angle = angle
    }
    
    func transformView(_ view: UIView) {
        view.transform =  view.transform.rotated(by: angle)
    }
}

class MoveAnimation: Animation {
    private let newCoordinates: CGPoint
    
    init(newCoordinates: CGPoint) {
        self.newCoordinates = newCoordinates
    }
    
    func transformView(_ view: UIView) {
        view.frame = { var frame = view.frame; frame.origin = self.newCoordinates; return frame}()
    }
}

extension UIView {
    func performAnimation(_ animation: Animation) -> Observable<UIView> {
        return Observable.create { [self] (observer) -> Disposable in
            
            UIView.animate(withDuration: 1, animations: { [self] in
                animation.transformView(self)
            }) { [self] completed in
                observer.onNext(self)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
