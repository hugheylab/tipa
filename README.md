# tipa

[![check-coverage-deploy](https://github.com/hugheylab/tipa/workflows/check-coverage-deploy/badge.svg)](https://github.com/hugheylab/tipa/actions)
[![codecov](https://codecov.io/gh/hugheylab/tipa/branch/master/graph/badge.svg)](https://codecov.io/gh/hugheylab/tipa)

`tipa` accurately calculates phase shifts in circadian time-course data. `tipa` accounts for period changes and for the point in the circadian cycle at which the stimulus occurs.

For details about the method and to see how we benchmarked it using simulations, check out [Tackenberg et al. (2018)](https://doi.org/10.1177/0748730418768116) and the [accompanying results](https://doi.org/10.6084/m9.figshare.5484916).

## Installation

If you use RStudio, go to Tools -> Global Options... -> Packages -> Add... (under Secondary repositories), then enter:

- Name: hugheylab
- Url: https://hugheylab.github.io/drat/

You only have to do this once. Then you can install or update the package by entering:

```R
if (!requireNamespace('BiocManager', quietly = TRUE))
  install.packages('BiocManager')

BiocManager::install('tipa')
```

Alternatively, you can install or update the package by entering:

```R
if (!requireNamespace('BiocManager', quietly = TRUE))
  install.packages('BiocManager')

BiocManager::install('tipa', site_repository = 'https://hugheylab.github.io/drat/')
```

## Usage

See the examples and detailed guidance in the [reference documentation](https://tipa.hugheylab.org/reference/index.html).
