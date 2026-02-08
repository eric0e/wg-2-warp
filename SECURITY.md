# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

**DO NOT open a public issue for security vulnerabilities.**

To report a security vulnerability:

1. **Email:** Send details to the repository owner's email (check GitHub profile)
2. **Include:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if you have one)

3. **Response time:** 
   - Acknowledgment within 48 hours
   - Initial assessment within 7 days
   - Resolution timeline depends on severity

## Security Considerations

**This project handles:**
- WireGuard private keys (stored in `wireguard/wg1.conf`)
- WARP registration data (stored in `warp-data/`)
- Network traffic routing

**Best practices:**

1. **Protect configuration files:**
   - Never commit `wireguard/wg1.conf` with real keys
   - Add to `.gitignore` (already configured)
   - Set proper file permissions: `chmod 600 wireguard/wg1.conf`

2. **Secure your VPS:**
   - Use SSH key authentication
   - Keep system packages updated
   - Configure firewall properly
   - Monitor logs regularly

3. **Network security:**
   - Only open required ports (UDP 51822 for WireGuard)
   - Use strong WireGuard keys
   - Regularly rotate keys if needed
   - Monitor for unauthorized access attempts

4. **Container security:**
   - Keep Docker updated
   - Regularly rebuild images: `docker compose build --no-cache`
   - Review logs: `docker compose logs`
   - Monitor container resource usage

5. **Data persistence:**
   - `warp-data/` contains WARP registration
   - `wireguard/` contains WireGuard configuration
   - Back up these directories securely
   - Never share registration or key files

## Known Security Limitations

1. **Free WARP service:**
   - Uses shared Cloudflare infrastructure
   - No guaranteed anonymity
   - Traffic visible to Cloudflare
   - Subject to Cloudflare's terms of service

2. **Container privileges:**
   - Requires `NET_ADMIN` capability
   - Runs in privileged mode
   - Necessary for network configuration
   - Limit access to trusted users

3. **Log data:**
   - Containers log IP addresses
   - Logs may contain sensitive data
   - Review before sharing logs publicly
   - Sanitize logs when reporting issues

## Updates and Patches

Security updates will be:
- Released as soon as possible
- Announced in GitHub releases
- Documented in CHANGELOG.md
- Tagged with severity level

**To update:**
```bash
git pull
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Disclosure Policy

After a security issue is fixed:
1. A new version will be released
2. A security advisory will be published
3. Credit given to reporter (if desired)
4. Details disclosed after users have time to update

## Contact

For security concerns, contact the repository owner through GitHub.

For general issues, use GitHub Issues (but NOT for security vulnerabilities).
