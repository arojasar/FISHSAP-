# global.R

# Leer .Renviron de la raíz del proyecto (en lugar de una ruta absoluta)
readRenviron(".Renviron")

# Depuración: Mostrar variables de entorno (excepto la contraseña)
message("DB_HOST: ", Sys.getenv("DB_HOST"))
message("DB_NAME: ", Sys.getenv("DB_NAME"))
message("DB_USER: ", Sys.getenv("DB_USER"))
message("DB_PORT: ", Sys.getenv("DB_PORT"))

library(shiny)
library(RPostgres)
library(DBI)
library(DT)

# Conexión a Neon
central_conn <- tryCatch({
  dbConnect(
    RPostgres::Postgres(),
    dbname = Sys.getenv("DB_NAME"),
    host = Sys.getenv("DB_HOST"),
    port = as.integer(Sys.getenv("DB_PORT")),
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD"),
    sslmode = "require",
    connect_timeout = 15  # Añadido para manejar el "cold start" de Neon
  )
}, error = function(e) {
  message("Error al conectar a Neon en global.R: ", e$message)
  NULL
})

if (is.null(central_conn)) {
  message("Conexión a Neon no establecida en global.R. Verifica las variables de entorno.")
} else {
  message("Conexión a Neon establecida en global.R.")
}

# Cargar utilidades y módulos
source("utils/db_setup.R")
source("utils/sync.R")
source("utils/helpers.R")

if (!is.null(central_conn)) {
  setup_databases(central_conn)
} else {
  warning("No se configuraron las bases de datos debido a un fallo en la conexión.")
}

message("Cargando ref_tables_ui.R...")
source("modules/ref_tables_ui.R")
message("Cargando ref_tables_server.R...")
source("modules/ref_tables_server.R")
message("Cargando ingreso_datos_ui.R...")
source("modules/ingreso_datos_ui.R")
message("Cargando ingreso_datos_server.R...")
source("modules/ingreso_datos_server.R")
source("modules/captura_esfuerzo.R")
