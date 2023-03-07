# Renaming netCDF variables

Characters such as white spaces or parenthesis don't behave well with ERDDAP.      
The file names can be edited easily (`rename`) while the variable names require the use of `nco`.

## Example of command

```bash
ncrename -v ."Water body dissolved inorganic nitrogen (DIN)","Water body dissolved inorganic nitrogen" -v ."Water body dissolved inorganic nitrogen (DIN)_L1","Water body dissolved inorganic nitrogen_L1" -v ."Water body dissolved inorganic nitrogen (DIN)_L2","Water body dissolved inorganic nitrogen_L2" -v ."Water body dissolved inorganic nitrogen (DIN)_err","Water body dissolved inorganic nitrogen_err" -v ."Water body dissolved inorganic nitrogen (DIN)_relerr","Water body dissolved inorganic nitrogen_relerr" -v ."Water body dissolved inorganic nitrogen (DIN)_deepest","Water body dissolved inorganic nitrogen_deepest" -v ."Water body dissolved inorganic nitrogen (DIN)_deepest_L1","Water body dissolved inorganic nitrogen_deepest_L1" -v ."Water body dissolved inorganic nitrogen (DIN)_deepest_L2","Water body dissolved inorganic nitrogen_deepest_L2" -v ."Water body dissolved inorganic nitrogen (DIN)_deepest_depth","Water body dissolved inorganic nitrogen_deepest_depth" Water_body_dissolved_inorganic_nitrogen.nc
```

- [`ncrename`](https://linux.die.net/man/1/ncrename): renaming variables, attributes or dimensions
- `-v`: work on variables
- the dot before the old variable name is used to avoid getting an error if the variable doesn't exist

## Recreating the JSON file

For each netCDF file there should be a JSON file that indicates which are the _additional fields_.

Such JSON file is created with
```bash
~/bin/emodnet_genjson netcdf_file
```

If you get the error (on OGS04 server in particular)
```bash
Traceback (most recent call last):
  File "/home/uniliege01/bin/emodnet_genjson", line 12, in <module>
    import netCDF4
  File "/home/uniliege01/.local/lib/python2.7/site-packages/netCDF4/__init__.py", line 3, in <module>
    from ._netCDF4 import *
ImportError: libhdf5_hl.so.7: cannot open shared object file: No such file or directory
```

you can use the virtual environment `emodnet`:
```bash
workon emodnet
python ~/bin/emodnet_genjson netcdf_file
```
