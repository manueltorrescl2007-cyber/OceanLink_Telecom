package servlets.supervisor;

import beans.capacityplanner.Segmento;
import daos.BaseDao;
import daos.capacityplanner.SegmentoDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "SegmentoServletSuper", value = "/SegmentoServletSuper")
public class SegmentoServletSuper extends HttpServlet {

  private static final int REGISTROS_POR_PAGINA = 10;
  private static final DateTimeFormatter FORMATO_FECHA =
    DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.forLanguageTag("es-PE"));

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response)
    throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String estadoFiltro = texto(request.getParameter("estado"));
    String nivelFiltro = texto(request.getParameter("nivel"));
    int idDetalle = parseId(request.getParameter("detalle"));

    SegmentoDao segmentoDao = new SegmentoDao();

    try {
      ArrayList<Segmento> todos = segmentoDao.listarSegmentos();
      ArrayList<Segmento> filtrados = new ArrayList<>();

      for (Segmento s : todos) {
        if (!estadoFiltro.isEmpty() && !estadoFiltro.equals(s.getEstado())) {
          continue;
        }
        if (!nivelFiltro.isEmpty() && !nivelFiltro.equals(obtenerClaveNivel(s))) {
          continue;
        }
        filtrados.add(s);
      }

      int totalRegistros = filtrados.size();
      int totalPaginas = (int) Math.ceil((double) totalRegistros / REGISTROS_POR_PAGINA);
      if (totalPaginas == 0) {
        totalPaginas = 1;
      }

      int paginaActual = parsePagina(request.getParameter("pagina"), totalPaginas);
      int inicio = (paginaActual - 1) * REGISTROS_POR_PAGINA;
      int fin = Math.min(inicio + REGISTROS_POR_PAGINA, totalRegistros);

      List<Segmento> listaPaginada = new ArrayList<>();
      if (inicio < totalRegistros) {
        listaPaginada = filtrados.subList(inicio, fin);
      }

      int registroInicio = totalRegistros == 0 ? 0 : inicio + 1;
      int registroFin = fin;

      if (idDetalle > 0) {
        Segmento detalle = segmentoDao.obtenerSegmento(idDetalle);
        if (detalle != null) {
          request.setAttribute("segmentoDetalle", detalle);
          request.setAttribute("historialSegmento", consultarHistorialSegmento(idDetalle));
        }
      }

      request.setAttribute("listaSegmentos", listaPaginada);
      request.setAttribute("estadoSeleccionado", estadoFiltro);
      request.setAttribute("nivelSeleccionado", nivelFiltro);

      request.setAttribute("paginaActual", paginaActual);
      request.setAttribute("totalPaginas", totalPaginas);
      request.setAttribute("totalRegistros", totalRegistros);
      request.setAttribute("registroInicio", registroInicio);
      request.setAttribute("registroFin", registroFin);

      request.getRequestDispatcher("/supervisor/segmentos.jsp")
        .forward(request, response);

    } catch (SQLException e) {
      throw new ServletException("No se pudieron cargar los segmentos.", e);
    }
  }

  private String obtenerClaveNivel(Segmento s) {
    if (s.getCapacidadTotal() <= 0) {
      return "normal";
    }
    long usada = s.getCapacidadOcupada() + s.getCapacidadReservada();
    double pct = (usada * 100.0) / s.getCapacidadTotal();
    if (pct > 95.0) {
      return "critica";
    } else if (pct >= 80.0) {
      return "alta";
    }
    return "normal";
  }

  private List<EventoSegmento> consultarHistorialSegmento(int idSegmento) {
    List<EventoSegmento> eventos = new ArrayList<>();
    HistorialSegmentoHelper helper = new HistorialSegmentoHelper();
    helper.cargarIncidencias(idSegmento, eventos);
    helper.cargarMantenimientos(idSegmento, eventos);

    eventos.sort(Comparator.comparing(
      (EventoSegmento e) -> e.fechaOrden,
      Comparator.nullsLast(Comparator.reverseOrder())
    ));
    return eventos;
  }

  private static class EventoSegmento {
    LocalDateTime fechaOrden;
    String[] datos; // [0]=tipo, [1]=codigo, [2]=descripcion, [3]=fecha, [4]=estado, [5]=urlDetalle
  }

  private static class HistorialSegmentoHelper extends BaseDao {

    void cargarIncidencias(int idSegmento, List<EventoSegmento> destino) {
      String sql =
        "SELECT i.id_incidencia, i.codigo, i.titulo, i.estado, i.severidad, "
          + "       COALESCE(i.fecha_restauracion, i.fecha_registro) AS fecha_evento "
          + "FROM incidencias i "
          + "INNER JOIN segmentos_has_incidencias si ON i.id_incidencia = si.id_incidencia "
          + "WHERE si.id_segmento = ?";

      try (Connection conn = getConnection();
           PreparedStatement pstmt = conn.prepareStatement(sql)) {

        pstmt.setInt(1, idSegmento);

        try (ResultSet rs = pstmt.executeQuery()) {
          while (rs.next()) {
            int idInc = rs.getInt("id_incidencia");
            Timestamp ts = rs.getTimestamp("fecha_evento");
            LocalDateTime ldt = ts != null ? ts.toLocalDateTime() : null;

            EventoSegmento ev = new EventoSegmento();
            ev.fechaOrden = ldt;
            ev.datos = new String[]{
              "Incidencia",
              rs.getString("codigo"),
              rs.getString("titulo"),
              ldt != null ? ldt.format(FORMATO_FECHA) : "—",
              rs.getString("estado") + " (" + rs.getString("severidad") + ")",
              "/IncidenciaServletSuper?action=detalle&id=" + idInc
            };
            destino.add(ev);
          }
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
    }

    void cargarMantenimientos(int idSegmento, List<EventoSegmento> destino) {
      String sql =
        "SELECT m.id_mantenimiento, m.tipo, m.estado, m.prioridad, "
          + "       COALESCE(m.fecha_fin, m.fecha_inicio) AS fecha_evento "
          + "FROM mantenimientos m "
          + "WHERE m.id_segmento = ?";

      try (Connection conn = getConnection();
           PreparedStatement pstmt = conn.prepareStatement(sql)) {

        pstmt.setInt(1, idSegmento);

        try (ResultSet rs = pstmt.executeQuery()) {
          while (rs.next()) {
            int idMnt = rs.getInt("id_mantenimiento");
            Timestamp ts = rs.getTimestamp("fecha_evento");
            LocalDateTime ldt = ts != null ? ts.toLocalDateTime() : null;

            EventoSegmento ev = new EventoSegmento();
            ev.fechaOrden = ldt;
            ev.datos = new String[]{
              "Mantenimiento",
              String.format("MNT-%03d", idMnt),
              "Mantenimiento " + rs.getString("tipo"),
              ldt != null ? ldt.format(FORMATO_FECHA) : "—",
              rs.getString("estado") + " (" + rs.getString("prioridad") + ")",
              "/MantenimientoServletSuper?accion=estado&idMantenimiento=" + idMnt
            };
            destino.add(ev);
          }
        }
      } catch (SQLException e) {
        e.printStackTrace();
      }
    }
  }

  @Override
  protected void doPost(HttpServletRequest request,
                        HttpServletResponse response)
    throws IOException {
    response.sendRedirect(request.getContextPath() + "/SegmentoServletSuper");
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }

  private int parseId(String valor) {
    try {
      return Integer.parseInt(valor);
    } catch (NumberFormatException e) {
      return -1;
    }
  }

  private int parsePagina(String valor, int maxPaginas) {
    try {
      int p = Integer.parseInt(valor);
      if (p < 1) return 1;
      if (p > maxPaginas) return maxPaginas;
      return p;
    } catch (NumberFormatException e) {
      return 1;
    }
  }
}
