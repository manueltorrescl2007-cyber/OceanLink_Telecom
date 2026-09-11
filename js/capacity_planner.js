const botonNuevo = document.getElementById("botonNuevo");
const modalAccion = document.getElementById("modalAccion");
const cerrarModal = document.getElementById("cerrarModal");
const cancelarAccion = document.getElementById("cancelarAccion");
const formularioAccion = document.getElementById("formularioAccion");
const descripcionAccion = document.getElementById("descripcionAccion");
const prioridadAccion = document.getElementById("prioridadAccion");
const listaAcciones = document.getElementById("listaAcciones");
const cantidadAcciones = document.getElementById("cantidadAcciones");

/* Acciones iniciales */

const accionesIniciales = [
  {
    codigo: "SOL-014",
    descripcion: "Verificar capacidad",
    prioridad: "critica"
  },
  {
    codigo: "SOL-018",
    descripcion: "Seleccionar ruta",
    prioridad: "alta"
  },
  {
    codigo: "SOL-021",
    descripcion: "Confirmar reserva",
    prioridad: "media"
  }
];

/* Recupera las acciones guardadas en el navegador */

let acciones = JSON.parse(localStorage.getItem("accionesPendientes"));

if (acciones === null) {
  acciones = accionesIniciales;
  guardarAcciones();
}

/* Abre el formulario */

botonNuevo.addEventListener("click", function () {
  modalAccion.classList.add("mostrar");
  descripcionAccion.focus();
});

/* Cierra el formulario */

cerrarModal.addEventListener("click", cerrarVentana);
cancelarAccion.addEventListener("click", cerrarVentana);

function cerrarVentana() {
  modalAccion.classList.remove("mostrar");
  formularioAccion.reset();
}

/* Cierra el formulario al presionar fuera del cuadro */

modalAccion.addEventListener("click", function (evento) {
  if (evento.target === modalAccion) {
    cerrarVentana();
  }
});

/* Registra una nueva acción */

formularioAccion.addEventListener("submit", function (evento) {
  evento.preventDefault();

  const nuevaAccion = {
    codigo: generarCodigo(),
    descripcion: descripcionAccion.value.trim(),
    prioridad: prioridadAccion.value
  };

  acciones.push(nuevaAccion);

  guardarAcciones();
  mostrarAcciones();
  cerrarVentana();
});

/* Genera automáticamente un código */

function generarCodigo() {
  let numeroMayor = 0;

  acciones.forEach(function (accion) {
    const numero = parseInt(accion.codigo.replace("SOL-", ""));

    if (numero > numeroMayor) {
      numeroMayor = numero;
    }
  });

  const nuevoNumero = numeroMayor + 1;

  return "SOL-" + String(nuevoNumero).padStart(3, "0");
}

/* Muestra todas las acciones dentro de la tarjeta */

function mostrarAcciones() {
  listaAcciones.innerHTML = "";

  acciones.forEach(function (accion) {
    const elemento = document.createElement("li");

    elemento.innerHTML = `
      <div class="informacion-accion">
        <strong>${accion.codigo}</strong>
        <span>${accion.descripcion}</span>
      </div>

      <span class="prioridad ${accion.prioridad}">
        ${obtenerNombrePrioridad(accion.prioridad)}
      </span>
    `;

    listaAcciones.appendChild(elemento);
  });

  cantidadAcciones.textContent = acciones.length;
}

/* Convierte el nombre de la prioridad */

function obtenerNombrePrioridad(prioridad) {
  if (prioridad === "critica") {
    return "Crítica";
  }

  if (prioridad === "alta") {
    return "Alta";
  }

  return "Media";
}

/* Guarda las acciones en el navegador */

function guardarAcciones() {
  localStorage.setItem(
    "accionesPendientes",
    JSON.stringify(acciones)
  );
}

/* Muestra la lista al cargar la página */

mostrarAcciones();