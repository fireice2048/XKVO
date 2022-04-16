Pod::Spec.new do |s|
  s.name             = 'XKVO'
  s.version          = '2.0.1'
  s.license      = { :type => "Copyright", :text => "Copyright © 2021. All rights reserved." }
  s.summary  = 'XKVO for iOS'
  s.homepage = 'https://gitee.com/fireice2048/xkvo'
  s.description = 'XKVO'
  s.author           = { 'medie' => 'medie@163.com' }
  s.source           = { :git => 'https://gitee.com/fireice2048/xkvo.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = ['XKVO/*']

  
end
