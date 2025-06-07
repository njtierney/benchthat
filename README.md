
# benchthat

<!-- badges: start -->
<!-- badges: end -->

The goal of benchthat is to facilitate writing benchmark performance tests across functions when you are developing a package or some other code base. The approach is similar to snapshot testing in [testthat](https://github.com/r-lib/testthat/).

## Installation

You can install the development version of benchthat from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("njtierney/benchthat")
```

## Example usage

The `benchthat` package leverages off of the [bench](https://github.com/r-lib/bench/) package

Establish using benchthat with

```r
use_benchthat()
```

Which add the folder structure:

```
.
└── benchmarks
    ├── benchthat.R
    └── benchthat
         └── bench-template.R
```

(in the future we may integrate into /tests to sit alongside [testthat](https://github.com/r-lib/testthat)).

You can then add a new benchmark with:

```r
use_bench("function_name")
```

Which adds some template code:

```r
bench_that("function_name", {
  # data set up
  # data <- magic_function_for_setup(...)
  expect_benchmark(
    x = function_name(data = data)
    speed_tolerance = 0.1 # 10% tolerance before failure
    speed_var = "median" # decide which variable(s) you want to benchmark on
  )
}
)
```

This would then create a `_bench` directory, similar to the `_snaps` directory in snapshot testing

Inside this would be compressed `.rds` files containing benchmarks:

- `_bench/function_name.rds`

Subsequent changes to code would compare the speeds to this .rds file, combining it into a `benchmark` object from the `bench` package. Ideally, this will be a .csv so we don't get locked out of a serialisation (.rds) format and future proof things, somewhat.

If the code drops behind a certain speed threshold, you get an error and a shiny app similar to failures in `expect_snapshot()` - you would get a `benchmark_review()` function. You can decide if you will accept or keep a new function, based on the benchmark. If you do so, it will archive the benchmarks - noting the commit (if available), and date, and function name. The idea being  you can then historically look back on code development to see where and how long code has taken to run.

We can then materialise the plots on demand in a report.

## Motivation

Essentially, the problem I was trying to solve was that when I want to test if one function is faster than a new implementation, then I would typically do something like the following:

1. Copy the existing implementation, name the function "my_fun_original".
2. Write a new implementation, name this one, "my_fun_new"
3. Run benchmark coding on "my_fun_original" and "my_fun_new"

My issue with this is that I really don't like copying and pasting implementations like this. I would rather just have a way of comparing the baseline approach by having it saved somehow. In addition, it would also be really useful to have a suite of functions that would allow you to compare the speed of approaches, in case you've made some additions that are substantially slower (or faster!) without having to consciously step in to a benchmarking.

Essentially, this problem feels really similar to (one of) the motivations behind writing tests for development: informal testing. Informal testing is this process:

1. Make changes to code
2. Check changes to code in console
3. See if they match what you were thinking
4. Repeat steps 1-3 until it matches what your ideas.

The problem is these expectations you had aren't formalised, so if you stick with this process, then the only way to avoid breaking your code is to remember what all these expectations were. We don't like needing to remember those things, so we formalise them into tests, that run automatically. If you do this well, and thoroughly, then your code is wrapped in this protective cocoon of tests, so you can then go on to make changes with great freedom, and know that you don't need to hold all of the logic in the rest of your head about how this might break any other part of the codebase that this interacts with.

Similarly, I want to have a set of expectations that test your code to see if they get faster or slower. 

### Workflow: local, git, continuous integration

My initial ideal was to enforce a git-based workflow for this, where you would make changes in a branch, and then it could check out the main branch and see if your changes were any better. Overall, this is where I'd like the package to end up. However, trying to do all of that all at once felt a bit overwhelming. So I want the development to proceed as follows:

1. Develop locally and determine workflow and architecture.
2. Facilitate using git branches to compare benchmarks ("branchmarking" - a term that I believe was coined by [Romain François](https://github.com/romainfrancois)).
3. Extend to run comparisons continuously using github actions.

### Limitations

Benchmarking is complicated, and I've got a lot to learn about it. But overall the package will track (initially) only timing information for a given function name. There are some limitations to this approach:

1. We do not have guarantees that the functions return the same output (your function could be fast because it returns nothing!). This could be overcome by using a git branch approach where you can check out the function from a given branch, save it as a different function name, and then run it as a proper comparison in the new benchmark. However, that is a bit complex at the moment - but it should be possible.

2. We do not track computational environments, which means that running code on a faster machine might just make your code faster with no changes to the code. This could be overcome by tracking computational environments with the benchmarks so that you can then compare based on key machine characteristics (RAM, OS, OS version, R version, package versions, storage, chip?)

Overall, I do want to have some sort of way to benchmark changes to know if they are getting faster, without going through the pain of writing a function as "fun2" and saving that.


## Existing approaches

There are already two R packages that focus on this problem: [touchstone](https://github.com/lorenzwalthert/touchstone), and [Rperform](https://github.com/analyticalmonk/Rperform). 

I wanted an approach that felt more familiar to other approaches, and so I wanted to try out mimicking the design of `testthat`, specifically snapshot testing. 
