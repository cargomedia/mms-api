require File.expand_path('../lib/mms/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'mms-api'
  s.version     = MMS::VERSION
  s.summary     = 'MongoDB MMS API client'
  s.description = 'Agent to collect data for MMS API'
  s.authors     = ['Cargo Media', 'kris-lab', 'tomaszdurka']
  s.email       = 'hello@cargomedia.ch'
  s.files       = Dir['LICENSE*', 'README*', '{bin,lib,data}/**/*']
  s.executables = ['mms-api']
  s.homepage    = 'https://github.com/cargomedia/mms'
  s.license     = 'MIT'

  s.add_development_dependency 'net-http-digest_auth'
  s.add_development_dependency 'terminal-table'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.0'
end
