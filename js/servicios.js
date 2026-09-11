const CLAVE_CLIENTES = "clientesOceanLinkV2";
const CLAVE_RUTAS = "rutasOceanLinkV1";

let clientes =
  JSON.parse(localStorage.getItem(CLAVE_CLIENTES)) || [];

let rutas =
  JSON.parse(localStorage.getItem(CLAVE_RUTAS)) || [];

let registroSeleccionado = null;
let modoFormulario = "nuevo";

/* Elementos */

const tablaServicios = document.getElementById("tablaServicios");
const sinServicios = document.getElementById("sinServicios");
const cantidadServicios = document.getElementById("cantidadServicios");
const filtroEstado = document.getElementById("filtroEstado");

const botonNuevo = document.getElementById("nuevoServicio");
const modalServicio = document.getElementById("modalServicio");
const tituloModal = document.getElementById("tituloModal");
const formularioServicio = document.getElementById("formularioServicio");
const cerrarModal = document.getElementById("cerrarModal");
const cancelarServicio = document.getElementById("cancelarServicio");

const clienteServicio = document.getElementById("clienteServicio");
const rutaServicio = document.getElementById("rutaServicio");
const cantidadCapacidad = document.getElementById("cantidadCapacidad");
const unidadCapacidad = document.getElementById("unidadCapacidad");
const estadoServicio = document.getElementById("estadoServicio");
const riesgoServicio = document.getElementById("riesgoServicio");

const detalleServicio = document.getElementById("detalleServicio");
const detalleCodigo = document.getElementById("detalleCodigo");
const detalleCliente = document.getElementById("detalleCliente");
const detalleRuta = document.getElementById("detalleRuta");
const detalleOrigen = document.getElementById("detalleOrigen");
const detalleDestino = document.getElementById("detalleDestino");
const detalleCapacidad = document.getElementById("detalleCapacidad");
const detalleEstado = document.getElementById("detalleEstado");
const detalleRiesgo = document.getElementById("detalleRiesgo");

const cerrarDetalle = document.getElementById("cerrarDetalle");
const editarServicio = document.getElementById("editarServicio");
const eliminarServicio = document.getElementById("eliminarServicio");

/* Obtiene todos los servicios */

function obtenerServicios() {
  const servicios = [];

  clientes.forEach(function (cliente) {
    if (!Array.isArray(cliente.servicios)) {
      cliente.servicios = [];
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

/* Tabla */

function mostrarServicios() {
  tablaServicios.innerHTML = "";

  const seleccion = filtroEstado.value;

  const registros = obtenerServicios().filter(function (registro) {
    return (
      seleccion === "Todos" ||
      registro.servicio.estado === seleccion
    );
  });

  cantidadServicios.textContent =
    registros.length + " servicios";

  sinServicios.style.display =
    registros.length === 0 ? "block" : "none";

  registros.forEach(function (registro) {
    const servicio = registro.servicio;
    const fila = document.createElement("tr");

    fila.innerHTML = `
      <td class="codigo">${servicio.codigo}</td>
      <td>${registro.clienteNombre}</td>
      <td>${servicio.origen}</td>
      <td>${servicio.destino}</td>
      <td>${servicio.capacidad}</td>
      <td>${servicio.rutaCodigo}</td>

      <td>
        <span class="estado ${servicio.estado.toLowerCase()}">
          ${servicio.estado}
        </span>
      </td>

      <td>
        <button class="boton-ver" type="button">Ver</button>
      </td>
    `;

    fila.querySelector(".boton-ver").addEventListener(
      "click",
      function () {
        mostrarDetalle(registro);
      }
    );

    tablaServicios.appendChild(fila);
  });
}

/* Carga clientes y rutas */

function cargarOpciones() {
  clienteServicio.innerHTML =
    '<option value="">Seleccione un cliente</option>';

  clientes.forEach(function (cliente) {
    const opcion = document.createElement("option");

    opcion.value = cliente.codigo;
    opcion.textContent = cliente.codigo + " · " + cliente.nombre;

    clienteServicio.appendChild(opcion);
  });

  rutaServicio.innerHTML =
    '<option value="">Seleccione una ruta</option>';

  rutas.forEach(function (ruta) {
    const opcion = document.createElement("option");

    opcion.value = ruta.codigo;

    opcion.textContent =
      ruta.codigo + " · " + ruta.origen + " - " + ruta.destino;

    rutaServicio.appendChild(opcion);
  });
}

/* Nuevo servicio */

botonNuevo.addEventListener("click", function () {
  if (clientes.length === 0 || rutas.length === 0) {
    alert("Debe existir por lo menos un cliente y una ruta.");
    return;
  }

  modoFormulario = "nuevo";
  registroSeleccionado = null;

  tituloModal.textContent = "Nuevo servicio";
  formularioServicio.reset();

  cargarOpciones();

  estadoServicio.value = "Provisionado";
  unidadCapacidad.value = "Gbps";

  modalServicio.classList.add("mostrar");
});

/* Guardar */

formularioServicio.addEventListener("submit", function (evento) {
  evento.preventDefault();

  const clienteDestino = clientes.find(function (cliente) {
    return cliente.codigo === clienteServicio.value;
  });

  const rutaElegida = rutas.find(function (ruta) {
    return ruta.codigo === rutaServicio.value;
  });

  if (!clienteDestino || !rutaElegida) {
    alert("Seleccione un cliente y una ruta válidos.");
    return;
  }

  const capacidadTexto =
    cantidadCapacidad.value + " " + unidadCapacidad.value;

  const capacidadGbps = convertirAGbps(
    Number(cantidadCapacidad.value),
    unidadCapacidad.value
  );

  if (modoFormulario === "nuevo") {
    const servicio = {
      codigo: generarCodigoServicio(),
      rutaCodigo: rutaElegida.codigo,
      ruta: rutaElegida.origen + " - " + rutaElegida.destino,
      origen: rutaElegida.origen,
      destino: rutaElegida.destino,
      capacidad: capacidadTexto,
      capacidadGbps: capacidadGbps,
      riesgo: riesgoServicio.value.trim(),
      estado: estadoServicio.value
    };

    clienteDestino.servicios.push(servicio);

    registroSeleccionado = {
      clienteCodigo: clienteDestino.codigo,
      clienteNombre: clienteDestino.nombre,
      servicio: servicio
    };
  } else {
    actualizarServicio(
      clienteDestino,
      rutaElegida,
      capacidadTexto,
      capacidadGbps
    );
  }

  guardarClientes();
  cerrarVentana();
  mostrarServicios();
  mostrarDetalle(registroSeleccionado);
});

/* Editar */

editarServicio.addEventListener("click", function () {
  if (!registroSeleccionado) {
    return;
  }

  const servicio = registroSeleccionado.servicio;

  modoFormulario = "editar";
  tituloModal.textContent = "Editar " + servicio.codigo;

  cargarOpciones();

  clienteServicio.value = registroSeleccionado.clienteCodigo;
  rutaServicio.value = servicio.rutaCodigo;

  const datos = separarCapacidad(servicio.capacidad);

  cantidadCapacidad.value = datos.cantidad;
  unidadCapacidad.value = datos.unidad;
  estadoServicio.value = servicio.estado;
  riesgoServicio.value = servicio.riesgo;

  modalServicio.classList.add("mostrar");
});

function actualizarServicio(
  clienteDestino,
  rutaElegida,
  capacidadTexto,
  capacidadGbps
) {
  const clienteAnterior = clientes.find(function (cliente) {
    return cliente.codigo === registroSeleccionado.clienteCodigo;
  });

  const servicio = registroSeleccionado.servicio;

  if (clienteAnterior.codigo !== clienteDestino.codigo) {
    clienteAnterior.servicios = clienteAnterior.servicios.filter(
      function (elemento) {
        return elemento.codigo !== servicio.codigo;
      }
    );

    clienteDestino.servicios.push(servicio);
  }

  servicio.rutaCodigo = rutaElegida.codigo;
  servicio.ruta = rutaElegida.origen + " - " + rutaElegida.destino;
  servicio.origen = rutaElegida.origen;
  servicio.destino = rutaElegida.destino;
  servicio.capacidad = capacidadTexto;
  servicio.capacidadGbps = capacidadGbps;
  servicio.riesgo = riesgoServicio.value.trim();
  servicio.estado = estadoServicio.value;

  registroSeleccionado = {
    clienteCodigo: clienteDestino.codigo,
    clienteNombre: clienteDestino.nombre,
    servicio: servicio
  };
}

/* Eliminar */

eliminarServicio.addEventListener("click", function () {
  if (!registroSeleccionado) {
    return;
  }

  const confirmar = confirm(
    "¿Desea eliminar el servicio " +
    registroSeleccionado.servicio.codigo +
    "?"
  );

  if (!confirmar) {
    return;
  }

  const cliente = clientes.find(function (elemento) {
    return elemento.codigo === registroSeleccionado.clienteCodigo;
  });

  cliente.servicios = cliente.servicios.filter(function (servicio) {
    return servicio.codigo !== registroSeleccionado.servicio.codigo;
  });

  guardarClientes();

  registroSeleccionado = null;
  detalleServicio.classList.add("oculto");

  mostrarServicios();
});

/* Detalle */

function mostrarDetalle(registro) {
  registroSeleccionado = registro;

  const servicio = registro.servicio;

  detalleCodigo.textContent = servicio.codigo;
  detalleCliente.textContent = registro.clienteNombre;
  detalleRuta.textContent = servicio.rutaCodigo;
  detalleOrigen.textContent = servicio.origen;
  detalleDestino.textContent = servicio.destino;
  detalleCapacidad.textContent = servicio.capacidad;
  detalleEstado.textContent = servicio.estado;
  detalleRiesgo.textContent = servicio.riesgo;

  detalleServicio.classList.remove("oculto");

  detalleServicio.scrollIntoView({
    behavior: "smooth",
    block: "start"
  });
}

/* Funciones auxiliares */

function generarCodigoServicio() {
  let mayor = 0;

  obtenerServicios().forEach(function (registro) {
    const numero = parseInt(
      registro.servicio.codigo.replace("SER-", "")
    );

    if (numero > mayor) {
      mayor = numero;
    }
  });

  return "SER-" + String(mayor + 1).padStart(3, "0");
}

function convertirAGbps(cantidad, unidad) {
  if (unidad === "Mbps") {
    return cantidad / 1000;
  }

  return cantidad;
}

function separarCapacidad(texto) {
  const partes = String(texto).split(" ");

  return {
    cantidad: parseFloat(partes[0]) || 0,
    unidad: partes[1] === "Mbps" ? "Mbps" : "Gbps"
  };
}

function guardarClientes() {
  localStorage.setItem(
    CLAVE_CLIENTES,
    JSON.stringify(clientes)
  );
}

function cerrarVentana() {
  modalServicio.classList.remove("mostrar");
  formularioServicio.reset();
}

cerrarModal.addEventListener("click", cerrarVentana);
cancelarServicio.addEventListener("click", cerrarVentana);

modalServicio.addEventListener("click", function (evento) {
  if (evento.target === modalServicio) {
    cerrarVentana();
  }
});

cerrarDetalle.addEventListener("click", function () {
  detalleServicio.classList.add("oculto");
  registroSeleccionado = null;
});

filtroEstado.addEventListener("change", mostrarServicios);

/* Inicio */

cargarOpciones();
mostrarServicios();