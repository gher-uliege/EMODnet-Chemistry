import os
import glob
import netCDF4
import calendar
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import Polygon
import warnings
import matplotlib.cbook
import logging
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)

logger = logging.getLogger("EMODnet-Chemistry-Data-positions")
logger.setLevel(logging.DEBUG)
logging.info("Starting")

colorlist = {"ArcticSea": "#1f77b4", "Atlantic": "#ff7f0e",
             "BalticSea": "#2ca02c", "BlackSea": "#d62728",
             "MedSea2": "#9467bd", "NorthSea": "#8c564b"}

datadir = "/data/EMODnet/Eutrophication/Split/"

def read_all_positions(datafilelist):
    """Read all the longitudes and latitudes from a list of file
    """
    lonall = np.array([])
    latall = np.array([])
    for datafile in datafilelist:
        with netCDF4.Dataset(datafile, "r") as nc:
            lon = nc.get_variables_by_attributes(standard_name="longitude")[0][:]
            lat = nc.get_variables_by_attributes(standard_name="latitude")[0][:]
        llon, llat = m(lon, lat)
        lonall = np.append(lonall, llon)
        latall = np.append(latall, llat)

def read_oxy_woa(datafile, domain, filetype="woa"):
    """Read the variable from the WOA or DIVAnd netCDF file `datafile`
    """

    with netCDF4.Dataset(datafile, "r") as nc:
        lon = nc.variables["lon"][:]
        lat = nc.variables["lat"][:]
        goodlon = np.where( (lon >= domain[0]) & (lon <= domain[1]) )[0]
        goodlat = np.where( (lat >= domain[2]) & (lat <= domain[3]) )[0]
        lon = lon[goodlon]
        lat = lat[goodlat]
        depth = nc.variables["depth"][:]

        if filetype == "woa":
            oxy = nc.variables["o_an"][0,:,goodlat,goodlon]
        elif filetype == "diva":
            oxy = nc.variables["Water body dissolved oxygen concentration"][0,:,goodlat,goodlon]

    return lon, lat, depth, oxy

def plot_oxy_map(llon, llat, field, depth, figname=None):
    """Create map with the interpolated values of oxygen concentration
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
    if figname is not None:
        plt.savefig(figname, dpi=300, bbox_inches="tight")
    # plt.show()
    plt.close()

def plot_WOA_DIVAnd_comparison(m, lon1, lat1, field1, lon2, lat2, field2, depth, figname=None,
                              vmin=200., vmax=375., deltavar=25.,
                              units=r"$\mu$moles/kg"):

    """Create a plot with WOA and DIVAnd maps together
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
    plt.title("World Ocean Atlas 2018 at {} m".format(int(depth)))

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
    cb = plt.colorbar(pcm,  cax=cbar_ax, extend="both", orientation="horizontal")
    cb.set_label(units, rotation=0, ha="left")
    cb.set_ticks(np.arange(vmin, vmax + 0.0001, deltavar))
    if figname is not None:
        plt.savefig(figname, dpi=300, bbox_inches="tight")
    plt.close()

def plot_data_locations(m, varname, regiondict, figname=None):
    """Plot the data location on a map, one color per region
    """
    logger.info("Data files in {}".format(datadir))
    datafilelist = sorted(glob.glob(os.path.join(datadir, f"*{varname}*.nc")))
    nfiles = len(datafilelist)
    logger.info("Working on {} files".format(nfiles))

    fig = plt.figure(figsize=(12, 12))
    regionkeyold = ""
    for datafile in datafilelist:
        regionkey = os.path.basename(datafile).split("_")[0]
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
    plt.title(f"Observations of sea water {varname} concentration", fontsize=20)
    if figname is not None:
        plt.savefig(figname, dpi=300, bbox_inches="tight", facecolor="w",
        transparent=False)
    plt.close()

def plot_data_locations_domains(m, varname, regiondict, figname):
    """Plot the data positions and the domains on the map
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
    plt.title(f"Observations of sea water {varname} concentration", fontsize=20)
    if figname is not None:
        plt.savefig(figname, dpi=300, bbox_inches="tight", facecolor="w",
                    transparent=False)
    plt.close()

def plot_hexbin_datalocations(m, varname, figname=None):
    """Create hexbin plot using the data positions read from a list of file
    """
    datafilelist = sorted(glob.glob(os.path.join(datadir, f"*{varname}*.nc")))
    nfiles = len(datafilelist)
    logger.info("Working on {} files".format(nfiles))

    lonall, latall = read_all_positions(datafilelist)
    fig = plt.figure(figsize=(10, 10))

    m.hexbin(lonall, latall, bins="log", vmin=1, vmax=100000,
             mincnt=3, gridsize=30, zorder=3, cmap=plt.cm.hot_r)
    m.fillcontinents(color=".75", zorder=5, alpha=.9)
    cb = plt.colorbar(shrink=.7, extend="both")
    #cb.set_ticks([1., 2., 3., 4., 5.])
    #cb.set_ticklabels(["10", "100", "1000", "10000", "100000"])
    cb.set_label("Number of profiles\nper cell", fontsize=14, rotation=0, ha="left")
    if figname is not None:
        plt.savefig(figname, dpi=300, bbox_inches="tight", facecolor="w",
        transparent=False)
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
    plt.title(varname.replace("_", " ").capitalize(), fontsize=20)
    plt.savefig(os.path.join(figdir, f"values_histogram_{varname}"), dpi=300, bbox_inches="tight")
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
    plt.title(varname.replace("_", " ").capitalize(), fontsize=20)
    plt.savefig(os.path.join(figdir, f"year_histogram_{varname}"), dpi=300, bbox_inches="tight")
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
    plt.title(varname.replace("_", " ").capitalize(), fontsize=20)
    plt.savefig(os.path.join(figdir, f"month_histogram_{varname}"), dpi=300, bbox_inches="tight")
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
