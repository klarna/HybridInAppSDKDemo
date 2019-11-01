//
//  WKWebViewController.swift
//  HybridInAppSDKDemo
//

import UIKit
import WebKit
import KlarnaMobileSDK

// MARK: - WKWebViewController demo
class WKWebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var url: URL?
    
    private var navbarView: UIView!
    private var addressTextField: UITextField!
    private var klarnaHybridSDK: KlarnaHybridSDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        klarnaHybridSDK = KlarnaHybridSDK(returnUrl: URL(string: "your-app-scheme://")!, eventListener: self)
        klarnaHybridSDK?.addWebView(webView)
        setupNavbar()
        if let url = url {
            addressTextField.text = url.absoluteString
            loadUrl(url)
        }
    }
    
    private func loadUrl(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
}

// MARK: - WKNavigationDelegate
extension WKWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        klarnaHybridSDK?.newPageLoad(in: webView)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(klarnaHybridSDK?.shouldFollowNavigation(withRequest: navigationAction.request) == true ? .allow : .cancel)
    }
}

// MARK: - KlarnaHybridSDKEventListener
extension WKWebViewController: KlarnaHybridEventListener {
    
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
}

extension WKWebViewController {
    static func instantiate(url: URL?) -> WKWebViewController {
        let viewController: WKWebViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: self)) as! WKWebViewController
        viewController.url = url
        return viewController
    }
}

// MARK: - UITextFieldDelegate
extension WKWebViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigateToString(textField.text)
        
        return true
    }
}

// MARK: - Helpers
extension WKWebViewController {
    
    private func setupNavbar() {
        addressTextField = UITextField()
        addressTextField.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.975, alpha: 1)
        addressTextField.borderStyle = .roundedRect
        addressTextField.adjustsFontSizeToFitWidth = true
        addressTextField.returnKeyType = .done
        addressTextField.delegate = self
        addressTextField.clearButtonMode = .whileEditing
        addressTextField.autocorrectionType = .no
        addressTextField.autocapitalizationType = .none
        
        NSLayoutConstraint.activate([
            addressTextField.heightAnchor.constraint(equalToConstant: 24)
            ])
        
        // - Go Button
        let goButton = UIButton(type: .system)
        goButton.setImage(UIImage(named: "navbar-go"), for: .normal)
        goButton.addTarget(self, action: #selector(goTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            goButton.widthAnchor.constraint(equalToConstant: 24),
            goButton.heightAnchor.constraint(equalToConstant: 24)
            ])
        
        // - Background and stack view
        let navbarBackground = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
        navbarBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navbarBackground)
        
        self.navbarView = navbarBackground
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0, alpha: 0.1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        navbarBackground.contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: navbarBackground.contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: navbarBackground.contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: navbarBackground.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
            ])
        
        let navbarContainer = UIStackView(arrangedSubviews: [addressTextField, goButton])
        navbarContainer.translatesAutoresizingMaskIntoConstraints = false
        navbarContainer.spacing = 10
        navbarContainer.distribution = .fill
        navbarBackground.contentView.addSubview(navbarContainer)
        
        NSLayoutConstraint.activate([
            navbarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            navbarBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navbarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            navbarContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            navbarContainer.leadingAnchor.constraint(equalTo: navbarBackground.contentView.leadingAnchor, constant: 10),
            navbarContainer.trailingAnchor.constraint(equalTo: navbarBackground.contentView.trailingAnchor, constant: -10),
            navbarContainer.bottomAnchor.constraint(equalTo: navbarBackground.contentView.bottomAnchor, constant: -10)
            ])
    }
    
    private func navigateToString(_ destination: String?) {
        if let text = destination {
            // If navbar contents can be parsed as a URL, load it, otherwise perform a google query
            if let url = URL(string: text) {
                addressTextField.text = url.absoluteString
                loadUrl(url)
            } else {
                var urlComponents = URLComponents()
                urlComponents.scheme = "https"
                urlComponents.host = "google.com"
                urlComponents.path = "/search"
                urlComponents.queryItems = [URLQueryItem(name: "q", value: text)]
                addressTextField.text = text
                loadUrl(urlComponents.url!)
            }
        }
        
        // If text field is focused, unfocus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.addressTextField.isFirstResponder {
                self.addressTextField.resignFirstResponder()
            }
        }
    }
    
    @objc private func goTapped() {
        navigateToString(addressTextField.text)
    }
}
