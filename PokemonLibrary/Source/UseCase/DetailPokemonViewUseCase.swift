import Foundation
import RxSwift
import ApiGateway
import Repository

public protocol DetailPokemonViewUseCaseType {
    func fetchPokemonInformation(id: Int) -> Observable<DetailPokemonViewUseCaseModel.FetchResult>
}

public enum DetailPokemonViewUseCaseModel {
    public enum FetchResult: Equatable {
        case loading
        case loaded(DetailInformation)

        public struct DetailInformation: Equatable {
            public let id: Int
            public let name: String
            public let weight: Int
            public let height: Int
            public let flavorText: String
            public let image: URL
            public let sound: URL
            public let abilities: [String]
        }
    }
}
