// www/indexeddb.js

const db = new Dexie("FISHSAP_DB");

db.version(1).stores({
  sitios: "site_code, site_name",
  especies: "species_code, common_name, scientific_name, constant_a, constant_b",
  categorias: "cat_code, cat_name",
  faena_principal: "registro, Sincronizado",
  clasifica: "clas_code, clas_name, Sincronizado",
  subgrupo: "subgrupo_code, subgrupo_name, Sincronizado",
  grupos: "grupo_code, grupo_name, Sincronizado"  // Añadida para "Grupos"
});

db.on("populate", function() {
  db.sitios.bulkPut([
    { site_code: "SIT01", site_name: "Puerto 1" },
    { site_code: "SIT02", site_name: "Puerto 2" }
  ]);
  db.especies.bulkPut([
    { species_code: "ESP01", common_name: "Sardina", scientific_name: "Sardina pilchardus", constant_a: "0.01", constant_b: "2.5" }
  ]);
  db.categorias.bulkPut([
    { cat_code: "CAT01", cat_name: "Fresco" }
  ]);
  db.faena_principal.bulkPut([
    { registro: "Faena 1", Sincronizado: 0 },
    { registro: "Faena 2", Sincronizado: 0 }
  ]);
  db.clasifica.bulkPut([
    { clas_code: "CLAS01", clas_name: "Clasificación 1", Sincronizado: 0 }
  ]);
  db.subgrupo.bulkPut([
    { subgrupo_code: "SUB01", subgrupo_name: "Subgrupo 1", Sincronizado: 0 }
  ]);
  db.grupos.bulkPut([
    { grupo_code: "GRP01", grupo_name: "Grupo 1", Sincronizado: 0 }
  ]);
});

Shiny.addCustomMessageHandler("update", function(message) {
  console.log("Recibido mensaje update:", message);
  loadTableData(message.table);
  showForm(message.table);
});

function loadTableData(tableName) {
  if (!db[tableName]) {
    console.error("Tabla no encontrada en IndexedDB:", tableName);
    return;
  }
  db[tableName].toArray().then(data => {
    console.log("Datos cargados de", tableName, ":", data);
    if (tableName === "faena_principal") {
      Shiny.setInputValue("faena_table_data", data, { priority: "event" });
    } else {
      Shiny.setInputValue("ref_table_output_data", data, { priority: "event" });
    }
  }).catch(error => {
    console.error("Error al cargar datos:", error);
  });
}

Shiny.addCustomMessageHandler("saveData", function(message) {
  console.log("Recibido mensaje saveData:", message);
  const tableName = message.table;
  const data = message.data;
  if (!db[tableName]) {
    console.error("Tabla no encontrada en IndexedDB:", tableName);
    return;
  }
  db[tableName].put(data).then(() => {
    console.log("Datos guardados en", tableName);
    loadTableData(tableName);
  }).catch(error => {
    console.error("Error al guardar:", error);
  });
});

Shiny.addCustomMessageHandler("showForm", function(message) {
  console.log("Recibido mensaje showForm:", message);
  const tableName = message.table;
  let formFields = [];
  if (tableName === "sitios") {
    formFields = [
      { id: "site_code", label: "Código", type: "text", required: true },
      { id: "site_name", label: "Nombre", type: "text", required: true }
    ];
  } else if (tableName === "especies") {
    formFields = [
      { id: "species_code", label: "Código de especie", type: "text", required: true },
      { id: "common_name", label: "Nombre común", type: "text", required: true },
      { id: "scientific_name", label: "Nombre científico", type: "text" },
      { id: "constant_a", label: "Constante A", type: "number" },
      { id: "constant_b", label: "Constante B", type: "number" }
    ];
  } else if (tableName === "categorias") {
    formFields = [
      { id: "cat_code", label: "Código de categoría", type: "text", required: true },
      { id: "cat_name", label: "Nombre de categoría", type: "text", required: true }
    ];
  } else if (tableName === "faena_principal") {
    formFields = [
      { id: "registro", label: "Registro", type: "text", required: true }
    ];
  } else if (tableName === "clasifica") {
    formFields = [
      { id: "clas_code", label: "Código de Clasificación", type: "text", required: true },
      { id: "clas_name", label: "Nombre de Clasificación", type: "text", required: true }
    ];
  } else if (tableName === "subgrupo") {
    formFields = [
      { id: "subgrupo_code", label: "Código de Subgrupo", type: "text", required: true },
      { id: "subgrupo_name", label: "Nombre de Subgrupo", type: "text", required: true }
    ];
  } else if (tableName === "grupos") {
    formFields = [
      { id: "grupo_code", label: "Código", type: "text", required: true },
      { id: "grupo_name", label: "Nombre", type: "text", required: true }
    ];
  }
  Shiny.setInputValue("form_fields", formFields);
});

Shiny.addCustomMessageHandler("syncData", function(message) {
  console.log("Recibido mensaje syncData:", message);
  db.faena_principal.where("Sincronizado").equals(0).toArray().then(data => {
    if (data.length > 0) {
      fetch("http://localhost:8001/sync", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
      }).then(response => response.json()).then(result => {
        console.log("Sincronización exitosa:", result);
        db.faena_principal.where("Sincronizado").equals(0).modify({ Sincronizado: 1 });
      }).catch(error => {
        console.error("Error en sincronización:", error);
      });
    }
  });
});

Shiny.addCustomMessageHandler("updateSyncStatus", function(message) {
  console.log("Actualizando estado de sincronización:", message);
  const tableName = message.table;
  const registro = message.registro;
  const Sincronizado = message.Sincronizado;
  if (!db[tableName]) {
    console.error("Tabla no encontrada en IndexedDB:", tableName);
    return;
  }
  // Ajustar la clave primaria según la tabla
  const primaryKey = {
    sitios: "site_code",
    especies: "species_code",
    categorias: "cat_code",
    faena_principal: "registro",
    clasifica: "clas_code",
    subgrupo: "subgrupo_code",
    grupos: "grupo_code"
  }[tableName];
  db[tableName].where(primaryKey).equals(registro).modify({ Sincronizado: Sincronizado }).then(() => {
    console.log("Estado de sincronización actualizado en", tableName);
    loadTableData(tableName);
  }).catch(error => {
    console.error("Error al actualizar estado:", error);
  });
});

db.on("ready", function() {
  loadTableData("sitios");
  loadTableData("especies");
  loadTableData("categorias");
  loadTableData("faena_principal");
  loadTableData("clasifica");
  loadTableData("subgrupo");
  loadTableData("grupos");
});
