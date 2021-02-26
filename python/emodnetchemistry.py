import netCDF4
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import Polygon
import warnings
import matplotlib.cbook
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)


def make_histo_values(obsval, varname):
    """Create a histogram from the values stored in array `obsval`
    """

    # Set limits from the percentile
    vmax = np.percentile(obsval, 97.5)
    vmin = np.percentile(obsval, 2.5)

    if varname == "chlorophyll-a":
        units = r"mg/m^{3}"
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

def make_histo_year(years, varname):
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

def make_histo_month(months, varname):
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
