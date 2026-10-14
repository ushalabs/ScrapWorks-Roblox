# Publishing release archives on GitHub

The package ZIP files are *prepared release assets*, not published GitHub Releases.

1. Create a GitHub repository (or tell the assistant its existing owner/name).
2. Upload this repository source tree to the default branch.
3. In GitHub, open Releases → Draft a new release.
4. Choose the tag and release title from `docs/RELEASE_NOTES.md`.
5. Attach the matching ZIP file and paste the relevant notes.
6. Repeat for v0.1.0, v0.2.0 and v0.3.0. You can mark v0.3.5 as a pre-release until playtested.

Tags and release asset files are separate from chronological git commits. For accurate source history, create a commit for each tested phase when you upload the historical versions.
