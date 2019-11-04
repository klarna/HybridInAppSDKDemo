## KlarnaMobileSDK Demo

This demo shows how you can integrate KlarnaMobileSDK into your existing WKWebView.

### Run the demo app

This demo demonstrate how you can use Cocoapods to integrate KlarnaMobileSDK into your XCode project, this is included in `Podfile`:

```ruby
use_frameworks!

platform :ios, "10.0"

target "HybridInAppSDKDemo" do
   pod "KlarnaMobileSDK"
end
```

To run the demo app, just open `HybridInAppSDKDemo.xcworkspace`, click on `Run`. 

### Important steps during integration

There are a few important steps that you need to perform to have a successful integration:

* Initialize `KlarnaHybridSDK` with a `WKWebView`, make sure providing a `returnUrl` and `eventListener` during the initialization. 

```swift
  klarnaHybridSDK = KlarnaHybridSDK(webView: webView,
                                  returnUrl: URL(string: "your-app-scheme://")!,
                                  eventListener: self)
```

* Implement WebView's delegate (`WKNavigationDelegate`), call	relavant `KlarnaHybridSDK` methods.

```swift
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      klarnaHybridSDK?.newPageWillLoad(in: webView)
  }
  
  func webView(_ webView: WKWebView,
	                 decidePolicyFor navigationAction: WKNavigationAction,
	                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      decisionHandler(klarnaHybridSDK?.shouldFollowNavigation(withRequest: navigationAction.request) == true ? .allow : .cancel)
  }
```

* Implement `KlarnaHybridSDKEventListener`.

```swift
  func klarnaWillShowFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
      print("[KlarnaHybridSDK]: will show fullscreen")
      completionHandler()
  }
    
  func klarnaDidShowFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
      print("[KlarnaHybridSDK]: did show fullscreen")
      completionHandler()
  }
    
  func klarnaWillHideFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
      print("[KlarnaHybridSDK]: will hide fullscreen")
      completionHandler()
  }
    
  func klarnaDidHideFullscreen(inWebView webView: KlarnaWebView, completionHandler: @escaping () -> Void) {
      print("[KlarnaHybridSDK]: did hide fullscreen")
      completionHandler()
  }
    
  func klarnaFailed(inWebView webView: KlarnaWebView, withError error: KlarnaMobileSDKError) {
      // Handle Klarna hybrid SDK related errors
      print("[KlarnaHybridSDK]: did get error: \(error.debugDescription)")
  }	
```





