BasicReactiveExample
====================


Here I took a simple collectionview example I was able to find on the internet and added some reactive code.

Very simple example of reactive programming example in conjunction with a collection view.
 This example does three things. 
 
 1.) Displays a collection view with random colors.
 2.) Displays a UIAlertView when a message string is changed.
 3.) NSLogs a message when an item is added.
 
 Number 1 is pretty basic collection view. It's non reactive meaning it's not really using
 Reactive Cocoa. The collection view example code is taken from the sourcecode for the book
 
 RACObserve()
 ---------------------------
 Number 2.) Is Reactive Cocoa code. Here I want to display a UIAlertView whenever an NSString value
 is changed. In order to do this I observe the self.message NSString object using RACObserve.
 This creates a signal that receives the new value and displays a UIAlertView with the new string value.
 
 UIButton:rac_signalForControlEvents:
 ---------------------------------------------------
 Number 3.) Is also Reactive Cocoa where I bind a RAC signal to a touch up inside control event. When the 
 button receives the touch up inside event a signal is sent to create a new color cell add it to the collection view datasource
 and call reload data on the collection view.
 
 
 RACDelegateProxy
 ----------------------
 I am also using RACDelegateProxy to bind to the collection view's didSelectItemAtIndex selector.
 
