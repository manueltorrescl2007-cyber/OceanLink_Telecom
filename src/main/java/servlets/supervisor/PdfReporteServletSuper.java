package servlets.supervisor;

import beans.supervisor.ReporteSupervisor;
import com.lowagie.text.Document;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import daos.supervisor.ReporteSupervisorDao;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.awt.Color;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(name = "PdfReporteServletSuper", value = "/PdfReporteServletSuper")
public class PdfReporteServletSuper extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    req.setCharacterEncoding("UTF-8");

    String tipo = texto(req.getParameter("tipo"));
    if (tipo.isEmpty()) tipo = "capacidad";
    String desde = texto(req.getParameter("desde"));
    String hasta = texto(req.getParameter("hasta"));
    String segmento = texto(req.getParameter("segmento"));
    if (segmento.isEmpty()) segmento = "Todos";
    String cliente = texto(req.getParameter("cliente"));
    if (cliente.isEmpty()) cliente = "Todos";
    String severidad = texto(req.getParameter("severidad"));
    if (severidad.isEmpty()) severidad = "Todas";
    String estado = texto(req.getParameter("estado"));
    if (estado.isEmpty()) estado = "Todos";
    boolean descargar = "si".equals(req.getParameter("descargar"));

    ReporteSupervisorDao dao = new ReporteSupervisorDao();
    String[] encabezados = dao.obtenerEncabezados(tipo);
    List<ReporteSupervisor> lista = dao.generarReporte(tipo, desde, hasta, segmento, cliente, severidad, estado);

    String fechaActual = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    String nombreArchivo = "Reporte_" + tipo + "_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm")) + ".pdf";

    resp.setContentType("application/pdf");
    resp.setHeader("Content-Disposition", (descargar ? "attachment" : "inline") + "; filename=\"" + nombreArchivo + "\"");

    try {
      Document doc = new Document(PageSize.A4.rotate());
      PdfWriter.getInstance(doc, resp.getOutputStream());
      doc.open();

      Font fontTitulo = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16, new Color(11, 61, 92));
      Font fontSub = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.DARK_GRAY);
      Font fontHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.WHITE);
      Font fontCelda = FontFactory.getFont(FontFactory.HELVETICA, 9, Color.BLACK);

      doc.add(new Paragraph("OceanLink Telecom - Reporte de Supervisión", fontTitulo));
      doc.add(new Paragraph("Tipo de reporte: " + obtenerNombreTitulo(tipo), fontSub));
      doc.add(new Paragraph(construirLineaFiltros(tipo, desde, hasta, segmento, cliente, severidad, estado), fontSub));
      doc.add(new Paragraph("Fecha de emisión: " + fechaActual + " | Total registros: " + lista.size(), fontSub));
      doc.add(new Paragraph(" "));

      PdfPTable tabla = new PdfPTable(6);
      tabla.setWidthPercentage(100);

      for (String h : encabezados) {
        PdfPCell cell = new PdfPCell(new Phrase(h, fontHeader));
        cell.setBackgroundColor(new Color(11, 61, 92));
        cell.setPadding(6);
        tabla.addCell(cell);
      }

      if (lista.isEmpty()) {
        PdfPCell vacia = new PdfPCell(new Phrase("No se encontraron registros para los filtros seleccionados.", fontCelda));
        vacia.setColspan(6);
        vacia.setPadding(8);
        tabla.addCell(vacia);
      } else {
        for (ReporteSupervisor r : lista) {
          tabla.addCell(crearCelda(r.getCol1(), fontCelda));
          tabla.addCell(crearCelda(r.getCol2(), fontCelda));
          tabla.addCell(crearCelda(r.getCol3(), fontCelda));
          tabla.addCell(crearCelda(r.getCol4(), fontCelda));
          tabla.addCell(crearCelda(r.getCol5(), fontCelda));
          tabla.addCell(crearCelda(r.getCol6(), fontCelda));
        }
      }

      doc.add(tabla);
      doc.close();
    } catch (Exception e) {
      throw new RuntimeException("Error al generar el PDF del reporte", e);
    }
  }

  private String construirLineaFiltros(String tipo, String desde, String hasta,
                                       String segmento, String cliente, String severidad, String estado) {
    if ("consolidado".equals(tipo)) {
      return "Alcance: Resumen general consolidado de toda la red OceanLink";
    }
    StringBuilder sb = new StringBuilder("Filtros aplicados -> ");
    if (!"capacidad".equals(tipo)) {
      sb.append("Periodo: ").append(desde.isEmpty() ? "Inicio" : desde)
        .append(" a ").append(hasta.isEmpty() ? "Actualidad" : hasta).append(" | ");
    }
    if ("clientes_servicios".equals(tipo)) {
      sb.append("Cliente: ").append(cliente).append(" | ");
    } else {
      sb.append("Segmento: ").append(segmento).append(" | ");
    }
    if ("incidencias".equals(tipo) || "mantenimientos".equals(tipo)) {
      sb.append("Severidad/Prioridad: ").append(severidad).append(" | ");
    }
    sb.append("Estado: ").append(estado);
    return sb.toString();
  }

  private PdfPCell crearCelda(String texto, Font fuente) {
    PdfPCell cell = new PdfPCell(new Phrase(texto == null ? "-" : texto, fuente));
    cell.setPadding(5);
    return cell;
  }

  private String obtenerNombreTitulo(String tipo) {
    switch (tipo) {
      case "incidencias": return "Incidencias de Red";
      case "mantenimientos": return "Mantenimientos Programados y Ejecutados";
      case "clientes_servicios": return "Clientes, Solicitudes y Servicios";
      case "consolidado": return "Resumen Ejecutivo Consolidado";
      default: return "Estado y Capacidad de Segmentos";
    }
  }

  private String texto(String valor) {
    return valor == null ? "" : valor.trim();
  }
}
