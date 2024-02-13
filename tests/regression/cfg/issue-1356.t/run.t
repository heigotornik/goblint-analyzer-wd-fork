  $ cfgDot issue-1356.c

  $ graph-easy --as=boxart minus.dot
  
    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                                                  │
    │                                                                     ┌─────────────────────────────────────────┐  │
    │                                                                     │ minus()                                 │  │
    │                                                                     └─────────────────────────────────────────┘  │
    │                                                                       │                                          │
    │ Pos((long )a >= (long )b - 2147483648)                                │ (body)                                   │
    ▼                                                                       ▼                                          │
  ┌─────────────────────────────────────────┐                             ┌─────────────────────────────────────────┐  │
  │ issue-1356.c:9:3-9:53 (synthetic)       │  Pos(b <= 0)                │ issue-1356.c:9:3-9:53 (synthetic)       │  │
  │ (issue-1356.c:9:3-9:53 (synthetic))     │ ◀────────────────────────── │ (issue-1356.c:9:3-9:53 (synthetic))     │  │
  └─────────────────────────────────────────┘                             └─────────────────────────────────────────┘  │
    │                                                                       │                                          │
    │                                                                       │ Neg(b <= 0)                              │
    │                                                                       ▼                                          │
    │                                                                     ┌─────────────────────────────────────────┐  │
    │                                                                     │ issue-1356.c:9:3-9:53                   │  │
    │                                                                     │ (issue-1356.c:9:3-9:53)                 │ ─┘
    │                                                                     └─────────────────────────────────────────┘
    │                                                                       │
    │                                                                       │ Neg((long )a >= (long )b - 2147483648)
    │                                                                       ▼
    │                                                                     ┌─────────────────────────────────────────┐
    │                                                                     │ issue-1356.c:9:3-9:53 (synthetic)       │
    │                                                                     │ (issue-1356.c:9:3-9:53 (synthetic))     │
    │                                                                     └─────────────────────────────────────────┘
    │                                                                       │
    │                                                                       │ tmp = 0
    │                                                                       ▼
    │                                                                     ┌─────────────────────────────────────────┐
    │                                         tmp = 1                     │ issue-1356.c:9:3-9:53 (synthetic)       │
    └───────────────────────────────────────────────────────────────────▶ │ (issue-1356.c:9:3-9:53 (synthetic))     │
                                                                          └─────────────────────────────────────────┘
                                                                            │
                                                                            │ assume_abort_if_not(tmp)
                                                                            ▼
                                                                          ┌─────────────────────────────────────────┐
                                                                          │ issue-1356.c:10:3-10:53 (synthetic)     │
                                                                          │ (issue-1356.c:10:3-10:53 (synthetic))   │ ─┐
                                                                          └─────────────────────────────────────────┘  │
                                                                            │                                          │
                                                                            │ Neg(b >= 0)                              │
                                                                            ▼                                          │
  ┌─────────────────────────────────────────┐                             ┌─────────────────────────────────────────┐  │
  │ issue-1356.c:10:3-10:53 (synthetic)     │  Neg(a <= b + 2147483647)   │ issue-1356.c:10:3-10:53                 │  │
  │ (issue-1356.c:10:3-10:53 (synthetic))   │ ◀────────────────────────── │ (issue-1356.c:10:3-10:53)               │  │ Pos(b >= 0)
  └─────────────────────────────────────────┘                             └─────────────────────────────────────────┘  │
    │                                                                       │                                          │
    │                                                                       │ Pos(a <= b + 2147483647)                 │
    │                                                                       ▼                                          │
    │                                                                     ┌─────────────────────────────────────────┐  │
    │                                                                     │ issue-1356.c:10:3-10:53 (synthetic)     │  │
    │                                                                     │ (issue-1356.c:10:3-10:53 (synthetic))   │ ◀┘
    │                                                                     └─────────────────────────────────────────┘
    │                                                                       │
    │                                                                       │ tmp___0 = 1
    │                                                                       ▼
    │                                                                     ┌─────────────────────────────────────────┐
    │                                         tmp___0 = 0                 │ issue-1356.c:10:3-10:53 (synthetic)     │
    └───────────────────────────────────────────────────────────────────▶ │ (issue-1356.c:10:3-10:53 (synthetic))   │
                                                                          └─────────────────────────────────────────┘
                                                                            │
                                                                            │ assume_abort_if_not(tmp___0)
                                                                            ▼
                                                                          ┌─────────────────────────────────────────┐
                                                                          │ issue-1356.c:11:3-11:15                 │
                                                                          │ (unknown)                               │
                                                                          └─────────────────────────────────────────┘
                                                                            │
                                                                            │ return a - b
                                                                            ▼
                                                                          ┌─────────────────────────────────────────┐
                                                                          │ return of minus()                       │
                                                                          └─────────────────────────────────────────┘
