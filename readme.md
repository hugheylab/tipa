# tipa
`tipa` is a package for accurately calculating phase shifts in circadian time-course data. `tipa` accounts for period changes and for the point in the circadian cycle at which the stimulus occurs.

For details about the method and to see how we benchmarked it using simulations, check out [Tackenberg et al. (2018)](https://doi.org/10.1177/0748730418768116) and the [accompanying results](https://doi.org/10.6084/m9.figshare.5484916).

## Installation
First install drat.
```R
install.packages('drat')
```

Then add the following line to your `.Rprofile` file (located at "~/.Rprofile"), which gets run every time R starts. See [here](https://csgillespie.github.io/efficientR/3-3-r-startup.html#r-startup) for details.
```R
drat::addRepo('hugheylab')
```

Now you can install the package.
```R
install.packages('tipa', type = 'source')
```
You can update the package using `update.packages()`.

## Docker
You can also use a pre-built [docker image](https://hub.docker.com/r/hugheylab/hugheyverse), which has all dependencies installed.
```bash
docker pull hugheylab/hugheyverse
```

## Getting started
See the examples in the documentation:
```R
library('tipa')
?tipaPhaseRef
?tipaCosinor
```
