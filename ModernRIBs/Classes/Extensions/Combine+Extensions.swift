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

import Combine

/// A `CompositeCancellable` represents a group of cancellable resources that are cancelled together.
final class CompositeCancellable: Cancellable {
    // MARK: - Internal

    /// The number of elements in a composite cancellable set
    var count: Int {
        cancellables.count
    }

    /// Insert a cancellable to cancellables
    ///
    /// - parameter cancellable: to add to a composite cancellable set
    func insert(_ cancellable: AnyCancellable) {
        guard !isCancelled else {
            cancellable.cancel()
            return
        }
        cancellables.insert(cancellable)
    }

    /// Cancel all cancellables in a composite cancellable set
    func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Private

    private var isCancelled: Bool = false
    private var cancellables: Set<AnyCancellable> = .init()
}
