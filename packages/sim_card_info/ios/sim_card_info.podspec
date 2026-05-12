Pod::Spec.new do |s|
  s.name             = 'sim_card_info'
  s.version          = '1.0.2'
  s.summary          = 'SIM card information plugin.'
  s.description      = <<-DESC
Flutter plugin for SIM card information. iOS returns an unsupported error because
iOS does not expose SIM phone-number details to third-party apps.
                       DESC
  s.homepage         = 'https://github.com/FadyFouad/sim_card_info'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fady Fouad' => 'FadyFouad@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
end
