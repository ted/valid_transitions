require_relative 'lib/valid_transitions/version'

Gem::Specification.new do |spec|
  spec.name          = "valid_transitions"
  spec.version       = ValidTransitions::VERSION
  spec.authors       = ["ted"]
  spec.email         = ["tedmaloney@me.com"]

  spec.summary       = %q{Adds valid transition validations to AR.}
  spec.homepage      = "https://github.com/ted/valid_transitions"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.add_runtime_dependency "activerecord", ">= 3.0.0"
  spec.add_runtime_dependency "activesupport", ">= 3.0.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
