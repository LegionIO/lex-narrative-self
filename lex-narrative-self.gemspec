# frozen_string_literal: true

require_relative 'lib/legion/extensions/narrative_self/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-narrative-self'
  spec.version       = Legion::Extensions::NarrativeSelf::VERSION
  spec.authors       = ['Matthew Iverson']
  spec.email         = ['matt@iverson.io']

  spec.summary       = 'Autobiographical narrative and self-concept for LegionIO'
  spec.description   = 'Models autonoetic consciousness — maintains an autobiographical narrative of ' \
                       'episodes, narrative threads, and an evolving self-concept that emerges from ' \
                       'the pattern of lived experience.'
  spec.homepage      = 'https://github.com/LegionIO/lex-narrative-self'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.files         = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.add_development_dependency 'legion-gaia'
end
