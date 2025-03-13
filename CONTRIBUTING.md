# Contributing to Z+ Password Manager

Thank you for your interest in contributing to Z+ Password Manager! This document provides guidelines for contributing while maintaining the security of the application.

## Security First

1. **Never commit sensitive information**:
   - API keys
   - Firebase configuration
   - Certificates or keystores
   - User data or passwords
   - Environment files
   - Debug logs containing sensitive information

2. **Code Security Guidelines**:
   - Use strong encryption (AES-256) for all sensitive data
   - Implement proper error handling without exposing sensitive details
   - Never log sensitive information
   - Use cryptographically secure random number generation
   - Follow secure coding practices
   - Keep dependencies updated

3. **Testing**:
   - Write security-focused tests
   - Test encryption/decryption functionality
   - Test authentication flows
   - Verify data sanitization
   - Check for memory leaks of sensitive data

## Development Setup

1. Fork the repository
2. Create a new branch for your feature
3. Copy example configuration files and add your own API keys (not in version control)
4. Follow the README.md setup instructions

## Pull Request Process

1. Update documentation if needed
2. Add tests for new functionality
3. Ensure all tests pass
4. Update the README.md if needed
5. Verify no sensitive information is included

## Code Review Guidelines

When reviewing code, pay special attention to:

1. Security implications
2. Proper encryption usage
3. Secure data handling
4. Authentication and authorization
5. Input validation
6. Error handling
7. Dependency security

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT open a public issue**
2. Email me at areebkashaf7350@gmail.com
3. Include detailed information about the vulnerability
4. Wait for a response before disclosing publicly

## Development Best Practices

1. **Local Storage**:
   - Use Flutter Secure Storage for sensitive data
   - Never store unencrypted sensitive data
   - Clear sensitive data when logging out

2. **Network Security**:
   - Use HTTPS for all network communications
   - Implement certificate pinning
   - Validate all server responses
   - Handle network errors securely

3. **Authentication**:
   - Implement proper session management
   - Use secure token storage
   - Implement proper logout functionality
   - Handle authentication errors properly

4. **Data Handling**:
   - Encrypt all sensitive data before storage
   - Implement secure key management
   - Clear sensitive data from memory when not needed
   - Implement proper data backup/restore functionality

## Questions?

If you have questions about security practices or implementation details, please reach out to the maintainers before implementing security-critical features. 