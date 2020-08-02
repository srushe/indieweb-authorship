lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "indieweb/authorship/version"

Gem::Specification.new do |spec|
  spec.name          = "indieweb-authorship"
  spec.version       = Indieweb::Authorship::VERSION
  spec.authors       = ["Stephen Rushe"]
  spec.email         = ["steve+authorship@deeden.co.uk"]

  spec.summary       = 'Identify the author of an IndieWeb post'
  spec.description   = 'Identify the author of an IndieWeb post using the Authorship algorithm'
  spec.homepage      = "https://code.deeden.co.uk/indieweb-authorship"
  spec.license       = "MIT"

  spec.metadata = {
    'bug_tracker_uri' => 'https://code.deeden.co.uk/indieweb-authorship/issues',
    'changelog_uri'   => 'https://code.deeden.co.uk/indieweb-authorship/changelog',
    'homepage_uri'    => 'https://code.deeden.co.uk/indieweb-authorship/'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "microformats", "~> 4.0", ">= 4.1.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
