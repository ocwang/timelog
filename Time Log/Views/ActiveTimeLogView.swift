//
//  ActiveTimeLogView.swift
//  Time Log
//
//  Created by Chase Wang on 1/14/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit

enum ActiveTimeLogViewState {
    case fullScreen(TimeInterval)
    case collapsed(TimeInterval)
    case inactive
}

enum ActiveTimeLogViewBlurBackgroundState {
    case solid
    case translucent(alpha: CGFloat)
    case clear
}

protocol ActiveTimeLogViewDelegate: class {
    func didPan(_ panGesture: UIPanGestureRecognizer, on view: ActiveTimeLogView)
    
    func didTap(toggleStateButton button: UIButton, on view: ActiveTimeLogView)
    
    func didChange(_ state: ActiveTimeLogViewState, on view: ActiveTimeLogView)
    
    func didTap(stopTimerButton button: UIButton, on view: ActiveTimeLogView)
    
    func didTapCollapsedTimerInfo(on view: ActiveTimeLogView)
}

class ActiveTimeLogView: UIView {
    
    // MARK: - Instance Vars
    
    
    static let collapsedHeight: CGFloat = 65
    
    weak var delegate: ActiveTimeLogViewDelegate?
    
    var state: ActiveTimeLogViewState = .inactive {
        didSet {
            delegate?.didChange(state, on: self)
        }
    }
    
    internal var blurBackgroundState: ActiveTimeLogViewBlurBackgroundState = .solid {
        didSet {
            switch blurBackgroundState {
            case .solid:
                blurBackgroundView.alpha = 1
                toggleStateButton.alpha = 0
                fullScreenTimeElapsedLabel.alpha = 0
                
            case .translucent(let alpha):
                blurBackgroundView.alpha = alpha
                toggleStateButton.alpha = 1 - alpha
                fullScreenTimeElapsedLabel.alpha = 1 - alpha
                
            case .clear:
                blurBackgroundView.alpha = 0
                toggleStateButton.alpha = 1
                fullScreenTimeElapsedLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Subviews
    @IBOutlet private weak var blurBackgroundView: UIView!
    @IBOutlet weak var fullScreenStopButton: UIButton!
    @IBOutlet weak var fullScreenTimeElapsedLabel: UILabel!
    
    @IBOutlet weak var toggleStateButton: UIButton!
    
    @IBOutlet weak var collapsedStopButton: UIButton!
    @IBOutlet weak var collapsedTimeElapsedLabel: UILabel!
    @IBOutlet weak var collapsedTitleLabel: UILabel!
    @IBOutlet weak var collapsedTimerContentView: UIView!
    @IBOutlet weak var expandActiveTimerButton: UIButton!
    
    @IBOutlet weak var collapsedTimerInfoStackView: UIStackView!
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Cell Lifecycle
    @IBAction func collapsedTimerInfoTapped(_ sender: UITapGestureRecognizer) {
        delegate?.didTapCollapsedTimerInfo(on: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        blurBackgroundView.backgroundColor = .white
        toggleStateButton.setImage(#imageLiteral(resourceName: "ic_chevron_black_highlighted"), for: .highlighted)
        collapsedStopButton.setImage(#imageLiteral(resourceName: "btn_stop_rec_sm_highlighted"), for: .highlighted)
        fullScreenStopButton.setImage(#imageLiteral(resourceName: "btn_stop_rec_lg_highlighted"), for: .highlighted)
        
        collapsedTimeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: UIFontWeightRegular)
        fullScreenTimeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: UIFontWeightThin)
        setCollapsedTimerContentView(withAlpha: 0)
    }
    
    func setCollapsedTimerContentView(withAlpha alpha: CGFloat) {
        collapsedTimerContentView.alpha = alpha
        collapsedTimerContentView.isHidden = alpha > 0 ? false : true
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        delegate?.didTap(stopTimerButton: sender, on: self)
    }
    
    
    @IBAction func toggleStateButtonTapped(_ sender: UIButton) {
        delegate?.didTap(toggleStateButton: toggleStateButton, on: self)
    }
    
    func didPan(_ panGesture: UIPanGestureRecognizer) {
        delegate?.didPan(panGesture, on: self)
    }
}
