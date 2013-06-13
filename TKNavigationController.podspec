Pod::Spec.new do |s|
  s.name         = "TKNavigationController"
  s.version      = "0.1"
  s.summary      = "UIViewController subclass that can show bottom view controller with swipe up animation."
  s.homepage     = "http://github.com/mapedd/TKNavigationController"
  s.license      = 'Apache'
  s.author       = { "Tomek Kuzma" => "mapedd@mapedd.com" }
  s.source       = { :git => "https://github.com/mapedd/TKNavigationController.git", :tag => "0.1" }
  s.platform     = :ios
  s.source_files = 'TKNavigationController.{h,m}'
  s.requires_arc = true
end
