# tipa
`tipa` is a package for accurately calculating phase shifts in circadian time-course data. `tipa` accounts for period changes and for the point in the circadian cycle at which the stimulus occurs.

For details about the method and to see how we benchmarked it using simulations, check out [Tackenberg et al. (2018)](https://doi.org/10.1177/0748730418768116) and the [accompanying results](https://doi.org/10.6084/m9.figshare.5484916).

## Install using devtools
```R
install.packages('devtools')
devtools::install_github('hugheylab/tipa')
```
You can update the package using just the second line.

## Install using docker
You can use a pre-built [docker image](https://hub.docker.com/r/hugheylab/hugheyverse), which has all dependencies installed:
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
