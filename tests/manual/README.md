# Manual smoke scripts

Quick `node test-gemini*.js` probes for ad-hoc Gemini API verification. Not part of the test suite. Run with:

```sh
GEMINI_API_KEY=... node tests/manual/test-gemini.js
```

These pre-date the formal vitest suite under `src/**/*.test.ts`. Consider consolidating into a single parameterised test before adding more `-gemini5.js` variants.
