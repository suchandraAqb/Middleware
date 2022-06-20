/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

class StockOverlay: UIView {

    private enum Constants {
        static let contentWidth: CGFloat = 234
        static let contentHeight: CGFloat = 60
        static let taskLogoWidth: CGFloat = 60
        static let taskLogoHeight: CGFloat = 60
        static let taskLabelToTaskLogoSpace: CGFloat = 7
        static let taskLabelToContentEndSpace: CGFloat = 24
        static let taskLabelToContentTopSpace: CGFloat = 13
        static let taskLabelToContentBottomSpace: CGFloat = 12
        static let taskLabelTextColor: UIColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
        static let taskLogoBackgroundColor: UIColor = UIColor(red: 0.35, green: 0.84, blue: 0.78, alpha: 1.0)
    }

    private let model: StockModel

    private(set) var shouldUpdateConstraints = true
    func abcd(){
        self.toggleShowingBarcodeData()
    }
    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.contentHeight / 2
        return view
    }()

    private lazy var taskLogo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.alpha = 1
        imageView.layer.cornerRadius = Constants.taskLogoHeight / 2
        return imageView
    }()

    private lazy var taskLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Constants.taskLabelTextColor
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.attributedText = self.taskAttributedText
        return label
    }()

    private lazy var barcodeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = Constants.taskLabelTextColor
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.isHidden = true
        label.text = self.model.barcodeData
        return label
    }()

    private lazy var effectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blur)

        return blurView
    }()

    init(with model: StockModel) {
        self.model = model
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.contentWidth, height: Constants.contentHeight))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(contentView)
        contentView.addSubview(effectView)
        contentView.addSubview(taskLogo)
        contentView.addSubview(taskLabel)
        contentView.addSubview(barcodeLabel)
        update()
        updateConstraints()
    }

    override func updateConstraints() {
        if shouldUpdateConstraints {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            effectView.translatesAutoresizingMaskIntoConstraints = false
            taskLogo.translatesAutoresizingMaskIntoConstraints = false
            taskLabel.translatesAutoresizingMaskIntoConstraints = false
            barcodeLabel.translatesAutoresizingMaskIntoConstraints = false
            addConstraints([
                widthAnchor.constraint(lessThanOrEqualToConstant: Constants.contentWidth),
                heightAnchor.constraint(equalToConstant: Constants.contentHeight),

                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

                taskLogo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                taskLogo.topAnchor.constraint(equalTo: contentView.topAnchor),
                taskLogo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                taskLogo.widthAnchor.constraint(equalToConstant: Constants.taskLogoWidth),

                taskLabel.leadingAnchor.constraint(equalTo: taskLogo.trailingAnchor,
                                                   constant: Constants.taskLabelToTaskLogoSpace),
                taskLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: Constants.taskLabelToContentTopSpace),
                taskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -Constants.taskLabelToContentEndSpace),
                taskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -Constants.taskLabelToContentBottomSpace),

                barcodeLabel.centerYAnchor.constraint(equalTo: taskLabel.centerYAnchor),
                barcodeLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor),
                barcodeLabel.widthAnchor.constraint(equalTo: taskLabel.widthAnchor),
                barcodeLabel.heightAnchor.constraint(equalTo: taskLabel.heightAnchor, multiplier: 0.5),

                effectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                effectView.topAnchor.constraint(equalTo: contentView.topAnchor),
                effectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                effectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            contentView.setContentHuggingPriority(.required, for: .horizontal)
            shouldUpdateConstraints.toggle()
        }
        super.updateConstraints()
    }

    private func update() {
        taskLogo.image = UIImage(named: "StockCount")
        taskLogo.backgroundColor = Constants.taskLogoBackgroundColor
        taskLabel.attributedText = taskAttributedText
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleShowingBarcodeData))
        contentView.addGestureRecognizer(tapRecognizer)
    }

    @objc private func toggleShowingBarcodeData() {
        taskLabel.isHidden.toggle()
        barcodeLabel.isHidden = !taskLabel.isHidden
    }

    private var taskAttributedText: NSAttributedString {
        let firstLineAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
        ]
        let attributedString = NSMutableAttributedString(string: "Report stock count",
                                                         attributes: firstLineAttributes)
        attributedString.append(NSAttributedString(string: "\n"))
        let secondLineAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ]
        let secondLine = NSAttributedString(string: "Shelf: \(model.shelfCount), Back room: \(model.backroomCount)",
                                            attributes: secondLineAttributes
        )
        attributedString.append(secondLine)
        return attributedString
    }

}
