import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/order.dart';

class InvoicePdfService {
  static String _clean(String text) {
    return text
        .replaceAll('•', '-')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}]', unicode: true), '')
        .trim();
  }

  static Future<Uint8List> generateReceiptPdf(OrderModel order) async {
    final pdf = pw.Document(
      title: 'Bonchi_Receipt_${order.orderId}',
      author: 'Bonchi Cloud Kitchens',
    );

    final currencyFormatter = NumberFormat('#,##0', 'en_US');
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');
    final formattedDate = dateFormatter.format(order.orderTime);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Brand & Tax Registration
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BONCHI',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#059669'),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Bonchi Cloud Kitchens (Pvt) Ltd',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                      ),
                      pw.Text(
                        'No. 128, Galle Road, Kollupitiya, Colombo 03',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Tax ID: VAT-7729103-01 | Reg: PV 00294821',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Hotline: +94 11 234 5678 | help@bonchi.lk',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#ECFDF5'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          border: pw.Border.all(color: PdfColor.fromHex('#059669'), width: 1),
                        ),
                        child: pw.Text(
                          'OFFICIAL TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#059669'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Invoice #${order.orderId}',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Date: $formattedDate',
                        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Status: PAID (Confirmed)',
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669')),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 18),
              pw.Divider(thickness: 1.5, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // Customer & Kitchen Dispatch Details Grid
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED & DELIVERED TO:',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          _clean(order.customerName),
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Phone: ${_clean(order.customerPhone)}',
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Address: ${_clean(order.deliveryAddress)}',
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DISPATCH & RESTAURANT:',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          _clean(order.restaurantName),
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Rider: ${_clean(order.riderName)} (${_clean(order.riderVehicle)})',
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Payment Mode: ${_clean(order.paymentMethod)}',
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Delivery Window: ${_clean(order.deliveryTimeOption)}',
                          style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Itemized Food Order Table
              pw.Text(
                'ORDER ITEMS & SPECIFICATIONS',
                style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder(
                  bottom: const pw.BorderSide(color: PdfColors.grey300, width: 0.8),
                  horizontalInside: const pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text('Spice Level', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text('Rate (LKR)', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Text('Amount (LKR)', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...order.items.map((item) {
                    final unitPrice = item.foodItem.priceLkr;
                    final total = item.totalPriceLkr;
                    final spice = _clean(item.selectedSpiceLevel?.name ?? 'Regular');

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(_clean(item.foodItem.name), style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                              if (item.specialInstructions.isNotEmpty)
                                pw.Text('Note: ${_clean(item.specialInstructions)}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          child: pw.Text(spice, style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          child: pw.Text(currencyFormatter.format(unitPrice), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          child: pw.Text(currencyFormatter.format(total), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 16),

              // Financial Breakdown & Verification Code Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Verification Barcode & QR code
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'VERIFICATION & TRACKING',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          height: 40,
                          width: 170,
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.code128(),
                            data: order.orderId,
                            drawText: true,
                            textStyle: const pw.TextStyle(fontSize: 7.5),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Container(
                              height: 52,
                              width: 52,
                              child: pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: 'https://bonchi.lk/orders/${order.orderId}',
                              ),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Scan to verify digital authenticity', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                                pw.Text('Instant re-order & live kitchen logs', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                                pw.Text('Protected by Bonchi Cloud Security', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  // Totals Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F8FAFC'),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                      ),
                      child: pw.Column(
                        children: [
                          _buildPdfAmountRow('Subtotal', 'Rs. ${currencyFormatter.format(order.subtotalLkr)}'),
                          pw.SizedBox(height: 4),
                          _buildPdfAmountRow(
                            'Delivery Fee',
                            order.deliveryFeeLkr == 0 ? 'FREE' : 'Rs. ${currencyFormatter.format(order.deliveryFeeLkr)}',
                          ),
                          if (order.discountLkr > 0) ...[
                            pw.SizedBox(height: 4),
                            _buildPdfAmountRow(
                              'Discounts & Coins',
                              '- Rs. ${currencyFormatter.format(order.discountLkr)}',
                              textColor: PdfColor.fromHex('#059669'),
                            ),
                          ],
                          pw.Divider(thickness: 0.8, color: PdfColors.grey300),
                          pw.SizedBox(height: 2),
                          _buildPdfAmountRow(
                            'GRAND TOTAL',
                            'Rs. ${currencyFormatter.format(order.grandTotalLkr)}',
                            isBold: true,
                            fontSize: 12,
                            textColor: PdfColor.fromHex('#059669'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Official Rubber Stamp & Footer Notice
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Thank you for dining with Bonchi! Freshness & taste guaranteed.',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                      ),
                      pw.Text(
                        'This is a computer-generated tax invoice. No signature required.',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex('#059669'), width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'BONCHI AUTHENTICATED',
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669')),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfAmountRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 9.5,
    PdfColor? textColor,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isBold ? PdfColors.grey900 : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor ?? (isBold ? PdfColors.grey900 : PdfColors.grey800),
          ),
        ),
      ],
    );
  }
}
