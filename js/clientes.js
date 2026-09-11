const CLAVE_CLIENTES = "clientesOceanLinkV2";

/* Datos iniciales */

const clientesIniciales = [
  {
    codigo: "CLI-001",
    nombre: "Pacífico",
    tipo: "Empresa de red",
    contacto: "María Torres",
    correo: "maria.torres@pacifico.com",
    telefono: "+51 987 456 321",
    estado: "Activo",
    visitas: 4,

    solicitudes: [
      {
        codigo: "SOL-014",
        origen: "Lima",
        destino: "Jamaica",
        ruta: "Lima - Jamaica",
        capacidad: "50 Mbps",
        fecha: "2026-09-11",
        estado: "Pendiente",
        justificacion:
          "El cliente necesita ampliar su conectividad internacional."
      },
      {
        codigo: "SOL-021",
        origen: "Callao",
        destino: "Panamá",
        ruta: "Callao - Panamá",
        capacidad: "100 Mbps",
        fecha: "2026-09-11",
        estado: "Aprobado",
        justificacion:
          "El cliente requiere una ruta adicional para sus operaciones."
      }
    ],

    servicios: [
      {
        codigo: "SER-008",
        ruta: "Lima - España",
        capacidad: "80 Mbps",
        riesgo: "Capacidad limitada en un segmento",
        estado: "Activo"
      },
      {
        codigo: "SER-012",
        ruta: "Callao - Miami",
        capacidad: "100 Mbps",
        riesgo: "Sin riesgos registrados",
        estado: "Activo"
      }
    ]
  },

  {
    codigo: "CLI-002",
    nombre: "Atlántico",
    tipo: "Empresa de telecomunicaciones",
    contacto: "Carlos Méndez",
    correo: "carlos.mendez@atlantico.com",
    telefono: "+51 955 234 871",
    estado: "Activo",
    visitas: 2,

    solicitudes: [
      {
        codigo: "SOL-018",
        origen: "Lima",
        destino: "Miami",
        ruta: "Lima - Miami",
        capacidad: "200 Mbps",
        fecha: "2026-09-11",
        estado: "Pendiente",
        justificacion:
          "Se requiere mayor capacidad para atender nuevos clientes."
      }
    ],

    servicios: [
      {
        codigo: "SER-015",
        ruta: "Lima - Chile",
        capacidad: "200 Mbps",
        riesgo: "Saturación durante horas de alta demanda",
        estado: "Inactivo"
      }
    ]
  },

  {
    codigo: "CLI-003",
    nombre: "Mediterráneo",
    tipo: "Empresa de red",
    contacto: "Lucía Salazar",
    correo: "lucia.salazar@mediterraneo.com",
    telefono: "+51 944 682 150",
    estado: "En evaluación",
    visitas: 1,

    solicitudes: [
      {
        codigo: "SOL-025",
        origen: "Lima",
        destino: "España",
        ruta: "Lima - España",
        capacidad: "150 Mbps",
        fecha: "2026-09-11",
        estado: "Pendiente",
        justificacion:
          "El cliente desea contratar conectividad entre Perú y España."
      }
    ],

    servicios: []
  }
];

/* Elementos de la lista */

const listaClientes =
  document.getElementById("listaClientes");

const cantidadClientes =
  document.getElementById("cantidadClientes");

/* Elementos del resumen */

const identificadorCliente =
  document.getElementById("identificadorCliente");

const resumenSolicitudes =
  document.getElementById("resumenSolicitudes");

const resumenServicios =
  document.getElementById("resumenServicios");

const resumenContacto =
  document.getElementById("resumenContacto");

const resumenEstado =
  document.getElementById("resumenEstado");

const opcionesResumen =
  document.querySelectorAll(".opcion-resumen");

/* Elementos del detalle */

const panelDetalle =
  document.getElementById("panelDetalle");

const clienteDetalle =
  document.getElementById("clienteDetalle");

const tituloDetalle =
  document.getElementById("tituloDetalle");

const contenidoDetalle =
  document.getElementById("contenidoDetalle");

const cerrarDetalle =
  document.getElementById("cerrarDetalle");

/* Elementos del formulario */

const modalCliente =
  document.getElementById("modalCliente");

const tituloModalCliente =
  document.getElementById("tituloModalCliente");

const formularioCliente =
  document.getElementById("formularioCliente");

const cerrarModalCliente =
  document.getElementById("cerrarModalCliente");

const cancelarCliente =
  document.getElementById("cancelarCliente");

const nombreCliente =
  document.getElementById("nombreCliente");

const tipoCliente =
  document.getElementById("tipoCliente");

const contactoCliente =
  document.getElementById("contactoCliente");

const correoCliente =
  document.getElementById("correoCliente");

const telefonoCliente =
  document.getElementById("telefonoCliente");

const estadoCliente =
  document.getElementById("estadoCliente");

/* Botones */

const botonNuevo =
  document.getElementById("nuevoCliente");

const botonEditar =
  document.getElementById("editarCliente");

const botonEliminar =
  document.getElementById("eliminarCliente");

/* Recuperar clientes */

let clientes =
  JSON.parse(localStorage.getItem(CLAVE_CLIENTES));

if (clientes === null) {
  clientes = clientesIniciales;
  guardarClientes();
}

/* Normaliza datos antiguos */

normalizarDatosClientes();

let codigoClienteSeleccionado =
  clientes.length > 0 ? clientes[0].codigo : null;

let modoFormulario = "nuevo";

/* Completa datos que falten */

function normalizarDatosClientes() {
  clientes.forEach(function (cliente) {
    cliente.visitas = cliente.visitas || 0;

    if (!Array.isArray(cliente.solicitudes)) {
      cliente.solicitudes = [];
    }

    if (!Array.isArray(cliente.servicios)) {
      cliente.servicios = [];
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
        solicitud.fecha || "No registrada";

      solicitud.estado =
        normalizarEstadoSolicitud(solicitud.estado);

      solicitud.justificacion =
        solicitud.justificacion ||
        "Solicitud registrada por el cliente.";
    });

    cliente.servicios.forEach(function (servicio) {
      servicio.ruta =
        servicio.ruta ||
        servicio.nombre ||
        "Ruta no especificada";

      servicio.riesgo =
        servicio.riesgo ||
        "Sin riesgos registrados";

      servicio.estado =
        servicio.estado || "Activo";
    });
  });

  guardarClientes();
}

/* Normaliza estados antiguos */

function normalizarEstadoSolicitud(estado) {
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

/* Calcula clientes frecuentes */

function calcularPuntuacion(cliente) {
  return cliente.servicios.length * 3 + cliente.visitas;
}

/* Muestra los clientes */

function mostrarClientes() {
  listaClientes.innerHTML = "";

  const clientesOrdenados = [...clientes].sort(
    function (clienteA, clienteB) {
      return (
        calcularPuntuacion(clienteB) -
        calcularPuntuacion(clienteA)
      );
    }
  );

  cantidadClientes.textContent = clientes.length;

  if (clientesOrdenados.length === 0) {
    listaClientes.innerHTML = `
      <li class="sin-clientes">
        Todavía no existen clientes registrados.
      </li>
    `;

    limpiarResumen();
    return;
  }

  clientesOrdenados.forEach(function (cliente) {
    const elemento = document.createElement("li");

    elemento.className = "cliente";

    if (cliente.codigo === codigoClienteSeleccionado) {
      elemento.classList.add("activo");
    }

    elemento.innerHTML = `
      <div class="avatar-cliente">
        ${obtenerInicial(cliente.nombre)}
      </div>

      <div>
        <strong>${cliente.nombre}</strong>

        <span>
          ${cliente.tipo} ·
          ${cliente.servicios.length} servicios
        </span>
      </div>
    `;

    elemento.addEventListener("click", function () {
      seleccionarCliente(cliente.codigo);
    });

    listaClientes.appendChild(elemento);
  });
}

/* Selecciona un cliente */

function seleccionarCliente(codigo) {
  codigoClienteSeleccionado = codigo;

  const cliente = obtenerClienteSeleccionado();

  if (!cliente) {
    return;
  }

  cliente.visitas = cliente.visitas + 1;

  guardarClientes();
  mostrarClientes();
  actualizarResumen();
  ocultarDetalle();
}

/* Obtiene el cliente seleccionado */

function obtenerClienteSeleccionado() {
  return clientes.find(function (cliente) {
    return cliente.codigo === codigoClienteSeleccionado;
  });
}

/* Actualiza el resumen */

function actualizarResumen() {
  const cliente = obtenerClienteSeleccionado();

  if (!cliente) {
    limpiarResumen();
    return;
  }

  identificadorCliente.textContent =
    cliente.codigo + " · " + cliente.nombre;

  resumenSolicitudes.textContent =
    cliente.solicitudes.length +
    " solicitudes registradas";

  resumenServicios.textContent =
    cliente.servicios.length +
    " servicios contratados";

  resumenContacto.textContent = cliente.contacto;
  resumenEstado.textContent = cliente.estado;
}

/* Limpia el resumen */

function limpiarResumen() {
  identificadorCliente.textContent =
    "Ningún cliente seleccionado";

  resumenSolicitudes.textContent = "0 solicitudes";
  resumenServicios.textContent = "0 servicios";
  resumenContacto.textContent = "Sin contacto";
  resumenEstado.textContent = "Sin estado";

  ocultarDetalle();
}

/* Opciones del resumen */

opcionesResumen.forEach(function (opcion) {
  opcion.addEventListener("click", function () {
    if (!codigoClienteSeleccionado) {
      alert("Primero debe registrar o seleccionar un cliente.");
      return;
    }

    opcionesResumen.forEach(function (elemento) {
      elemento.classList.remove("seleccionada");
    });

    opcion.classList.add("seleccionada");

    mostrarDetalle(opcion.dataset.detalle);
  });
});

/* Muestra el detalle seleccionado */

function mostrarDetalle(tipo) {
  const cliente = obtenerClienteSeleccionado();

  if (!cliente) {
    return;
  }

  clienteDetalle.textContent =
    "Cliente " + cliente.nombre;

  panelDetalle.classList.remove("oculto");

  if (tipo === "solicitudes") {
    mostrarSolicitudes(cliente);
  }

  if (tipo === "servicios") {
    mostrarServicios(cliente);
  }

  if (tipo === "contacto") {
    mostrarContacto(cliente);
  }

  if (tipo === "estado") {
    mostrarEstado(cliente);
  }

  panelDetalle.scrollIntoView({
    behavior: "smooth",
    block: "start"
  });
}

/* Solicitudes asociadas */

function mostrarSolicitudes(cliente) {
  tituloDetalle.textContent = "Solicitudes asociadas";
  contenidoDetalle.innerHTML = "";

  if (cliente.solicitudes.length === 0) {
    contenidoDetalle.innerHTML = `
      <article class="tarjeta-detalle">
        <p>Este cliente no tiene solicitudes asociadas.</p>
      </article>
    `;

    return;
  }

  cliente.solicitudes.forEach(function (solicitud) {
    const claseEstado =
      obtenerClaseEstadoSolicitud(solicitud.estado);

    contenidoDetalle.innerHTML += `
      <article class="tarjeta-detalle">

        <h3>
          ${solicitud.codigo} · ${solicitud.ruta}
        </h3>

        <p>
          <strong>Capacidad solicitada:</strong>
          ${solicitud.capacidad}
        </p>

        <p>
          <strong>Estado:</strong>

          <span class="${claseEstado}">
            ${solicitud.estado}
          </span>
        </p>

      </article>
    `;
  });
}

/* Clase correspondiente al estado */

function obtenerClaseEstadoSolicitud(estado) {
  if (estado === "Aprobado") {
    return "estado-aprobado";
  }

  if (estado === "Desaprobado") {
    return "estado-desaprobado";
  }

  return "estado-solicitud";
}

/* Servicios contratados */

function mostrarServicios(cliente) {
  tituloDetalle.textContent = "Servicios contratados";
  contenidoDetalle.innerHTML = "";

  if (cliente.servicios.length === 0) {
    contenidoDetalle.innerHTML = `
      <article class="tarjeta-detalle">
        <p>
          Este cliente todavía no tiene servicios contratados.
        </p>
      </article>
    `;

    return;
  }

  cliente.servicios.forEach(function (servicio) {
    const claseEstado =
      servicio.estado === "Activo"
        ? "estado-activo"
        : "estado-inactivo";

    contenidoDetalle.innerHTML += `
      <article class="tarjeta-detalle">

        <h3>${servicio.codigo}</h3>

        <p>
          <strong>Ruta:</strong>
          ${servicio.ruta}
        </p>

        <p>
          <strong>Capacidad contratada:</strong>
          ${servicio.capacidad}
        </p>

        <p>
          <strong>Riesgo de la ruta:</strong>
          ${servicio.riesgo}
        </p>

        <p>
          <strong>Estado del servicio:</strong>

          <span class="${claseEstado}">
            ${servicio.estado}
          </span>
        </p>

      </article>
    `;
  });
}

/* Contacto */

function mostrarContacto(cliente) {
  tituloDetalle.textContent = "Información de contacto";

  contenidoDetalle.innerHTML = `
    <article class="tarjeta-detalle">

      <h3>${cliente.contacto}</h3>

      <p>
        <strong>Correo:</strong>
        ${cliente.correo}
      </p>

      <p>
        <strong>Teléfono:</strong>
        ${cliente.telefono}
      </p>

    </article>
  `;
}

/* Estado del cliente */

function mostrarEstado(cliente) {
  tituloDetalle.textContent = "Estado del cliente";

  const claseEstado =
    cliente.estado === "Activo"
      ? "estado-activo"
      : "estado-inactivo";

  contenidoDetalle.innerHTML = `
    <article class="tarjeta-detalle">

      <h3>${cliente.nombre}</h3>

      <p>
        <strong>Estado:</strong>

        <span class="${claseEstado}">
          ${cliente.estado}
        </span>
      </p>

    </article>
  `;
}

/* Oculta el detalle */

function ocultarDetalle() {
  panelDetalle.classList.add("oculto");

  opcionesResumen.forEach(function (opcion) {
    opcion.classList.remove("seleccionada");
  });
}

cerrarDetalle.addEventListener("click", ocultarDetalle);

/* Nuevo cliente */

botonNuevo.addEventListener("click", function () {
  modoFormulario = "nuevo";

  tituloModalCliente.textContent = "Nuevo cliente";

  formularioCliente.reset();
  estadoCliente.value = "Activo";

  modalCliente.classList.add("mostrar");
  nombreCliente.focus();
});

/* Editar cliente */

botonEditar.addEventListener("click", function () {
  const cliente = obtenerClienteSeleccionado();

  if (!cliente) {
    alert("No existe un cliente seleccionado.");
    return;
  }

  modoFormulario = "editar";

  tituloModalCliente.textContent = "Editar cliente";

  nombreCliente.value = cliente.nombre;
  tipoCliente.value = cliente.tipo;
  contactoCliente.value = cliente.contacto;
  correoCliente.value = cliente.correo;
  telefonoCliente.value = cliente.telefono;
  estadoCliente.value = cliente.estado;

  modalCliente.classList.add("mostrar");
  nombreCliente.focus();
});

/* Guarda el cliente */

formularioCliente.addEventListener(
  "submit",
  function (evento) {
    evento.preventDefault();

    if (modoFormulario === "nuevo") {
      const nuevoCliente = {
        codigo: generarCodigoCliente(),
        nombre: nombreCliente.value.trim(),
        tipo: tipoCliente.value.trim(),
        contacto: contactoCliente.value.trim(),
        correo: correoCliente.value.trim(),
        telefono: telefonoCliente.value.trim(),
        estado: estadoCliente.value,
        visitas: 0,
        solicitudes: [],
        servicios: []
      };

      clientes.push(nuevoCliente);

      codigoClienteSeleccionado =
        nuevoCliente.codigo;
    } else {
      const cliente = obtenerClienteSeleccionado();

      if (!cliente) {
        return;
      }

      cliente.nombre = nombreCliente.value.trim();
      cliente.tipo = tipoCliente.value.trim();
      cliente.contacto = contactoCliente.value.trim();
      cliente.correo = correoCliente.value.trim();
      cliente.telefono = telefonoCliente.value.trim();
      cliente.estado = estadoCliente.value;
    }

    guardarClientes();
    mostrarClientes();
    actualizarResumen();
    ocultarDetalle();
    cerrarFormularioCliente();
  }
);

/* Elimina el cliente */

botonEliminar.addEventListener("click", function () {
  const cliente = obtenerClienteSeleccionado();

  if (!cliente) {
    alert("No existe un cliente seleccionado.");
    return;
  }

  if (cliente.servicios.length > 0) {
    alert(
      "No se puede eliminar este cliente porque tiene servicios contratados."
    );

    return;
  }

  const confirmar = confirm(
    "¿Está seguro de eliminar al cliente " +
    cliente.nombre +
    "?"
  );

  if (!confirmar) {
    return;
  }

  clientes = clientes.filter(function (elemento) {
    return elemento.codigo !== cliente.codigo;
  });

  codigoClienteSeleccionado =
    clientes.length > 0 ? clientes[0].codigo : null;

  guardarClientes();
  mostrarClientes();
  actualizarResumen();
});

/* Genera el código del cliente */

function generarCodigoCliente() {
  let numeroMayor = 0;

  clientes.forEach(function (cliente) {
    const numero = parseInt(
      cliente.codigo.replace("CLI-", "")
    );

    if (numero > numeroMayor) {
      numeroMayor = numero;
    }
  });

  return "CLI-" +
    String(numeroMayor + 1).padStart(3, "0");
}

/* Cierra el formulario */

function cerrarFormularioCliente() {
  modalCliente.classList.remove("mostrar");
  formularioCliente.reset();
}

cerrarModalCliente.addEventListener(
  "click",
  cerrarFormularioCliente
);

cancelarCliente.addEventListener(
  "click",
  cerrarFormularioCliente
);

modalCliente.addEventListener("click", function (evento) {
  if (evento.target === modalCliente) {
    cerrarFormularioCliente();
  }
});

/* Funciones auxiliares */

function obtenerInicial(nombre) {
  return nombre.charAt(0).toUpperCase();
}

function guardarClientes() {
  localStorage.setItem(
    CLAVE_CLIENTES,
    JSON.stringify(clientes)
  );
}

/* Actualiza los datos al regresar desde Solicitudes */

function actualizarDesdeAlmacenamiento() {
  const datosActualizados =
    JSON.parse(localStorage.getItem(CLAVE_CLIENTES));

  if (datosActualizados) {
    clientes = datosActualizados;
  }

  normalizarDatosClientes();

  const clienteExiste = clientes.some(
    function (cliente) {
      return cliente.codigo === codigoClienteSeleccionado;
    }
  );

  if (!clienteExiste) {
    codigoClienteSeleccionado =
      clientes.length > 0 ? clientes[0].codigo : null;
  }

  mostrarClientes();
  actualizarResumen();
  ocultarDetalle();
}

/* Actualiza al regresar a Clientes */

window.addEventListener(
  "pageshow",
  actualizarDesdeAlmacenamiento
);

/* Actualiza si Solicitudes cambia en otra pestaña */

window.addEventListener(
  "storage",
  function (evento) {
    if (evento.key === CLAVE_CLIENTES) {
      actualizarDesdeAlmacenamiento();
    }
  }
);

/* Primera carga */

actualizarDesdeAlmacenamiento();