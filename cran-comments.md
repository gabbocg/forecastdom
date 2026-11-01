## Submission

This is a patch release (0.1.0 -> 0.1.1) that fixes two bugs:

* `spa_test()` tested Hansen's (2005) superior predictive ability null in the
  wrong direction and did not use Hansen's consistent recentring. It now
  follows the paper.
* `cspa_test()` returned swapped p-values in the boundary cases where the null
  is rejected at every level or at none.

It also adds tests for these functions and refines the package title and
`DESCRIPTION` text.

## R CMD check results

0 errors | 0 warnings | 0 notes

`devtools::spell_check()` reports no spelling errors under `Language: en-GB`
(all domain terms, author surnames, and acronyms are whitelisted in
`inst/WORDLIST`).

## Test environments

* local: macOS Sequoia 15.7.4, R 4.5.1 (aarch64-apple-darwin20)
* GitHub Actions (R-CMD-check)
* R-hub v2 (GitHub Actions): linux (r-devel), windows (r-devel), macos (r-devel) — all Status: OK

## Downstream dependencies

There are no reverse dependencies.
