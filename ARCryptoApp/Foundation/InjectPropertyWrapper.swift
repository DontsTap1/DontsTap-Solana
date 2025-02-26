//
//  InjectPropertyWrapper.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 25.01.2025.
//

@propertyWrapper
struct Inject<T> {
    private var service: T

    init() {
        let resolver = AppAssembler.shared.resolver 

        self.service = resolver.forceResolve(T.self)
    }

    var wrappedValue: T {
        return service
    }
}
