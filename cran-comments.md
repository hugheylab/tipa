## R CMD check results

### Local

`devtools::check()`:

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

### R-hub

`devtools::check_rhub()`:

  0 errors ✓ | 0 warnings ✓ | 2 notes ✓

```
* checking CRAN incoming feasibility ... [7s/16s] NOTE
Maintainer: ‘Jake Hughey <jakejhughey@gmail.com>’

Possibly misspelled words in DESCRIPTION:
  al (8:21)
  et (8:18)
  Tackenberg (8:7)
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
```

See results for [Windows](https://builder.r-hub.io/status/tipa_1.0.8.tar.gz-90c36d6e64374ae58df2d3ae857da56c), [Ubuntu](https://builder.r-hub.io/status/tipa_1.0.8.tar.gz-4dcddeb172784305a1f8d3cfb42a20ef), and [Fedora](https://builder.r-hub.io/status/tipa_1.0.8.tar.gz-88b440981be94fd4bcc0b9ecd50917e8).

### GitHub Actions

  0 errors ✓ | 0 warnings ✓ | 0 notes ✓

See results for Mac, Windows, and Ubuntu [here](https://github.com/hugheylab/tipa/actions/runs/5919858803).

## Changes from current CRAN release

* Switched from using optimr package to optimx, as requested.
