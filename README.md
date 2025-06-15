# Chirp

A Twitter clone built with Elixir and the Phoenix Framework.

## Features

- User authentication with email/password
- Social login with Google and GitHub OAuth
- User registration and login
- Password reset functionality
- User settings management

## Setup

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Configure OAuth providers (see OAuth Setup section below)
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### OAuth Setup

To enable Google and GitHub login, you need to set up OAuth applications and configure environment variables.

#### Google OAuth Setup

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client IDs"
5. Set the application type to "Web application"
6. Add `http://localhost:4000/auth/google/callback` to authorized redirect URIs
7. Copy the Client ID and Client Secret

#### GitHub OAuth Setup

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in the application details:
   - Application name: `Chirp`
   - Homepage URL: `http://localhost:4000`
   - Authorization callback URL: `http://localhost:4000/auth/github/callback`
4. Copy the Client ID and Client Secret

#### Environment Variables

Set the following environment variables:

```bash
export GOOGLE_CLIENT_ID="your-google-client-id"
export GOOGLE_CLIENT_SECRET="your-google-client-secret"
export GITHUB_CLIENT_ID="your-github-client-id"
export GITHUB_CLIENT_SECRET="your-github-client-secret"
```

Or create a `.env` file in the project root (make sure to add it to `.gitignore`):

```
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
```

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
