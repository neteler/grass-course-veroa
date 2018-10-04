#!/bin/bash

########################################################################
# Worflow for Landsat 8 data processing in GRASS GIS
# GRASS GIS postgraduate course in Rio Cuarto
# Author: Veronica Andreo
# October, 2018
########################################################################

# Download Landsat 8 scene for NC
https://earthexplorer.usgs.gov/

# Launch GRASS GIS, -c creates new mapset user1_l8
grass72 $HOME/grassdata/nc_spm_08_grass7/user1_l8/ -c
# Let us check the projection of the location
g.proj -p
# List all the mapsets in the search path
g.mapsets -p
# Add the mapset landsat to the search path
g.mapsets mapset=landsat operation=add
# List all the mapsets in the search path
g.mapsets -p
# List all the raster maps in all the mapsets in the search path
g.list type=rast
# Set the computational region 
g.region rast=lsat7_2002_20 res=30 -a    

# Change directory to the input Landsat 8 data
cd $HOME/data_dir/LC80150352016168LGN00
# Define a variable
BASE="LC80150352016168LGN00"

# Define a loop to import all the bands
for i in "1" "2" "3" "4" "5" "6" "7" "9" "QA" "10" "11"; do
  r.import input=${BASE}_B${i}.TIF output=${BASE}_B${i} resolution=value resolution_value=30
done

# PAN band 8 imported separately because of different spatial resolution
r.import input=${BASE}_B8.TIF output=${BASE}_B8 resolution=value resolution_value=15

Task: Note that we are using r.import instead of r.in.gdal to import the data. Check the difference between two and explain why we used r.import here?

Task: Repeat the import step for the second scene "LC80150352016200LGN00"

The next step is to convert the digital number (Landsat 8 OLI sensor provides 16 bit data with range between 0 and 65536) to TOA reflectance. For the thermal bands 10 and 11, DN is converted to TOA Brightness Temperature. In GRASS GIS i.landsat.toar can do this step for all the landsat sensors.

# Convert from DN to TOA reflectance and Brightness Temperature
i.landsat.toar input=${BASE}_B output=${BASE}_toar metfile=${BASE}_MTL.txt sensor=oli8
g.list rast map=. pattern=${BASE}_toar*

Now let us use the PAN band 8 (15 m resolution) to downsample other spectral bands to 15 m resolution. We use an addon i.fusion.hpf which applies a high pass filter addition method to down sample. Here we introduce the long list of addons in GRASS GIS and demonstrate how to install and use them. Check g.extension to install the addons and GRASS GIS addons for the list of available addons.

# Set the region
g.region rast=lsat7_2002_20 res=15 -a
# Install the reqquired addon
g.extension extension=i.fusion.hpf op=add
# Apply the fusion based on high pass filter
i.fusion.hpf -l -c pan=${BASE}_toar8 msx=${BASE}_toar1,${BASE}_toar2,${BASE}_toar3,${BASE}_toar4,${BASE}_toar5,${BASE}_toar6,${BASE}_toar7 center=high modulation=max trim=0.0 --o
# list the fused maps
g.list rast map=. pattern=${BASE}_toar*.hpf


Image Composites

# Set the region
g.region rast=lsat7_2002_20 res=15 -a
# Enhance the colors in the clipped region
i.colors.enhance red="${BASE}_toar4.hpf" green="${BASE}_toar3.hpf" blue="${BASE}_toar2.hpf" strength=95
# Create RGB composites
r.composite red="${BASE}_toar4.hpf" green="${BASE}_toar3.hpf" blue="${BASE}_toar2.hpf" output="${BASE}_toar.hpf_comp_432"
# Enhance the colors in the clipped region
i.colors.enhance red="${BASE}_toar5.hpf" green="${BASE}_toar4.hpf" blue="${BASE}_toar3.hpf" strength=95
# Create RGB composites
r.composite red="${BASE}_toar5.hpf" green="${BASE}_toar4.hpf" blue="${BASE}_toar3.hpf" output="${BASE}_toar.hpf_comp_543"  

Cloud mask from the QA layer

# Set the region
g.region rast=lsat7_2002_20 res=15 -a
# Install the required extension
g.extension extension=i.landsat8.qc op=add
# Create a rule set
i.landsat8.qc cloud="Maybe,Yes" output=Cloud_Mask_rules.txt
# Reclass the BQA band based on the rule set created 
r.reclass input=${BASE}_BQA output=${BASE}_Cloud_Mask rules=Cloud_Mask_rules.txt
# Report the area covered by Cloud
r.report -e map=${BASE}_Cloud_Mask units=k -n

Vegetation Indices

# Set the region
g.region rast=lsat7_2002_20 res=15 -a
# Set the cloud mask to avoid computing over clouds
r.mask rast=${BASE}_Cloud_Mask
# Compute NDVI
r.mapcalc "${BASE}_NDVI = (${BASE}_toar5.hpf - ${BASE}_toar4.hpf) / (${BASE}_toar5.hpf + ${BASE}_toar4.hpf) * 1.0"
# Set the color palette
r.colors ${BASE}_NDVI color=ndvi
# Compute NDWI
r.mapcalc "${BASE}_NDWI = (${BASE}_toar5.hpf - ${BASE}_toar6.hpf) / (${BASE}_toar5.hpf + ${BASE}_toar6.hpf) * 1.0"
# Set the color palette
r.colors ${BASE}_NDWI color=ndwi
# Remove the mask
r.mask -r
           
Texture extraction

r.texture input=lsat7_2002_80 prefix=lsat7_2002_80_texture size=7 distance=1 method=corr,idm,entr

#Use scatter plot in Map Display to compare IDM and Entr textures.

 
Unsupervised Classification

# List the bands needed for classification
g.list rast map=. pattern=${BASE}_toar*.hpf
# add maps to an imagery group for easier management
i.group group=${BASE}_hpf subgroup=${BASE}_hpf input=`g.list rast map=. pattern=${BASE}_toar*.hpf sep=","`
# statistics for unsupervised classification
i.cluster group=${BASE}_hpf subgroup=${BASE}_hpf sig=${BASE}_hpf classes=8 separation=0.5
# Maximum Likelihood unsupervised classification
i.maxlik group=${BASE}_hpf subgroup=${BASE}_hpf sig=${BASE}_hpf output=${BASE}_hpf.class rej=${BASE}_hpf.rej
    
