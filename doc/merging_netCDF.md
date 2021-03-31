# Processing

The goal of this tutorial is to explain how to create a unique netCDF file from
several netCDF corresponding, for instance, to different seasons. In addition, the time
periods have to be sorted in the final file.

__Files:__ phosphate concentration in the Black Sea for the Autumn season.
The old file:       
`Water body phosphate.4Danl.nc`: it contains the gridded field on 42 6-year periods.      
The new file:      
`Water body phosphate_Autumn.4Danl.nc`: it contains the gridded field on 42 6-year periods.

__Tools:__
* [`nco`](http://nco.sourceforge.net/), the netCDF Operators toolkit.
* [`Julia`](julialang.org/), your favorite programming language.

## Procedure

### Step 1: add record variable

Before merging the files we need to add a record variable, usually the time,
that will be used for the concatenation. This is done with `ncks` tool:

```bash
ncks -O --mk_rec_dmn time Water\ body\ phosphate_Autumn.4Danl.nc Water\ body\ phosphate_Autumn.4Danl.nc
```
where `-O` means that we overwrite the (existing) output file.     
We can see the difference in the file before and after this operation, using `ncdump`:

__Before:__
```bash
dimensions:
	lon = 310 ;
	lat = 160 ;
	depth = 12 ;
	time = 3 ;
...
```
__After:__
```bash
dimensions:
	time = UNLIMITED ; // (3 currently)
	depth = 12 ;
	lat = 160 ;
	lon = 310 ;
  ...
```
We see that now the time dimension is _unlimited_: it is the record variable.

### Step 2 [optional]: remove common time periods

It is possible to one or several time periods appear in the 2 file. For instance the last
period of the old file can be the same as the first period of the new file.

For instance if we want to remove the last time period of the old file, we do:
```
ncks -d time,0,40 "Water body phosphate.4Danl.nc" "Water body phosphate.4Danl_time.nc"
```
We check the time dimension:
```
time = UNLIMITED ; // (41 currently)
```

### Step 3: merge the files

We use the `ncrcat` operator, designed to concatenate record variables across an arbitrary number of input files (here we only have two input files).

```bash
ncrcat "Water body phosphate.4Danl.nc" "Water body phosphate_Autumn.4Danl.nc" output1.nc
```

Checking the dimensions with `ncdump` gives:
```
...
time = UNLIMITED ; // (45 currently)
...
```

### Step 4 [optional]: sort time

If the files were properly prepared, the time variable should already be sorted in
chronological order. If this is not the case, this [notebook](https://github.com/gher-ulg/SeaDataCloud/blob/master/Julia/sort_climatology_time.ipynb) explains how to proceed.

### Step 5: merge observations

When merging with `ncrcat`, we merged the files according to time. This means that
the variables that don't depend on time were not merged. This is the case for the observations, i.e. the variables `obslon`, `obslat`, ...

The old file has 192215 observations.      
The new file has 7362 observations.      
The 192215 observations of the first file are already written in the merged netCDF,
so we only need to read those from the new file and write them to the netCDF.

As the dimension is already fixed in the file, we cannot directly append the new observations.

__Solution:__ delete the variables that depends on the dimension `observations`:
```bash
ncks -x -v obslon,obslat,obsdepth,obstime,obsid output1.nc output2.nc
```

Once the variables have been removed, use the script [merge_obs.jl](https://github.com/gher-ulg/EMODnet-Chemistry/blob/master/julia/merge_obs.jl) to merge the observations
from the 2 input files.
- Adapt the paths of the files
- Run the file `merge_obs.jl`
