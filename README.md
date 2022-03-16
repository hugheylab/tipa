# tipa

[![check-deploy](https://github.com/hugheylab/tipa/workflows/check-deploy/badge.svg)](https://github.com/hugheylab/tipa/actions)
[![Conforms to code style?](https://github.com/hugheylab/tipa/workflows/lint-package/badge.svg)](https://github.com/hugheylab/tipa/actions)
[![codecov](https://codecov.io/gh/hugheylab/tipa/branch/master/graph/badge.svg)](https://codecov.io/gh/hugheylab/tipa)
[![Netlify Status](https://api.netlify.com/api/v1/badges/0c6262a3-b9f8-4478-a7b1-8f0ef78786b1/deploy-status)](https://app.netlify.com/sites/stoic-sinoussi-75a610/deploys)
[![CRAN Status](https://www.r-pkg.org/badges/version/tipa)](https://cran.r-project.org/package=tipa)

`tipa` accurately calculates phase shifts in circadian time-course data. `tipa` accounts for period changes and for the point in the circadian cycle at which the stimulus occurs.

For details about the method and to see how we benchmarked it using simulations, check out [Tackenberg et al. (2018)](https://doi.org/10.1177/0748730418768116) and the [accompanying results](https://doi.org/10.6084/m9.figshare.5484916).

## Installation

### Option 1: CRAN

```r
install.packages('tipa')
```

### Option 2: Hughey Lab Drat Repository

1. Install [`BiocManager`](https://cran.r-project.org/package=BiocManager).

    ```r
    if (!requireNamespace('BiocManager', quietly = TRUE))
      install.packages('BiocManager')
    ```

1. If you use RStudio, go to Tools → Global Options... → Packages → Add... (under Secondary repositories), then enter:

    - Name: hugheylab
    - Url: https://hugheylab.github.io/drat/

    You only have to do this once. Then you can install or update the package by entering:

    ```r
    BiocManager::install('tipa')
    ```

    Alternatively, you can install or update the package by entering:

    ```r
    BiocManager::install('tipa', site_repository = 'https://hugheylab.github.io/drat/')
    ```

## Usage

See the examples and detailed guidance in the [reference documentation](https://tipa.hugheylab.org/reference/index.html).
