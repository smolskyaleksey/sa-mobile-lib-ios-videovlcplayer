# run `pod lib lint SAVideoVLCPlayer.podspec --allow-warnings --use-libraries'

Pod::Spec.new do |s|
  s.name             = "SAVideoVLCPlayer"
  s.version          = "1.0.2"
  s.summary          = "Alternative SAVideoPlayer using VLC"
  s.description      = <<-DESC
 		       Experimental SAVideoPlayer that can replace the normal video player, but instead of using AVPlayer as base, it uses VLC player
                       DESC

  s.homepage         = "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-videovlcplayer"
  s.license          = { :type => "Apache License", :file => "LICENSE" }
  s.author           = { "Gabriel Coman" => "gabriel.coman@superawesome.tv" }
  s.source           = { :git => "https://github.com/SuperAwesomeLTD/sa-mobile-lib-ios-videovlcplayer.git", :tag => "1.0.2" }
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SAVideoVLCPlayer' => ['Pod/Assets/*.png']
  }
  s.dependency 'SAUtils'
  s.dependency 'MobileVLCKit'
end
