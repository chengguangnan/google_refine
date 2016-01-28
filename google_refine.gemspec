require 'pathname'

Gem::Specification.new do |s|
  s.name        = 'google_refine'
  s.version     = '0.6'
  s.summary     = 'Upload to Google Refine.'
  s.description = 'Ruby library and command line executables for uploading tab files into Google Refine (v2.0 and v2.5).'
  s.authors     = 'Cheng Guangnan'
  s.email       = 'chengguangnan@gmail.com'
  s.homepage    = 'https://github.com/chengguangnan/google_refine'
  s.files       = ['lib/google_refine.rb']

  s.add_dependency 'rest-client'
  s.add_dependency 'trollop'

  s.executables = Pathname.glob('bin/*').map { |p| p.basename.to_s }
end
