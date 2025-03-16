# utils/db_setup.R

setup_databases <- function(conn) {
  if (is.null(conn)) {
    warning("No se puede configurar la base de datos: conexión nula.")
    return()
  }
  
  # Lista de tablas y sus definiciones SQL
  tables <- list(
    "sitios" = "
      CREATE TABLE IF NOT EXISTS sitios (
        CODSIT VARCHAR(10) PRIMARY KEY,
        NOMSIT VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "especies" = "
      CREATE TABLE IF NOT EXISTS especies (
        CODESP VARCHAR(10) PRIMARY KEY,
        Nombre_Comun VARCHAR(100),
        Nombre_Cientifico VARCHAR(100),
        Subgrupo_ID VARCHAR(10),
        Clasificacion_ID VARCHAR(10),
        Constante_A DECIMAL,
        Constante_B DECIMAL,
        Clase_Medida VARCHAR(10),
        Clasificacion_Comercial VARCHAR(10),
        Grupo VARCHAR(50),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "estados" = "
      CREATE TABLE IF NOT EXISTS estados (
        CODEST VARCHAR(10) PRIMARY KEY,
        NOMEST VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "clasifica" = "
      CREATE TABLE IF NOT EXISTS clasifica (
        CODCLA VARCHAR(10) PRIMARY KEY,
        NOMCLA VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "grupos" = "
      CREATE TABLE IF NOT EXISTS grupos (
        CODGRU VARCHAR(10) PRIMARY KEY,
        NOMGRU VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "subgrupo" = "
      CREATE TABLE IF NOT EXISTS subgrupo (
        CODSUBGRU VARCHAR(10) PRIMARY KEY,
        NOMSUBGRU VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "arte" = "
      CREATE TABLE IF NOT EXISTS arte (
        CODART VARCHAR(10) PRIMARY KEY,
        NOMART VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "metodo" = "
      CREATE TABLE IF NOT EXISTS metodo (
        CODMET VARCHAR(10) PRIMARY KEY,
        NOMMET VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "propulsion" = "
      CREATE TABLE IF NOT EXISTS propulsion (
        CODPRO VARCHAR(10) PRIMARY KEY,
        NOMPRO VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "area" = "
      CREATE TABLE IF NOT EXISTS area (
        CODARE VARCHAR(10) PRIMARY KEY,
        NOMARE VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "subarea" = "
      CREATE TABLE IF NOT EXISTS subarea (
        CODSUBARE VARCHAR(10) PRIMARY KEY,
        NOMSUBARE VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "registrador" = "
      CREATE TABLE IF NOT EXISTS registrador (
        CODREG VARCHAR(10) PRIMARY KEY,
        NOMREG VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "embarcaciones" = "
      CREATE TABLE IF NOT EXISTS embarcaciones (
        CODEMB VARCHAR(10) PRIMARY KEY,
        NOMEMB VARCHAR(100),
        Matricula VARCHAR(20),
        Potencia INTEGER,
        Propulsion VARCHAR(50),
        Numero_Motores INTEGER,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "gastos" = "
      CREATE TABLE IF NOT EXISTS gastos (
        CODGAS VARCHAR(10) PRIMARY KEY,
        NOMGAS VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "valor_mensual_gastos" = "
      CREATE TABLE IF NOT EXISTS valor_mensual_gastos (
        ID SERIAL PRIMARY KEY,
        Gasto_ID VARCHAR(10),
        Ano INTEGER,
        Mes INTEGER,
        Valor DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "trm_dolar" = "
      CREATE TABLE IF NOT EXISTS trm_dolar (
        ID SERIAL PRIMARY KEY,
        Fecha DATE,
        Valor DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "faena_principal" = "
      CREATE TABLE IF NOT EXISTS faena_principal (
        ID SERIAL PRIMARY KEY,
        Registro VARCHAR(50),
        Fecha_Zarpe DATE,
        Fecha_Arribo DATE,
        Sitio_Desembarque VARCHAR(10),
        Subarea VARCHAR(10),
        Registrador VARCHAR(10),
        Embarcacion VARCHAR(10),
        Pescadores INTEGER,
        Hora_Salida TIME,
        Hora_Arribo TIME,
        Horario VARCHAR(10),
        Galones DECIMAL,
        Estado_Verificacion VARCHAR(20),
        Verificado_Por VARCHAR(50),
        Fecha_Verificacion TIMESTAMP,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "detalles_captura" = "
      CREATE TABLE IF NOT EXISTS detalles_captura (
        ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER,
        Especie_ID VARCHAR(10),
        Estado VARCHAR(10),
        Indv INTEGER,
        Peso DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "costos_operacion" = "
      CREATE TABLE IF NOT EXISTS costos_operacion (
        ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER,
        Gasto_ID VARCHAR(10),
        Valor DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )"
  )
  
  # Ejecutar las creaciones de tablas
  for (table_name in names(tables)) {
    tryCatch({
      dbExecute(conn, tables[[table_name]])
      message(paste("Tabla", table_name, "creada o ya existente."))
    }, error = function(e) {
      warning(paste("Error al crear la tabla", table_name, ":", e$message))
    })
  }
  
  # Opcional: Cerrar la conexión si no se necesita más
  # dbDisconnect(conn)  # Descomenta solo si quieres cerrar aquí
}