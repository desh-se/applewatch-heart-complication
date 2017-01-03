import UIKit
import HealthKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func enableHealthKit(sender: AnyObject) {
        let health = HKHealthStore()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        health.requestAuthorization(toShare: nil, read: [heartRateType], completion: { (success, error) in
            if success {
                NSLog("requestAuthorization: success")
            } else {
                NSLog("requestAuthorization: failure")
            }
        })
    }
}
