## Julia

Tools used to
1. prepare the merged products that combine the regional climatologies.
2. create new, pan-European sea climatologies with `DIVAnd`.

### Files

`MergingClim.jl` is the module where all the functions are defined.       
`merge_products.jl` is the script that actually performs the merging.

### Testing

```julia
include("test.jl")
```

### To do

- Automatically set variable range for the plots
