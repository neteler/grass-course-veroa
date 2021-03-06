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

## Satellite imagery processing in GRASS GIS

---

@snap[north-west span-60]
<h3>Overview</h3>
@snapend

@snap[west span-100]
<br><br>
@ol[list-content-verbose]
- Basics of Imagery processing in GRASS GIS
- Digital Number to Reflectance
- Data fusion/Pansharpening
- Create composites
- Cloud mask from quality band
- Vegetation and Water indices
- Unsupervised classification
@olend
@snapend

---

### Basics of imagery processing in GRASS GIS

Satellite data is identical to raster data @fa[arrow-right] same rules apply
<br>

> @color[#8EA33B](*i.**) commands are explicitly dedicated to image processing

<br>

@size[24px](For further details see: <a href="https://grass.osgeo.org/grass74/manuals/imageryintro.html">Imagery Intro</a> manual and <a href="https://grasswiki.osgeo.org/wiki/Image_processing">Image Processing</a> wiki)

---

@snap[north span-100]
<h3>Data</h3>
@snapend

@snap[west span-60]
Two Landsat 8 (OLI) scenes
@ul[list-content-verbose](false)
- Dates: 16 June 2016 and 18 July 2016
- Path/Row: 015/035
- CRS: UTM zone 18 N (EPSG:32618)
@ulend
<br>
@snapend

@snap[east span-40]
![L8](https://landsat.gsfc.nasa.gov/sites/landsat/files/2013/01/ldcm_2012_COL-300x168.png)
<br><br>
@snapend

@snap[south span-100]
Download the clipped [Landsat 8 scenes](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/data/NC_L8_scenes.zip?inline=false), move the file to `$HOME/gisdata` and unzip it there.

Also download the file with the [code](https://gitlab.com/veroandreo/curso-grass-gis-rioiv/raw/master/code/04_L8_imagery_code.sh?inline=false) to follow this session.
@snapend

+++

![L8 vs L7 bands](https://landsat.gsfc.nasa.gov/sites/landsat/files/2013/01/ETM+vOLI-TIRS-web_Feb20131.jpg)

@size[24px](Spectral bands of Landsat 7 ETM+ and 8 OLI. Source: <https://landsat.gsfc.nasa.gov/landsat-data-continuity-mission/> and <a href="https://landsat.usgs.gov/what-are-band-designations-landsat-satellites">Landsat bands details</a>)

---?code=code/04_L8_imagery_code.sh&lang=bash&title=Start GRASS and create new mapset

@[19-20](Launch GRASS GIS and create new mapset landsat8)
@[21-22](Check the projection)
@[23-28](List mapsets and add landsat mapset to path)
@[29-30](List all available raster maps)
@[31-32](Set computational region to a landsat scene)
   
---?code=code/04_L8_imagery_code.sh&lang=bash&title=Import L8 data

@[35-38](Change directory and set variable)
@[46-51](Import all the bands with 30m res, note extent=region)
@[53-56](Import PAN band separately)            
        
+++

@snap[north span-100]
Directory option to import from the GUI
@snapend

@snap[west span-50]
<br>
<img src="assets/img/import_directory_1.png">
@snapend

@snap[east span-50]
<br>
<img src="assets/img/import_directory_2.png">
@snapend

+++

> **Task:** 
>
> - Note that we are using [r.import](https://grass.osgeo.org/grass74/manuals/r.import.html) instead of [r.in.gdal](https://grass.osgeo.org/grass74/manuals/r.in.gdal.html) to import the data. Check the difference between the two of them and explain why we used r.import here?
> - Repeat the import step for the second scene "LC80150352016200LGN00"

---

#### From Digital Number (DN) to Reflectance and Temperature

- Landsat 8 OLI sensor provides 16-bit data with range between 0 and 65536.
- [i.landsat.toar](https://grass.osgeo.org/grass74/manuals/i.landsat.toar.html) converts DN to TOA reflectance (and brightness temperature) for all Landsat sensors. It optionally provides surface reflectance after DOS atmospheric correction. 
- [i.atcorr](https://grass.osgeo.org/grass74/manuals/i.atcorr.html) provides more complex atmospheric correction method for many sensors, i.e., S6.

+++?code=code/04_L8_imagery_code.sh&lang=bash&title=DN to Reflectance and Temperature

@[64-66](Convert from DN to surface reflectance and temperature - DOS method)
@[68-72](Check info before and after conversion for one band)

+++

![Band 10 Temperature](assets/img/L8_band10_kelvin.png)

@size[24px](L8 band 10 with kelvin color pallete)

+++

> **Task:** 
>
> - Repeat the conversion step for the second scene "LC80150352016200LGN00"
> - Set the color palette of Band 10 of LC80150352016200LGN00 to "kelvin" and visualize

---

#### Data fusion/Pansharpening

We'll use the PAN band 8 (15 m resolution) to downsample other spectral bands to 15 m resolution

<br>
> [i.fusion.hpf](https://grass.osgeo.org/grass7/manuals/addons/i.fusion.hpf.html) applies a high pass filter addition method

+++?code=code/04_L8_imagery_code.sh&lang=bash&title=Data fusion/Pansharpening

@[80-81](Install extension)
@[83-84](Set the region)
@[86-91](Run the fusion)
@[93-94](List fused maps)
@[96-98](Visualize differences)

+++            

<img src="assets/img/pansharpen_mapswipe.png" width="75%">

@size[24px](Original 30m data and fused 15m data)

+++

> **Task:** Repeat the fusion step for the second scene "LC80150352016200LGN00"

---?code=code/04_L8_imagery_code.sh&lang=bash&title=Image Composites

@[106-110](Enhance the colors for natural color composition)
@[112-116](Display RGB combination - d.rgb)
@[118-122](Create RGB 432 composite)
@[124-128](Enhance the colors for false color composition)
@[130-134](Create RGB 543 composite)
@[136-138](Display the composite raster)

+++

![Composites 432 and 543](assets/img/composites_432_543.png)

@size[24px](True color and False color composites of the Landsat 8 image dated 18 July 2016)

+++

> **Task:** Create the composites for the second scene "LC80150352016200LGN00"

---

#### Cloud mask from the QA layer

- Landsat 8 provides a quality layer which contains 16bit integer values
that represent *bit-packed combinations of surface, atmosphere, and
sensor conditions that can affect the overall usefulness of a given
pixel*. 
- [i.landsat8.qc](https://grass.osgeo.org/grass7/manuals/addons/i.landsat8.qc.html)
reclassifies Landsat8 QA band according to pixel quality. 

<br>
@size[24px](More information about L8 quality band at http://landsat.usgs.gov/qualityband.php)

+++?code=code/04_L8_imagery_code.sh&lang=bash&title=Apply cloud mask from QA layer
 
@[146-147](Install i.landsat8.qc extension)
@[149-150](Create the rule set with clouds QA band)
@[152-153](Reclass the BQA band based on the rule set created )
@[155-156](Report the area covered by cloud)
@[158-160](Display the reclassified map)

+++

![Cloud mask and Composites 543](assets/img/cloud_composite_543.png)

@size[24px](False color composite and the derived cloud mask of the Landsat 8 image dated 16 June 2016)

+++

> **Task:** Visually compare the cloud coverage with the false color composite

---?code=code/04_L8_imagery_code.sh&lang=bash&title=Vegetation and water indices

@[168-169](Set the cloud mask to avoid computing over clouds)
@[171-174](Compute NDVI and set color pallete)
@[176-179](Compute NDWI and set color pallete)
@[181-182](Remove the mask)
@[184-187](Display the maps)

+++

![NDVI and NDWI](assets/img/L8_ndvi_ndwi.png)

@size[24px](NDVI and NDWI derived from Landsat 8 image dated 16 June 2016)

+++
            
> **Task:** Compute the vegetation indices from the second scene "LC80150352016200LGN00"

---

#### Unsupervised Classification

@ol
- Group the images: [i.group](https://grass.osgeo.org/grass74/manuals/i.group.html)
- Generate signatures for n classes: [i.cluster](https://grass.osgeo.org/grass74/manuals/i.cluster.html)
- Classify using Maximum likelihood: [i.maxlik](https://grass.osgeo.org/grass74/manuals/i.maxlik.html)
@olend   
        
+++?code=code/04_L8_imagery_code.sh&lang=bash&title=Unsupervised classification

@[195-196](List all maps with pattern)
@[198-200](Create an imagery group for ease of management)
@[202-206](Get statistics -signatures- for unsupervised classification)
@[208-212](Unsupervised classification)
@[214-216](Display classified map)

+++

![L8 Unsupervised Classification](assets/img/L8_unsup_class.png)

@size[24px](Unsupervised classification - Landsat 8 image dated 16 June 2016)

+++

More derived information could be obtained from:

- texture measures ([r.texture](https://grass.osgeo.org/grass74/manuals/r.texture.html)), 
- diversity measures ([r.diversity](https://grass.osgeo.org/grass7/manuals/addons/r.diversity.html)), 
- contextual information ([r.neighbors](https://grass.osgeo.org/grass74/manuals/r.neighbors.html)),
- etc.

---

### Learn more about classification in GRASS GIS

- [Topic classification](http://grass.osgeo.org/grass74/manuals/topic_classification.html) in GRASS GIS manual
- [Image classification](http://grasswiki.osgeo.org/wiki/Image_classification) in the GRASS wiki
- [Classification examples](http://training.gismentors.eu/grass-gis-irsae-winter-course-2018/units/28.html) at GRASS GIS course IRSAE 2018
- [Classification with Random Forest](https://neteler.gitlab.io/grass-gis-analysis/03_grass-gis_ecad_randomforest/) at GRASS GIS presentation GEOSTAT 2018

---

## QUESTIONS?

<img src="assets/img/gummy-question.png" width="45%">

---

**Thanks for your attention!!**

![GRASS GIS logo](assets/img/grass_logo_alphab.png)

---

@snap[north span-90]
<br><br><br>
Move on to: 
<br>
[Exercise 3: Working with Sentinel 2 images](https://gitpitch.com/veroandreo/curso-grass-gis-rioiv/master?p=exercises/04_processing_sentinel2&grs=gitlab#/)
@snapend

@snap[south span-50]
@size[18px](Presentation powered by)
<br>
<a href="https://gitpitch.com/">
<img src="assets/img/gitpitch_logo.png" width="20%"></a>
@snapend
