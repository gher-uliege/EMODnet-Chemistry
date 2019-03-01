import netCDF4
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.patches import Polygon
import warnings
import matplotlib.cbook
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)


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
