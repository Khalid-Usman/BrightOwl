# Uncomment this line to define a global platform for your project
platform :ios, ‘9.0’
# Uncomment this line if you're using Swift
use_frameworks!

target 'BrightOwl' do
    
pod 'ABSteppedProgressBar'
pod 'SVProgressHUD'
pod 'NVActivityIndicatorView'
pod "Koloda"
pod 'Alamofire', '~> 3.1.2'
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'

end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`

end

