# Contributing to wg-2-warp

Thank you for considering contributing to wg-2-warp! This document provides guidelines for contributing to the project.

## Ways to Contribute

**Report bugs:**
- Search existing issues first
- Include OS version, Docker version, and error logs
- Provide steps to reproduce

**Suggest enhancements:**
- Explain the use case
- Describe the expected behavior
- Consider backward compatibility

**Submit code:**
- Fork the repository
- Create a feature branch
- Test your changes thoroughly
- Submit a pull request

**Improve documentation:**
- Fix typos and unclear sections
- Add examples and troubleshooting tips
- Translate to other languages

## Development Setup

### Prerequisites

- Linux system (Ubuntu 22.04+ recommended)
- Docker and Docker Compose
- git
- Text editor

### Getting Started

```bash
# Fork and clone
git clone https://github.com/eric0e/wg-2-warp.git
cd wg-2-warp

# Create feature branch
git checkout -b feature/my-feature

# Make changes and test
docker compose build --no-cache
docker compose up -d

# Check logs
docker compose logs
```

## Testing Guidelines

**Before submitting a pull request:**

1. **Build successfully:**
   ```bash
   docker compose build --no-cache
   ```

2. **Start without errors:**
   ```bash
   docker compose up -d
   docker compose ps
   ```

3. **Verify health checks pass:**
   ```bash
   docker ps
   ```
   Both containers should show "healthy" status.

4. **Test basic functionality:**
   - WARP connects and shows 104.x.x.x IP
   - WireGuard starts and creates wg1 interface
   - Routing table 200 is configured
   - Client can connect and traffic routes through WARP

5. **Check for errors:**
   ```bash
   docker compose logs | grep -i error
   docker compose logs | grep -i fail
   ```

## Code Style

**Shell scripts:**
- Use 4 spaces for indentation
- Add comments for complex logic
- Use meaningful variable names
- Include error checking with `set -e` where appropriate

**Docker files:**
- Use official base images
- Minimize layers where possible
- Add comments for non-obvious commands
- Pin versions for reproducibility

**Documentation:**
- Use Markdown format
- Keep line length under 100 characters
- Use code blocks with language specification
- Include examples where helpful

## Pull Request Process

1. **Update documentation:**
   - Update README.md if behavior changes
   - Add entries to troubleshooting if needed
   - Update configuration examples

2. **Describe your changes:**
   - Clear title summarizing the change
   - Detailed description of what and why
   - Reference related issues

3. **Testing evidence:**
   - Show that it builds successfully
   - Include relevant log output
   - Describe testing performed

4. **Keep commits clean:**
   - One logical change per commit
   - Clear commit messages
   - Squash trivial commits

## Reporting Bugs

**Good bug reports include:**

- **System information:**
  - OS and version (e.g., Ubuntu 24.04)
  - Docker version (`docker --version`)
  - Docker Compose version (`docker compose version`)
  - Kernel version (`uname -r`)

- **Steps to reproduce:**
  1. Specific commands run
  2. Configuration used
  3. What happened vs. what was expected

- **Error output:**
  ```bash
  docker compose logs
  ```
  Include relevant portions, not just last line.

- **Configuration files:**
  - Sanitize private keys and IP addresses
  - Include docker-compose.yml if modified
  - Include relevant portions of wg1.conf

## Feature Requests

**Good feature requests include:**

- **Use case:** Why is this needed?
- **Expected behavior:** What should happen?
- **Alternatives considered:** What other solutions exist?
- **Impact:** Who would benefit from this?

## Testing on Different Platforms

If you test on a platform not listed in README.md, please report results:

**Working platforms:**
- OS and version
- Docker version
- Any special configuration needed

**Non-working platforms:**
- OS and version
- Error messages
- What was attempted

## Communication

**Be respectful:**
- Assume good intentions
- Be patient with response times
- Stay on topic

**Be clear:**
- Use precise language
- Provide examples
- Ask for clarification when needed

**Be helpful:**
- Link to related issues
- Share workarounds
- Help others troubleshoot

## Areas Needing Help

**High priority:**
- Testing on different Linux distributions
- Testing on various VPS providers
- Documentation improvements
- Troubleshooting guide expansion

**Future enhancements:**
- ARM64/ARM support
- IPv6 improvements
- Automated testing
- Configuration validation scripts
- Health monitoring improvements

## Questions?

If you have questions about contributing:
1. Check existing documentation
2. Search closed issues
3. Open a new issue with the "question" label

Thank you for contributing to wg-2-warp!
