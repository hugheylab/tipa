# tipa

`tipa` is a package for accurately calculating phase shifts in circadian time-course data. `tipa` accounts for period changes and for the point in the circadian cycle at which the stimulus occurs.

For details about the method and to see how we benchmarked it using simulations, check out [Tackenberg et al. ()]() and the [accompanying results]().

## Installation
Install the package in your local version of R:
```R
install.packages('devtools')
devtools::install_github('hugheylab/tipa')
```

Or use a pre-built [docker image](https://hub.docker.com/r/hugheylab/hugheyverse), which has all dependencies already installed:
```
docker pull hugheylab/hugheyverse
```

## Getting started
See the examples in the documentation:
```R
library('tipa')
?tipaPhaseRef
?tipaCosinor
```
