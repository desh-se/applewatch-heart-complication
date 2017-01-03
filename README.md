# applewatch-heart-complication
Shows the latest heart rate reading on the watch face as often as possible, with some additional debugging

1. Install Xcode
2. Create an watchOS app with included Complication
3. Enable HealthKit under Capabilities for both the iOS app and the WatchKit Extension
4. Replace the iOS app's ViewController.swift and WatchKit Extension's ComplicationController.swift files with the ones in this project
5. Open the iOS app's Main.storyboard, add a button to the view, select the View Controller, and connect (drag) the "enableHealthKitWithSender" (under Received Actions in the Connections inspector) and choose Touch Up Inside.
6. Connect your iPhone using USB, select it, build and run the project
7. Profit
