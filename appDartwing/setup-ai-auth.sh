#!/bin/bash

echo "========================================="
echo "OpenAI & Claude Authentication Setup for DevContainer"
echo "========================================="

echo "This script helps you set up OpenAI and Claude authentication that will be"
echo "automatically available in your devcontainer."
echo ""

echo "1. Set your OpenAI credentials in the host environment:"
echo "   export OPENAI_API_KEY='your-api-key-here'"
echo "   export OPENAI_AUTH_TOKEN='your-auth-token-here'"
echo "   export OPENAI_SESSION_TOKEN='your-session-token-here'"
echo ""

echo "2. Set your Claude/Anthropic credentials in the host environment:"
echo "   export ANTHROPIC_API_KEY='your-anthropic-key-here'"
echo "   export CLAUDE_CODE_API_KEY='your-claude-key-here'"
echo "   export CLAUDE_CODE_AUTH_TOKEN='your-claude-auth-token-here'"
echo "   export CLAUDE_CODE_SESSION_TOKEN='your-claude-session-token-here'"
echo ""

echo "3. Or add them to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
echo "   echo 'export OPENAI_API_KEY=\"your-openai-key\"' >> ~/.bashrc"
echo "   echo 'export ANTHROPIC_API_KEY=\"your-anthropic-key\"' >> ~/.bashrc"
echo "   echo 'export CLAUDE_CODE_API_KEY=\"your-claude-key\"' >> ~/.bashrc"
echo ""

echo "4. For browser-based login authentication:"
echo "   - Login to OpenAI/ChatGPT in your browser on the host"
echo "   - Login to Claude/Anthropic services in your browser on the host"
echo "   - The container will mount browser profile directories"
echo "   - Authentication should persist across container rebuilds"
echo ""

echo "5. Test the setup:"
echo "   docker exec <container-name> env | grep -E '(OPENAI|CLAUDE|ANTHROPIC)'"
echo ""

echo "Note: Never commit API keys to git. Keep them in your local environment only."
