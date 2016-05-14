# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kumogata2/plugin/ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'kumogata2-plugin-ruby'
  spec.version       = Kumogata2::Plugin::Ruby::VERSION
  spec.authors       = ['winebarrel']
  spec.email         = ['sgwr_dts@yahoo.co.jp']

  spec.summary       = %q{Kumogata2 ruby plugin.}
  spec.description   = %q{Kumogata2 ruby plugin.}
  spec.homepage      = 'https://github.com/winebarrel/kumogata2-plugin-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'kumogata2'
  spec.add_dependency 'dslh', '>= 0.3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
