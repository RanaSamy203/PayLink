# PayLink design pack: Person 3 (Architecture & Data Design)

| File | Diagram | Brief reference |
|---|---|---|
| `use-case.mmd` | Use Case diagram (one use case per user story US-01..US-28) | Section 3.2 (FR-1 to FR-28) |
| `domain-class.mmd` | Domain Class diagram | Sections 2.3, 2.5, 3.1 |
| `er-diagram.mmd` | ER diagram (29 tables; `CHECK:` = allowed values) | Section 3.4: at least 10 tables |

To render these files, run `mmdc -i use-case.mmd -o use-case.png -s 3` (Mermaid CLI), or paste them into mermaid.live. The diagrams use the ELK layout. The `.png` files next to each source are exported from it; after editing a `.mmd` file, export its PNG again. The design decisions are in Section 7.4 of the SRS.

## Checklist for reviewing Person 4's diagrams
- [ ] The state diagram has exactly these states: Initiated, FundsHeld, SentToBiller, Completed, Failed, Unknown, Rejected, Refunded. Final states: Completed, Rejected, Refunded.
- [ ] There is **no** Unknown → Refunded transition, and no automatic refund from Unknown.
- [ ] The "Pay a bill" sequence follows the 9 steps in section 2.2, in order: limits → inquiry → fee → fraud → hold → biller → confirm → receipt. Reconciliation can be a separate note.
- [ ] The sequence diagrams use the class names from `domain-class.mmd` (`Payment`, `Wallet`, `Hold`, `LedgerEntry`, `FeeRule`, `Notification`, `BillerCall`, `BillerCallback`).
- [ ] The "Pay a bill" sequence shows the idempotency check before anything else and the 10-second timeout → Unknown branch.
- [ ] The "Refund a failed payment" sequence goes Failed → release hold (ledger HELD −, AVAILABLE +) → Refunded → notification → audit log.
- [ ] Every money movement in the sequences writes an `AuditLog` (FR-25).

## Prompt log
These diagrams were drafted with Claude (Opus 5.5). Before adding an entry to `/docs/prompt-log.md`, review each diagram yourself and record what you changed and why. The brief grades your judgement of the AI output, so the verdict column must be your own.
