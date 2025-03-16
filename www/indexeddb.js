// www/indexeddb.js

console.log("Iniciando indexeddb.js...");

// Inicializar Dexie para IndexedDB
const db = new Dexie("SIPEIN_DB");
db.version(1).stores({
  sitios: "++CODSIT, NOMSIT, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  especies: "++CODESP, Nombre_Comun, Nombre_Cientifico, Subgrupo_ID, Clasificacion_ID, Constante_A, Constante_B, Clase_Medida, Clasificacion_Comercial, Grupo, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  estados: "++CODEST, NOMEST, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  clasifica: "++CODCLA, NOMCLA, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  grupos: "++CODGRU, NOMGRU, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  subgrupo: "++CODSUBGRU, NOMSUBGRU, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  arte: "++CODART, NOMART, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  metodo: "++CODMET, NOMMET, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  propulsion: "++CODPRO, NOMPRO, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  area: "++CODARE, NOMARE, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  subarea: "++CODSUBARE, NOMSUBARE, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  registrador: "++CODREG, NOMREG, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  embarcaciones: "++CODEMB, NOMEMB, Matricula, Potencia, Propulsion, Numero_Motores, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  gastos: "++CODGAS, NOMGAS, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  valor_mensual_gastos: "++ID, Gasto_ID, Ano, Mes, Valor, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  trm_dolar: "++ID, Fecha, Valor, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  faena_principal: "++ID, Registro, Fecha_Zarpe, Fecha_Arribo, Sitio_Desembarque, Subarea, Registrador, Embarcacion, Pescadores, Hora_Salida, Hora_Arribo, Horario, Galones, Estado_Verificacion, Verificado_Por, Fecha_Verificacion, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  detalles_captura: "++ID, Faena_ID, Especie_ID, Estado, Indv, Peso, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado",
  costos_operacion: "++ID, Faena_ID, Gasto_ID, Valor, Creado_Por, Fecha_Creacion, Modificado_Por, Fecha_Modificacion, Sincronizado"
});

// Variable para almacenar los datos anteriores
let previousData = {};

// Cargar datos iniciales al iniciar la página
document.addEventListener("DOMContentLoaded", async () => {
  try {
    console.log("indexeddb.js cargado correctamente. Verificando base de datos...");

    // Verificar si la base de datos ya existe
    const dbExists = await Dexie.exists("SIPEIN_DB");
    if (!dbExists) {
      console.log("Creando base de datos por primera vez...");
      await db.open();
      console.log("Base de datos creada.");

      // Cargar datos iniciales solo si la base de datos es nueva
      await loadInitialData();
    } else {
      console.log("Base de datos ya existe. No se necesita recrear.");
    }
  } catch (error) {
    console.error("Error al inicializar IndexedDB:", error);
  }
});

// Función para cargar datos iniciales
async function loadInitialData() {
  const initialData = {
    sitios: [
      { CODSIT: "SIT01", NOMSIT: "Puerto Principal", Creado_Por: "system", Fecha_Creacion: new Date().toISOString(), Modificado_Por: "system", Fecha_Modificacion: new Date().toISOString(), Sincronizado: 0 },
      { CODSIT: "SIT02", NOMSIT: "Bahía Secundaria", Creado_Por: "system", Fecha_Creacion: new Date().toISOString(), Modificado_Por: "system", Fecha_Modificacion: new Date().toISOString(), Sincronizado: 0 }
    ],
    subgrupo: [
      { CODSUBGRU: "SUB01", NOMSUBGRU: "Peces Pelágicos", Creado_Por: "system", Fecha_Creacion: new Date().toISOString(), Modificado_Por: "system", Fecha_Modificacion: new Date().toISOString(), Sincronizado: 0 },
      { CODSUBGRU: "SUB02", NOMSUBGRU: "Peces Demersales", Creado_Por: "system", Fecha_Creacion: new Date().toISOString(), Modificado_Por: "system", Fecha_Modificacion: new Date().toISOString(), Sincronizado: 0 }
    ],
    // Agregar más datos iniciales para otras tablas...
  };

  for (const [table, data] of Object.entries(initialData)) {
    if (await db[table].count() === 0) {
      await db[table].bulkAdd(data);
      console.log(`Datos iniciales de ${table} agregados.`);
    }
  }
}

// Escuchar mensajes personalizados desde el servidor Shiny
Shiny.addCustomMessageHandler("update", function(moduleId) {
  console.log("Recibido mensaje de actualización para módulo: ", moduleId);
  if (moduleId === "ref_tables") {
    Shiny.setInputValue("ref_tables-ref_table_output", Date.now());
  } else if (moduleId === "ingreso_datos") {
    Shiny.setInputValue("ingreso_datos-faena_table", Date.now());
    Shiny.setInputValue("ingreso_datos-faena_form", Date.now());
  }
});

// Manejador de loadTableData
Shiny.addCustomMessageHandler("loadTableData", function(message) {
  try {
    const table = message.table;
    db[table].toArray().then(data => {
      // Verificar si los datos han cambiado antes de enviarlos a Shiny
      if (JSON.stringify(data) !== JSON.stringify(previousData[table])) {
        console.log(`Datos cargados de ${table}:`, data);
        Shiny.setInputValue("ref_table_output_data", data);
        previousData[table] = data; // Almacenar los datos actuales para comparar en el futuro
      }
    }).catch(error => {
      console.error(`Error al cargar datos de ${table}:`, error);
    });
  } catch (error) {
    console.error("Error en loadTableData:", error);
  }
});

// Manejar el mensaje saveData para guardar en IndexedDB
Shiny.addCustomMessageHandler("saveData", async function(message) {
  try {
    console.log("Recibido mensaje saveData:", message);
    const { table, data } = message;
    await db[table].put(data);
    console.log(`Datos guardados en ${table}:`, data);
    // Forzar recarga de la tabla después de guardar
    loadTableData(table);
  } catch (error) {
    console.error("Error al guardar datos en IndexedDB:", error);
  }
});

// Función para cargar datos de la tabla
function loadTableData(table) {
  db[table].toArray().then(data => {
    console.log(`Datos recargados para ${table} después de guardar:`, data);
    Shiny.setInputValue("ref_table_output_data", data);
  }).catch(error => {
    console.error(`Error al recargar datos de ${table}:`, error);
  });
}

// Sincronización con PostgreSQL
Shiny.addCustomMessageHandler("syncData", function(message) {
  if (navigator.onLine) {
    const tables = ["sitios", "especies", "estados", "clasifica", "grupos", "subgrupo", "arte", "metodo", "propulsion", "area", "subarea", "registrador", "embarcaciones", "gastos", "valor_mensual_gastos", "trm_dolar", "faena_principal", "detalles_captura", "costos_operacion"];
    tables.forEach(table => {
      db[table].where("Sincronizado").equals(0).toArray().then(data => {
        data.forEach(row => {
          fetch('http://localhost:8001/sync', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ table: table, data: row })
          })
          .then(response => {
            if (!response.ok) {
              throw new Error(`Error en la respuesta: ${response.statusText}`);
            }
            return response.json();
          })
          .then(result => {
            if (result.success) {
              db[table].update(row[Object.keys(row)[0]], { Sincronizado: 1 });
              console.log(`Datos sincronizados para ${table}:`, row);
            } else if (result.conflict) {
              Shiny.setInputValue("conflict_detected", {
                table: table,
                local: result.local,
                central: result.central
              });
              console.log("Conflicto detectado:", result);
            }
          })
          .catch(err => {
            console.error(`Error al sincronizar ${table}:`, err);
            Shiny.setInputValue("sync_error", `Error al sincronizar ${table}: ${err.message}`);
          });
        });
      })
      .catch(error => {
        console.error(`Error al consultar datos para sincronizar en ${table}:`, error);
        Shiny.setInputValue("sync_error", `Error al consultar datos para sincronizar en ${table}: ${error.message}`);
      });
    });
  } else {
    console.log("No hay conexión a internet para sincronizar.");
    Shiny.setInputValue("sync_error", "No hay conexión a internet para sincronizar.");
  }
});

// Actualizar estado de sincronización en IndexedDB
Shiny.addCustomMessageHandler("updateSyncStatus", function(message) {
  try {
    const { table, id, Sincronizado } = message;
    db[table].update(id, { Sincronizado: Sincronizado });
    console.log(`Estado de sincronización actualizado para ${table}, ID: ${id}`);
  } catch (error) {
    console.error("Error al actualizar estado de sincronización:", error);
  }
});

// Actualizar IndexedDB con datos de PostgreSQL
Shiny.addCustomMessageHandler("updateIndexedDB", function(message) {
  try {
    const { table, data } = message;
    db[table].put(data);
    console.log(`IndexedDB actualizado para ${table}:`, data);
  } catch (error) {
    console.error("Error al actualizar IndexedDB:", error);
  }
});

// Función para validar datos antes de guardar
async function validateForm(table) {
  let errors = [];
  let data = {};

  try {
    if (table === "sitios") {
      const CODSIT = document.getElementById("sitios_CODSIT").value;
      const NOMSIT = document.getElementById("sitios_NOMSIT").value;

      if (!CODSIT) errors.push("El código es obligatorio.");
      if (!NOMSIT) errors.push("El nombre es obligatorio.");

      const count = await db.sitios.where("CODSIT").equals(CODSIT).count();
      if (count > 0 && action !== "edit") errors.push("El código ya existe.");

      data = {
        CODSIT: CODSIT,
        NOMSIT: NOMSIT,
        Creado_Por: "system",
        Fecha_Creacion: new Date().toISOString(),
        Modificado_Por: "system",
        Fecha_Modificacion: new Date().toISOString(),
        Sincronizado: 0
      };
    } else if (table === "especies") {
      const CODESP = document.getElementById("especies_CODESP").value;
      const Nombre_Comun = document.getElementById("especies_Nombre_Comun").value;
      const Nombre_Cientifico = document.getElementById("especies_Nombre_Cientifico").value;
      const Subgrupo_ID = document.getElementById("especies_Subgrupo_ID").value;
      const Clasificacion_ID = document.getElementById("especies_Clasificacion_ID").value;
      const Constante_A = parseFloat(document.getElementById("especies_Constante_A").value) || 0;
      const Constante_B = parseFloat(document.getElementById("especies_Constante_B").value) || 0;
      const Clase_Medida = document.getElementById("especies_Clase_Medida").value;
      const Clasificacion_Comercial = document.getElementById("especies_Clasificacion_Comercial").value;
      const Grupo = document.getElementById("especies_Grupo").value;

      if (!CODESP) errors.push("El código es obligatorio.");
      if (!Nombre_Comun) errors.push("El nombre común es obligatorio.");
      if (!Nombre_Cientifico) errors.push("El nombre científico es obligatorio.");
      if (!Subgrupo_ID) errors.push("El subgrupo es obligatorio.");
      if (!Clasificacion_ID) errors.push("La clasificación es obligatorio.");

      const count = await db.especies.where("CODESP").equals(CODESP).count();
      if (count > 0 && action !== "edit") errors.push("El código ya existe.");

      data = {
        CODESP: CODESP,
        Nombre_Comun: Nombre_Comun,
        Nombre_Cientifico: Nombre_Cientifico,
        Subgrupo_ID: Subgrupo_ID,
        Clasificacion_ID: Clasificacion_ID,
        Constante_A: Constante_A,
        Constante_B: Constante_B,
        Clase_Medida: Clase_Medida,
        Clasificacion_Comercial: Clasificacion_Comercial,
        Grupo: Grupo,
        Creado_Por: "system",
        Fecha_Creacion: new Date().toISOString(),
        Modificado_Por: "system",
        Fecha_Modificacion: new Date().toISOString(),
        Sincronizado: 0
      };
    } else if (table === "valor_mensual_gastos") {
      const Gasto_ID = document.getElementById("vmg_Gasto_ID").value;
      const Ano = parseInt(document.getElementById("vmg_Ano").value) || 2025;
      const Mes = parseInt(document.getElementById("vmg_Mes").value) || 1;
      const Valor = parseFloat(document.getElementById("vmg_Valor").value) || 0;

      if (!Gasto_ID) errors.push("El gasto es obligatorio.");
      if (Ano < 2000 || Ano > 2100) errors.push("El año debe estar entre 2000 y 2100.");

      data = {
        Gasto_ID: Gasto_ID,
        Ano: Ano,
        Mes: Mes,
        Valor: Valor,
        Creado_Por: "system",
        Fecha_Creacion: new Date().toISOString(),
        Modificado_Por: "system",
        Fecha_Modificacion: new Date().toISOString(),
        Sincronizado: 0
      };
    } else if (table === "faena_principal") {
      const Registro = document.getElementById("faena_Registro").value;
      const Fecha_Zarpe = document.getElementById("faena_Fecha_Zarpe").value;
      const Fecha_Arribo = document.getElementById("faena_Fecha_Arribo").value;
      const Sitio_Desembarque = document.getElementById("faena_Sitio_Desembarque").value;
      const Subarea = document.getElementById("faena_Subarea").value;
      const Registrador = document.getElementById("faena_Registrador").value;
      const Embarcacion = document.getElementById("faena_Embarcacion").value;
      const Pescadores = parseInt(document.getElementById("faena_Pescadores").value) || 0;
      const Hora_Salida = document.getElementById("faena_Hora_Salida").value;
      const Hora_Arribo = document.getElementById("faena_Hora_Arribo").value;
      const Horario = document.getElementById("faena_Horario").value;
      const Galones = parseFloat(document.getElementById("faena_Galones").value) || 0;

      if (!Registro) errors.push("El registro es obligatorio.");
      if (!Fecha_Zarpe) errors.push("La fecha de zarpe es obligatoria.");
      if (!Fecha_Arribo) errors.push("La fecha de arribo es obligatoria.");
      if (!Sitio_Desembarque) errors.push("El sitio de desembarque es obligatorio.");
      if (!Subarea) errors.push("La subárea es obligatoria.");
      if (!Registrador) errors.push("El registrador es obligatorio.");
      if (!Embarcacion) errors.push("La embarcación es obligatoria.");
      if (!Hora_Salida) errors.push("La hora de salida es obligatoria.");
      if (!Hora_Arribo) errors.push("La hora de arribo es obligatoria.");

      const count = await db.faena_principal.where("Registro").equals(Registro).count();
      if (count > 0 && action !== "edit") errors.push("El registro ya existe.");

      data = {
        Registro: Registro,
        Fecha_Zarpe: Fecha_Zarpe,
        Fecha_Arribo: Fecha_Arribo,
        Sitio_Desembarque: Sitio_Desembarque,
        Subarea: Subarea,
        Registrador: Registrador,
        Embarcacion: Embarcacion,
        Pescadores: Pescadores,
        Hora_Salida: Hora_Salida,
        Hora_Arribo: Hora_Arribo,
        Horario: Horario,
        Galones: Galones,
        Estado_Verificacion: "Pendiente",
        Verificado_Por: "",
        Fecha_Verificacion: "",
        Creado_Por: "system",
        Fecha_Creacion: new Date().toISOString(),
        Modificado_Por: "system",
        Fecha_Modificacion: new Date().toISOString(),
        Sincronizado: 0
      };
    } else {
      const ID = document.getElementById("generic_ID").value;
      const Nombre = document.getElementById("generic_Nombre").value;

      if (!ID) errors.push("El código es obligatorio.");
      if (!Nombre) errors.push("El nombre es obligatorio.");

      const count = await db[table].where("ID").equals(ID).count();
      if (count > 0 && action !== "edit") errors.push("El código ya existe.");

      data = {
        ID: ID,
        Nombre: Nombre,
        Creado_Por: "system",
        Fecha_Creacion: new Date().toISOString(),
        Modificado_Por: "system",
        Fecha_Modificacion: new Date().toISOString(),
        Sincronizado: 0
      };
    }
  } catch (error) {
    console.error("Error al validar formulario:", error);
    errors.push("Error al validar los datos.");
  }

  return { errors, data };
}

// Función para guardar datos en IndexedDB
async function saveForm(table) {
  try {
    const { errors, data } = await validateForm(table);

    if (errors.length > 0) {
      document.getElementById("error_message").innerHTML = errors.join("<br>");
      return;
    }

    await db[table].put(data);
    console.log(`Datos guardados desde formulario en ${table}:`, data);
    loadTableData(table);
    document.getElementById("ref_form_ui").innerHTML = "<p style='color: green;'>Datos guardados correctamente.</p>";
  } catch (error) {
    console.error("Error al guardar datos desde formulario:", error);
    document.getElementById("error_message").innerHTML = "Error al guardar los datos.";
  }
}

// Función para cancelar
function cancelForm() {
  document.getElementById("ref_form_ui").innerHTML = "";
}

console.log("indexeddb.js cargado completamente.");