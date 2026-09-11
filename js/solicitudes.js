const CLAVE_CLIENTES = "clientesOceanLinkV2";

/* Recupera los clientes guardados */

let clientes =
  JSON.parse(localStorage.getItem(CLAVE_CLIENTES)) || [];

/* Elementos de la tabla */

const tablaSolicitudes =
  document.getElementById("tablaSolicitudes");

const sinSolicitudes =
  document.getElementById("sinSolicitudes");

const cantidadSolicitudes =
  document.getElementById("cantidadSolicitudes");

const filtroEstado =
  document.getElementById("filtroEstado");

const botonNuevaSolicitud =
  document.getElementById("nuevaSolicitud");

/* Elementos del formulario */

const modalSolicitud =
  document.getElementById("modalSolicitud");

const tituloModalSolicitud =
  document.getElementById("tituloModalSolicitud");

const formularioSolicitud =
  document.getElementById("formularioSolicitud");

const cerrarModal =
  document.getElementById("cerrarModal");

const cancelarSolicitud =
  document.getElementById("cancelarSolicitud");

const clienteSolicitud =
  document.getElementById("clienteSolicitud");

const origenSolicitud =
  document.getElementById("origenSolicitud");

const destinoSolicitud =
  document.getElementById("destinoSolicitud");

const capacidadSolicitud =
  document.getElementById("capacidadSolicitud");

const fechaSolicitud =
  document.getElementById("fechaSolicitud");

const estadoSolicitud =
  document.getElementById("estadoSolicitud");

const justificacionSolicitud =
  document.getElementById("justificacionSolicitud");

/* Elementos del detalle */

const detalleSolicitud =
  document.getElementById("detalleSolicitud");

const cerrarDetalle =
  document.getElementById("cerrarDetalle");

const detalleCodigo =
  document.getElementById("detalleCodigo");

const detalleCliente =
  document.getElementById("detalleCliente");

const detalleFecha =
  document.getElementById("detalleFecha");

const detalleOrigen =
  document.getElementById("detalleOrigen");

const detalleDestino =
  document.getElementById("detalleDestino");

const detalleCapacidad =
  document.getElementById("detalleCapacidad");

const detalleEstado =
  document.getElementById("detalleEstado");

const detalleJustificacion =
  document.getElementById("detalleJustificacion");

/* Botones del detalle */

const botonEditarSolicitud =
  document.getElementById("editarSolicitud");

const botonEliminarSolicitud =
  document.getElementById("eliminarSolicitud");

/* Variables de control */

let modoFormulario = "nuevo";
let registroSeleccionado = null;

/* Adapta las solicitudes creadas anteriormente */

function normalizarSolicitudes() {
  clientes.forEach(function (cliente) {
    if (!Array.isArray(cliente.solicitudes)) {
      cliente.solicitudes = [];
    }

    cliente.solicitudes.forEach(function (solicitud) {
      if (!solicitud.origen || !solicitud.destino) {
        const partes =
          (solicitud.ruta || "").split(" - ");

        solicitud.origen =
          partes[0] || "No especificado";

        solicitud.destino =
          partes[1] || "No especificado";
      }

      solicitud.ruta =
        solicitud.origen + " - " + solicitud.destino;

      solicitud.fecha =
        solicitud.fecha || obtenerFechaActual();

      solicitud.estado =
        normalizarEstado(solicitud.estado);

      solicitud.justificacion =
        solicitud.justificacion ||
        "Solicitud registrada por el cliente.";
    });
  });

  guardarClientes();
}

/* Convierte estados antiguos a los estados actuales */

function normalizarEstado(estado) {
  if (estado === "Aprobada") {
    return "Aprobado";
  }

  if (estado === "Rechazada") {
    return "Desaprobado";
  }

  if (
    estado !== "Aprobado" &&
    estado !== "Desaprobado"
  ) {
    return "Pendiente";
  }

  return estado;
}

/* Obtiene todas las solicitudes y sus clientes */

function obtenerSolicitudes() {
  const solicitudes = [];

  clientes.forEach(function (cliente) {
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

/* Muestra las solicitudes en la tabla */

function mostrarSolicitudes() {
  tablaSolicitudes.innerHTML = "";

  const estadoElegido = filtroEstado.value;

  const solicitudesFiltradas =
    obtenerSolicitudes().filter(function (registro) {
      return (
        estadoElegido === "Todos" ||
        registro.solicitud.estado === estadoElegido
      );
    });

  cantidadSolicitudes.textContent =
    solicitudesFiltradas.length + " solicitudes";

  if (solicitudesFiltradas.length === 0) {
    sinSolicitudes.style.display = "block";
  } else {
    sinSolicitudes.style.display = "none";
  }

  solicitudesFiltradas.forEach(function (registro) {
    const solicitud = registro.solicitud;

    const fila = document.createElement("tr");

    fila.className = "fila-solicitud";

    fila.innerHTML = `
      <td class="codigo">
        ${solicitud.codigo}
      </td>

      <td>
        ${registro.clienteNombre}
      </td>

      <td>
        ${solicitud.origen}
      </td>

      <td>
        ${solicitud.destino}
      </td>

      <td>
        ${solicitud.capacidad}
      </td>

      <td>
        <select
          class="selector-estado ${obtenerClaseEstado(
            solicitud.estado
          )}"
        >
          <option value="Pendiente">
            Pendiente
          </option>

          <option value="Aprobado">
            Aprobado
          </option>

          <option value="Desaprobado">
            Desaprobado
          </option>
        </select>
      </td>
    `;

    const selector =
      fila.querySelector(".selector-estado");

    selector.value = solicitud.estado;

    /* Evita abrir el detalle al usar el selector */

    selector.addEventListener(
      "click",
      function (evento) {
        evento.stopPropagation();
      }
    );

    /* Cambia el estado */

    selector.addEventListener(
      "change",
      function (evento) {
        evento.stopPropagation();

        solicitud.estado = selector.value;

        guardarClientes();
        mostrarSolicitudes();

        if (
          registroSeleccionado &&
          registroSeleccionado.solicitud.codigo ===
            solicitud.codigo
        ) {
          registroSeleccionado = registro;
          mostrarDetalle(registro);
        }
      }
    );

    /* Abre todos los datos de la solicitud */

    fila.addEventListener("click", function () {
      mostrarDetalle(registro);
    });

    tablaSolicitudes.appendChild(fila);
  });
}

/* Devuelve la clase CSS correspondiente al estado */

function obtenerClaseEstado(estado) {
  if (estado === "Aprobado") {
    return "aprobado";
  }

  if (estado === "Desaprobado") {
    return "desaprobado";
  }

  return "pendiente";
}

/* Carga los clientes en el formulario */

function cargarClientes() {
  clienteSolicitud.innerHTML =
    '<option value="">Seleccione un cliente</option>';

  clientes.forEach(function (cliente) {
    const opcion = document.createElement("option");

    opcion.value = cliente.codigo;

    opcion.textContent =
      cliente.codigo + " · " + cliente.nombre;

    clienteSolicitud.appendChild(opcion);
  });
}

/* Abre el formulario para registrar */

botonNuevaSolicitud.addEventListener(
  "click",
  function () {
    if (clientes.length === 0) {
      alert("Primero debe registrar un cliente.");
      return;
    }

    modoFormulario = "nuevo";
    registroSeleccionado = null;

    tituloModalSolicitud.textContent =
      "Crear nueva solicitud";

    formularioSolicitud.reset();

    cargarClientes();

    estadoSolicitud.value = "Pendiente";
    fechaSolicitud.value = obtenerFechaActual();

    modalSolicitud.classList.add("mostrar");
    clienteSolicitud.focus();
  }
);

/* Abre el formulario para editar */

botonEditarSolicitud.addEventListener(
  "click",
  function () {
    if (!registroSeleccionado) {
      alert("Primero debe seleccionar una solicitud.");
      return;
    }

    const solicitud =
      registroSeleccionado.solicitud;

    modoFormulario = "editar";

    tituloModalSolicitud.textContent =
      "Editar solicitud " + solicitud.codigo;

    cargarClientes();

    clienteSolicitud.value =
      registroSeleccionado.clienteCodigo;

    origenSolicitud.value =
      solicitud.origen;

    destinoSolicitud.value =
      solicitud.destino;

    capacidadSolicitud.value =
      solicitud.capacidad;

    fechaSolicitud.value =
      solicitud.fecha;

    estadoSolicitud.value =
      solicitud.estado;

    justificacionSolicitud.value =
      solicitud.justificacion;

    modalSolicitud.classList.add("mostrar");
    clienteSolicitud.focus();
  }
);

/* Guarda una solicitud nueva o editada */

formularioSolicitud.addEventListener(
  "submit",
  function (evento) {
    evento.preventDefault();

    const clienteDestino = clientes.find(
      function (cliente) {
        return (
          cliente.codigo === clienteSolicitud.value
        );
      }
    );

    if (!clienteDestino) {
      alert("Seleccione un cliente válido.");
      return;
    }

    if (modoFormulario === "nuevo") {
      registrarNuevaSolicitud(clienteDestino);
    } else {
      editarSolicitudGuardada(clienteDestino);
    }

    guardarClientes();
    mostrarSolicitudes();
    cerrarVentanaSolicitud();

    if (registroSeleccionado) {
      mostrarDetalle(registroSeleccionado);
    }
  }
);

/* Registra una nueva solicitud */

function registrarNuevaSolicitud(clienteDestino) {
  const nuevaSolicitud = {
    codigo: generarCodigoSolicitud(),

    origen:
      origenSolicitud.value.trim(),

    destino:
      destinoSolicitud.value.trim(),

    ruta:
      origenSolicitud.value.trim() +
      " - " +
      destinoSolicitud.value.trim(),

    capacidad:
      capacidadSolicitud.value.trim(),

    fecha:
      fechaSolicitud.value,

    estado:
      estadoSolicitud.value,

    justificacion:
      justificacionSolicitud.value.trim()
  };

  clienteDestino.solicitudes.push(nuevaSolicitud);

  registroSeleccionado = {
    clienteCodigo: clienteDestino.codigo,
    clienteNombre: clienteDestino.nombre,
    solicitud: nuevaSolicitud
  };
}

/* Guarda los cambios de una solicitud */

function editarSolicitudGuardada(clienteDestino) {
  const clienteAnterior = clientes.find(
    function (cliente) {
      return (
        cliente.codigo ===
        registroSeleccionado.clienteCodigo
      );
    }
  );

  if (!clienteAnterior) {
    alert("No se encontró el cliente anterior.");
    return;
  }

  const solicitud =
    registroSeleccionado.solicitud;

  /* Si cambió el cliente, mueve la solicitud */

  if (
    clienteAnterior.codigo !==
    clienteDestino.codigo
  ) {
    clienteAnterior.solicitudes =
      clienteAnterior.solicitudes.filter(
        function (elemento) {
          return elemento.codigo !== solicitud.codigo;
        }
      );

    clienteDestino.solicitudes.push(solicitud);
  }

  solicitud.origen =
    origenSolicitud.value.trim();

  solicitud.destino =
    destinoSolicitud.value.trim();

  solicitud.ruta =
    solicitud.origen + " - " + solicitud.destino;

  solicitud.capacidad =
    capacidadSolicitud.value.trim();

  solicitud.fecha =
    fechaSolicitud.value;

  solicitud.estado =
    estadoSolicitud.value;

  solicitud.justificacion =
    justificacionSolicitud.value.trim();

  registroSeleccionado = {
    clienteCodigo: clienteDestino.codigo,
    clienteNombre: clienteDestino.nombre,
    solicitud: solicitud
  };
}

/* Elimina la solicitud seleccionada */

botonEliminarSolicitud.addEventListener(
  "click",
  function () {
    if (!registroSeleccionado) {
      alert("Primero debe seleccionar una solicitud.");
      return;
    }

    const codigoSolicitud =
      registroSeleccionado.solicitud.codigo;

    const confirmar = confirm(
      "¿Está seguro de eliminar la solicitud " +
      codigoSolicitud +
      "?"
    );

    if (!confirmar) {
      return;
    }

    const cliente = clientes.find(
      function (elemento) {
        return (
          elemento.codigo ===
          registroSeleccionado.clienteCodigo
        );
      }
    );

    if (!cliente) {
      alert("No se encontró el cliente.");
      return;
    }

    cliente.solicitudes =
      cliente.solicitudes.filter(
        function (solicitud) {
          return (
            solicitud.codigo !== codigoSolicitud
          );
        }
      );

    registroSeleccionado = null;

    guardarClientes();
    mostrarSolicitudes();

    detalleSolicitud.classList.add("oculto");

    alert("La solicitud fue eliminada correctamente.");
  }
);

/* Genera el código de solicitud */

function generarCodigoSolicitud() {
  let numeroMayor = 0;

  obtenerSolicitudes().forEach(function (registro) {
    const numero = parseInt(
      registro.solicitud.codigo.replace("SOL-", "")
    );

    if (numero > numeroMayor) {
      numeroMayor = numero;
    }
  });

  return "SOL-" +
    String(numeroMayor + 1).padStart(3, "0");
}

/* Muestra todos los datos de la solicitud */

function mostrarDetalle(registro) {
  registroSeleccionado = registro;

  const solicitud = registro.solicitud;

  detalleCodigo.textContent =
    solicitud.codigo;

  detalleCliente.textContent =
    registro.clienteNombre;

  detalleFecha.textContent =
    formatearFecha(solicitud.fecha);

  detalleOrigen.textContent =
    solicitud.origen;

  detalleDestino.textContent =
    solicitud.destino;

  detalleCapacidad.textContent =
    solicitud.capacidad;

  detalleEstado.textContent =
    solicitud.estado;

  detalleJustificacion.textContent =
    solicitud.justificacion;

  detalleSolicitud.classList.remove("oculto");

  detalleSolicitud.scrollIntoView({
    behavior: "smooth",
    block: "start"
  });
}

/* Cierra el formulario */

function cerrarVentanaSolicitud() {
  modalSolicitud.classList.remove("mostrar");
  formularioSolicitud.reset();
}

cerrarModal.addEventListener(
  "click",
  cerrarVentanaSolicitud
);

cancelarSolicitud.addEventListener(
  "click",
  cerrarVentanaSolicitud
);

modalSolicitud.addEventListener(
  "click",
  function (evento) {
    if (evento.target === modalSolicitud) {
      cerrarVentanaSolicitud();
    }
  }
);

/* Cierra el detalle */

cerrarDetalle.addEventListener(
  "click",
  function () {
    detalleSolicitud.classList.add("oculto");
    registroSeleccionado = null;
  }
);

/* Filtra por estado */

filtroEstado.addEventListener(
  "change",
  mostrarSolicitudes
);

/* Guarda los clientes y sus solicitudes */

function guardarClientes() {
  localStorage.setItem(
    CLAVE_CLIENTES,
    JSON.stringify(clientes)
  );
}

/* Obtiene la fecha actual */

function obtenerFechaActual() {
  const fecha = new Date();

  const anio =
    fecha.getFullYear();

  const mes =
    String(fecha.getMonth() + 1).padStart(2, "0");

  const dia =
    String(fecha.getDate()).padStart(2, "0");

  return anio + "-" + mes + "-" + dia;
}

/* Muestra la fecha como día/mes/año */

function formatearFecha(fecha) {
  if (!fecha) {
    return "No registrada";
  }

  const partes = fecha.split("-");

  return (
    partes[2] +
    "/" +
    partes[1] +
    "/" +
    partes[0]
  );
}

/* Inicio */

normalizarSolicitudes();
cargarClientes();
mostrarSolicitudes();