# Processing

The goal of this tutorial is to explain how to create a unique netCDF file from
several netCDF corresponding, for instance, to different seasons. In addition, the time
periods have to be sorted in the final file.

__Files:__ seasonal phosphate concentration in the Black Sea.
* `Water body phosphate_Autumn.4Danl.nc`
* `Water body phosphate_Spring.4Danl.nc`
* `Water body phosphate_Summer.4Danl.nc`
* `Water body phosphate_Winter.4Danl.nc`

__Tools:__
* [`nco`](http://nco.sourceforge.net/), the netCDF Operators toolkit.
* [`Julia`](julialang.org/), your favorite programming language.

## Procedure

### Step 1: add record variable

Before merging the files we need to add a record variable, usually the time,
that will be used for the concatenation. This is done with `ncks` tool:

```bash
ncks -O --mk_rec_dmn time Water\ body\ phosphate_Summer.4Danl.nc Water\ body\ phosphate_Summer.4Danl.nc
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
We see that now the time is unlimited


### Step 2: merge all the files with `nco`
