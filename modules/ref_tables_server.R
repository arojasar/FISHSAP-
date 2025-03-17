# modules/ref_tables_server.R

ref_tables_server <- function(id, central_conn = NULL, table_name) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    message("Entrando en ref_tables_server para ID:", id)

    output$ref_table_output <- renderDT({
      message("Renderizando tabla en ref_tables_server dentro de renderDT...")
      req(input$ref_table_output_data)
      input$ref_table_output_data
    })

    observeEvent(input$save_button, {
      message("Botón Guardar presionado en ref_tables_server. Enviando datos a IndexedDB...")
      table <- table_name()
      new_data <- list()

      if (table == "Sitios de Desembarque") {
        new_data <- list(
          site_code = input$site_code,
          site_name = input$site_name
        )
      } else if (table == "Especies Comerciales") {
        new_data <- list(
          species_code = input$species_code,
          common_name = input$common_name,
          scientific_name = input$scientific_name,
          constant_a = input$constant_a,
          constant_b = input$constant_b
        )
      } else if (table == "Categorías de Estado") {
        new_data <- list(
          cat_code = input$cat_code,
          cat_name = input$cat_name
        )
      } else if (table == "Clasificación") {
        new_data <- list(
          clas_code = input$clas_code,
          clas_name = input$clas_name
        )
      } else if (table == "Subgrupos") {
        new_data <- list(
          subgrupo_code = input$subgrupo_code,
          subgrupo_name = input$subgrupo_name
        )
      } else if (table == "Grupos") {
        new_data <- list(
          grupo_code = input$grupo_code,
          grupo_name = input$grupo_name
        )
      }

      table_map <- list(
        "Sitios de Desembarque" = "sitios",
        "Especies Comerciales" = "especies",
        "Categorías de Estado" = "categorias",
        "Clasificación" = "clasifica",
        "Subgrupos" = "subgrupo",
        "Grupos" = "grupos"
      )
      table_key <- table_map[[table]]

      if (!is.null(table_key)) {
        session$sendCustomMessage("saveData", list(table = table_key, data = new_data))

        if (!is.null(central_conn)) {
          tryCatch({
            form_df <- as.data.frame(new_data, stringsAsFactors = FALSE)
            form_df$Sincronizado <- 0
            dbWriteTable(central_conn, table_key, form_df, append = TRUE)
            print("Datos guardados en Neon:", form_df)

            primary_key <- switch(table_key,
              "sitios" = "site_code",
              "especies" = "species_code",
              "categorias" = "cat_code",
              "clasifica" = "clas_code",
              "subgrupo" = "subgrupo_code",
              "grupos" = "grupo_code"
            )
            session$sendCustomMessage("updateSyncStatus", list(table = table_key, registro = new_data[[primary_key]], Sincronizado = 1))
          }, error = function(e) {
            print("Error al guardar en Neon:", e$message)
          })
        } else {
          print("No hay conexión a Neon; datos guardados solo en IndexedDB.")
        }
      } else {
        message("Tabla no reconocida para guardar:", table)
      }
    })

    message("Saliendo de ref_tables_server para ID:", id)
  })
}
