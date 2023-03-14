import Foundation

final class Store<Value, Action>: ObservableObject {
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?
    let reducer: Reducer<Value, Action>
    
    init(value: Value, reducer: @escaping Reducer<Value, Action>) {
        self.value = value
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        let effects = self.reducer(&self.value, action)
            for effect in effects {
                effect.run(self.send)
            }
    }
    
    public func view<LocalValue, LocalAction>(value toLocalValue: @escaping (Value) -> LocalValue,
                                              action toGlobalAction: @escaping (LocalAction) -> Action) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(value: toLocalValue(value),
                                                        reducer: {localValue, localAction in
            self.send(toGlobalAction(localAction))
            localValue = toLocalValue(self.value)
            return []
        })
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        } as? Cancellable
        return localStore
    }
}

func combine<Value, Action>(_ reducers: Reducer<Value, Action>...) -> Reducer<Value, Action> {
    return {value, action in
        var effects = [Effect<Action>]()
        for reducer in reducers {
            let localEffects = reducer(&value, action)
            effects.append(contentsOf: localEffects)
        }
        return effects
    }
}

func pullback<LocalValue, GlobalValue, GlobalAction, LocalAction>(_ reducer: @escaping Reducer<LocalValue, LocalAction>,
                                               value: WritableKeyPath<GlobalValue, LocalValue>,
                                                                  action: WritableKeyPath<GlobalAction, LocalAction?>) -> Reducer<GlobalValue, GlobalAction> {
    return {globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        return localEffects.compactMap { localEffect in
            return Effect { callback in
                localEffect.run { localAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    callback(globalAction)
                }
            }
        }
    }
}

public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }
    
    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        Effect<B>(run: { callback in self.run { a in callback(f(a)) } } )
    }
}

extension Effect {
    func recieve(on queue: DispatchQueue) -> Effect {
        return Effect { callback in
            self.run { a in
                queue.async {
                    callback(a)
                }
            }
        }
    }
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

