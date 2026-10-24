package servlets.networkoperator;

import beans.networkoperator.Segmento;
import beans.networkoperator.UtilizacionDiaria;
import daos.networkoperator.SegmentoDao;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        SegmentoDao segmentoDao = new SegmentoDao();
        RequestDispatcher view;

        switch (action) {

            case "lista":

                String filtroEstado = request.getParameter("estado");
                if (!esValido(filtroEstado, ESTADOS)) {
                    filtroEstado = null;
                }

                ArrayList<Segmento> listaSegmentos = segmentoDao.listarSegmentos(filtroEstado);

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

                request.setAttribute("listaSegmentos", listaSegmentos);
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

            default:
                response.sendRedirect(request.getContextPath() + "/EstadoRedServlet");
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
