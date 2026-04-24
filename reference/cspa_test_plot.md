# Plot CSPA Test Results

Visualizes the estimated conditional mean functions \\\hat{h}\_j(x)\\,
their lower envelope, and the confidence bound from the CSPA test.

## Usage

``` r
cspa_test_plot(
  object = NULL,
  Y = NULL,
  X = NULL,
  level = 0.05,
  trim = 0,
  prewhiten = -1L,
  preselect = TRUE,
  ylab = "Loss Difference",
  xlab = "Conditioning Variable"
)
```

## Arguments

- object:

  A `cspa_test` object returned by
  [`cspa_test`](https://gabbocg.github.io/forecastdom/reference/cspa_test.md),
  or omitted if `Y` and `X` are provided directly.

- Y:

  An `n x J` matrix of loss differentials. Ignored if `object` is
  provided.

- X:

  An `n x 1` numeric vector of the conditioning variable. Ignored if
  `object` is provided.

- level:

  Significance level (e.g., 0.05). Ignored if `object` is provided.

- trim:

  Trimming parameter. Default `0`.

- prewhiten:

  Pre-whitening order. Default `-1`.

- preselect:

  Logical; adaptive inequality selection. Default `TRUE`.

- ylab:

  Label for the y-axis. Default `"Loss Difference"`.

- xlab:

  Label for the x-axis. Default `"Conditioning Variable"`.

## Value

A `ggplot` object.
