import UIKit


final class CosmicSlider: UISlider {

    /// слой, отвечающий за показ пустого (незаполненного) слайдера
    private let baseLayer = CALayer()
    /// слой, отвечающий за заполнунную часть слайдера
    private let trackLayer = CAGradientLayer()
    
    /// прямоугольник в начале слайдера
    private let startRect = CALayer()
    /// прямоугольник в конце слайдера
    private let endRect = CALayer()
    
    private let activeColor = #colorLiteral(red: 0.318577975, green: 0.9818529487, blue: 0.5583183169, alpha: 1)
    private let inactiveColor = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3294117647, alpha: 0.5)
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setup()
    }

    private func setup() {
        self.clear()
        self.createBaseLayer()
        self.createRects()
        self.createThumbImageView()
        self.configureTrackLayer()
        self.addUserInteractions()
        self.valueChanged(self)
    }

    private func clear() {
        self.tintColor = .clear
        self.maximumTrackTintColor = .clear
        self.minimumTrackTintColor = .clear
        self.backgroundColor = .clear
        self.thumbTintColor = .clear
    }

    // Step 3
    private func createBaseLayer() {
        baseLayer.borderWidth = 0
        baseLayer.borderColor = self.inactiveColor.cgColor
        baseLayer.masksToBounds = true
        baseLayer.backgroundColor = self.inactiveColor.cgColor
        baseLayer.frame = .init(x: 0, y: frame.height / 3, width: frame.width, height: frame.height/6)
        layer.insertSublayer(baseLayer, at: 0)
    }
    private func createRects() {
        self.startRect.borderWidth = 0
        self.startRect.borderColor = self.activeColor.cgColor
        self.startRect.masksToBounds = true
        self.startRect.backgroundColor = self.activeColor.cgColor
        self.startRect.cornerRadius = 2
        let sizeOfRect = CGSize(width: 10, height: 20)
        self.startRect.frame = .init(x: -sizeOfRect.width,
                                     y: baseLayer.frame.midY - sizeOfRect.height/2.0,
                                     width: sizeOfRect.width,
                                     height: sizeOfRect.height)
        
        self.layer.insertSublayer(self.startRect, at: 1)
        
        self.endRect.borderWidth = 0
        self.endRect.borderColor = self.inactiveColor.cgColor
        self.endRect.masksToBounds = true
        self.endRect.backgroundColor = self.inactiveColor.cgColor
        self.endRect.cornerRadius = 2
        self.endRect.frame = .init(x: self.frame.width ,
                                     y: baseLayer.frame.midY - sizeOfRect.height/2.0,
                                     width: sizeOfRect.width,
                                     height: sizeOfRect.height)
        
        self.layer.insertSublayer(self.endRect, at: 2)
        
    }
    // Step 7
    private func configureTrackLayer() {
        let firstColor = self.activeColor.cgColor
        let secondColor = self.activeColor.cgColor
        trackLayer.colors = [firstColor, secondColor]
        trackLayer.startPoint = .init(x: 0, y: 0.5)
        trackLayer.endPoint = .init(x: 1, y: 0.5)
        trackLayer.frame = .init(x: 0, y: self.frame.height / 3, width: 0, height: frame.height/6)
        layer.insertSublayer(trackLayer, at: 3)
    }

    // Step 8
    private func addUserInteractions() {
        addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }

    @objc private func valueChanged(_ sender: CosmicSlider) {
        // Step 10
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // Step 9
        let thumbRectA = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        trackLayer.frame = .init(x: 0, y: self.frame.height / 3, width: thumbRectA.midX, height: frame.height/6)
        // Step 10
        
        if self.value == self.maximumValue {
            self.endRect.backgroundColor = self.activeColor.cgColor
            self.endRect.borderColor = self.activeColor.cgColor
        } else {
            self.endRect.backgroundColor = self.inactiveColor.cgColor
            self.endRect.borderColor = self.inactiveColor.cgColor
        }
        
        if self.value == self.minimumValue {
            self.startRect.backgroundColor = self.inactiveColor.cgColor
            self.startRect.borderColor = self.inactiveColor.cgColor
        } else {
            self.startRect.backgroundColor = self.activeColor.cgColor
            self.startRect.borderColor = self.activeColor.cgColor
        }
        
        CATransaction.commit()
    }

    // Step 5
    private func createThumbImageView() {
        let thumbSize: CGFloat = 55
        let thumbView = ThumbView(frame: .init(x: 0, y: 0, width: thumbSize, height: thumbSize))
        thumbView.layer.cornerRadius = thumbSize / 2
        let thumbSnapshot = thumbView.snapshot
        setThumbImage(thumbSnapshot, for: .normal)
        // Step 6
        setThumbImage(thumbSnapshot, for: .highlighted)
        setThumbImage(thumbSnapshot, for: .application)
        setThumbImage(thumbSnapshot, for: .disabled)
        setThumbImage(thumbSnapshot, for: .focused)
        setThumbImage(thumbSnapshot, for: .reserved)
        setThumbImage(thumbSnapshot, for: .selected)
    }
}

// Step 4
final class ThumbView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = #colorLiteral(red: 0.318577975, green: 0.9818529487, blue: 0.5583183169, alpha: 1)
    }
}

// Step 4
extension UIView {

    var snapshot: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let capturedImage = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        return capturedImage
    }
}
