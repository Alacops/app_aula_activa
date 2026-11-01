import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/curso.dart';
import '../../models/estudiante_ranking.dart';
import '../../models/sesion.dart';

class ExcelExportService {
  /// Genera y comparte un archivo Excel (.xlsx) estructurado con la plantilla oficial UNSAAC
  static Future<String> exportarRankingExcel({
    required Curso curso,
    required Sesion sesion,
    required List<EstudianteRanking> ranking,
    bool esSesionDelDia = true,
  }) async {
    final excel = Excel.createExcel();
    final nombreHoja = esSesionDelDia ? 'Sesion_${sesion.fecha}' : 'Ranking_Acumulado';
    
    // Configurar o renombrar la hoja activa
    final Sheet sheet = excel[nombreHoja];
    excel.setDefaultSheet(nombreHoja);
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Estilos de Celdas
    final estiloTitulo = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#7A1F2B'),
    );

    final estiloSubtitulo = CellStyle(
      bold: false,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#1E293B'),
    );

    final estiloCabeceraTabla = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#7A1F2B'),
    );

    // 1. Título y Metadatos Institucionales
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('UNIVERSIDAD NACIONAL DE SAN ANTONIO ABAD DEL CUSCO')
      ..cellStyle = estiloTitulo;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('FACULTAD DE INGENIERÍA ELÉCTRICA, ELECTRÓNICA, INFORMÁTICA Y MECÁNICA')
      ..cellStyle = estiloSubtitulo;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
      ..value = TextCellValue('Asignatura: ${curso.nombre} (${curso.codigo}) — Semestre: ${curso.semestre}')
      ..cellStyle = estiloSubtitulo;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
      ..value = TextCellValue('Docente: ${curso.docente} | Fecha: ${sesion.fecha} | Tema: ${sesion.tema}')
      ..cellStyle = estiloSubtitulo;

    // Fila en blanco
    // 2. Encabezados de Columnas (Fila 5)
    final encabezados = [
      'N° Orden',
      'Código UNSAAC',
      'Apellidos y Nombres',
      esSesionDelDia ? 'Puntos Sesión' : 'Puntos Totales',
      esSesionDelDia ? 'Nota Sesión (0-20)' : 'Nota Semestre (0-20)',
      'Rendimiento',
    ];

    for (int col = 0; col < encabezados.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 5));
      cell.value = TextCellValue(encabezados[col]);
      cell.cellStyle = estiloCabeceraTabla;
    }

    // 3. Filas de Datos de Estudiantes
    int fila = 6;
    for (final item in ranking) {
      final puntos = esSesionDelDia ? item.puntosSesion : item.puntosTotales;
      final nota = esSesionDelDia ? item.notaSesion : item.notaTotal;
      final rendimiento = nota >= 18.0
          ? 'Sobresaliente'
          : nota >= 14.0
              ? 'Aprobado'
              : nota >= 10.5
                  ? 'Regular'
                  : 'Por Mejorar';

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: fila)).value =
          IntCellValue(item.estudiante.numeroOrden);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: fila)).value =
          TextCellValue(item.estudiante.codigoUnsaac);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: fila)).value =
          TextCellValue(item.estudiante.nombreCompleto);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: fila)).value =
          IntCellValue(puntos);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: fila)).value =
          DoubleCellValue(double.parse(nota.toStringAsFixed(1)));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: fila)).value =
          TextCellValue(rendimiento);

      fila++;
    }

    // 4. Guardar archivo en disco
    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('No se pudo codificar el archivo Excel');
    }

    final tempDir = await getApplicationDocumentsDirectory();
    final fechaSanitizada = sesion.fecha.replaceAll('/', '-');
    final archivoNombre = 'AulaActiva_${curso.codigo}_$fechaSanitizada.xlsx';
    final archivoPath = '${tempDir.path}/$archivoNombre';

    final file = File(archivoPath);
    await file.writeAsBytes(bytes, flush: true);

    // 5. Invocar diálogo del sistema para compartir/guardar
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(archivoPath)],
      subject: 'Reporte de Participaciones - ${curso.nombre}',
      text: 'Planilla de calificaciones generada por AulaActiva UNSAAC.',
    );

    return archivoPath;
  }
}
