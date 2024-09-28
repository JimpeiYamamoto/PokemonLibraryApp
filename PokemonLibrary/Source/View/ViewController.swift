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

        let pokemonCardView = PokemonCardView()
        pokemonCardView.configure()
        view.addSubview(pokemonCardView)
        pokemonCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pokemonCardView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4),
            pokemonCardView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4),
            pokemonCardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
    }
}

public final class PokemonCardView: UIView {
    private lazy var containerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerView, spriteImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fill
        view.alignment = .center
        view.layer.cornerRadius = 8.0
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.red.cgColor
        return view
    }()

    private lazy var headerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [numberLabel, nameLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 4
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 40),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let spriteImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
        ])

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4),
            headerView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4),
            headerView.heightAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            numberLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 4),
            numberLabel.heightAnchor.constraint(equalToConstant: 40),
            numberLabel.widthAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            spriteImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4),
            spriteImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4),
            spriteImageView.heightAnchor.constraint(equalTo: spriteImageView.widthAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure() {
        numberLabel.text = "1"
        nameLabel.text = "フシギダネ"
        let apiClient = ApiClient()
        apiClient.loadImage(
            from: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!,
            onSuccess: { [spriteImageView] image in
                spriteImageView.image = image
            },
            onError: { error in
            }
        )
    }
}
