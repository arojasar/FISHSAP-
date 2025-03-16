library(shiny)

server <- function(input, output, session) {
  message("Iniciando server...")
  
  output$sync_status <- renderText({
    "Sincronización pendiente..."
  })
  
  output$conflict_resolution_ui <- renderUI({
    if (!is.null(input$conflict_detected)) {
      tagList(
        h4("Conflictos detectados"),
        p("Resuelve los conflictos aquí."),
        actionButton("resolve_conflict", "Resolver"),
        tableOutput("conflict_table")
      )
    } else {
      NULL
    }
  })
  
  output$conflict_table <- renderTable({
    if (!is.null(input$conflict_detected)) {
      data.frame(
        Table = input$conflict_detected$table,
        Local = I(list(input$conflict_detected$local)),
        Central = I(list(input$conflict_detected$central))
      )
    }
  })
  
  observeEvent(input$resolve_conflict, {
    if (!is.null(input$conflict_detected)) {
      session$sendCustomMessage("resolveConflict", input$conflict_detected)
    }
  })
  
  message("Invocando ref_tables_server...")
  ref_tables_server("ref_tables", central_conn = NULL, table_name = reactive(input$ref_table))
  message("Invocando ingreso_datos_server...")
  ingreso_datos_server("ingreso_datos", central_conn = NULL, submodule = reactive(input$ingreso_submodule))
  
  observeEvent(input$ref_table, {
    message("Cambio detectado en input$ref_table, forzando renderizado...")
    session$sendCustomMessage("update", "ref_tables")
  }, ignoreInit = TRUE)
  
  observeEvent(input$ingreso_submodule, {
    message("Cambio detectado en input$ingreso_submodule, forzando renderizado...")
    session$sendCustomMessage("update", "ingreso_datos")
  }, ignoreInit = TRUE)
  
  observeEvent(input$sync_btn, {
    session$sendCustomMessage("syncData", {})
  })
  
  # Manejar el evento del botón "Guardar"
  observeEvent(input$save_button, {
    message("Botón Guardar presionado. Enviando datos a IndexedDB...")
    new_data <- list(
      Registro = input$registro_input,
      Fecha_Zarpe = input$fecha_zarpe_input,
      Fecha_Arribo = input$fecha_arribo_input,
      Sitio_Desembarque = input$sitio_desembarque_input,
      Subarea = input$subarea_input,
      Registrador = input$registrador_input,
      Embarcacion = input$embarcacion_input,
      Pescadores = input$pescadores_input,
      Hora_Salida = input$hora_salida_input,
      Hora_Arribo = input$hora_arribo_input,
      Horario = input$horario_input,
      Galones = input$galones_input,
      Estado_Verificacion = "Pendiente",
      Verificado_Por = "",
      Fecha_Verificacion = "",
      Creado_Por = "system",
      Fecha_Creacion = as.character(Sys.time()),
      Modificado_Por = "system",
      Fecha_Modificacion = as.character(Sys.time()),
      Sincronizado = 0
    )
    session$sendCustomMessage("saveData", list(table = "faena_principal", data = new_data))
  })
}