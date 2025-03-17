# server.R

library(shiny)

server <- function(input, output, session) {
  message("Iniciando server...")

  # Renderizar el estado de sincronización
  output$sync_status <- renderText({
    "Sincronización pendiente..."
  })

  # Renderizar la UI de resolución de conflictos
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

  # Renderizar la tabla de conflictos
  output$conflict_table <- renderTable({
    if (!is.null(input$conflict_detected)) {
      data.frame(
        Table = input$conflict_detected$table,
        Local = I(list(input$conflict_detected$local)),
        Central = I(list(input$conflict_detected$central))
      )
    }
  })

  # Manejar la resolución de conflictos
  observeEvent(input$resolve_conflict, {
    if (!is.null(input$conflict_detected)) {
      session$sendCustomMessage("resolveConflict", input$conflict_detected)
    }
  })

  # Inicializar el servidor para "Tablas de Referencia" cuando cambie la tabla seleccionada
  observeEvent(input$ref_table, {
    message("Cambio detectado en input$ref_table, forzando renderizado...")
    ref_tables_server("ref_tables", central_conn = central_conn, table_name = reactive({ input$ref_table }))
    session$sendCustomMessage("update", "ref_tables")
  }, ignoreInit = TRUE)

  # Inicializar el servidor para "Ingreso de Datos" cuando cambie el submódulo seleccionado
  observeEvent(input$ingreso_submodule, {
    message("Cambio detectado en input$ingreso_submodule, forzando renderizado...")
    ingreso_datos_server("ingreso_datos", central_conn = central_conn, selected_submodule = reactive({ input$ingreso_submodule }))
    session$sendCustomMessage("update", "ingreso_datos")
  }, ignoreInit = TRUE)

  # Manejar el botón de sincronización
  observeEvent(input$sync_btn, {
    session$sendCustomMessage("syncData", {})
    if (!is.null(central_conn)) {
      tryCatch({
        message("Sincronización iniciada. Implementa la lógica para leer de IndexedDB y escribir en Neon.")
        # Nota: Necesitarías un mensaje desde indexeddb.js para obtener datos no sincronizados
      }, error = function(e) {
        message("Error en sincronización:", e$message)
      })
    } else {
      message("No hay conexión a Neon para sincronizar.")
    }
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

    # Intentar sincronizar con Neon si hay conexión
    if (!is.null(central_conn)) {
      tryCatch({
        form_df <- data.frame(
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
          Sincronizado = 0,
          stringsAsFactors = FALSE
        )
        dbWriteTable(central_conn, "faena_principal", form_df, append = TRUE)
        print("Datos guardados en Neon:", form_df)

        # Actualizar estado de sincronización en IndexedDB
        session$sendCustomMessage("updateSyncStatus", list(table = "faena_principal", registro = input$registro_input, Sincronizado = 1))
      }, error = function(e) {
        print("Error al guardar en Neon:", e$message)
      })
    } else {
      print("No hay conexión a Neon; datos guardados solo en IndexedDB.")
    }
  })

  # Opcional: Cerrar la conexión a Neon al cerrar la app
  session$onSessionEnded(function() {
    if (!is.null(central_conn)) {
      tryCatch({
        dbDisconnect(central_conn)
        message("Conexión a Neon cerrada.")
      }, error = function(e) {
        message("Error al cerrar conexión a Neon:", e$message)
      })
    }
  })
}
