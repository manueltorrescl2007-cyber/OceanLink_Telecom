package servlets.supervisor;

import beans.Usuario;
import beans.networkoperator.Incidencia;
import beans.networkoperator.Observacion;
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

@WebServlet(name = "IncidenciaServletSuper", value = "/IncidenciaServletSuper")
public class IncidenciaServletSuper extends HttpServlet {

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
                view = request.getRequestDispatcher("/supervisor/visualizar.jsp");
                view.forward(request, response);
                break;
            }

            case "historial": {
                String filtroSeveridad = validarSeveridad(request.getParameter("severidad"));

                ArrayList<Incidencia> lista = incidenciaDao.listarIncidencias(true, filtroSeveridad, -1);
                cargarSegmentos(lista, segmentoDao);

                request.setAttribute("listaIncidencias", lista);
                request.setAttribute("filtroSeveridad", filtroSeveridad == null ? "" : filtroSeveridad);
                view = request.getRequestDispatcher("/supervisor/historial_incidencias.jsp");
                view.forward(request, response);
                break;
            }

            case "detalle": {
                int id = parseId(request.getParameter("id"));
                Incidencia incidencia = incidenciaDao.obtenerIncidencia(id);

                if (incidencia == null) {

                    response.sendRedirect(request.getContextPath() + "/IncidenciaServletSuper");
                } else {
                    incidencia.setSegmentos(segmentoDao.listarSegmentosDeIncidencia(id));

                    request.setAttribute("incidencia", incidencia);
                    request.setAttribute("siguienteEstado", siguienteEstado(incidencia.getEstado()));
                    request.setAttribute("listaObservaciones", new ObservacionDao().listarObservaciones(id));
                    request.setAttribute("listaServicios", new ServicioDao().listarServiciosAfectados(id));
                    view = request.getRequestDispatcher("/supervisor/incidencias-detalle.jsp");
                    view.forward(request, response);
                }
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/IncidenciaServletSuper");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        IncidenciaDao incidenciaDao = new IncidenciaDao();
        SegmentoDao segmentoDao = new SegmentoDao();
        String servlet = request.getContextPath() + "/IncidenciaServletSuper";

        switch (action) {

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

    private String validarSeveridad(String valor) {
        for (String s : SEVERIDADES) {
            if (s.equals(valor)) {
                return valor;
            }
        }
        return null;
    }

    private int parseId(String valor) {
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}
