#!/bin/bash

########################################################################
# Worflow for Sentinel 2 data processing in GRASS GIS
# GRASS GIS postgraduate course in Rio Cuarto
# Author: Veronica Andreo
# October, 2018
########################################################################

# Create an account in copernicus-hub

# Create a text file called SENTINEL_SETTING with
your_username
your_password

# install dependencies
pip install sentinelsat
pip install pandas

# install extension
g.extension extension=i.sentinel

# set region to elevation map
g.region -p raster=elevation

# explore list of scenes for a certain date range
i.sentinel.download -l settings=$HOME/gisdata/SETTING_SENTINEL \
 start="2018-08-19" end="2018-08-26"
#~ 5 Sentinel product(s) found
#~ a559365f-8fc4-4399-8d1c-9123f72cc7a2 2018-08-24T15:48:09Z  1% S2MSI1C
#~ 780697f6-0071-4675-b7eb-662d1747776b 2018-08-24T15:48:09Z  5% S2MSI1C
#~ f188af8c-c7f6-47a6-aca2-4925e2cb2404 2018-08-22T15:59:01Z  6% S2MSI1C
#~ c326f43f-5b1f-46e0-8ecc-c37e819425fc 2018-08-22T15:59:01Z  9% S2MSI1C
#~ 74f27482-145d-42ea-a628-57a2bd9ca095 2018-08-19T15:49:01Z 16% S2MSI1C

# pick a scene to download
i.sentinel.download settings=$HOME/gisdata/SETTING_SENTINEL \
 uuid=a559365f-8fc4-4399-8d1c-9123f72cc7a2 output=$HOME/gisdata \
 footprints=sentinel_2018_08

# import the downloaded data
# -r flag is used to reproject the data during import
# -c flag allows to import the cloud mask
i.sentinel.import -rc input=$HOME/gisdata/

# display an RGB combination
d.mon wx0
d.rgb -n red=B04 green=B03 blue=B02
d.barscale length=50 units=kilometers segment=4 fontsize=14
d.text -b text="Sentinel original" color=black align=cc font=sans size=8

# perform color auto-balancing for RGB bands 
i.colors.enhance red=B04 green=B03 blue=B02

### The module to use is i.color.enhance. This module modifies the color table of each image band to provide a more natural color mixture, but the base data remains untouched. 


[i.sentinel.preproc](https://grass.osgeo.org/grass7/manuals/addons/i.sentinel.preproc.html)
requires some extra inputs since it also performs atmospheric
correction. First, this module requires the image as an unzipped
directory, so you have to unzip one of the previous downloaded files,
for example:
       
cd $HOME/gisdata/
unzip $HOME/gisdata/S2B_MSIL1C_20170730T154909_N0205_R054_T17SQV_20170730T160022.zip
        
Another required input is the visibility map. Since we do not have this
kind of data, we will replace it with an estimated Aerosol Optical Depth
(AOD) value. It is possible to obtain AOD from [http://aeronet.gsfc.nasa.gov](https://aeronet.gsfc.nasa.gov). 
In this case, we will use the
[EPA-Res_Triangle_Pk](https://aeronet.gsfc.nasa.gov/cgi-bin/webtool_opera_v2_inv?stage=3&region=United_States_East&state=North_Carolina&site=EPA-Res_Triangle_Pk&place_code=10&if_polarized=0)
station, select `01-07-2017` as start date and `30-08-2017` as end date, tick the box labelled as 'Combined file (all products without phase functions)' near the bottom, choose 'All Points' under Data
Format, and download and unzip the file into `$HOME/gisdata/` folder (the final file has a .dubovik extension).
The last input data required is the elevation map. Inside the `North Carolina basic location` there is an elevation map called `elevation`. The extent of the `elevation` map is smaller than our
Sentinel-2 image extent, so if you will use this elevation map only a subset of the Sentinel image will be atmospherically corrected; to get an elevation map for the entire area please read the [next
session](#srtm). At this point you can run [i.sentinel.preproc](https://grass.osgeo.org/grass74/manuals/addons/i.sentinel.preproc.html)
(please check which elevation map you want to use). The `text_file` option creates a text file useful as input for [i.sentinel.mask](https://grass.osgeo.org/grass74/manuals/addons/i.sentinel.mask.html),
the next step in the workflow.

            
i.sentinel.preproc -atr \
input_dir=$HOME/gisdata/S2B_MSIL1C_20170730T154909_N0205_R054_T17SQV_20170730T160022.SAFE \
elevation=elevation aeronet_file=$HOME/gisdata/170701_170831_EPA-Res_Triangle_Pk.dubovik \
suffix=corr text_file=$HOME/gisdata/sentinel_mask
            
d.mon wx0
d.rgb -n red=B04_corr green=B03_corr blue=B02_corr
d.barscale length=50 units=kilometers segment=4 fontsize=14
d.text -b text="Sentinel pre-processed scene" color=black align=cc font=sans size=8

get the clouds and clouds shadows masks for the Sentinel-2 scene using [i.sentinel.mask](https://grass.osgeo.org/grass74/manuals/addons/i.sentinel.mask.html).

i.sentinel.mask input_file=$HOME/gisdata/sentinel_mask \
 cloud_mask=T17SQV_20170730T160022_cloud \
 shadow_mask=T17SQV_20170730T160022_shadow \
 mtd=$HOME/gisdata/S2B_MSIL1C_20170730T154909_N0205_R054_T17SQV_20170730T160022.SAFE/MTD_MSIL1C.xml

visualize the output of [i.sentinel.mask](https://grass.osgeo.org/grass74/manuals/addons/i.sentinel.mask.html).

d.mon wx0
d.rgb -n red=T17SQV_20170730T154909_B04_corr green=T17SQV_20170730T154909_B03_corr blue=T17SQV_20170730T154909_B02_corr
d.vect T17SQV_20170730T160022_cloud fill_color=red
d.barscale length=50 units=kilometers segment=4 fontsize=14
d.text -b text="Cloud mask in red" color=black bgcolor=229:229:229 align=cc font=sans size=8


[Shuttle Radar Topography Mission (SRTM)](https://www2.jpl.nasa.gov/srtm/) is a worldwide Digital Elevation Model with a resolution of 30 or 90 meters. GRASS GIS has two
modules to work with SRTM data, [r.in.srtm](https://grass.osgeo.org/grass74/manuals/r.in.srtm.html) to import already downloaded SRTM data and, the add-on
[r.in.srtm.region](https://grass.osgeo.org/grass74/manuals/addons/r.in.srtm.region.html) which is able to download and import SRTM data for the current GRASS GIS
computational region. However, [r.in.srtm.region](https://grass.osgeo.org/grass74/manuals/addons/r.in.srtm.region.html) is working only in a Longitude-Latitude location.

First, we need to obtain the bounding box, in Longitude and Latitude on WGS84, of the Sentinel data we want to process
            
g.region raster=T17SQV_20170730T154909_B04,T17SPV_20170730T154909_B04 -b
    
change to a lat-long location

Set the right region using the values obtain before
           
g.region n=36:08:35N s=35:06:24N e=77:33:33W w=79:54:47W -p
            
After this you need to install [r.in.srtm.region](https://grass.osgeo.org/grass74/manuals/addons/r.in.srtm.region.html) and run it

g.extension r.in.srtm.region
r.in.srtm.region output=srtm user=your_NASA_user pass=your_NASA_password

You can now exit from this GRASS GIS session and restart to work in the previous one (where Sentinel data are).
To reproject the SRTM map from the `longlat` you have to use [r.proj](https://grass.osgeo.org/grass74/manuals/r.proj.html)

r.proj location=longlat mapset=PERMANENT input=srtm resolution=30

now you can use `srtm` map as input of `elevation` option in [i.sentinel.preproc](https://grass.osgeo.org/grass74/manuals/addons/i.sentinel.preproc.html)

# estimate indices

i.vi

i.wi

# classification

