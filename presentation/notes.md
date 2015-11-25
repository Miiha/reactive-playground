# What is functional programming?
Imperative Programmierung: Programm besteht aus Folgen von Anweisungen die meistens Variablen verändern
Funktionale Programmierung: Programm besteht ausschliesslich aus Funktionen, welche als Datentypen behandet werden. 
Funktionen als Parameter
First class objects
Verzicht auf state

# Was ist reactive?
Beschreiben des Dataflows, reagieren auf events 

# Funktionen getter/setter
Eric Mejer

#ReactiveCocoa common interface
Alle machen sehr aenliche Sachen
Sie stehen nicht wirklich in konkurrenz 
Auswaehlen was einem am besten passt
Am wichtigsten ist das Konzept zu verstehen

#Reactive Cocoa
Ist seit anfang 2012 in Objective C

#Signals
Ein Signal kann alles sein

#Create Producer
Unterscheidung zwischen Hot und Cold Signals

```swift
// search signal with flatmap

.flatMap(.Latest, transform: { (data, response) -> SignalProducer<Array<String>, NSError> in
	return SignalProducer { observer, disposable in
	    do {
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
		if let words = json as? [String] {
		    observer.sendNext(words)
		    observer.sendCompleted()
		} else {
		    observer.sendFailed(NSError(domain:"json serialization error", code: 0, userInfo: nil))
		}
	    } catch let error as NSError {
		observer.sendFailed(error)
	    }
	}
})
```
