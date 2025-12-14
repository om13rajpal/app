# aiSeaSafe

A Flutter application with OpenAI Real-Time voice assistant integration.

## Getting Started

### Prerequisites

- Flutter SDK (>=3.8.1)
- An OpenAI API key with Real-Time API access

### Environment Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your OpenAI API key:
   ```
   OPENAI_API_KEY=sk-your-actual-api-key-here
   ```

3. Get your API key from: https://platform.openai.com/api-keys

### Installation

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Security Notes

- Never commit your `.env` file to version control
- The `.env` file is already in `.gitignore`
- Only `.env.example` (without real keys) should be committed
- If you accidentally expose an API key, revoke it immediately at https://platform.openai.com/api-keys

## Features

- Real-time voice conversations with OpenAI GPT-4o
- Server-side Voice Activity Detection (VAD)
- Low-latency audio streaming

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [OpenAI Real-Time API](https://platform.openai.com/docs/api-reference/realtime)
