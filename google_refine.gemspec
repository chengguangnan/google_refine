require 'pathname'

Gem::Specification.new do |s|
  s.name        = 'google_refine'
  s.version     = '0.1'
  s.summary     = 'Upload files to refine using command line or programmtically.'
  s.authors     = 'Cheng Guang-Nan'
  s.email       = 'guangnan@chengguangnan.com'
  s.homepage    = 'https://github.com/guangnan/google_refine'
  s.files       = ['lib/google_refine.rb']

  s.add_dependency 'rest-client'
  s.add_dependency 'trollop'

  s.executables = Pathname.glob('bin/*').map { |p| p.basename.to_s }
end
