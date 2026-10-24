package servlets.networkoperator;

import beans.Usuario;
import beans.networkoperator.Incidencia;
import beans.networkoperator.Observacion;
import beans.networkoperator.Segmento;
import daos.networkoperator.IncidenciaDao;
import daos.networkoperator.ObservacionDao;
import daos.networkoperator.SegmentoDao;
import daos.networkoperator.ServicioDao;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "IncidenciaServlet", value = "/IncidenciaServlet")
public class IncidenciaServlet extends HttpServlet {

    private static final String[] SEVERIDADES = {"Leve", "Media", "Alta", "Critica"};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        IncidenciaDao incidenciaDao = new IncidenciaDao();
        SegmentoDao segmentoDao = new SegmentoDao();
        RequestDispatcher view;

        switch (action) {

            case "lista": {
                String filtroSeveridad = validarSeveridad(request.getParameter("severidad"));
                int filtroIdSegmento = parseId(request.getParameter("idSegmento"));

                ArrayList<Incidencia> lista = incidenciaDao.listarIncidencias(false, filtroSeveridad, filtroIdSegmento);
                cargarSegmentos(lista, segmentoDao);

                request.setAttribute("listaIncidencias", lista);
                request.setAttribute("listaSegmentos", segmentoDao.listarSegmentos(null));
                request.setAttribute("filtroSeveridad", filtroSeveridad == null ? "" : filtroSeveridad);
                request.setAttribute("filtroIdSegmento", filtroIdSegmento);
                view = request.getRequestDispatcher("/network_operator/incidencias-visualizar.jsp");
                view.forward(request, response);
                break;
            }

            case "historial": {
                String filtroSeveridad = validarSeveridad(request.getParameter("severidad"));

                ArrayList<Incidencia> lista = incidenciaDao.listarIncidencias(true, filtroSeveridad, -1);
                cargarSegmentos(lista, segmentoDao);

                request.setAttribute("listaIncidencias", lista);
                request.setAttribute("filtroSeveridad", filtroSeveridad == null ? "" : filtroSeveridad);
                view = request.getRequestDispatcher("/network_operator/historial.jsp");
                view.forward(request, response);
                break;
            }

            case "formCrear":
                mostrarFormulario(request, response, segmentoDao, "", "", "", new ArrayList<>(), null);
                break;

            case "detalle": {
                int id = parseId(request.getParameter("id"));
                Incidencia incidencia = incidenciaDao.obtenerIncidencia(id);

                if (incidencia == null) {

                    response.sendRedirect(request.getContextPath() + "/IncidenciaServlet");
                } else {
                    incidencia.setSegmentos(segmentoDao.listarSegmentosDeIncidencia(id));

                    request.setAttribute("incidencia", incidencia);
                    request.setAttribute("siguienteEstado", siguienteEstado(incidencia.getEstado()));
                    request.setAttribute("listaObservaciones", new ObservacionDao().listarObservaciones(id));
                    request.setAttribute("listaServicios", new ServicioDao().listarServiciosAfectados(id));
                    view = request.getRequestDispatcher("/network_operator/incidencias-detalle.jsp");
                    view.forward(request, response);
                }
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/IncidenciaServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        IncidenciaDao incidenciaDao = new IncidenciaDao();
        SegmentoDao segmentoDao = new SegmentoDao();
        String servlet = request.getContextPath() + "/IncidenciaServlet";

        switch (action) {

            case "crear": {
                String titulo = valorOVacio(request.getParameter("titulo"));
                String descripcion = valorOVacio(request.getParameter("descripcion"));
                String severidad = valorOVacio(request.getParameter("severidad"));
                String boton = valorOVacio(request.getParameter("boton"));

                ArrayList<Integer> idsElegidos = new ArrayList<>();
                String[] ocultos = request.getParameterValues("segmentos");
                if (ocultos != null) {
                    for (String valor : ocultos) {
                        agregarSinRepetir(idsElegidos, parseId(valor));
                    }
                }

                int idQuitar = parseId(request.getParameter("quitar"));
                if (idQuitar > 0) {
                    idsElegidos.remove(Integer.valueOf(idQuitar));
                    mostrarFormulario(request, response, segmentoDao, titulo, descripcion, severidad, idsElegidos, null);
                    break;
                }

                agregarSinRepetir(idsElegidos, parseId(request.getParameter("segmentoNuevo")));

                if ("agregar".equals(boton)) {
                    mostrarFormulario(request, response, segmentoDao, titulo, descripcion, severidad, idsElegidos, null);
                    break;
                }

                if (titulo.trim().isEmpty() || descripcion.trim().isEmpty()
                        || validarSeveridad(severidad) == null || idsElegidos.isEmpty()) {
                    mostrarFormulario(request, response, segmentoDao, titulo, descripcion, severidad, idsElegidos,
                            "Completa el título, la severidad, la descripción y agrega al menos un segmento.");
                    break;
                }

                Usuario usuario = new Usuario();
                usuario.setIdUsuario(incidenciaDao.obtenerIdNetworkOperator());

                Incidencia incidencia = new Incidencia();
                incidencia.setTitulo(titulo.trim());
                incidencia.setDescripcion(descripcion.trim());
                incidencia.setSeveridad(severidad);
                incidencia.setUsuario(usuario);

                int idNuevo = incidenciaDao.crearIncidencia(incidencia);
                if (idNuevo == -1) {
                    mostrarFormulario(request, response, segmentoDao, titulo, descripcion, severidad, idsElegidos,
                            "No se pudo guardar la incidencia. Revisa la conexión con la base de datos.");
                    break;
                }

                for (int idSegmento : idsElegidos) {
                    incidenciaDao.asociarSegmento(idNuevo, idSegmento);
                }
                response.sendRedirect(servlet + "?action=detalle&id=" + idNuevo + "&ok=creada");
                break;
            }

            case "severidad": {
                int id = parseId(request.getParameter("idIncidencia"));
                String severidad = validarSeveridad(request.getParameter("severidad"));
                if (severidad != null) {
                    incidenciaDao.actualizarSeveridad(id, severidad);
                }
                response.sendRedirect(servlet + "?action=detalle&id=" + id);
                break;
            }

            case "avanzar": {
                int id = parseId(request.getParameter("idIncidencia"));
                String estadoActual = request.getParameter("estadoActual");
                boolean cambiado;

                if ("En reparacion".equals(estadoActual)) {
                    cambiado = incidenciaDao.registrarRestauracion(id);
                } else if ("Servicio restaurado".equals(estadoActual)) {
                    cambiado = incidenciaDao.cerrarIncidencia(id);
                } else {
                    String nuevo = siguienteEstado(estadoActual);
                    cambiado = nuevo != null && incidenciaDao.actualizarEstado(id, estadoActual, nuevo);
                }

                response.sendRedirect(servlet + "?action=detalle&id=" + id + (cambiado ? "" : "&error=estado"));
                break;
            }

            case "observar": {
                int id = parseId(request.getParameter("idIncidencia"));
                String mensaje = request.getParameter("mensaje");
                Incidencia incidencia = incidenciaDao.obtenerIncidencia(id);

                if (incidencia != null && !"Cerrada".equals(incidencia.getEstado())
                        && mensaje != null && !mensaje.trim().isEmpty()) {

                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(incidenciaDao.obtenerIdNetworkOperator());

                    Observacion observacion = new Observacion();
                    observacion.setIncidencia(incidencia);
                    observacion.setUsuario(usuario);
                    observacion.setMensaje(mensaje.trim());
                    new ObservacionDao().crearObservacion(observacion);
                }
                response.sendRedirect(servlet + "?action=detalle&id=" + id);
                break;
            }

            default:
                response.sendRedirect(servlet);
        }
    }

    private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response, SegmentoDao segmentoDao,
                                   String titulo, String descripcion, String severidad,
                                   ArrayList<Integer> idsElegidos, String error)
            throws ServletException, IOException {

        ArrayList<Segmento> elegidos = new ArrayList<>();
        ArrayList<Segmento> disponibles = new ArrayList<>();
        for (Segmento s : segmentoDao.listarSegmentos(null)) {
            if (idsElegidos.contains(s.getIdSegmento())) {
                elegidos.add(s);
            } else {
                disponibles.add(s);
            }
        }

        request.setAttribute("titulo", titulo);
        request.setAttribute("descripcion", descripcion);
        request.setAttribute("severidad", severidad);
        request.setAttribute("segmentosElegidos", elegidos);
        request.setAttribute("segmentosDisponibles", disponibles);
        request.setAttribute("listaServicios", new ServicioDao().listarServiciosPorSegmentos(idsElegidos));
        request.setAttribute("error", error);

        RequestDispatcher view = request.getRequestDispatcher("/network_operator/registrar_incidencia.jsp");
        view.forward(request, response);
    }

    private String siguienteEstado(String actual) {
        if (actual == null) {
            return null;
        }
        switch (actual) {
            case "Detectada":             return "En analisis";
            case "En analisis":           return "Reparacion programada";
            case "Reparacion programada": return "En reparacion";
            case "En reparacion":         return "Servicio restaurado";
            case "Servicio restaurado":   return "Cerrada";
            default:                      return null;
        }
    }

    private void cargarSegmentos(ArrayList<Incidencia> lista, SegmentoDao segmentoDao) {
        for (Incidencia inc : lista) {
            inc.setSegmentos(segmentoDao.listarSegmentosDeIncidencia(inc.getIdIncidencia()));
        }
    }

    private void agregarSinRepetir(ArrayList<Integer> lista, int id) {
        if (id > 0 && !lista.contains(id)) {
            lista.add(id);
        }
    }

    private String validarSeveridad(String valor) {
        for (String s : SEVERIDADES) {
            if (s.equals(valor)) {
                return valor;
            }
        }
        return null;
    }

    private String valorOVacio(String valor) {
        return valor == null ? "" : valor;
    }

    private int parseId(String valor) {
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
