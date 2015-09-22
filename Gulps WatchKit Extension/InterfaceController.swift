import WatchKit
import Foundation
import Realm
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var goalLabel: WKInterfaceLabel!
    @IBOutlet weak var progressImage: WKInterfaceImage!

    var realmToken: RLMNotificationToken?
    var previousPercentage = 0.0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        /* 
        The realm notification token works only with WatchOS 1.
        */
        if #available(watchOS 2.0, *) {
        } else {
            realmToken = RLMRealm.defaultRealm().addNotificationBlock { note, realm in
                self.reloadAndUpdateUI()
            }
        }

        let entry = EntryHandler.sharedHandler.currentEntry() as Entry
        previousPercentage = entry.percentage
        progressImage.setImageNamed("activity-")
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        reloadAndUpdateUI()
    }

    @IBAction func addSmallGulpAction() {
        updateWithGulp(Constants.Gulp.Small.key())
    }

    @IBAction func addBigGulpAction() {
        updateWithGulp(Constants.Gulp.Big.key())
    }

    override func willActivate() {
        super.willActivate()
        reloadAndUpdateUI()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
}

// MARK: Private Helper Methods

private extension InterfaceController {
    
    func reloadAndUpdateUI() {
        let entry = EntryHandler.sharedHandler.currentEntry() as Entry
        var delta = Int(entry.percentage - previousPercentage)
        if (delta < 0) {
            // animate in reverse using negative duration
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(entry.percentage), -delta), duration: -1.0, repeatCount: 1)
        } else {
            if (delta == 0) {
                // if the range's length is 0, no image is loaded
                delta = 1
            }
            progressImage.startAnimatingWithImagesInRange(NSMakeRange(Int(previousPercentage), delta), duration: 1.0, repeatCount: 1)
        }
        goalLabel.setText(NSLocalizedString("daily goal:", comment: "") + entry.formattedPercentage())
        previousPercentage = entry.percentage
    }
    
    func updateWithGulp(gulp: String) {
        EntryHandler.sharedHandler.addGulp(NSUserDefaults.groupUserDefaults().doubleForKey(gulp))
        if realmToken == .None {
            // The realm token is not set in WatchOS 2, updating the UI manually
            reloadAndUpdateUI()
        }
    }
}
