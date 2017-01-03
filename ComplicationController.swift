import ClockKit
import HealthKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    var incr = 0;
    var exhaust = "";
    let health = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    let sort = [ NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false) ]
    let dateformatter = DateFormatter()

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        handler(Date(timeIntervalSinceNow: 60*10))
    }
    
    func requestedUpdateBudgetExhausted() {
        exhaust = ", ex"
        NSLog("DEBUG exhaust")
        let server=CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications! {
            server.reloadTimeline(for: complication)
        }
    }
    
    func requestedUpdateDidBegin() {
        exhaust = ""
        NSLog("DEBUG update")
        let server=CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications! {
            server.reloadTimeline(for: complication)
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        var rate = 0.0
        var when = Date()
        incr += 1;
        
        health.requestAuthorization(toShare: nil, read: [heartRateType], completion: { (success, error) in
            // TODO abort/log
        })
        
        var done = false
        let sampleQuery = HKSampleQuery(sampleType: self.heartRateType, predicate: nil, limit: 1, sortDescriptors: sort, resultsHandler: {
            query, results, error in
            if let results = results as? [HKQuantitySample]
            {
                if results.count > 0 {
                    let sample = results[0] as HKQuantitySample
                    rate = sample.quantity.doubleValue(for: self.heartRateUnit)
                    when = sample.endDate;
                }
                done = true
            }
        })
        health.execute(sampleQuery)
        
        // XXX very quickndirty wait
        var timeout = 0.0
        while (!done) {
            timeout += 0.1
            if (timeout >= 10) {
                break
            }
            usleep(100000)
        }
        
        if complication.family == .modularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            dateformatter.dateFormat = "HH:mm"
            //template.headerTextProvider = CLKSimpleTextProvider(text: "HR " + String(format: "%.0f", HR) + "(" + String(incr1) + "," + timeout + ")" + exhaust)
            template.headerTextProvider = CLKSimpleTextProvider(text: "♥ " + String(format: "%.0f", rate))
            template.body1TextProvider = CLKTimeTextProvider(date: when)
            template.body2TextProvider = CLKSimpleTextProvider(text: dateformatter.string(from: Date()) + ", #" + String(incr) + ", " +  String(timeout) + "s " + exhaust)
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        } else {
            handler(nil)
        }
    }
}
