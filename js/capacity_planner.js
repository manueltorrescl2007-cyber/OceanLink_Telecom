const CLAVE_CLIENTES = "clientesOceanLinkV2";
const CLAVE_RUTAS = "rutasOceanLinkV1";
const CLAVE_ACCIONES = "accionesDashboardV2";

/* Datos recuperados */

let clientes = [];
let rutas = [];
let accionesManuales = [];

/* Resumen */

const totalSolicitudes =
  document.getElementById("totalSolicitudes");

const totalPendientes =
  document.getElementById("totalPendientes");

const totalAprobadas =
  document.getElementById("totalAprobadas");

const totalServiciosActivos =
  document.getElementById("totalServiciosActivos");

/* Rutas */

const textoDisponibles =
  document.getElementById("textoDisponibles");

const textoLimitadas =
  document.getElementById("textoLimitadas");

const textoInsuficientes =
  document.getElementById("textoInsuficientes");

/* Acciones */

const listaAcciones =
  document.getElementById("listaAcciones");

const cantidadAcciones =
  document.getElementById("cantidadAcciones");

const botonNuevo =
  document.getElementById("botonNuevo");

/* Modal de acciones */

const modalAccion =
  document.getElementById("modalAccion");

const cerrarModal =
  document.getElementById("cerrarModal");

const cancelarAccion =
  document.getElementById("cancelarAccion");

const formularioAccion =
  document.getElementById("formularioAccion");

const descripcionAccion =
  document.getElementById("descripcionAccion");

const prioridadAccion =
  document.getElementById("prioridadAccion");

/* Recupera todos los datos */

function cargarDatos() {
  clientes =
    JSON.parse(
      localStorage.getItem(CLAVE_CLIENTES)
    ) || [];

  rutas =
    JSON.parse(
      localStorage.getItem(CLAVE_RUTAS)
    ) || [];

  accionesManuales =
    JSON.parse(
      localStorage.getItem(CLAVE_ACCIONES)
    ) || [];
}

/* Obtiene todas las solicitudes */

function obtenerSolicitudes() {
  const solicitudes = [];

  clientes.forEach(function (cliente) {
    if (!Array.isArray(cliente.solicitudes)) {
      return;
    }

    cliente.solicitudes.forEach(function (solicitud) {
      solicitudes.push({
        clienteCodigo: cliente.codigo,
        clienteNombre: cliente.nombre,
        solicitud: solicitud
      });
    });
  });

  return solicitudes;
}

/* Obtiene todos los servicios */

function obtenerServicios() {
  const servicios = [];

  clientes.forEach(function (cliente) {
    if (!Array.isArray(cliente.servicios)) {
      return;
    }

    cliente.servicios.forEach(function (servicio) {
      servicios.push({
        clienteCodigo: cliente.codigo,
        clienteNombre: cliente.nombre,
        servicio: servicio
      });
    });
  });

  return servicios;
}

/* Actualiza los números del resumen */

function actualizarResumen() {
  const solicitudes = obtenerSolicitudes();
  const servicios = obtenerServicios();

  const pendientes = solicitudes.filter(
    function (registro) {
      return registro.solicitud.estado === "Pendiente";
    }
  );

  const aprobadas = solicitudes.filter(
    function (registro) {
      return registro.solicitud.estado === "Aprobado";
    }
  );

  const serviciosActivos = servicios.filter(
    function (registro) {
      return registro.servicio.estado === "Activo";
    }
  );

  totalSolicitudes.textContent =
    solicitudes.length;

  totalPendientes.textContent =
    pendientes.length;

  totalAprobadas.textContent =
    aprobadas.length;

  totalServiciosActivos.textContent =
    serviciosActivos.length;
}

/* Calcula la capacidad utilizada por una ruta */

function calcularCapacidadUsada(codigoRuta) {
  let capacidadUsada = 0;

  obtenerServicios().forEach(function (registro) {
    const servicio = registro.servicio;

    const consumeCapacidad =
      servicio.estado === "Activo" ||
      servicio.estado === "Provisionado";

    if (
      servicio.rutaCodigo === codigoRuta &&
      consumeCapacidad
    ) {
      capacidadUsada +=
        obtenerCapacidadServicio(servicio);
    }
  });

  return capacidadUsada;
}

/* Convierte la capacidad de un servicio a Gbps */

function obtenerCapacidadServicio(servicio) {
  if (
    typeof servicio.capacidadGbps === "number"
  ) {
    return servicio.capacidadGbps;
  }

  const texto =
    String(servicio.capacidad || "");

  const cantidad =
    parseFloat(texto) || 0;

  if (
    texto.toLowerCase().includes("mbps")
  ) {
    return cantidad / 1000;
  }

  return cantidad;
}

/* Obtiene la capacidad total de una ruta */

function obtenerCapacidadRuta(ruta) {
  if (
    typeof ruta.capacidadTotalGbps === "number"
  ) {
    return ruta.capacidadTotalGbps;
  }

  const texto = String(
    ruta.capacidadTotal ||
    ruta.capacidad ||
    ""
  );

  const cantidad =
    parseFloat(texto) || 0;

  if (
    texto.toLowerCase().includes("mbps")
  ) {
    return cantidad / 1000;
  }

  return cantidad;
}

/* Calcula el estado automático de una ruta */

function calcularEstadoRuta(ruta) {
  const capacidadTotal =
    obtenerCapacidadRuta(ruta);

  const capacidadUsada =
    calcularCapacidadUsada(ruta.codigo);

  const disponible =
    capacidadTotal - capacidadUsada;

  const porcentajeDisponible =
    capacidadTotal > 0
      ? disponible / capacidadTotal
      : 0;

  if (disponible <= 0) {
    return "Insuficiente";
  }

  if (porcentajeDisponible <= 0.30) {
    return "Limitada";
  }

  return "Disponible";
}

/* Actualiza la tarjeta de rutas */

function actualizarEstadoRutas() {
  let disponibles = 0;
  let limitadas = 0;
  let insuficientes = 0;

  rutas.forEach(function (ruta) {
    const estado =
      calcularEstadoRuta(ruta);

    if (estado === "Disponible") {
      disponibles++;
    }

    if (estado === "Limitada") {
      limitadas++;
    }

    if (estado === "Insuficiente") {
      insuficientes++;
    }
  });

  textoDisponibles.textContent =
    disponibles + " disponibles";

  textoLimitadas.textContent =
    limitadas + " limitadas";

  textoInsuficientes.textContent =
    insuficientes + " insuficientes";
}

/* Convierte solicitudes pendientes en acciones */

function obtenerAccionesSolicitudes() {
  const acciones = [];

  obtenerSolicitudes().forEach(function (registro) {
    const solicitud = registro.solicitud;

    if (solicitud.estado === "Pendiente") {
      acciones.push({
        codigo: solicitud.codigo,

        descripcion:
          "Evaluar solicitud de " +
          registro.clienteNombre,

        prioridad: "media",

        tipo: "solicitud"
      });
    }
  });

  return acciones;
}

/* Une acciones automáticas y manuales */

function obtenerTodasLasAcciones() {
  return [
    ...obtenerAccionesSolicitudes(),
    ...accionesManuales
  ];
}

/* Muestra las acciones */

function mostrarAcciones() {
  const acciones =
    obtenerTodasLasAcciones();

  listaAcciones.innerHTML = "";

  cantidadAcciones.textContent =
    acciones.length;

  if (acciones.length === 0) {
    listaAcciones.innerHTML = `
      <li class="sin-acciones">
        No existen acciones pendientes.
      </li>
    `;

    return;
  }

  acciones.forEach(function (accion) {
    const elemento =
      document.createElement("li");

    elemento.innerHTML = `
      <div class="informacion-accion">
        <strong>${accion.codigo}</strong>
        <span>${accion.descripcion}</span>
      </div>

      <span class="prioridad ${accion.prioridad}">
        ${obtenerNombrePrioridad(accion)}
      </span>
    `;

    listaAcciones.appendChild(elemento);
  });
}

/* Texto mostrado dentro de la etiqueta */

function obtenerNombrePrioridad(accion) {
  if (accion.tipo === "solicitud") {
    return "Pendiente";
  }

  if (accion.prioridad === "critica") {
    return "Crítica";
  }

  if (accion.prioridad === "alta") {
    return "Alta";
  }

  return "Media";
}

/* Abre el formulario de acciones */

botonNuevo.addEventListener(
  "click",
  function () {
    formularioAccion.reset();
    modalAccion.classList.add("mostrar");
    descripcionAccion.focus();
  }
);

/* Guarda una acción manual */

formularioAccion.addEventListener(
  "submit",
  function (evento) {
    evento.preventDefault();

    const accion = {
      codigo: generarCodigoAccion(),

      descripcion:
        descripcionAccion.value.trim(),

      prioridad:
        prioridadAccion.value,

      tipo: "manual"
    };

    accionesManuales.push(accion);

    guardarAcciones();
    mostrarAcciones();
    cerrarVentana();
  }
);

/* Genera el código de acción */

function generarCodigoAccion() {
  let numeroMayor = 0;

  accionesManuales.forEach(function (accion) {
    const numero = parseInt(
      accion.codigo.replace("ACC-", "")
    );

    if (numero > numeroMayor) {
      numeroMayor = numero;
    }
  });

  return "ACC-" +
    String(numeroMayor + 1).padStart(3, "0");
}

/* Guarda las acciones manuales */

function guardarAcciones() {
  localStorage.setItem(
    CLAVE_ACCIONES,
    JSON.stringify(accionesManuales)
  );
}

/* Cierra el formulario */

function cerrarVentana() {
  modalAccion.classList.remove("mostrar");
  formularioAccion.reset();
}

cerrarModal.addEventListener(
  "click",
  cerrarVentana
);

cancelarAccion.addEventListener(
  "click",
  cerrarVentana
);

modalAccion.addEventListener(
  "click",
  function (evento) {
    if (evento.target === modalAccion) {
      cerrarVentana();
    }
  }
);

/* Actualiza todo el Dashboard */

function actualizarDashboard() {
  cargarDatos();
  actualizarResumen();
  actualizarEstadoRutas();
  mostrarAcciones();
}

/* Actualiza cuando se regresa de otra página */

window.addEventListener(
  "pageshow",
  actualizarDashboard
);

/* Actualiza si otra pestaña cambia los datos */

window.addEventListener(
  "storage",
  function (evento) {
    if (
      evento.key === CLAVE_CLIENTES ||
      evento.key === CLAVE_RUTAS ||
      evento.key === CLAVE_ACCIONES
    ) {
      actualizarDashboard();
    }
  }
);

/* Primera carga */

actualizarDashboard();