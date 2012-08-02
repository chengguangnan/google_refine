require 'pathname'

Gem::Specification.new do |s|
  s.name        = 'google_refine'
  s.version     = '0.2.' + Time.now.to_i.to_s
  s.summary     = 'Upload to Google Refine.'
  s.description = 'Ruby library and command line executables for uploading tab files into Google Refine (v2.0 and v2.5).'
  s.authors     = 'Cheng Guang-Nan'
  s.email       = 'me@chengguangnan.com'
  s.homepage    = 'https://github.com/guangnan/google_refine'
  s.files       = ['lib/google_refine.rb']

  s.add_dependency 'rest-client'
  s.add_dependency 'trollop'

  s.executables = Pathname.glob('bin/*').map { |p| p.basename.to_s }
end
