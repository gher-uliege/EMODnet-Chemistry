# Processing

The goal of this tutorial is to explain how to processing the residuals
obtained with `DIVAnd` using `Ocean Data View` (ODV).

In this example:
* __File:__ `Water body phosphate_monthly_residuals.nc` (monthly residuals of
	phosphate concentration).
* __ODV version:__ 5.4.0 (downloaded March 2021)


## Procedure

### 1. Open the netCDF file containing the residuals

![Open file](../figures/ODV-residuals/odv_res01.png "Open file")

### Follow the Wizard steps


### Leave variables and metadata




Use decimal date (or dummy variable) as Primary variable




Finish the netCDF setup





Select a Surface window in Views




Result of the Surface window. Here you can change the dot size (Properties) and other details





Set the z-variable as the residuals
























Set the ranges for the residuals, for instance between -5. and 5.









Use the sample filter to display only the points with a high value for the residual.
For example we show residuals above 5.




12. Example of what is obtained with the filter




13. Select your region of interest using the Set ranges.
In this case we can see the measurements in the Black Sea for which the residuals exceed a 5 µmol/l.
