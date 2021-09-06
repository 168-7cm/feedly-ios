# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

plugin 'cocoapods-pod-linkage'

target 'feedly' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for feedly
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'R.swift'
  pod 'Google-Mobile-Ads-SDK'

  # Firebase
  pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '8.1.0'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'FirebaseFirestoreSwift', '8.2.0-beta'
  pod 'Firebase/Storage'
  
  target 'feedlyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'feedlyUITests' do
    # Pods for testing
  end

end
