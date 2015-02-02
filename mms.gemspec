require File.expand_path('../lib/mms/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'mms-api'
  s.version     = MMS::VERSION
  s.summary     = 'MongoDB MMS API client'
  s.description = 'Agent for MMS API'
  s.authors     = ['Cargo Media', 'kris-lab', 'tomaszdurka']
  s.email       = 'hello@cargomedia.ch'
  s.files       = Dir['LICENSE*', 'README*', '{bin,lib}/**/*']
  s.executables = ['mms-api']
  s.homepage    = 'https://github.com/cargomedia/mms-api'
  s.license     = 'MIT'

  s.add_runtime_dependency 'net-http-digest_auth', '~> 1.4'
  s.add_runtime_dependency 'terminal-table', '~> 1.4.5'
  s.add_runtime_dependency 'parseconfig', '~> 1.0.6'
  s.add_runtime_dependency 'clamp', '~> 0.6.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.0'
end
