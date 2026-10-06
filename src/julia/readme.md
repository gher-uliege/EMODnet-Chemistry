## Julia

Tools used to
1. prepare the merged products that combine the regional climatologies.
2. create new, pan-European sea climatologies with `DIVAnd`
3. applying post-processing to the climatology files (edting attributes etc).

The files and notebooks are now separared in different sub-folders.

### 1. Climatology merging

`MergingClim.jl` is the module where all the functions are defined.       
`merge_products.jl` is the script that actually performs the merging.

#### Testing

```julia
include("test.jl")
```

### 2. All European Seas products

Contains the scripts for the preparation of the new products covering all the European Seas.
            
### Post-processing

Contains scripts to edit the attributes or to add the _deepest depth_ variable.
