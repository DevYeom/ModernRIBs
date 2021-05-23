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

/// Defines the base class for a sequence of steps that execute a flow through the application RIB tree.
///
/// At each step of a `Workflow` is a pair of value and actionable item. The value can be used to make logic decisions.
/// The actionable item is invoked to perform logic for the step. Typically the actionable item is the `Interactor` of a
/// RIB.
///
/// A workflow should always start at the root of the tree.
open class Workflow<ActionableItemType> {

    /// Called when the last step publisher is completed.
    ///
    /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
    /// The default implementation does nothing.
    open func didComplete() {
        // No-op
    }

    /// Called when the `Workflow` is forked.
    ///
    /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
    /// The default implementation does nothing.
    open func didFork() {
        // No-op
    }

    /// Called when the last step publisher is has error.
    ///
    /// Subclasses should override this method if they want to execute logic at this point in the `Workflow` lifecycle.
    /// The default implementation does nothing.
    open func didReceiveError(_ error: Error) {
        // No-op
    }

    /// Initializer.
    public init() {}

    /// Execute the given closure as the root step.
    ///
    /// - parameter onStep: The closure to execute for the root step.
    /// - returns: The next step.
    public final func onStep<NextActionableItemType, NextValueType>(_ onStep: @escaping (ActionableItemType) -> AnyPublisher<(NextActionableItemType, NextValueType), Error>) -> Step<ActionableItemType, NextActionableItemType, NextValueType> {
        return Step(workflow: self, publisher: subject.prefix(1).eraseToAnyPublisher())
            .onStep { (actionableItem: ActionableItemType, _) in
                onStep(actionableItem)
            }
    }

    /// Subscribe and start the `Workflow` sequence.
    ///
    /// - parameter actionableItem: The initial actionable item for the first step.
    /// - returns: The cancellable of this workflow.
    public final func subscribe(_ actionableItem: ActionableItemType) -> Cancellable {
        guard compositeCancellable.count > 0 else {
            assertionFailure("Attempt to subscribe to \(self) before it is comitted.")
            return CompositeCancellable()
        }

        subject.send((actionableItem, ()))
        return compositeCancellable
    }

    // MARK: - Private

    private let subject = PassthroughSubject<(ActionableItemType, ()), Error>()
    private var didInvokeComplete = false

    /// The composite cancellable that contains all subscriptions including the original workflow
    /// as well as all the forked ones.
    fileprivate let compositeCancellable = CompositeCancellable()

    fileprivate func didCompleteIfNotYet() {
        // Since a workflow may be forked to produce multiple subscribed Rx chains, we should
        // ensure the didComplete method is only invoked once per Workflow instance. See `Step.commit`
        // on why the side-effects must be added at the end of the Rx chains.
        guard !didInvokeComplete else {
            return
        }
        didInvokeComplete = true
        didComplete()
    }
}

/// Defines a single step in a `Workflow`.
///
/// A step may produce a next step with a new value and actionable item, eventually forming a sequence of `Workflow`
/// steps.
///
/// Steps are asynchronous by nature.
open class Step<WorkflowActionableItemType, ActionableItemType, ValueType> {

    private let workflow: Workflow<WorkflowActionableItemType>
    private var publisher: AnyPublisher<(ActionableItemType, ValueType), Error>

    fileprivate init(workflow: Workflow<WorkflowActionableItemType>, publisher: AnyPublisher<(ActionableItemType, ValueType), Error>) {
        self.workflow = workflow
        self.publisher = publisher
    }

    /// Executes the given closure for this step.
    ///
    /// - parameter onStep: The closure to execute for the `Step`.
    /// - returns: The next step.
    public final func onStep<NextActionableItemType, NextValueType>(_ onStep: @escaping (ActionableItemType, ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), Error>) -> Step<WorkflowActionableItemType, NextActionableItemType, NextValueType> {
        let confinedNextStep = publisher
            .map { (actionableItem, value) -> AnyPublisher<(Bool, ActionableItemType, ValueType), Error> in
                // We cannot use generic constraint here since Swift requires constraints be
                // satisfied by concrete types, preventing using protocol as actionable type.
                if let interactor = actionableItem as? Interactable {
                    return interactor
                        .isActiveStream
                        .map({ (isActive: Bool) -> (Bool, ActionableItemType, ValueType) in
                            (isActive, actionableItem, value)
                        })
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Just((true, actionableItem, value))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .filter { (isActive: Bool, _, _) -> Bool in
                isActive
            }
            .prefix(1)
            .map { (_, actionableItem: ActionableItemType, value: ValueType) -> AnyPublisher<(NextActionableItemType, NextValueType), Error> in
                onStep(actionableItem, value)
            }
            .switchToLatest()
            .prefix(1)
            .share()
            .eraseToAnyPublisher()

        return Step<WorkflowActionableItemType, NextActionableItemType, NextValueType>(workflow: workflow, publisher: confinedNextStep)
    }

    /// Executes the given closure when the `Step` produces an error.
    ///
    /// - parameter onError: The closure to execute when an error occurs.
    /// - returns: This step.
    public final func onError(_ onError: @escaping ((Error) -> ())) -> Step<WorkflowActionableItemType, ActionableItemType, ValueType> {
        publisher = publisher
            .handleEvents(receiveCompletion: { result in
                if case .failure(let error) = result {
                    onError(error)
                }
            })
            .eraseToAnyPublisher()
        return self
    }

    /// Commit the steps of the `Workflow` sequence.
    ///
    /// - returns: The committed `Workflow`.
    @discardableResult
    public final func commit() -> Workflow<WorkflowActionableItemType> {
        // Side-effects must be chained at the last publisher sequence, since errors and complete
        // events can be emitted by any publishers on any steps of the workflow.
        let cancellable = publisher
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    self.workflow.didCompleteIfNotYet()
                case .failure(let error):
                    self.workflow.didReceiveError(error)
                }
            }, receiveValue: { (actionableItem: ActionableItemType, value: ValueType) in
            })

        workflow.compositeCancellable.insert(cancellable)

        return workflow
    }

    /// Convert the `Workflow` into a publisher.
    ///
    /// - returns: The publisher representation of this `Workflow`.
    public final func asPublisher() -> AnyPublisher<(ActionableItemType, ValueType), Error> {
        return publisher
    }

    /// Convert the `Workflow` into a publisher.
    ///
    /// - returns: The publisher representation of this `Workflow`.
    @available(*, deprecated, renamed: "asPublisher()")
    public final func asObservable() -> AnyPublisher<(ActionableItemType, ValueType), Error> {
        return asPublisher()
    }
}

/// `Workflow` related publisher extensions.
public extension Publisher {

    /// Fork the step from this publisher.
    ///
    /// - parameter workflow: The workflow this step belongs to.
    /// - returns: The newly forked step in the workflow. `nil` if this publisher does not conform to the required
    ///   generic type of (ActionableItemType, ValueType).
    func fork<WorkflowActionableItemType, ActionableItemType, ValueType>(_ workflow: Workflow<WorkflowActionableItemType>) -> Step<WorkflowActionableItemType, ActionableItemType, ValueType>? {
        if let stepPublisher = self as? AnyPublisher<(ActionableItemType, ValueType), Error> {
            workflow.didFork()
            return Step(workflow: workflow, publisher: stepPublisher)
        }
        return nil
    }
}

/// `Workflow` related `AnyCancellable` extensions.
public extension AnyCancellable {

    /// Cancel the subscription when the given `Workflow` is cancelled.
    ///
    /// When using this composition, the subscription closure may freely retain the workflow itself, since the
    /// subscription closure is cancelled once the workflow is cancelled, thus releasing the retain cycle before the
    /// `Workflow` needs to be deallocated.
    ///
    /// - note: This is the preferred method when trying to confine a subscription to the lifecycle of a `Workflow`.
    ///
    /// - parameter workflow: The workflow to cancel the subscription with.
    func cancelWith<ActionableItemType>(workflow: Workflow<ActionableItemType>) {
        workflow.compositeCancellable.insert(self)
    }

    /// Cancel the subscription when the given `Workflow` is cancelled.
    ///
    /// When using this composition, the subscription closure may freely retain the workflow itself, since the
    /// subscription closure is cancelled once the workflow is cancelled, thus releasing the retain cycle before the
    /// `Workflow` needs to be deallocated.
    ///
    /// - note: This is the preferred method when trying to confine a subscription to the lifecycle of a `Workflow`.
    ///
    /// - parameter workflow: The workflow to cancel the subscription with.
    @available(*, deprecated, renamed: "cancelWith(workflow:)")
    func disposeWith<ActionableItemType>(worflow: Workflow<ActionableItemType>) {
        cancelWith(workflow: worflow)
    }
}
