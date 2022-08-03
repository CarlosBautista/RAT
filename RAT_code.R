library(raster)
library(rgdal)
library(rasterVis)

# load Alps Modis
MODIS_Alps <- raster("/ModisAlpsCrop.tif")
plot(MODIS_Alps)

# reproject
sr <- "+proj=longlat +datum=WGS84" 
MODIS_Alps_LatLong <- projectRaster(MODIS_Alps, crs = sr)
plot(MODIS_Alps_LatLong)

# load TS
BeechAlps <- read_csv("/BeechAlps.csv")
BeechAlps <- BeechAlps %>%
  st_as_sf(coords = c("X", "Y"), crs = 4326) %>%
  dplyr::select(ID)

plot(BeechAlps, col= "black", add=TRUE)

# get names
nam <- unique(BeechAlps$ID)

# create a data.frame
nam_df <- data.frame(ID2 = 1:length(nam), nam = nam)

# Place IDs
BeechAlps$ID2 <- nam_df$ID2[match(BeechAlps$ID,nam_df$nam)]

# rasterize
MODIS_Alps_LatLong
r <- raster(ncol = 185, nrow = 162, ext = extent(MODIS_Alps_LatLong)) # resolution and extent from MODIS
ras <- rasterize(x = BeechAlps, y = r, field = "ID2")

# ratify raster
r2 <- ratify(ras)

# Create levels
rat <- levels(r2)[[1]]
rat$names <- nam_df$nam
rat$IDs <- nam_df$ID2
rat
levels(r2) <- rat

rasterVis::levelplot(r2)
r2

# buffer
b <- buffer(r2, width=1000)
b
plot(b, col="black")