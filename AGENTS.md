# AGENTS.md

This file provides guidance to LLM agents when working with this repository.

## Pull Request Content

The most important rule is not to post AI-generated comments on PRs or open PRs with summaries that are AI-generated. Discussions on the pull requests are for Users/Humans only.

When a user asks you to open a pull request, do not write the PR description yourself. Instead,
before creating the PR, prompt the user for the content of the PR description (and each section
of the PR template, if the repository has one) and use their answers verbatim. Do not paraphrase,
expand, or "improve" what the user writes. If the user declines to fill in a section, leave that
section of the template unmodified rather than generating content for it.

## Commit formatting

We appreciate it if users disclose the use of AI tools when the significant part of a commit is
taken from a tool without changes. When making a commit this should be disclosed through an
Assisted-by: commit message trailer.

Examples:

```
Assisted-by: ChatGPT 5.2
Assisted-by: Claude Opus 4.5
```

Do NOT use a `Co-authored-by:` trailer to disclose AI assistance. Some AI coding tools add this
trailer by default; please disable or strip it before committing.
