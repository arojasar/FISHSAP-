# modules/ingreso_datos_server.R

ingreso_datos_server <- function(id, central_conn = NULL, selected_submodule) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$faena_form <- renderUI({
      req(selected_submodule())
      tagList(
        textInput(ns("registro"), "Registro"),
        textInput(ns("fecha_zarpe"), "Fecha de Zarpe"),
        textInput(ns("fecha_arribo"), "Fecha de Arribo"),
        textInput(ns("sitio_desembarque"), "Sitio de Desembarque"),
        textInput(ns("subarea"), "Subarea"),
        textInput(ns("registrador"), "Registrador"),
        textInput(ns("embarcacion"), "Embarcación"),
        numericInput(ns("pescadores"), "Pescadores", value = 1),
        textInput(ns("hora_salida"), "Hora de Salida"),
        textInput(ns("hora_arribo"), "Hora de Arribo"),
        textInput(ns("horario"), "Horario"),
        numericInput(ns("galones"), "Galones", value = 0),
        actionButton(ns("save_button"), "Guardar")
      )
    })

    output$faena_table <- renderDT({
      req(input$faena_table_data)
      input$faena_table_data
    })

    observeEvent(input$save_button, {
      message("Botón Guardar presionado en ingreso_datos_server. Enviando datos a IndexedDB...")
      form_data <- list(
        registro = input$registro,
        fecha_zarpe = input$fecha_zarpe,
        fecha_arribo = input$fecha_arribo,
        sitio_desembarque = input$sitio_desembarque,
        subarea = input$subarea,
        registrador = input$registrador,
        embarcacion = input$embarcacion,
        pescadores = input$pescadores,
        hora_salida = input$hora_salida,
        hora_arribo = input$hora_arribo,
        horario = input$horario,
        galones = input$galones,
        estado_verificacion = "Pendiente",
        verificado_por = "",
        fecha_verificacion = "",
        creado_por = "system",
        fecha_creacion = as.character(Sys.time()),
        modificado_por = "system",
        fecha_modificacion = as.character(Sys.time()),
        Sincronizado = 0
      )
      session$sendCustomMessage("saveData", list(table = "faena_principal", data = form_data))

      if (!is.null(central_conn)) {
        tryCatch({
          form_df <- as.data.frame(form_data, stringsAsFactors = FALSE)
          dbWriteTable(central_conn, "faena_principal", form_df, append = TRUE)
          print("Datos guardados en Neon:", form_df)
          session$sendCustomMessage("updateSyncStatus", list(table = "faena_principal", registro = input$registro, Sincronizado = 1))
        }, error = function(e) {
          print("Error al guardar en Neon:", e$message)
        })
      } else {
        print("No hay conexión a Neon; datos guardados solo en IndexedDB.")
      }
    })
  })
}
