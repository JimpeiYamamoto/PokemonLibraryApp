import UIKit

public final class AbilityView: UIView {
    
    private let label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(abilityText: String) {
        label.text = abilityText
    }
}
