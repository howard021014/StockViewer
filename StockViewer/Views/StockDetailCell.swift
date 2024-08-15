//
//  StockDetailCell.swift
//  StockViewer
//
//  Created by Howard tsai on 2024-08-15.
//

import UIKit

class StockDetailCell: UITableViewCell {

    static let identifier = "StockDetailCell"
    
    let headingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .gray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let infoStackView = UIStackView(arrangedSubviews: [headingLabel, infoLabel])
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .horizontal
        infoStackView.distribution = .equalSpacing

        contentView.addSubview(infoStackView)
        
        NSLayoutConstraint.activate([
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(with heading: String, and info: String) {
        headingLabel.text = heading
        infoLabel.text = info
    }
}
