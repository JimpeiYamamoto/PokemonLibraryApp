import UIKit
import PokemonAPI
import RxSwift
import RxRelay

public final class ViewController: UIViewController {

    let viewStream: ViewStream
    let disposeBag = DisposeBag()

    public init(viewStream: ViewStream) {
        self.viewStream = viewStream
        super.init(nibName: nil, bundle: nil)

        viewStream.output.nameLabelText
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] result in
                self?.nameLabel.text = result
            }
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = "empty"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        viewStream.input.viewDidLoad.accept(())

        let pokemonCardView = PokemonCardViewCell()
        pokemonCardView.configure(
            number: "1",
            name: "フシギダネ",
            imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!
        )
        view.addSubview(pokemonCardView)
        pokemonCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pokemonCardView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4),
            pokemonCardView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4),
            pokemonCardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
    }
}
