//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Dispatch
import Foundation
import Combine

public class Executor {
    static var subscriptions: Set<AnyCancellable> = .init()

    /// Execute the given logic after the given delay assuming the given maximum frame duration.
    ///
    /// This allows excluding the time elapsed due to breakpoint pauses.
    ///
    /// - note: The logic closure is not guaranteed to be performed exactly after the given delay. It may be performed
    ///   later if the actual frame duration exceeds the given maximum frame duration.
    ///
    /// - parameter delay: The delay to perform the logic, excluding any potential elapsed time due to breakpoint
    ///   pauses.
    /// - parameter maxFrameDuration: The maximum duration a single frame should take. Defaults to 33ms.
    /// - parameter logic: The closure logic to perform.
    public static func execute(withDelay delay: TimeInterval, maxFrameDuration: Int = 33, logic: @escaping () -> ()) {
        let period = TimeInterval(maxFrameDuration / 3) / 1_000 // milliseconds
        var lastRunLoopTime = Date().timeIntervalSinceReferenceDate
        var properFrameTime = 0.0
        var didExecute = false
        var cancellable: AnyCancellable?

        cancellable = Timer.publish(every: period, on: .main, in: .common)
            .autoconnect()
            .prefix(while: { _ in
                !didExecute
            })
            .sink(receiveCompletion: { [weak cancellable] _ in
                if let cancellable = cancellable {
                    subscriptions.remove(cancellable)
                }
            }, receiveValue: { _ in
                let currentTime = Date().timeIntervalSinceReferenceDate
                let trueElapsedTime = currentTime - lastRunLoopTime
                lastRunLoopTime = currentTime

                // If we did drop frame, we under-count the frame duration, which is fine. It
                // just means the logic is performed slightly later.
                let boundedElapsedTime = min(trueElapsedTime, Double(maxFrameDuration) / 1000)
                properFrameTime += boundedElapsedTime
                if properFrameTime > delay {
                    didExecute = true

                    logic()
                }
            })

        cancellable?.store(in: &subscriptions)
    }
}
