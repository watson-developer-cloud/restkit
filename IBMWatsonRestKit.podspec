Pod::Spec.new do |s|

  s.name                  = 'IBMWatsonRestKit'
  s.version               = '1.3.0'
  s.summary               = 'Networking layer for the IBM Watson Swift SDK'
  s.license               = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.homepage              = 'https://www.ibm.com/watson/'
  s.authors               = { 'Anthony Oliveri' => 'oliveri@us.ibm.com',
                              'Mike Kistler'    => 'mkistler@us.ibm.com' }

  s.module_name           = 'RestKit'
  s.ios.deployment_target = '8.0'
  s.source                = { :git => 'https://github.com/watson-developer-cloud/restkit.git', :tag => s.version.to_s }
  
  s.source_files          = 'Sources/**/*.swift'
  s.swift_version         = '4.1'
  
end
