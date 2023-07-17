# frozen_string_literal: true

require File.expand_path("lib/voicemeeter/version", __dir__)

Gem::Specification.new do |spec|
  spec.name = "voicemeeter"
  spec.version = Voicemeeter::Version
  spec.summary = "Voicemeeter API wrapper for Ruby"
  spec.description = "A Ruby wrapper around Voicemeeter Remote API"
  spec.authors = ["onyx_online"]
  spec.email = "code@onyxandiris.online"
  spec.files = Dir["lib/**/*.rb"]
  spec.extra_rdoc_files = Dir["README.md", "CHANGELOG.md", "LICENSE"]
  spec.homepage = "https://rubygems.org/gems/voicemeeter"
  spec.license = "MIT"
  spec.add_runtime_dependency "ffi", "~> 1.9", ">= 1.9.10"
  spec.add_development_dependency "standard", "~> 1.30"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.18"
  spec.required_ruby_version = ">= 3.2"
  spec.metadata = {
    "source_code_uri" => "https://github.com/onyx-and-iris/voicemeeter-rb.git"
  }
end
