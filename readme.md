# tipa

`tipa` accurately calculates phase shifts in circadian time-course data. `tipa` accounts for period changes and for the point in the circadian cycle at which the stimulus occurs.

For details about the method and to see how we benchmarked it using simulations, check out [Tackenberg et al. (2018)](https://doi.org/10.1177/0748730418768116) and the [accompanying results](https://doi.org/10.6084/m9.figshare.5484916).

## Installation

First add the hugheylab repository to your repos. There are multiple ways to do this.

If you use RStudio, go to Tools -> Global Options... -> Packages -> Add... (under Secondary repositories), then enter the following values.

- Name: hugheylab
- Url: https://hugheylab.github.io/drat/

You only have to do this once.

Alternatively, enter the following command each time you want to install or update the package.

```R
options(repos = c(getOption('repos'), 'https://hugheylab.github.io/drat/'))
```

Now you can install the package.

```R
install.packages('tipa', type = 'source')
```

You can update the package using `update.packages()`.

There's also a [docker image](https://hub.docker.com/r/hugheylab/hugheyverse), which has all dependencies installed.

```bash
docker pull hugheylab/hugheyverse
```

## Usage

See the examples and detailed guidance in the [reference documentation](reference/index.html).
