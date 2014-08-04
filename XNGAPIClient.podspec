Pod::Spec.new do |s|
  s.name = 'XNGAPIClient'
  s.version = '0.2.2'
  s.license = 'MIT'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.7'
  s.summary = 'The official Objective-C client for the XING API'
  s.author  = {
    'XING iOS Team' => 'iphonedev@xing.com'
  }
  s.source = {
    :git => 'https://github.com/xing/XNGAPIClient.git',
    :tag => s.version.to_s
  }
  s.requires_arc = true
  s.homepage = 'https://www.xing.com'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files = 'XNGAPIClient/*.{h,m}'
    sp.dependency   'XNGOAuth1Client', '~> 0.0.2'
    sp.frameworks = 'Security'
  end

  s.subspec 'NSDictionary-Typecheck' do |sp|
    sp.source_files = 'XNGAPIClient/NSDictionary+Typecheck.{h,m}'
  end
end
