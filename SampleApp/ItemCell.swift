//
//  ItemCell.swift
//  SampleApp
//
//  Created by 권현구 on 3/25/24.
//

import UIKit

class ItemCell: UITableViewCell {
    
    static let reuseIdentifier = "ItemCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        self.selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var nameLabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var categoryLabel = {
        let label = UILabel()
        return label
    }()
    
    private func setupLayout() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with item: Item) {
        let quantity = item.quantity
        nameLabel.text = "\(item.name)"
        categoryLabel.text = "\(item.category)"
        nameLabel.text = "\(item.name) - \(item.category) - \(item.quantity!) - \(item.note!)"
    }
}
