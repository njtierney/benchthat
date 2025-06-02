
# branchmark

<!-- badges: start -->
<!-- badges: end -->

The goal of branchmark is to demostrate using pull requests to set up benchmarks
on github actions. 

{touchstone} already does this but I wanted to try a different, albeit almost certainly less thorough approach, that will suit my purposes.

## Installation

You can install the development version of branchmark from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("njtierney/demo-branchmark")
```

## Example

Example usage will be generating example github actions files, and setting up file and folder structure. Something like:

```r
use_branchmark()
```

Which would setup github actions files, and the branchmark repo

```r
use_branchmark_r("n_miss")
```

Would setup "branchmark/branchmark_n_miss.R" with template code

