import Foundation
import Domain
import RxRelay
import UIKit

public protocol PokemonRepositoryType {
    func set(_ pokemon: Pokemon)
    func set(_ pokemons: [Pokemon])
    func get() -> [Pokemon]
    func get(id: Int) -> Pokemon?
}

public final class PokemonRepository: PokemonRepositoryType {

    private let data: BehaviorRelay<[Int: Pokemon]> = .init(value: [:])

    public func set(_ pokemon: Pokemon) {
        var _data = data.value
        guard let id = pokemon.id else { return }
        _data[id] = pokemon
        data.accept(_data)
    }

    public func set(_ pokemons: [Pokemon]) {
        var _data = data.value
        pokemons.forEach { pokemon in
            guard let id = pokemon.id else { return }
            _data[id] = pokemon
        }
        data.accept(_data)
    }

    public func get() -> [Pokemon] {
        Array(data.value.values)
    }

    public func get(id: Int) -> Pokemon? {
        data.value[id]
    }
}

extension PokemonRepository {
    public static let shared = PokemonRepository()
}
