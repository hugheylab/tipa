circMean = function(a, period = 1, na.rm = TRUE, forcePos = FALSE) {
  x = cos(a / period * 2 * pi)
  y = sin(a / period * 2 * pi)
  m = atan2(sum(y, na.rm = na.rm), sum(x, na.rm = na.rm)) / 2 / pi
  if (forcePos) {
    m = ifelse(m < 0, m + 1, m) * period
  } else {
    m = m * period}
  return(m)}


tipaPeriod = function(phaseRefTimes, stimOnset=0, stimDuration=0) {
  tPre = phaseRefTimes[phaseRefTimes < stimOnset]
  periodPre = (max(tPre) - min(tPre)) / (length(tPre) - 1)
  tPost = phaseRefTimes[phaseRefTimes > stimOnset + stimDuration]
  periodPost = (max(tPost) - min(tPost)) / (length(tPost) - 1)
  return(list(pre = periodPre, post = periodPost))}


#' Use phase reference points to estimate the phase shift induced by a stimulus
#' during a circadian time-course.
#'
#' Calculate the phase shift based on the times of a phase reference point
#' (e.g., onset of activity), accounting for possible period changes and for the
#' point in the circadian cycle at which the stimulus occurred. If the rhythms
#' of the measurement are approximately sinusoidal, it is recommended to instead
#' use [tipaCosinor()].
#'
#' @param phaseRefTimes Vector of times of the chosen phase reference point.
#' @param stimOnset Time at which the stimulus started.
#' @param stimDuration Duration of the stimulus and any transients. Data between
#'   `stimOnset` and `stimOnset + stimDuration` will be ignored.
#' @param period Optional list with elements "pre" and "post" corresponding to
#'   the period of the oscillations prior to and subsequent to the stimulus. If
#'   not supplied, the periods for pre- and post-stimulus are calculated as the
#'   mean time between occurrences of the phase reference point within the
#'   respective epoch. Using this argument is not recommended.
#'
#' @return A list.
#' \item{phaseShift}{Estimated phase shift in circadian hours. Negative values
#'   indicate a delay, positive values an advance.}
#' \item{epochInfo}{`data.frame` containing estimated period for each epoch.}
#'
#' @examples
#' # Peak times of bioluminescence (in hours)
#' phaseRefTimes = c(-75.5, -51.5, -27.4, -3.8,
#'                   20.5, 42.4, 65.5, 88.0)
#' result = tipaPhaseRef(phaseRefTimes, stimOnset = 0)
#'
#' # Data from multiple (simulated) experiments
#' getExtrFile = function() {
#'   system.file('extdata', 'phaseRefTimes.csv', package = 'tipa')}
#' getStimFile = function() {
#'   system.file('extdata', 'stimOnsets.csv', package = 'tipa')}
#'
#' extrDf = read.csv(getExtrFile(), stringsAsFactors = FALSE)
#' stimDf = read.csv(getStimFile(), stringsAsFactors = FALSE)
#'
#' resultList = lapply(stimDf$expId, function(ii) {
#'   phaseRefTimes = extrDf$phaseRefTime[extrDf$expId == ii]
#'   stimOnset = stimDf$stimOnset[stimDf$expId == ii]
#'   tipaPhaseRef(phaseRefTimes, stimOnset)})
#'
#' phaseShifts = sapply(resultList, function(r) r$phaseShift)
#'
#' @seealso [tipaCosinor()]
#'
#' @export
tipaPhaseRef = function(phaseRefTimes, stimOnset, stimDuration = 0, period = NULL) {
  phaseRefTimes = sort(phaseRefTimes)
  stimAnchor = stimOnset + 0.5 * stimDuration

  if (is.null(period)) {
    period = tipaPeriod(phaseRefTimes, stimOnset, stimDuration)}

  tPreLast = max(phaseRefTimes[phaseRefTimes < stimOnset])
  fracCycleRem = 1 - (stimAnchor - tPreLast) / period$pre

  tPost = phaseRefTimes[phaseRefTimes > stimOnset + stimDuration]
  tPostExpect = stimAnchor + period$post * (fracCycleRem + 0:(length(tPost)-1))
  tPostResid = tPostExpect - tPost

  phaseShift = circMean(tPostResid, period = period$post) * 24 / period$post
  epochInfo = data.frame(epoch = names(period), period = unname(unlist(period)),
                         stringsAsFactors = FALSE)
  return(list(phaseShift = phaseShift, epochInfo = epochInfo))}


cosinor = function(time, y, per, trend) {
  df = data.frame(y = y, time = time, timeCos = cos(2*pi*time/per),
                  timeSin = sin(2*pi*time/per))
  if (trend) {
    fit = stats::lm(y ~ timeCos + timeSin + splines::ns(time, df = 4), data = df)
  } else {
    fit = stats::lm(y ~ timeCos + timeSin, data = df)}
  return(fit)}


cosinorCost = function(time, y, per, trend) {
  fit = cosinor(time, y, per, trend)
  cost = mean(fit$residuals^2)
  return(cost)}


fitCosinor = function(time, y, periodGuess = 24, trend = TRUE) {
  optimFit = optimr::optimr(c(p = periodGuess),
                            fn = function(p) cosinorCost(time, y, p, trend),
                            lower = 0, method = 'L-BFGS-B')
  period = optimFit$par[['p']]
  cosinorFit = cosinor(time, y, period, trend)
  rmsError = sqrt(cosinorCost(time, y, period, trend))
  phaseRad = atan2(stats::coef(cosinorFit)[['timeSin']],
                   stats::coef(cosinorFit)[['timeCos']])
  data.frame(period = period, phaseRad = phaseRad, rmsError = rmsError)}


#' Use cosinor regression to estimate the phase shift induced by a stimulus
#' during a circadian time-course.
#'
#' Calculate the phase shift based on fitting sine curves to waveform data
#' before and after the stimulus, accounting for possible period changes and for
#' the point in the circadian cycle at which the stimulus occurred. This
#' function will work best for measurements whose rhythms are approximately
#' sinusoidal, or at least smoothly increasing and decreasing. If your data are
#' not sinusoidal, you can first define the phase reference points and then use
#' [tipaPhaseRef()].
#'
#' @param time Vector of time values for the full time-course.
#' @param y Vector of measurements (e.g., bioluminescence) for the full
#'   time-course.
#' @param stimOnset Time at which the stimulus started.
#' @param stimDuration Duration of the stimulus and any transients. Data between
#'   `stimOnset` and `stimOnset + stimDuration` will be ignored.
#' @param periodGuess Approximate period of the oscillations (in the same units
#'   used in `time`), used as initial value in fitting the sine curves.
#' @param trend Model a long-term trend in the cosinor fit for each epoch. Uses
#'   a natural cubic spline with 4 degrees of freedom. It is strongly
#'   recommended to keep as `TRUE`. If set to `FALSE`, the function may give an
#'   error or give completely invalid results.
#' @param shortcut Calculate phase shift using the standard TIPA procedure or
#'   using a shortcut based on the phases of the sine curve fits. The two
#'   methods give exactly the same result.
#'
#' @return A list.
#' \item{phaseShift}{Estimated phase shift in circadian hours. Negative values
#'   correspond to a delay, positive values an advance.}
#' \item{epochInfo}{Dataframe containing information about the sine curve fits
#'   for each epoch: period (in the same units used in `time`), phase (in
#'   radians), and root mean square error (in the same units as `y`). If the RMS
#'   errors pre-stimulus and post-stimulus are substantially different, then the
#'   stimulus may have induced a change in the waveform and thus phase shift
#'   estimates may be invalid.}
#'
#' @examples
#' # Time-course data from multiple (simulated) experiments
#' getTimecourseFile = function() {
#'   system.file('extdata', 'timecourses.csv', package = 'tipa')}
#' df = read.csv(getTimecourseFile(), stringsAsFactors = FALSE)
#'
#' resultList = lapply(sort(unique(df$expId)), function(ii) {
#'   time = df$time[df$expId == ii]
#'   y = df$intensity[df$expId == ii]
#'   tipaCosinor(time, y, stimOnset = 0)})
#'
#' phaseShifts = sapply(resultList, function(r) r$phaseShift)
#'
#' @seealso [tipaPhaseRef()]
#'
#' @export
tipaCosinor = function(time, y, stimOnset, stimDuration = 0, periodGuess = 24,
                       trend = TRUE, shortcut = TRUE) {
  stimOffset = stimOnset + stimDuration

  fitPre = fitCosinor(time[time < stimOnset], y[time < stimOnset], periodGuess, trend)
  fitPre = data.frame(epoch = 'pre', fitPre, stringsAsFactors = FALSE)

  fitPost = fitCosinor(time[time > stimOffset], y[time > stimOffset], periodGuess, trend)
  fitPost = data.frame(epoch = 'post', fitPost, stringsAsFactors = FALSE)

  if (shortcut) {
    phaseShift = (fitPre$phaseRad - fitPost$phaseRad) * 24 / 2 / pi
    phaseShift = phaseShift - 24 * (phaseShift > 12) + 24 * (phaseShift < (-12))
  } else {
    # find last peak time before stimOnset
    tPreLast = stats::optimize(function(tt) -cos(tt * 2 * pi / fitPre$period - fitPre$phaseRad),
                               interval = c(stimOnset - fitPre$period * 1.1, stimOnset))$minimum
    if (tPreLast + fitPre$period < stimOnset) {
      tPreLast = tPreLast + fitPre$period}

    # estimate fraction of cycle remaining
    fracCycleRem = 1 - (stimOnset - tPreLast) / fitPre$period

    # find first peak time after stimOffset
    tPostObs = stats::optimize(function(tt) -cos(tt * 2 * pi/fitPost$period - fitPost$phaseRad),
                               interval = c(stimOffset, stimOffset + fitPost$period * 1.1))$minimum

    # find expected time of first fit peak after stimOnset
    # (ok even if non-zero transients)
    tPostExpect = stimOnset + fitPost$period * fracCycleRem

    # circular mean of residual, using post period as reference
    phaseShift = circMean(tPostExpect - tPostObs, period = fitPost$period)

    # convert phase shift to circadian hours
    phaseShift = phaseShift * 24 / fitPost$period}

  return(list(phaseShift = phaseShift, epochInfo = rbind(fitPre, fitPost)))}
