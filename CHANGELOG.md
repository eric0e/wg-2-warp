# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial public release
- MIT License
- Comprehensive README.md documentation
- CONTRIBUTING.md guidelines
- Example WireGuard configuration file
- .gitignore for proper version control

### Changed
- Converted documentation to Markdown format
- Renamed wg1.conf to wg1.conf.example

### Security
- Fail-secure iptables rules to prevent traffic bypass
- TCPMSS clamping to prevent connection hangs

## [0.1.0] - 2026-02-08

### Added
- Two-container architecture (WireGuard + WARP)
- Policy-based routing through custom routing tables
- Health checks for both containers
- Persistent storage for WARP registration
- Persistent storage for WireGuard configuration
- Support for debian:trixie-slim base image
- Entrypoint scripts for both containers
- Docker Compose orchestration

### Notes
- Initial development version
- Tested on Ubuntu 22.04 and 24.04
- x86_64 architecture only
