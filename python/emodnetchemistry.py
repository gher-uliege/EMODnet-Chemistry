import os
import glob
import netCDF4
import calendar
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import Polygon

from pyproj import Transformer
from pyproj import CRS
import cartopy
import cartopy.feature as cfeature
import cartopy.mpl.gridliner as gridliner
import matplotlib.ticker as mticker
import cartopy.mpl.ticker as cartopyticker
lon_formatter = cartopyticker.LongitudeFormatter()
lat_formatter = cartopyticker.LatitudeFormatter()
coast = cfeature.GSHHSFeature(scale="i")

import warnings
import matplotlib.cbook
import logging
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)

import matplotlib as mpl

plt.rcParams.update({
    'savefig.dpi':  300,
    'figure.edgecolor': 'w',
    'figure.facecolor': 'w',
    'savefig.edgecolor': 'w',
    'savefig.facecolor': 'w',
    'font.size': 16,
    'savefig.bbox': "tight",
    'savefig.transparent': False,
    'figure.titlesize': 20
})


logger = logging.getLogger("EMODnet-Chemistry-Data-positions")
logger.setLevel(logging.DEBUG)
logging.info("Starting")

colorlist = {"ArcticSea": "#1f77b4",
             "Atlantic2": "#ff7f0e",
             "BalticSea": "#2ca02c", "BlackSea": "#d62728",
             "MedSea2": "#9467bd", "NorthSea": "#8c564b"}

# datadir = "/data/EMODnet/Eutrophication/Split/"
datadir = "/media/ctroupin/My Passport/data/EMODnet/Eutrophication/Split/"

def all_positions(m, datafilelist: list):
    """Read all the longitudes and latitudes from a list of file

    Parameters
    ----------
    m : Basemap
        An instance of a mpl_toolkits.basemap.Basemap
    datafilelist : list
        A list of file paths

    Returns
    -------
    lonall : numpy.ndarray
    latall : numpy.ndarray
    datesall : numpy.ndarray
        Array of DatetimeGregorian (as obtained by `netCDF4.num2date` method)
    """
    lonall = np.array([])
    latall = np.array([])
    datesall = np.array([])
    for datafile in datafilelist:
        with netCDF4.Dataset(datafile, "r") as nc:
            lon = nc.get_variables_by_attributes(standard_name="longitude")[0][:]
            lat = nc.get_variables_by_attributes(standard_name="latitude")[0][:]
            times = nc.get_variables_by_attributes(standard_name="time")[0]
            dates = netCDF4.num2date(times[:], times.units)

        # Ensure longitudes between -180° and 180°
        # (bug in previous version of ODV for the export)
        lon[lon > 180] -= 360.

        llon, llat = m(lon, lat)
        lonall = np.append(lonall, llon)
        latall = np.append(latall, llat)
        datesall = np.append(datesall, dates)
    return lonall, latall, datesall

def read_variable_woa(datafile, domain=[-180., 180., -90., 90.]):
    """Read the variable from the WOA or DIVAnd netCDF file `datafile`

    Parameters
    ----------
    datafile : str
        path of the netCDF file
    domain : list
        bounding box defined as (lonmin, lonmax, latmin, latmax)

    Returns
    -------
    lon : numpy.ndarray
    lat : numpy.ndarray
    depth : numpy.ndarray
    date : numpy.ndarray
    field : numpy.ndarray
    """

    with netCDF4.Dataset(datafile, "r") as nc:
        lon = nc.variables["lon"][:]
        lat = nc.variables["lat"][:]
        goodlon = np.where( (lon >= domain[0]) & (lon <= domain[1]) )[0]
        goodlat = np.where( (lat >= domain[2]) & (lat <= domain[3]) )[0]
        lon = lon[goodlon]
        lat = lat[goodlat]
        depth = nc.variables["depth"][:]
        time = nc.variables["time"][:]

        # generate list of variables
        varlist = list(nc.variables.keys())

        # Find variable corresponding to interpolated field
        varindex = 0
        varname = varlist[varindex]
        while not varname.endswith("_an"):
            varindex += 1
            varname = varlist[varindex]
        logger.info(f"Variable name: {varname}")
        logger.info(f"Standard name: {nc.variables[varname].standard_name}")

        field = nc.variables[varname][0,:,goodlat,goodlon]

    return lon, lat, depth, time, field


def read_variable_diva(datafile, domain=[-180., 180., -90., 90.], timeindex=0):
    """Read the variable from the DIVAnd netCDF file `datafile`

    Parameters
    ----------
    datafile : str
        Path of the netCDF file
    domain  : list, default: [-180., 180., -90., 90.]
        Bounding box defined as (lonmin, lonmax, latmin, latmax)
    timeindex : int, default: 0
        index for the time; for the DIVA monthly files,
        values between 1 (January) and 12 (December).

    Returns
    -------
    lon : numpy.ndarray
    lat : numpy.ndarray
    depth : numpy.ndarray
    date : numpy.ndarray
    field : numpy.ndarray

    Examples
    --------
    >>> read_variable_diva("./results.nc", domain=[-200., -10., 25., 35.], timeindex=2)
    """

    with netCDF4.Dataset(datafile, "r") as nc:
        lon = nc.variables["lon"][:]
        lat = nc.variables["lat"][:]
        goodlon = np.where( (lon >= domain[0]) & (lon <= domain[1]) )[0]
        goodlat = np.where( (lat >= domain[2]) & (lat <= domain[3]) )[0]
        lon = lon[goodlon]
        lat = lat[goodlat]
        depth = nc.variables["depth"][:]
        time = nc.variables["time"]
        date = netCDF4.num2date(time[timeindex], time.units)

        # Generate list of variables
        varlist = list(nc.variables.keys())
        varname = varlist[5]

        logger.info(f"Variable name: {varname}")
        logger.info(f"Long name: {nc.variables[varname].long_name}")

        field = nc.variables[varname][timeindex,:,goodlat,goodlon]

    return lon, lat, depth, date, field

def plot_oxy_map(llon, llat, field, depth, figname=""):
    """Create map with the interpolated values of oxygen concentration

    Parameters
    ----------
    llon : numpy.ndarray
    llat : numpy.ndarray
    field : numpy.ndarray
    depth : float
        Depth (in meters) of the layer to be plotted.
    figname : str, default: ""
        Path of the figure to be saved. If "", no figure is saved

    """
    fig = plt.figure(figsize=(10, 10))
    ax = plt.subplot(111)
    pcm = m.pcolormesh(llon, llat, field, latlon=True, vmin=200., vmax=375.)
    cb = plt.colorbar(pcm, shrink=.6, extend="both")
    cb.set_label(r"$\mu$moles/kg", rotation=0, ha="left")
    cb.set_ticks(np.arange(200., 376., 25))
    m.drawmeridians(np.arange(-40., 60., 20.), zorder=2, labels=[0, 0, 0, 1], fontsize=14,
                    linewidth=.25)
    m.drawparallels(np.arange(20., 80., 10.), zorder=2, labels=[1, 0, 0, 0], fontsize=14,
                    linewidth=.25)
    m.fillcontinents(color=".85", zorder=3)
    m.drawcoastlines(linewidth=0.1, zorder=4)
    plt.title("Oxygen concentration at {} m".format(depth))
    if len(figname) > 0:
        plt.savefig(figname)
    # plt.show()
    plt.close()

def plot_DIVAnd_field(m, lon, lat, field, depth, figname="",
                      vmin=200., vmax=375., deltavar=25.,
                      units=r"$\mu$moles/kg", monthname=None):

    """Create a plot with the DIVAnd results (alone)

    Parameters
    ----------
    llo : numpy.ndarray
    lla : numpy.ndarray
    field : numpy.ndarray
    depth : float
        Depth (in meters) of the layer to be plotted.
    figname : str, default: ""
        Path of the figure to be saved. If "", no figure is saved
    vmin : float, default: 200.
        Minimal value to be displaye in the `pcolor` plot
    vmax : float, default: 375.
        Maximal value to be displaye in the `pcolor` plot
    deltavar : float, default: 25.
        Separation of the ticks in the colorbar
    units : str, default: r"$\mu$moles/kg"
        Title of the colormap (units of the plotted value)
    monthname : int, default: None
        Numer (between 1 and 12) of the plotted field. If set to None, the month
        name is not indicated in the figure title.
    """

    fig = plt.figure(figsize=(12, 10))
    ax1 = plt.subplot(111)
    pcm = m.pcolormesh(lon, lat, field, latlon=True, vmin=vmin, vmax=vmax)
    m.drawmeridians(np.arange(-40., 70., 20.), zorder=2, labels=[0, 0, 0, 1], fontsize=14,
                    linewidth=.25)
    m.drawparallels(np.arange(20., 81., 10.), zorder=2, labels=[1, 0, 0, 0], fontsize=14,
                    linewidth=.25)
    m.fillcontinents(color=".85", zorder=3)
    m.drawcoastlines(linewidth=0.1, zorder=4)
    if monthname is not None:
        plt.title("DIVAnd field at {} m, {}".format(int(depth), monthname))
    else:
        plt.title("DIVAnd field at {} m".format(int(depth)))

    if vmin==0:
        cb = plt.colorbar(pcm, extend="max", shrink=0.5, orientation="horizontal")
    else:
        cb = plt.colorbar(pcm, extend="both", shrink=0.5, orientation="horizontal")
    cb.set_label(units)
    cb.set_ticks(np.arange(vmin, vmax + 0.0001, deltavar))
    if len(figname) > 0:
        plt.savefig(figname, dpi=300, bbox_inches="tight")
    plt.close()

def plot_WOA_DIVAnd_comparison(m, lon1, lat1, field1, lon2, lat2, field2, depth, figname="",
                              vmin=200., vmax=375., deltavar=25.,
                              units=r"$\mu$moles/kg", monthname=None):

    """Create a plot with WOA and DIVAnd maps together

    Parameters
    ----------
    lon1 : numpy.ndarray
        Longitudes of the field taken from the WOA2018
    lat1 : numpy.ndarray
        Latitudes of the field taken from the WOA2018
    field1 : numpy.ndarray
        Field from the WOA2018
    lon2 : numpy.ndarray
        Longitudes of the field taken from the DIVAnd analysis
    lat2 : numpy.ndarray
        Latitudes of the field taken from the DIVAnd analysis
    field2 : numpy.ndarray
        Field from the DIVAnd analysis
    depth : float
        Depth (in meters) of the layer to be plotted.
    figname : str, default: ""
        Path of the figure to be saved. If "", no figure is saved
    vmin : float, default: 200.
        Minimal value to be displaye in the `pcolor` plot
    vmax : float, default: 375.
        Maximal value to be displaye in the `pcolor` plot
    deltavar : float, default: 25.
        Separation of the ticks in the colorbar
    units : str, default: r"$\mu$moles/kg"
        Title of the colormap (units of the plotted value)
    monthname : int, default: None
        Numer (between 1 and 12) of the plotted field. If set to None, the month
        name is not indicated in the figure title.
    """

    fig = plt.figure(figsize=(12, 10))
    ax1 = plt.subplot(121)
    pcm = m.pcolormesh(lon1, lat1, field1, latlon=True, vmin=vmin, vmax=vmax)
    m.drawmeridians(np.arange(-40., 70., 20.), zorder=2, labels=[0, 0, 0, 1], fontsize=14,
                    linewidth=.25)
    m.drawparallels(np.arange(20., 81., 10.), zorder=2, labels=[1, 0, 0, 0], fontsize=14,
                    linewidth=.25)
    m.fillcontinents(color=".85", zorder=3)
    m.drawcoastlines(linewidth=0.1, zorder=4)
    if monthname is not None:
        plt.title("WOA 2018 at {} m, {}".format(int(depth), monthname))
    else:
        plt.title("WOA 2018 at {} m".format(int(depth)))

    ax2 = plt.subplot(122)
    pcm = m.pcolormesh(lon2, lat2, field2, latlon=True, vmin=vmin, vmax=vmax)
    m.drawmeridians(np.arange(-40., 70., 20.), zorder=2, labels=[0, 0, 0, 1], fontsize=14,
                    linewidth=.25)
    m.drawparallels(np.arange(20., 81., 10.), zorder=2, labels=[1, 0, 0, 0], fontsize=14,
                    linewidth=.25)
    m.fillcontinents(color=".85", zorder=3)
    m.drawcoastlines(linewidth=0.1, zorder=4)
    plt.title("DIVAnd")


    cbar_ax = fig.add_axes([0.15, 0.15, 0.7, 0.05])

    if vmin==0:
        cb = plt.colorbar(pcm, cax=cbar_ax, extend="max", orientation="horizontal")
    else:
        cb = plt.colorbar(pcm, cax=cbar_ax, extend="both", orientation="horizontal")
    cb.set_label(units, rotation=0, ha="center")
    cb.set_ticks(np.arange(vmin, vmax + 0.0001, deltavar))
    if len(figname) > 0:
        plt.savefig(figname, dpi=300, bbox_inches="tight")
    plt.close()

def plot_data_locations(m, varname, regiondict, figname=""):
    """Plot the data location on a map, one color per region

    Parameters
    ----------
    m : Basemap
        Basemap projection obtained with `m = Basemap(projection=...)`
    regiondict : dict
        Dictionary to link the file names to the regions
    figname : str default: None
        Path of the figure to be saved; if "", no figure is saved
    """

    logger.info("Data files in {}".format(datadir))
    datafilelist = sorted(glob.glob(os.path.join(datadir, f"*{varname}*.nc")))
    nfiles = len(datafilelist)
    logger.info("Working on {} files".format(nfiles))

    fig = plt.figure(figsize=(12, 12))
    regionkeyold = ""
    for datafile in datafilelist:
        regionkey = os.path.basename(datafile).split("_")[0]
        logger.info(regionkey)

        region = regiondict[regionkey]
        region.get_data_coords(datafile)

        col = colorlist[regionkey]
        pp = m.plot(region.londata, region.latdata, "o", color=col, ms=.03, latlon=True)

        if regionkey != regionkeyold:
            m.plot(5., 51., "o", ms=5, color=col, markerfacecolor=col, latlon=True, label=region.name)

        regionkeyold = regionkey

    m.plot(5., 51., "o", ms=6, color=".75", markerfacecolor=".75", latlon=True, zorder=4)
    m.fillcontinents(color=".75")
    plt.legend(fontsize=14, loc=3)
    plt.title(f"Observations of sea water {varname} concentration")
    if len(figname) > 0:
        plt.savefig(figname)
    plt.close()

def plot_data_locations_domains(m, varname, regiondict, figname=""):
    """Plot the data positions and the domains on the map

    Parameters
    ----------
    m : Basemap
        Basemap projection obtained `m = Basemap(projection=...)`
    varname : str
        Name of the variable; should be one of those:
        "phosphate", "silicate", "ammonium", "chlorophyll-a",
        "dissolved_inorganic_nitrogen", "dissolved_oxygen"
    regiondict : dict
        Dictionary to link the file names to the regions
    figname : str default: None
        Path of the figure to be saved; if "", no figure is saved
    """
    datafilelist = sorted(glob.glob(os.path.join(datadir, f"*{varname}*.nc")))
    nfiles = len(datafilelist)
    logger.info("Working on {} files".format(nfiles))

    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111)

    regionkeyold = ""
    for datafile in datafilelist:
        regionkey = os.path.basename(datafile).split("_")[0]
        region = regiondict[regionkey]
        region.get_data_coords(datafile)

        col = colorlist[regionkey]
        pp = m.plot(region.londata, region.latdata, "o", color=col, ms=.03, latlon=True)

        if regionkey != regionkeyold:

            # Get rectangle of products
            region.get_rect_coords()
            region.get_rect_patch(m, facecolor=col, alpha=0.4)

            m.plot(region.lonvector, region.latvector, color=col,
                   latlon=True, label=region.name, linewidth=2)
            ax.add_patch(region.rect)

        regionkeyold = regionkey

    m.plot(5., 51., "o", ms=6, color=".75", markerfacecolor=".75", latlon=True, zorder=4)
    m.fillcontinents(color=".75")
    plt.legend(fontsize=14, loc=3)
    plt.title(f"Observations of sea water {varname} concentration")
    if len(figname) > 0:
        plt.savefig(figname)
    plt.close()

def plot_hexbin_datalocations(m, varname, figname=None):
    """Create hexbin plot using the data positions read from a list of file

    Parameters
    ----------

    m : Basemap
        Basemap projection obtained `m = Basemap(projection=...)`
    varname : str
        Name of the variable; should be one of those:
        "phosphate", "silicate", "ammonium", "chlorophyll-a",
        "dissolved_inorganic_nitrogen", "dissolved_oxygen"
    figname : str default: None
        Path of the figure to be saved; if "", no figure is saved
    """

    # Generate list of files corresponding to the data directory
    datafilelist = sorted(glob.glob(os.path.join(datadir, f"*{varname}*.nc")))
    nfiles = len(datafilelist)
    logger.info("Working on {} files".format(nfiles))

    lonall, latall, dates_all = all_positions(m, datafilelist)
    fig = plt.figure(figsize=(10, 10))

    m.hexbin(lonall, latall, bins="log", vmin=1, vmax=100000,
             mincnt=3, gridsize=30, zorder=3, cmap=plt.cm.hot_r)
    m.fillcontinents(color=".75", zorder=5, alpha=.9)
    cb = plt.colorbar(shrink=.7, extend="both")
    #cb.set_ticks([1., 2., 3., 4., 5.])
    #cb.set_ticklabels(["10", "100", "1000", "10000", "100000"])
    cb.set_label("Number of\ndata points\nper cell", fontsize=14, rotation=0, ha="left")
    plt.title(varname.replace("_", " ").capitalize())
    if figname is not None:
        plt.savefig(figname)
    plt.close()

def make_histo_values(obsval, varname, figdir="./"):
    """Create a histogram from the values stored in array `obsval`
    """

    # Set limits from the percentile
    vmax = np.percentile(obsval, 97.5)
    vmin = np.percentile(obsval, 2.5)

    if varname == "chlorophyll-a":
        units = r"mg/m$^{3}$"
    else:
        units = r"$\mu$moles/l"

    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111)

    plt.hist(obsval, bins=np.linspace(vmin, vmax, 20), rwidth=.8, color=".2")
    plt.ylabel("Number of\nobservations", rotation=0, ha="right")
    plt.xlabel(units)
    plt.title(varname.replace("_", " ").capitalize())
    plt.savefig(os.path.join(figdir, f"values_histogram_{varname}"))
    #plt.show()
    plt.close()

def make_histo_year(years, varname, figdir="./"):
    """Create an histogram from the years
    """
    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111)
    plt.hist(years, bins=np.arange(1928, 2021), rwidth=.8, color=".2")
    plt.xticks(np.arange(1930, 2030, 10))
    fig.autofmt_xdate()
    plt.ylabel("Number of\nobservations", rotation=0, ha="right")
    plt.xlim(1925, 2021)
    plt.title(varname.replace("_", " ").capitalize())
    plt.savefig(os.path.join(figdir, f"year_histogram_{varname}"))
    plt.close()

def make_histo_month(months, varname, figdir="./"):
    """Create an histogram for the month
    """
    monthlist = [calendar.month_name[i] for i in range(1, 13)]
    fig = plt.figure(figsize=(12, 12))
    ax = plt.subplot(111)
    plt.hist(months, bins=12, rwidth=.8, color=".2")
    plt.xticks(np.arange(1.5, 13.5), monthlist)
    plt.ylabel("Number of\nobservations", rotation=0, ha="right")
    fig.autofmt_xdate()
    plt.title(varname.replace("_", " ").capitalize())
    plt.savefig(os.path.join(figdir, f"month_histogram_{varname}"))
    plt.close()

def plot_month_depth_ndata(obsdepth, months, figname="", depthlist = [5., 100., 500., 1000., 2000.]):
    """Create a polar plot where the angle is the month and the radius is
    the number of available measurements

    Parameters
    ----------
    obsdepth : list or tuple
        Depths of the observations.
    months : array
        Month for each measurement.
    figname : str, default=""
        Path of the figure
    depthlist : list or tuple, default=[5., 100., 500., 1000., 2000.]
        Depth levels at which the number of observations will be counted

    """
    angles = np.arange(0, 2. * np.pi + .1, np.pi / 6.)

    fig = plt.figure(figsize=(10, 10))
    ax = plt.subplot(111, projection='polar')
    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    ax.grid(color='.85', linestyle = '--', linewidth=1)
    ax.set_thetagrids(np.arange(0, 360, 30),
                      labels=[calendar.month_name[ii] for ii in range(1, 13)],
                      fontsize=20)
    ax.set_rlabel_position(2)
    ax.set_rgrids(np.arange(250000, 1500000, 250000))

    # Loop on the depths of interest
    for dd in depthlist:

        # Find data above (i.e., shallower than) the considered depth
        depthselector = np.where(obsdepth <= dd)[0]
        monthsdepth = months[depthselector]

        # Loop on the month
        ndatamonth = np.zeros(13)
        for mm in range(0, 12):
            # logger.info(mm)
            monthselector = np.where(monthsdepth == mm+1)[0]
            ndatamonth[mm] = len(monthselector)
        ndatamonth[-1] = ndatamonth[0]

        ax.plot(angles, ndatamonth, "o-", ms=5, label="< {} m".format(int(dd)))

    ax.yaxis.set_major_formatter(FormatStrFormatter('%d'))
    ax.legend(bbox_to_anchor=(1.2, 1.1))
    plt.title("Number of measurements of {}".format(varname))
    if len(figname) > 0:
        plt.savefig(figname)
    plt.close()


class Region(object):
    def __init__(self, lonmin, lonmax, latmin, latmax, dlon, dlat, name=None):
        self.lonmin = lonmin
        self.lonmax = lonmax
        self.latmin = latmin
        self.latmax = latmax
        self.dlon = dlon
        self.dlat = dlat
        self.name = name

    def get_coords(self):
        self.lons = np.arange(self.lonmin, self.lonmax + self.dlon, self.dlon)
        self.lats = np.arange(self.latmin, self.latmax + self.dlat, self.dlat)

    def get_rect_coords(self):

        self.get_coords()
        lonvector = self.lons
        lonvector = np.append(lonvector, self.lonmax * np.ones_like(self.lats))
        lonvector = np.append(lonvector, np.fliplr([self.lons])[0])
        lonvector = np.append(lonvector, self.lonmin * np.ones_like(self.lats))
        self.lonvector = lonvector

        latvector = self.latmin * np.ones_like(self.lons)
        latvector = np.append(latvector, self.lats)
        latvector = np.append(latvector, self.latmax * np.ones_like(self.lons))
        latvector = np.append(latvector, np.fliplr([self.lats])[0])
        self.latvector = latvector

    def get_rect_patch(self, m, **kwargs):
        x, y = m(self.lonvector, self.latvector)
        coords = []
        for xx, yy in zip(x, y):
            coords.append((xx, yy))
        self.rect = Polygon(coords, **kwargs)

    def get_data_coords(self, datafile):
        """
        Read the coordinates from the in situ data file
        """
        with netCDF4.Dataset(datafile, "r") as nc:
            self.londata = nc.get_variables_by_attributes(standard_name="longitude")[0][:]
            self.latdata = nc.get_variables_by_attributes(standard_name="latitude")[0][:]
