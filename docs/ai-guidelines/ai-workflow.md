# AI Workflow

1. Inspect `git status`, relevant files, package/lint configuration, routes, providers, shared widgets, assets, and tests.
2. Find an existing feature/component/provider/repository pattern and trace the affected data flow.
3. Convert the request into acceptance criteria and plan the smallest complete change.
4. Implement in the established feature/layer, reusing tokens, navigation, motion, and UI-state primitives.
5. Review architecture, theme variants, accessibility, error handling, security, performance, and user modifications.
6. Run only relevant validation, beginning with format/analyze/tests and adding profile/build checks when justified.
7. Inspect the diff and report exact changes, executed commands/results, assumptions, gaps, and follow-ups.

When requirements are ambiguous, choose the narrowest reversible interpretation and state it. If the missing choice changes the API, security model, navigation contract, or data ownership, ask before implementing it. If the backend contract is absent, preserve the repository seam and label mock/proposed work rather than inventing endpoints. If files contain existing user changes, preserve them and avoid overlapping edits; do not reset or overwrite. If a change could affect unrelated features, add regression coverage or stop and explain the impact.
