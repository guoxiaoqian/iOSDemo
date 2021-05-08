platform :ios, '9.0'
use_frameworks!

#source 'git@github.com:guoxiaoqian/SpecsRepo.git'

flutter_application_path = './my_flutter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'Demo' do
	#pod 'TTT', '1.0.3'
	pod 'WeexSDK'
  pod 'LookinServer'
#  pod 'Protobuf'
#  install_all_flutter_pods(flutter_application_path)
#  pod 'Protobuf-C++'
end

target 'SwiftUITest' do
  pod 'LookinServer'
end
