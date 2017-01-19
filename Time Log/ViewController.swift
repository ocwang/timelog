//
//  ViewController.swift
//  Time Log
//
//  Created by Chase Wang on 1/14/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit
import CoreData

func notImplemented() -> Never {
    fatalError("not implemented")
}

class ViewController: UIViewController {
    
    // MARK: - Instance Vars
    
    var managedContext: NSManagedObjectContext!
    
    var fetchResultsController: NSFetchedResultsController<Log>!
    
    fileprivate var didSetupConstraints = false
    
    var activeTimeLogViewTopConstraint: NSLayoutConstraint!
    
    var activeTimer: Timer?
    
    var startDate: NSDate?
    
    var timeLogs = [Log]()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE 'at' hh:mm a"
        
        return formatter
    }()
    
    // MARK: - Subviews
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var activeTimeLogView: ActiveTimeLogView!
    
    // MARK: - Navigation Bar
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    fileprivate var isNavigationBarHidden: Bool = false {
        didSet {
            guard let navCon = self.navigationController,
                navCon.isNavigationBarHidden != isNavigationBarHidden
                else { return }
            
            navCon.setNavigationBarHidden(isNavigationBarHidden, animated: true)
        }
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        activeTimeLogView.state = .inactive
        activeTimeLogView.delegate = self
        
        // hides table view separators for empty cells
        tableView.tableFooterView = UIView(frame: .zero)
        
        view.addSubview(activeTimeLogView)
        view.setNeedsUpdateConstraints()
    }
    
    func updateTimer(timer: Timer) {
        guard let startDate = startDate else { return }
        
        let secondsElapsed = -startDate.timeIntervalSinceNow
        let timeElapsedString = secondsElapsed.toTimerString
        
        activeTimeLogView.collapsedTimeElapsedLabel.text = timeElapsedString

        if timeElapsedString.hasPrefix("00:") {
            let prefixIndex = timeElapsedString.index(timeElapsedString.startIndex, offsetBy: 3)
            activeTimeLogView.fullScreenTimeElapsedLabel.text = timeElapsedString.substring(from: prefixIndex)
        } else {
            activeTimeLogView.fullScreenTimeElapsedLabel.text = timeElapsedString
        }
    }

    @IBAction func newButtonTapped(_ sender: UIBarButtonItem) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        activeTimeLogView.state = .fullScreen(0.3)
        startDate = NSDate()
        activeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
    }
}

// MARK: - Autolayout

extension ViewController {
    private func setupConstraints() {
        activeTimeLogView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        activeTimeLogView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        activeTimeLogView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        activeTimeLogViewTopConstraint = activeTimeLogView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height)
        activeTimeLogViewTopConstraint.isActive = true
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeLogCell", for: indexPath) as! TimeLogCell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: TimeLogCell, at indexPath: IndexPath) {
        let timeLog = fetchResultsController.object(at: indexPath)
        
        cell.titleLabel.text = timeLog.title
        
        guard let startDate = timeLog.startDateTime as? Date,
            let endDate = timeLog.endDateTime as? Date
            else { return }
        
        cell.startedAtLabel.text = dateFormatter.string(from: startDate)
        
        let timeIntervalElapsed = endDate.timeIntervalSince(startDate)
        cell.durationLabel.text = timeIntervalElapsed.toDurationString
    }
}

// MARK: - Core Data

extension ViewController {
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Log.startDateTime), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
}

// MARK: - ActiveTimeLogViewDelegate

extension ViewController: ActiveTimeLogViewDelegate {
    
    func didTapCollapsedTimerInfo(on view: ActiveTimeLogView) {
        view.state = .fullScreen(0.3)
    }
    
    func didChange(_ state: ActiveTimeLogViewState, on view: ActiveTimeLogView) {
        switch state {
        case .fullScreen(let duration):
            showFullActiveTimeLog(withDuration: duration)
            
        case .collapsed(let duration):
            collapseActiveTimeLogToBottom(withDuration: duration)
            
        case .inactive:
            break
        }
    }
    
    func didTap(stopTimerButton button: UIButton, on view: ActiveTimeLogView) {
        if let startDate = startDate {
            let timeLogToInsert = Log(title: "Untitled", start: startDate, end: NSDate(), in: managedContext)
            timeLogToInsert.insert(into: managedContext) { (result) in
                switch result {
                case .success: break
                case .error(let error): assertionFailure("Error: \(error.localizedDescription)")
                }
            }
        }
        
        stopTimerNow()
        activeTimeLogView.state = .inactive
    }
    
    func didTap(toggleStateButton button: UIButton, on view: ActiveTimeLogView) {
        switch view.state {
        case .fullScreen:
            view.state = .collapsed(0.3)
            
        case .collapsed:
            view.state = .fullScreen(0.3)
            
        default: break
        }
    }
    
    func didPan(_ panGesture: UIPanGestureRecognizer, on view: ActiveTimeLogView) {
        guard let panView = panGesture.view else { return }
        
        let translatedPoint = panGesture.translation(in: view)

        if panGesture.state == .began || panGesture.state == .changed {
            translate(panView: panView, withTranslatedPoint: translatedPoint)
            panGesture.setTranslation(.zero, in: view)
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)
            let verticalVelocity = velocity.y
            
            switch view.state {
            case .fullScreen where verticalVelocity > 3000:
                activeTimeLogView.state = .collapsed(0.1)
                
            case .fullScreen where activeTimeLogViewTopConstraint.constant < view.bounds.height * 0.65:
                activeTimeLogView.state = .fullScreen(0.2)
                
            case .fullScreen:
                activeTimeLogView.state = .collapsed(0.2)
                
            case .collapsed where verticalVelocity < -3000:
                activeTimeLogView.state = .fullScreen(0.1)
            
            case .collapsed where activeTimeLogViewTopConstraint.constant < view.bounds.height * 0.65:
                activeTimeLogView.state = .fullScreen(0.3)
                
            case .collapsed:
                activeTimeLogView.state = .collapsed(0.1)
                
            case .inactive: break
            }
        }
        
    }
    
    func translate(panView: UIView, withTranslatedPoint translatedPoint: CGPoint) {
        let maxConstraint = view.bounds.height - ActiveTimeLogView.collapsedHeight
        let clearBackgroundThreshold = view.bounds.height / 4
        let clearCollapsedContentViewThreshold = view.bounds.height * 0.8
        
        var translatedConstraint = activeTimeLogViewTopConstraint.constant + translatedPoint.y
        var blurBackgroundState: ActiveTimeLogViewBlurBackgroundState
        var collapsedContentViewAlpha: CGFloat = 1
        
        switch translatedConstraint {
        case _ where translatedConstraint > maxConstraint:
            translatedConstraint = maxConstraint
            blurBackgroundState = .solid
            
        case _ where translatedConstraint < 0:
            translatedConstraint = 0
            fallthrough
            
        case _ where translatedConstraint <= clearBackgroundThreshold:
            collapsedContentViewAlpha = 0
            blurBackgroundState = .clear
            
        case clearBackgroundThreshold...maxConstraint where translatedConstraint >= clearCollapsedContentViewThreshold:
            let alpha = (translatedConstraint - clearBackgroundThreshold) / (maxConstraint - clearBackgroundThreshold)
            blurBackgroundState = .translucent(alpha: alpha)
            collapsedContentViewAlpha = (translatedConstraint - clearCollapsedContentViewThreshold) / (maxConstraint - clearCollapsedContentViewThreshold)
            
        case clearBackgroundThreshold...maxConstraint:
            let alpha = (translatedConstraint - clearBackgroundThreshold) / (maxConstraint - clearBackgroundThreshold)
            blurBackgroundState = .translucent(alpha: alpha)
            collapsedContentViewAlpha = 0
            
        default:
            notImplemented()
        }

        let navBarHeight = navigationController?.navigationBar.bounds.height ?? 64
        isNavigationBarHidden = translatedConstraint > navBarHeight ? false : true
        
        activeTimeLogView.setCollapsedTimerContentView(withAlpha: collapsedContentViewAlpha) // here
        activeTimeLogView.blurBackgroundState = blurBackgroundState // here
        activeTimeLogViewTopConstraint.constant = translatedConstraint

        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }
}

// MARK: - ActiveTimeLogView Helpers

extension ViewController {
    func stopTimerNow() {
        
        self.activeTimer?.invalidate()
        self.activeTimer = nil
        self.startDate = nil
        
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.activeTimeLogView.blurBackgroundState = .solid
            self.activeTimeLogViewTopConstraint.constant = self.view.bounds.height
            
            self.activeTimeLogView.setCollapsedTimerContentView(withAlpha: 1)
            
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
    }
    
    func showFullActiveTimeLog(withDuration duration: TimeInterval) {
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration) {
            self.isNavigationBarHidden = true
            
            self.activeTimeLogView.blurBackgroundState = .clear
            self.activeTimeLogViewTopConstraint.constant = 0
            
            self.activeTimeLogView.setCollapsedTimerContentView(withAlpha: 0)
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
        
        self.activeTimeLogView.collapsedTimerContentView.isHidden = false
    }
    
    func collapseActiveTimeLogToBottom(withDuration duration: TimeInterval) {
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration) {
            self.isNavigationBarHidden = false
            
            self.activeTimeLogView.blurBackgroundState = .solid
            self.activeTimeLogViewTopConstraint.constant = self.view.bounds.height - ActiveTimeLogView.collapsedHeight
            
            self.activeTimeLogView.setCollapsedTimerContentView(withAlpha: 1)
        
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TimeLogCell
            configure(cell, at: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
