---?image=template/img/grass.png&position=bottom&size=100% 30%
@title[Front page]

@snap[north span-100]
<br>
<h2>Procesamiento de series de tiempo en @color[green](GRASS GIS)</h2>
<h3>Aplicaciones en Ecología y Ambiente</h3>
@snapend

@snap[south message-box-white]
<br>Dra. Verónica Andreo<br>CONICET - INMeT<br><br>Río Cuarto, 2018<br>
@snapend

---?image=template/img/grass.png&position=bottom&size=100% 30%

## Exercise 2: Create a new Location and Mapset

---

@snap[north-west span-60]
<h3>Overview</h3>
@snapend

@snap[west span-100]
<br><br>
@ol[list-content-verbose]
- Revise GRASS GIS database structure
- Data fo the exercise
- Create new locations and mapsets: different options
- Change mapsets / add mapsets to path
- Import raster and vector map
- Reproject raster and vector maps
- Export raster and vector maps
@olend
@snapend

---

@snap[north span-100]
<h3>Data for this exercise</h3>
@snapend

@snap[west span-100]
@ul[](false)
- Download the [raster](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/blob/master/data/sample_rasters.zip) and [vector](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/blob/master/data/streets.gpkg) sample files
- Create a folder in your `$HOME` directory (or Documents) and name it `gisdata`
- Unzip/Move the files within `$HOME/gisdata`
@ulend
@snapend

---

@snap[west span-55]
<img src="assets/img/start_screen2.png" width="90%">
@snapend

@snap[east span-45]
@ol[list-content-verbose]
- Select the GRASS database folder
- Select the `nc_spm_08_grass7` location 
- Select `user1` mapset
- Hit `Start GRASS session`
@olend
@snapend

---

@snap[north span-100]
<h3>Creating a new Location</h3>
@snapend

@snap[west span-100]
<br>
@ul[](false)
- From the GUI
  @ol[list-content-verbose](false)
  - button "New" in the Location wizard
  - from within a GRASS session: Settings @fa[arrow-right] GRASS working environment @fa[arrow-right] Create new location
  @olend
@ulend
<br><br>
@ul[](false)
- From the command line
  @ol[list-content-verbose](false)
  - using `-c` flag in the *[grass74](https://grass.osgeo.org/grass74/manuals/grass7.html)* start script
  - provide path to new location plus either a georeferenced map or an EPSG code
  @olend
@ulend
@snapend

---

#### Creating a new Location from the GUI

<img src="assets/img/new_location_epsg.png" width="99%">

@size[24px](Create new Lat-Long location using <a href="http://epsg.io/">EPSG</a> code)

---

<h4>Creating new location from command line</h4>

<br>
```bash
# Creates new location with EPSG code 4326
grass74 -c EPSG:4326 $HOME/grassdata/mylocation

# Creates new location based on georeferenced Shapefile 
grass74 -c myvector.shp $HOME/grassdata/mylocation

# Creates new location based on georeferenced GeoTIFF file 
grass74 -c myraster.tif $HOME/grassdata/mylocation
```

@size[26px](This can also be done from a different location; GRASS will switch to the newly created one.)

---

@snap[north span-100]
<h3>Creating a new mapset</h3>
@snapend

@snap[west span-100]
<br>
@ul[](false)
- From the GUI
  @ol[list-content-verbose](false)
  - button "New" in the Mapset wizard
  - from within a GRASS session: Settings @fa[arrow-right] GRASS working environment @fa[arrow-right] Create new mapset
  @olend
@ulend
<br><br>
@ul[](false)
- From command line
  @ol[list-content-verbose](false)
  - using `-c` flag in the *[grass74](https://grass.osgeo.org/grass74/manuals/grass7.html)* script, just add the mapset name to the path
  - with [g.mapset](https://grass.osgeo.org/grass74/manuals/g.mapset.html) command from within a GRASS session
  @olend
@ulend
@snapend

---
@snap[north span-100]
<h4>Creating a new mapset from the GUI</h4>
@snapend

@snap[west span-50]
<br>
@size[24px](using *New* button in wizard)
<img src="assets/img/new_mapset_gui.png" width="95%">
@snapend

@snap[east span-50]
@size[24px](from within a GRASS session)
<img src="assets/img/new_mapset_gui_within_grass.png" width="90%">
@snapend

---

#### Creating a new mapset from command line 

<br>
- Start GRASS and create location and mapset all at once
```bash
# Creates new location and mapset
grass74 -c EPSG:4326 $HOME/grassdata/mylocation/mymapset
```
<br>
- Create a mapset from within a running GRASS session:
```bash
# Create a new mapset within a GRASS session
g.mapset -c mapset=curso_rio4
```

---

### Remove Locations or Mapsets
<br>
> Just remove the folder or use the Location wizard

---

### Rename Locations and Mapsets
<br>
> From the Location wizard

---

### Change to a different mapset

- From the GUI:

<img src="assets/img/change_mapset.png" width="60%">

- From command line: 
```bash
# print current mapset
g.mapset -p
# list available mapsets
g.mapsets -l
# change to user1 mapset
g.mapset mapset=user1
```

---

### Add mapsets to path

Sometimes we need to @color[#8EA33B](*read data from a different mapset*) and use it for a certain processing, so we need to @color[#8EA33B](*see*) that mapset from the current one
<br>
```bash
# print accessible mapsets
g.mapsets -p
# add user1 to the accessible mapsets
g.mapsets mapset=user1 operation=add
# check it was added
g.mapsets -p
# check current mapset
g.mapset -p
```

---

>**Tasks:**
>
>- Create a new location with EPSG:4326 and name it *@color[green](latlong)*
>- Create a new mapset called *@color[green](curso_rio4)* within the *latlong* location

<br>

Choose whatever method you prefer

*Hint:* from command line is only one line @fa[smile-o fa-spin]...

---

### Import raster and vector maps
<br>
- [r.in.gdal](https://grass.osgeo.org/grass74/manuals/r.in.gdal.html): Imports raster data into a GRASS raster map using GDAL library. 
```bash
r.in.gdal input=myraster.tif output=myraster
```
<br>
- [v.in.ogr](https://grass.osgeo.org/grass74/manuals/v.in.ogr.html): Imports vector data into a GRASS vector map using OGR library. 
```bash
v.in.ogr input=myvector.shp output=myvector
```

@size[20px](CRS of maps must match that of the Location)

+++

### Import raster and vector maps
<br>
Alternatively, we can use:

- [r.import](https://grass.osgeo.org/grass74/manuals/r.import.html) 
- [v.import](https://grass.osgeo.org/grass74/manuals/v.import.html)

that offer also re-projection, resampling and subset on the fly @fa[smile-o]

+++

@snap[north span-100]
<h4>Import a raster map</h4>
@snapend

@snap[west span-50]
<img src="assets/img/r_import_1.png">
@snapend

@snap[east span-50]
<img src="assets/img/r_import_2.png">
@snapend

+++

@snap[north span-100]
<h4>Import a vector map</h4>
@snapend

@snap[west span-50]
<img src="assets/img/v_import_1.png">
@snapend

@snap[east span-50]
<img src="assets/img/v_import_2.png">
@snapend

+++

![imported maps](assets/img/imported_maps.png)

@size[24px](Imported maps are displayed by default)

---

#### Create location and mapset from georeferenced file

<img src="assets/img/new_location_with_file_a.png" width="95%">

+++

#### Create location and mapset from georeferenced file

<img src="assets/img/new_location_with_file_b.png" width="95%">

+++

#### Create location and mapset from georeferenced file

<img src="assets/img/new_location_with_file_8.png" width="80%">

@size[24px](How to get metadata from any raster map?)

```bash
gdalinfo <mapname>
```

---

### Set computational region
<br>
```bash
# check region
g.region -p
# set region to imported raster map
g.region raster=XX
```

---

### Working without importing maps
<br>
We can also only **link** our geodata to the GRASS DB:

- [r.external](https://grass.osgeo.org/grass74/manuals/r.external.html): Links GDAL supported raster data as a pseudo GRASS raster map.
- [v.external](https://grass.osgeo.org/grass74/manuals/v.external.html): Creates a pseudo-vector map as a link to an OGR-supported layer or a PostGIS feature table. 

<br>
**Do not rename, delete or move the *linked* file afterwards... !**

---

### Maps reprojection
<br>
Locations are defined by CRS, so 

> to transfer maps between locations @fa[arrow-right] map re-projection

+++

### Maps reprojection
<br>
- **Raster map re-projection:**
The user needs to set desired extent and resolution prior to re-projection in target location
- **Vector map re-projection:**
The whole vector map is re-projected by coordinate conversion

>**Mechanism:**
>Working in target location, maps are projected into it from the source location

---

>**Tasks:**
> 
>- Create a new location named @color[green](UTM18N) from the L8 band 5 file and then reproject (with [r.proj](https://grass.osgeo.org/grass74/manuals/r.proj.html)) it to North Carolina location (mapset curso_rio4)
>- Now, import (with reprojection on the fly) the L8 band 2 file into North Carolina location (mapset curso_rio4) and set the region to the imported raster map 

---

### Export raster and vector maps
<br>
>**Task:**
> 
>Explore [r.out.gdal](https://grass.osgeo.org/grass74/manuals/r.out.gdal.html) and [v.out.ogr](https://grass.osgeo.org/grass74/manuals/v.out.ogr.html) manual pages and export *elevation* and *roadsmajor* maps

---

**Thanks for your attention!!**

![GRASS GIS logo](assets/img/grass_logo_alphab.png)

---

@snap[north span-90]
<br><br><br>
Move on to: 
<br>
[Raster data processing](https://gitpitch.com/veroandreo/curso-grass-gis-rioiv/master?p=slides/03_raster&grs=gitlab#/)
@snapend

@snap[south span-50]
@size[18px](Presentation powered by)
<br>
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="20%"></a>
@snapend
