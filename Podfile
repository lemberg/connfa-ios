platform :ios, '10.3'

use_frameworks!
workspace 'Connfa.xcworkspace'

def import_public_pods
  pod 'SwiftDate'
  pod 'AlamofireImage', '~> 3.3'  
  pod 'SwiftyJSON'  
  pod 'OHHTTPStubs/Swift'
end

target 'Connfa' do
  project 'Connfa.xcodeproj'
  import_public_pods  
  pod 'SVProgressHUD'   
  pod 'TwitterKit'
  pod 'SwiftDate'  
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/DynamicLinks'
  target 'ConnfaTests' do
        inherit! :search_paths
	pod 'Firebase'
   end
end


=begin
target 'ConnfaCore' do
  project 'ConnfaCore/ConnfaCore.xcodeproj'
  import_public_pods
  pod 'Alamofire', '~> 4.5'   
end
=end
