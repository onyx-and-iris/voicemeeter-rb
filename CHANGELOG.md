# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Before any major/minor/patch is released all unit tests will be run to verify they pass.

## [Unreleased] - These changes have not been added to RubyGems yet

- [ ]

## [1.0.0] - 2023-09-01

### Added

- Bindings and abstraction classes are implemented
- An event system:
  - `pdirty`: parameter updates on the main Voicemeeter GUI
  - `mdirty`: macrobutton updates
  - `midi`: incoming data from a connected midi device
  - `ldirty`: channel level updates
- An entry point for fetching a Remote class for each kind of Voicemeeter (basic, banana, potato)
- Logging system for reading messages sent by getters and setters.
- Strip class refinement in util.rb. It's scope should be limited to the CBindings module.
- rbs type signatures but some of them need updating.
- example user profile configs included with repo.
