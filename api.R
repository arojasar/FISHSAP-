# api.R

#* @post /sync
function(req) {
  # Obtener los datos enviados desde IndexedDB
  body <- jsonlite::fromJSON(req$postBody)
  table <- body$table
  data <- body$data
  
  # Conectar a PostgreSQL
  central_conn <- tryCatch({
    dbConnect(RPostgreSQL::PostgreSQL(),
              host = Sys.getenv("PG_HOST", "localhost"),
              port = as.numeric(Sys.getenv("PG_PORT", 5432)),
              dbname = Sys.getenv("PG_DBNAME", "sipein"),
              user = Sys.getenv("PG_USER", "postgres"),
              password = Sys.getenv("PG_PASSWORD", "password"))
  }, error = function(e) {
    return(list(success = FALSE, message = "No se pudo conectar a la base de datos central"))
  })
  
  # Determinar la clave primaria
  primary_key <- ifelse(table %in% c("valor_mensual_gastos", "trm_dolar", "faena_principal", "detalles_captura", "costos_operacion"),
                        "ID",
                        paste0("COD", toupper(substr(table, 1, 3))))
  pk_value <- data[[primary_key]]
  
  # Verificar si el registro existe en PostgreSQL
  central_exists <- dbGetQuery(central_conn, sprintf("SELECT * FROM %s WHERE %s = '%s'", table, primary_key, pk_value))
  
  if (nrow(central_exists) > 0) {
    # Comparar Fecha_Modificacion para detectar conflictos
    local_mod_time <- lubridate::ymd_hms(data$Fecha_Modificacion)
    central_mod_time <- lubridate::ymd_hms(central_exists$Fecha_Modificacion[1])
    
    if (local_mod_time > central_mod_time) {
      # Actualizar el registro en PostgreSQL
      cols <- paste(names(data), collapse = ", ")
      placeholders <- paste(rep("?", length(names(data))), collapse = ", ")
      dbExecute(central_conn, sprintf("UPDATE %s SET (%s) = (%s) WHERE %s = ?", table, cols, placeholders, primary_key),
                params = c(unlist(data), pk_value))
      dbDisconnect(central_conn)
      return(list(success = TRUE))
    } else {
      # Registrar conflicto (manejo en el frontend)
      dbDisconnect(central_conn)
      return(list(success = FALSE, conflict = TRUE, local = data, central = as.list(central_exists)))
    }
  } else {
    # Insertar nuevo registro en PostgreSQL
    cols <- paste(names(data), collapse = ", ")
    placeholders <- paste(rep("?", length(names(data))), collapse = ", ")
    dbExecute(central_conn, sprintf("INSERT INTO %s (%s) VALUES (%s)", table, cols, placeholders), params = unlist(data))
    dbDisconnect(central_conn)
    return(list(success = TRUE))
  }
}