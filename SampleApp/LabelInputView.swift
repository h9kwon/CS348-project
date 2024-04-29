//
//  LabelInputView.swift
//  SampleApp
//
//  Created by 권현구 on 3/25/24.
//

import UIKit

class LabelInputView: UIStackView {

    init(title: String) {
        super.init(frame: .zero)
        print("init")
        titleLabel.text = title
        self.backgroundColor = .yellow
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.addSubview(titleLabel)
        self.addSubview(textField)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "asd"
        return label
    }()
    
    private lazy var textField = {
        let textField = UITextField()
        textField.text = "asdf"
        textField.borderStyle = .line
        return textField
    }()
}
