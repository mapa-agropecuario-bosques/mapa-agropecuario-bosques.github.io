#
# REMUESTREO DE CAPAS RASTER
#


# PAQUETES
library(here)
library(sf)
library(terra)


# PARÁMETROS GENERALES

# Directorio de capas vectoriales
DIRECTORIO_CAPAS_VECTORIALES_ORIGINALES <- 
  here("contenido", "2020", "datos", "originales", "vectoriales")

# Directorio de capas raster
DIRECTORIO_CAPAS_RASTER_ORIGINALES <- 
  here("contenido", "2020", "datos", "originales", "raster")

# Directorio de capas rasterizadas
DIRECTORIO_CAPAS_RASTERIZADAS <- 
  here("contenido", "2020", "datos", "procesados", "rasterizados")


# Archivo vectorial de Costa Rica
ARCHIVO_VECTORIAL_COSTARICA <- 
  here(DIRECTORIO_CAPAS_VECTORIALES_ORIGINALES, "costarica.gpkg")

ARCHIVO_RASTER_COSTARICA <- 
  here(DIRECTORIO_CAPAS_RASTERIZADAS, "costarica.tif")


# Resolución de las capas raster (en metros)
RESOLUCION <- 10


# PROCESAMIENTO

# COSTA RICA

cat("0a Rasterizando polígono del contorno de Costa Rica ...\n")

# Objeto sf de Costa Rica
costarica_sf <-
  st_read(ARCHIVO_VECTORIAL_COSTARICA, quiet = TRUE) |>
  st_make_valid()

# Recorte del objeto sf de Costa Rica (para omitir la Isla del Coco)
costarica_sf <- 
  costarica_sf |>
  st_crop(st_bbox(
    c(
      xmin = 280000, 
      ymin = 880000, 
      xmax = 660000, 
      ymax = 1250000
    ), 
    crs = st_crs(costarica_sf)
  ))

# Objeto raster de Costa Rica
costarica_terra <-
  rast(ext(vect(costarica_sf)), resolution = RESOLUCION)

# Asignación de CRS
crs(costarica_terra) <- "EPSG:5367"

# Asignar valores únicos a cada celda
values(costarica_terra) <- seq_len(ncell(costarica_terra))

# Enmascarar usando el polígono, para dejar NA fuera del contorno
costarica_rast <- mask(costarica_terra, vect(costarica_sf), touches=TRUE)

# Escritura
writeRaster(
  costarica_rast,
  ARCHIVO_RASTER_COSTARICA,
  overwrite=TRUE
)

cat("Finalizado\n\n")