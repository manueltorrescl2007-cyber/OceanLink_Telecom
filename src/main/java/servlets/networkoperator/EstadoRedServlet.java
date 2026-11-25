package servlets.networkoperator;

import beans.networkoperator.Incidencia;
import beans.networkoperator.Segmento;
import beans.networkoperator.UtilizacionDiaria;
import daos.manteinance.MantenimientoDao;
import daos.networkoperator.IncidenciaDao;
import daos.networkoperator.SegmentoDao;
import daos.networkoperator.ServicioDao;
import daos.networkoperator.UtilizacionDao;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;

@WebServlet(name = "EstadoRedServlet", value = "/EstadoRedServlet")
public class EstadoRedServlet extends HttpServlet {

    private static final String[] ESTADOS = {"Operativo", "Degradado", "En mantenimiento", "Fuera de servicio"};

    // Cantidad de segmentos que se muestran en cada página de la tabla
    private static final int SEGMENTOS_POR_PAGINA = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        // Antes de mostrar, se actualizan los estados según los mantenimientos (por si cambió la fecha)
        new MantenimientoDao().actualizarEstadosAutomaticamente();

        SegmentoDao segmentoDao = new SegmentoDao();
        RequestDispatcher view;

        switch (action) {

            case "lista":

                String filtroEstado = request.getParameter("estado");
                if (!esValido(filtroEstado, ESTADOS)) {
                    filtroEstado = null;
                }

                ArrayList<Segmento> listaSegmentos = segmentoDao.listarSegmentos(filtroEstado);

                // Paginación: de toda la lista solo se envían los 10 segmentos de la página pedida
                int totalFiltrados = listaSegmentos.size();
                int totalPaginas = Math.max(1, (int) Math.ceil((double) totalFiltrados / SEGMENTOS_POR_PAGINA));

                int pagina = parseId(request.getParameter("pagina"));
                if (pagina < 1) {
                    pagina = 1;              // sin número o número inválido: primera página
                }
                if (pagina > totalPaginas) {
                    pagina = totalPaginas;   // número muy grande: última página
                }

                int desde = (pagina - 1) * SEGMENTOS_POR_PAGINA;
                int hasta = Math.min(desde + SEGMENTOS_POR_PAGINA, totalFiltrados);
                ArrayList<Segmento> segmentosPagina = new ArrayList<>(listaSegmentos.subList(desde, hasta));

                ArrayList<Segmento> todaLaRed = segmentoDao.listarSegmentos(null);
                int total = 0, ocupada = 0, reservada = 0;
                int normal = 0, alta = 0, critica = 0;
                for (Segmento s : todaLaRed) {
                    total += s.getCapacidadTotal();
                    ocupada += s.getCapacidadOcupada();
                    reservada += s.getCapacidadReservada();

                    switch (s.getNivelUso()) {
                        case "critica": critica++; break;
                        case "alta":    alta++;    break;
                        default:        normal++;
                    }
                }

                UtilizacionDao utilizacionDao = new UtilizacionDao();
                LocalDate hoy = LocalDate.now();
                utilizacionDao.guardarFoto(hoy.toString(), total, ocupada, reservada);

                UtilizacionDiaria fotoHoy = new UtilizacionDiaria();
                fotoHoy.setFecha(hoy.toString());
                fotoHoy.setCapacidadTotal(total);
                fotoHoy.setCapacidadOcupada(ocupada);
                fotoHoy.setCapacidadReservada(reservada);

                LocalDate lunes = hoy.with(DayOfWeek.MONDAY);
                LocalDate domingo = lunes.plusDays(6);
                ArrayList<UtilizacionDiaria> fotos = utilizacionDao.listarEntreFechas(lunes.toString(), domingo.toString());

                UtilizacionDiaria[] semana = new UtilizacionDiaria[7];
                String[] fechasSemana = new String[7];
                for (int i = 0; i < 7; i++) {
                    LocalDate dia = lunes.plusDays(i);
                    fechasSemana[i] = String.format("%02d/%02d", dia.getDayOfMonth(), dia.getMonthValue());
                    for (UtilizacionDiaria foto : fotos) {
                        if (foto.getFecha().equals(dia.toString())) {
                            semana[i] = foto;
                        }
                    }
                }

                request.setAttribute("listaSegmentos", segmentosPagina);
                request.setAttribute("totalFiltrados", totalFiltrados);
                request.setAttribute("paginaActual", pagina);
                request.setAttribute("totalPaginas", totalPaginas);
                request.setAttribute("primeroPagina", totalFiltrados == 0 ? 0 : desde + 1);
                request.setAttribute("ultimoPagina", hasta);
                request.setAttribute("cantSegmentos", todaLaRed.size());
                request.setAttribute("filtroEstado", filtroEstado == null ? "" : filtroEstado);
                request.setAttribute("fotoHoy", fotoHoy);
                request.setAttribute("semana", semana);
                request.setAttribute("fechasSemana", fechasSemana);
                request.setAttribute("indiceHoy", hoy.getDayOfWeek().getValue() - 1);
                request.setAttribute("cantNormal", normal);
                request.setAttribute("cantAlta", alta);
                request.setAttribute("cantCritica", critica);

                view = request.getRequestDispatcher("/network_operator/estado_red.jsp");
                view.forward(request, response);
                break;

            case "detalle": {
                int idSegmento = parseId(request.getParameter("id"));
                Segmento segmento = segmentoDao.obtenerSegmento(idSegmento);

                if (segmento == null) {
                    response.sendRedirect(request.getContextPath() + "/EstadoRedServlet?error=noexiste");
                    break;
                }

                ArrayList<Integer> ids = new ArrayList<>();
                ids.add(idSegmento);

                ArrayList<Incidencia> incidencias = new IncidenciaDao().listarIncidencias(false, null, idSegmento);
                for (Incidencia inc : incidencias) {
                    inc.setSegmentos(segmentoDao.listarSegmentosDeIncidencia(inc.getIdIncidencia()));
                }

                request.setAttribute("segmento", segmento);
                request.setAttribute("listaIncidencias", incidencias);
                request.setAttribute("listaServicios", new ServicioDao().listarServiciosPorSegmentos(ids));

                view = request.getRequestDispatcher("/network_operator/segmento-detalle.jsp");
                view.forward(request, response);
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/EstadoRedServlet");
        }
    }

    private int parseId(String valor) {
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private boolean esValido(String valor, String[] permitidos) {
        if (valor == null) {
            return false;
        }
        for (String p : permitidos) {
            if (p.equals(valor)) {
                return true;
            }
        }
        return false;
    }
}
