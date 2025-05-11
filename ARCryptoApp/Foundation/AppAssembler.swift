//
//  AppAssembler.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 25.01.2025.
//

import Swinject

class AppAssembler {
    static let shared = AppAssembler()

    private let container = Container()
    private let assembler: Assembler

    let resolver: Resolver

    init() {
        let service = ServiceAssembly()
        let viewModel = ViewModelAssembly()
        self.assembler = Assembler([service, viewModel], container: container)
        service.assemble(container: container)
        viewModel.assemble(container: container)

        self.resolver = self.assembler.resolver
    }

    class ServiceAssembly: Assembly {
        func assemble(container: Container) {
            container.register(KeychainStoreProvider.self) { _ in
                return KeychainStore()
            }

            container.register(DatabaseProvider.self) { _ in
                return DatabaseManager()
            }

            container.register(CoinCollectStoreProvider.self) { resolver in
                return CoinCollectStore(userSession: resolver.forceResolve(UserSessionProvider.self))
            }


            container.register(UserSessionProvider.self) { resolver in
                return UserSessionService(
                    keychainStore: resolver.forceResolve(KeychainStoreProvider.self),
                    databaseProvider: resolver.forceResolve(DatabaseProvider.self)
                )
            }
            .inObjectScope(.container)

            container.register(AuthenticationProvider.self) { resolver in
                return AuthenticationService(
                    userSessionProvider: resolver.forceResolve(UserSessionProvider.self),
                    coinCollectStoreProvider: resolver.forceResolve(CoinCollectStoreProvider.self)
                )
            }

            container.register(PromocodesProvider.self) { resolver in
                return PromocodesService()
            }

            container.register(PromocodeStoreProvider.self) { resolver in
                return PromocodeStore()
            }

            container.register(GuardarianCountryAvailabilityService.self) { _ in
                return GuardarianCountryAvailabilityService()
            }
        }
    }

    class ViewModelAssembly: Assembly {
        func assemble(container: Container) {
        }
    }


}

extension Resolver {
    func forceResolve<Service>(_ serviceType: Service.Type) -> Service {
        guard let service = resolve(serviceType) else {
            fatalError("Can't resolve service \(serviceType)")
        }

        return service
    }
}
