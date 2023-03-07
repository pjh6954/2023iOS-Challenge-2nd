//
//  Extensions.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import UIKit

// Array 로 구현한 Queue
struct ArrayQueue<T> {
    // 빈 Array 선언
    private var queue: [T] = []
    
    public var publicQueue: [T] { self.queue }

    // Queue 내 원소 개수
    public var count: Int {
        return queue.count
    }

    // Queue 가 비었는지
    public var isEmpty: Bool {
        return queue.isEmpty
    }

    // 삽입 메소드
    public mutating func enqueue(_ element: T) {
        queue.append(element)
    }

    // 삭제 메소드
    public mutating func dequeue() -> T? {
        return isEmpty ? nil : queue.removeFirst()
    }

    // Queue 전체 삭제
    public mutating func clear() {
        queue.removeAll()
    }
}

extension UIImageView {
    /// URL에서 이미지 다운로드하여 이미지뷰에 적용
    func download(from url: URL, completion: @escaping(_ error: Error?, _ progress: Float) -> Void) {
        Constants.bgQueue.async {
            var observer: NSKeyValueObservation?
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                observer?.invalidate()
                observer = nil
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    DispatchQueue.main.async { [weak self] in
                        // 실패 시 기본이미지
                        self?.image = UIImage(systemName: "photo.artframe")
                        completion(error, 0.0)
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    completion(nil, 1.0)
                }
            }
            observer = task.progress.observe(\.fractionCompleted, options: [.new], changeHandler: { progress, change in
                DispatchQueue.main.async {
                    completion(nil, Float(progress.fractionCompleted))
                }
            })
            task.resume()
        }
    }
}

// 출처 : https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings/30593673#30593673%EF%BB%BF
extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
