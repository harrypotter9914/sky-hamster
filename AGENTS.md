# Project workflow

For each user-requested game change, complete an appropriate check, update source/pdxinfo (version and increasing buildNumber), document the change in CHANGELOG.md, commit, tag, and publish a GitHub release with a compiled .pdx ZIP to this project's origin. The user has explicitly authorized this workflow.

Use patch versions (for example 0.4.1, 0.4.2) for fixes, tuning, and small UI or tutorial changes. Use a minor version (for example 0.5.0) for substantial new features or mechanics. Choose based on scope; do not promote every change to a new minor version. Preserve published tags and releases. State validation limits accurately.
