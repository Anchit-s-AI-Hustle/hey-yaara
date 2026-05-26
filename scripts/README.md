# scripts/

Vercel + environment setup helpers. Run individually as needed:

| Script | Purpose |
|---|---|
| `set-env-vercel.sh` | Push the canonical `.env` vars into the Vercel project |
| `setup-groq-vercel.sh` | One-time Groq key wiring (uses `vercel env add`) |
| `setup-vercel-agent.sh` | Provision the wake-word agent function |

These should eventually consolidate into one `setup-vercel.sh <subcommand>` runner.
