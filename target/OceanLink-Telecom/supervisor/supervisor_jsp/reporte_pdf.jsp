<%@ page contentType="application/pdf"
         pageEncoding="UTF-8"
         trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.apache.pdfbox.pdmodel.PDDocument" %>
<%@ page import="org.apache.pdfbox.pdmodel.PDPage" %>
<%@ page import="org.apache.pdfbox.pdmodel.PDPageContentStream" %>
<%@ page import="org.apache.pdfbox.pdmodel.common.PDRectangle" %>
<%@ page import="org.apache.pdfbox.pdmodel.font.PDType1Font" %>
<%@ page import="org.apache.pdfbox.pdmodel.font.Standard14Fonts" %>
<%@ page import="java.awt.Color" %>

<%
    String idReporte = request.getParameter("id");

    ArrayList<Map<String, String>> reportes =
            (ArrayList<Map<String, String>>)
                    session.getAttribute("reportesSupervisor");

    Map<String, String> reporteSeleccionado = null;

    if (reportes != null && idReporte != null) {

        for (Map<String, String> reporte : reportes) {

            if (idReporte.equals(reporte.get("id"))) {
                reporteSeleccionado = reporte;
                break;
            }
        }
    }

    if (reporteSeleccionado == null) {
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(
                "No se encontró el reporte solicitado."
        );

        return;
    }

    String nombreArchivo =
            reporteSeleccionado.get("nombre");

    boolean descargar =
            "si".equals(request.getParameter("descargar"));

    response.reset();
    response.setContentType("application/pdf");

    response.setHeader(
            "Content-Disposition",
            (descargar ? "attachment" : "inline")
                    + "; filename=\"" + nombreArchivo + "\""
    );

    PDDocument documento = new PDDocument();

    try {

        PDPage pagina = new PDPage(PDRectangle.A4);
        documento.addPage(pagina);

        PDType1Font fuenteNormal =
                new PDType1Font(
                        Standard14Fonts.FontName.HELVETICA
                );

        PDType1Font fuenteNegrita =
                new PDType1Font(
                        Standard14Fonts.FontName.HELVETICA_BOLD
                );

        PDPageContentStream contenido =
                new PDPageContentStream(
                        documento,
                        pagina
                );

        float anchoPagina =
                pagina.getMediaBox().getWidth();

        contenido.setNonStrokingColor(
                new Color(11, 61, 92)
        );

        contenido.addRect(
                0,
                792,
                anchoPagina,
                50
        );

        contenido.fill();

        contenido.beginText();
        contenido.setNonStrokingColor(Color.WHITE);
        contenido.setFont(fuenteNegrita, 20);
        contenido.newLineAtOffset(45, 810);
        contenido.showText("OceanLink");
        contenido.endText();

        contenido.beginText();
        contenido.setNonStrokingColor(
                new Color(11, 61, 92)
        );
        contenido.setFont(fuenteNegrita, 18);
        contenido.newLineAtOffset(45, 755);
        contenido.showText(
                reporteSeleccionado.get("tipo")
        );
        contenido.endText();

        contenido.setStrokingColor(
                new Color(28, 140, 156)
        );

        contenido.setLineWidth(1);
        contenido.moveTo(45, 742);
        contenido.lineTo(550, 742);
        contenido.stroke();

        String[][] datos = {
                {
                        "Periodo",
                        reporteSeleccionado.get("desde")
                                + " hasta "
                                + reporteSeleccionado.get("hasta")
                },
                {
                        "Segmento",
                        reporteSeleccionado.get("segmento")
                },
                {
                        "Severidad",
                        reporteSeleccionado.get("severidad")
                },
                {
                        "Fecha de generaci\u00F3n",
                        reporteSeleccionado.get("fecha")
                }
        };

        float posicionY = 710;

        for (String[] dato : datos) {

            contenido.beginText();
            contenido.setNonStrokingColor(
                    new Color(100, 116, 139)
            );
            contenido.setFont(fuenteNormal, 11);
            contenido.newLineAtOffset(45, posicionY);
            contenido.showText(dato[0] + ":");
            contenido.endText();

            contenido.beginText();
            contenido.setNonStrokingColor(
                    new Color(30, 41, 59)
            );
            contenido.setFont(fuenteNegrita, 11);
            contenido.newLineAtOffset(170, posicionY);
            contenido.showText(dato[1]);
            contenido.endText();

            posicionY -= 25;
        }

        contenido.setNonStrokingColor(
                new Color(237, 243, 246)
        );

        contenido.addRect(
                45,
                550,
                505,
                70
        );

        contenido.fill();

        contenido.beginText();
        contenido.setNonStrokingColor(
                new Color(11, 61, 92)
        );
        contenido.setFont(fuenteNegrita, 13);
        contenido.newLineAtOffset(60, 595);
        contenido.showText("Resumen");
        contenido.endText();

        contenido.beginText();
        contenido.setNonStrokingColor(
                new Color(30, 41, 59)
        );
        contenido.setFont(fuenteNormal, 10);
        contenido.newLineAtOffset(60, 575);
        contenido.showText(
                "Reporte generado de acuerdo con los filtros"
        );
        contenido.newLineAtOffset(0, -15);
        contenido.showText(
                "seleccionados por el supervisor de OceanLink."
        );
        contenido.endText();

        contenido.beginText();
        contenido.setNonStrokingColor(
                new Color(11, 61, 92)
        );
        contenido.setFont(fuenteNegrita, 13);
        contenido.newLineAtOffset(45, 510);
        contenido.showText("Resultados registrados");
        contenido.endText();

        String[][] resultados = {
                {"Segmentos disponibles", "4"},
                {"Segmentos limitados", "5"},
                {"Segmentos insuficientes", "2"},
                {"Total evaluado", "11"}
        };

        posicionY = 480;

        for (String[] resultado : resultados) {

            contenido.beginText();
            contenido.setNonStrokingColor(
                    new Color(30, 41, 59)
            );
            contenido.setFont(fuenteNormal, 11);
            contenido.newLineAtOffset(55, posicionY);
            contenido.showText(resultado[0]);
            contenido.endText();

            contenido.beginText();
            contenido.setFont(fuenteNegrita, 11);
            contenido.newLineAtOffset(510, posicionY);
            contenido.showText(resultado[1]);
            contenido.endText();

            posicionY -= 25;
        }

        contenido.setStrokingColor(
                new Color(217, 225, 232)
        );

        contenido.moveTo(45, 65);
        contenido.lineTo(550, 65);
        contenido.stroke();

        contenido.beginText();
        contenido.setNonStrokingColor(
                new Color(100, 116, 139)
        );
        contenido.setFont(fuenteNormal, 8);
        contenido.newLineAtOffset(45, 48);
        contenido.showText(
                "Documento generado automáticamente por OceanLink."
        );
        contenido.endText();

        contenido.close();

        documento.save(response.getOutputStream());

    } finally {
        documento.close();
    }


%>
