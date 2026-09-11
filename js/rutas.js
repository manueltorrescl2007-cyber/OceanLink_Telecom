const CLAVE_RUTAS = "rutasOceanLinkV1";
const CLAVE_CLIENTES = "clientesOceanLinkV2";

const rutasIniciales = [
  {
    codigo: "RUT-001",
    origen: "Lima",
    destino: "Valparaíso",
    segmentos: 2,
    capacidadTotal: 100
  },
  {
    codigo: "RUT-002",
    origen: "Lima",
    destino: "España",
    segmentos: 4,
    capacidadTotal: 200
  }
];

let rutas =
  JSON.parse(localStorage.getItem(CLAVE_RUTAS));

let clientes =
  JSON.parse(localStorage.getItem(CLAVE_CLIENTES)) || [];

if (rutas === null) {
  rutas = rutasIniciales;
  guardarRutas();
}

normalizarRutas();

/* Elementos */

const tablaRutas = document.getElementById("tablaRutas");
const sinRutas = document.getElementById("sinRutas");
const cantidadRutas = document.getElementById("cantidadRutas");
const filtroEstado = document.getElementById("filtroEstado");

const botonAsignarRuta = document.getElementById("asignarRuta");
const modalRuta = document.getElementById("modalRuta");
const formularioRuta = document.getElementById("formularioRuta");
const cerrarModal = document.getElementById("cerrarModal");
const cancelarRuta = document.getElementById("cancelarRuta");

const origenRuta = document.getElementById("origenRuta");
const destinoRuta = document.getElementById("destinoRuta");
const segmentosRuta = document.getElementById("segmentosRuta");
const capacidadRuta = document.getElementById("capacidadRuta");

/* Convierte rutas antiguas */

function normalizarRutas() {
  rutas.forEach(function (ruta) {
    if (!ruta.capacidadTotal) {
      ruta.capacidadTotal =
        parseFloat(ruta.capacidad) || 0;
    }
  });

  guardarRutas();
}

/* Suma la capacidad de los servicios de una ruta */

function calcularCapacidadUsada(codigoRuta) {
  let total = 0;

  clientes.forEach(function (cliente) {
    if (!Array.isArray(cliente.servicios)) {
      return;
    }

    cliente.servicios.forEach(function (servicio) {
      const consumeCapacidad =
        servicio.estado === "Activo" ||
        servicio.estado === "Provisionado";

      if (
        servicio.rutaCodigo === codigoRuta &&
        consumeCapacidad
      ) {
        total += obtenerCapacidadGbps(servicio);
      }
    });
  });

  return total;
}

function obtenerCapacidadGbps(servicio) {
  if (typeof servicio.capacidadGbps === "number") {
    return servicio.capacidadGbps;
  }

  const texto = String(servicio.capacidad || "");
  const cantidad = parseFloat(texto) || 0;

  if (texto.toLowerCase().includes("mbps")) {
    return cantidad / 1000;
  }

  return cantidad;
}

/* Estado automático */

function calcularEstado(ruta, capacidadUsada) {
  const disponible =
    ruta.capacidadTotal - capacidadUsada;

  const porcentaje =
    ruta.capacidadTotal > 0
      ? disponible / ruta.capacidadTotal
      : 0;

  if (disponible <= 0) {
    return "Insuficiente";
  }

  if (porcentaje <= 0.30) {
    return "Limitada";
  }

  return "Disponible";
}

/* Tabla */

function mostrarRutas() {
  tablaRutas.innerHTML = "";

  const estadoFiltrado = filtroEstado.value;
  const filas = [];

  rutas.forEach(function (ruta) {
    const usada = calcularCapacidadUsada(ruta.codigo);

    const disponible = Math.max(
      ruta.capacidadTotal - usada,
      0
    );

    const estado = calcularEstado(ruta, usada);

    if (
      estadoFiltrado === "Todos" ||
      estado === estadoFiltrado
    ) {
      filas.push({
        ruta: ruta,
        usada: usada,
        disponible: disponible,
        estado: estado
      });
    }
  });

  cantidadRutas.textContent = filas.length + " rutas";
  sinRutas.style.display = filas.length === 0 ? "block" : "none";

  filas.forEach(function (registro) {
    const ruta = registro.ruta;
    const fila = document.createElement("tr");

    fila.innerHTML = `
      <td class="codigo-ruta">${ruta.codigo}</td>
      <td>${ruta.origen}</td>
      <td>${ruta.destino}</td>
      <td>${ruta.segmentos}</td>
      <td>${formatearCapacidad(ruta.capacidadTotal)}</td>
      <td>${formatearCapacidad(registro.usada)}</td>
      <td>${formatearCapacidad(registro.disponible)}</td>

      <td>
        <span class="estado-ruta ${registro.estado.toLowerCase()}">
          ${registro.estado}
        </span>
      </td>
    `;

    tablaRutas.appendChild(fila);
  });
}

/* Nueva ruta */

botonAsignarRuta.addEventListener("click", function () {
  formularioRuta.reset();
  modalRuta.classList.add("mostrar");
  origenRuta.focus();
});

formularioRuta.addEventListener("submit", function (evento) {
  evento.preventDefault();

  const nuevaRuta = {
    codigo: generarCodigoRuta(),
    origen: origenRuta.value.trim(),
    destino: destinoRuta.value.trim(),
    segmentos: Number(segmentosRuta.value),
    capacidadTotal: Number(capacidadRuta.value)
  };

  rutas.push(nuevaRuta);

  guardarRutas();
  mostrarRutas();
  cerrarVentana();
});

function generarCodigoRuta() {
  let mayor = 0;

  rutas.forEach(function (ruta) {
    const numero = parseInt(
      ruta.codigo.replace("RUT-", "")
    );

    if (numero > mayor) {
      mayor = numero;
    }
  });

  return "RUT-" + String(mayor + 1).padStart(3, "0");
}

function formatearCapacidad(valor) {
  return Number(valor.toFixed(2)) + " Gbps";
}

function guardarRutas() {
  localStorage.setItem(
    CLAVE_RUTAS,
    JSON.stringify(rutas)
  );
}

function cerrarVentana() {
  modalRuta.classList.remove("mostrar");
  formularioRuta.reset();
}

cerrarModal.addEventListener("click", cerrarVentana);
cancelarRuta.addEventListener("click", cerrarVentana);

modalRuta.addEventListener("click", function (evento) {
  if (evento.target === modalRuta) {
    cerrarVentana();
  }
});

filtroEstado.addEventListener("change", mostrarRutas);

/* Recarga los servicios al regresar a Rutas */

window.addEventListener("pageshow", function () {
  clientes =
    JSON.parse(localStorage.getItem(CLAVE_CLIENTES)) || [];

  rutas =
    JSON.parse(localStorage.getItem(CLAVE_RUTAS)) || rutas;

  mostrarRutas();
});

/* Inicio */

mostrarRutas();