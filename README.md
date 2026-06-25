# Pawn Coding Agent

This repository contains the "pawn-development" skill used by a coding assistant to safely edit and review Pawn scripts for open.mp / SA-MP projects. It provides:

- workflow guidance and agent instructions
- concise reference docs for Pawn language and open.mp APIs
- a small helper script to run a local compile check

<div align="center">

If you like this project, consider supporting us!

[![PayPal](https://img.shields.io/badge/paypal-One%20Time%20Donation-003087?style=flat&logo=paypal)](https://paypal.me/MichaelAceAnderson)
[![Patreon](https://img.shields.io/badge/patreon-Subscription-FF424D?style=flat&logo=patreon)](https://www.patreon.com/posts/san-andreas-open-153811828)

</div>

## Contents

- [.github/copilot-instructions.md](.github/copilot-instructions.md) — agent behavior and workflow
- [.github/skills/pawn-development/SKILL.md](.github/skills/pawn-development/SKILL.md) — skill manifest and rules
- [.github/skills/pawn-development/references/](.github/skills/pawn-development/references/) — language, API, style, and common-bugs guides
- [.github/skills/pawn-development/scripts/compile_check.sh](.github/skills/pawn-development/scripts/compile_check.sh) — helper to validate .pwn files with `pawncc`

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE).
