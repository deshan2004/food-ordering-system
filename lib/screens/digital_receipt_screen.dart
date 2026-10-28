import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/order.dart';
import '../services/invoice_pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_box.dart';

class DigitalReceiptScreen extends StatefulWidget {
  final OrderModel order;

  const DigitalReceiptScreen({super.key, required this.order});

  @override
  State<DigitalReceiptScreen> createState() => _DigitalReceiptScreenState();
}

class _DigitalReceiptScreenState extends State<DigitalReceiptScreen> {
  bool _isGeneratingPdf = false;

  String _formatLkr(double val) {
    return 'LKR ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Future<void> _handleDownloadPdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfBytes = await InvoicePdfService.generateReceiptPdf(widget.order);

      // Save PDF file directly into device storage
      final appDocDir = await getApplicationDocumentsDirectory();
      final cleanOrderId = widget.order.orderId.replaceAll('#', '').replaceAll(' ', '_');
      final fileName = 'Bonchi_Receipt_$cleanOrderId.pdf';
      final savedFile = File('${appDocDir.path}/$fileName');
      await savedFile.writeAsBytes(pdfBytes, flush: true);

      String displayPath = savedFile.path;
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final dlFile = File('${downloadsDir.path}/$fileName');
          await dlFile.writeAsBytes(pdfBytes, flush: true);
          displayPath = dlFile.path;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });

        _showPdfDownloadSuccessDialog(pdfBytes.lengthInBytes, displayPath, fileName);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  void _showPdfDownloadSuccessDialog(int byteSize, String filePath, String fileName) {
    final kbSize = (byteSize / 1024).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryGreen, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Receipt Downloaded! 📄',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Official Tax Invoice for Order #${widget.order.orderId} is ready.',
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('File Name:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text(fileName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('File Size:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('$kbSize KB', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Format:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('Standard A4 Tax Invoice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Saved Storage Path:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SelectableText(
                      filePath,
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File storage path copied to clipboard! 📋'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Path'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PDF invoice downloaded: $fileName 📥',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareReceiptSummary() {
    final summary = '''
🧾 *BONCHI OFFICIAL TAX RECEIPT*
Order ID: #${widget.order.orderId}
Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(widget.order.orderTime)}
Customer: ${widget.order.customerName}
Restaurant: ${widget.order.restaurantName}

Items:
${widget.order.items.map((i) => '• ${i.quantity}x ${i.foodItem.name} (${i.selectedSpiceLevel?.name ?? "Regular"}) - LKR ${i.totalPriceLkr.toInt()}').join('\n')}

Subtotal: ${_formatLkr(widget.order.subtotalLkr)}
Delivery Fee: ${_formatLkr(widget.order.deliveryFeeLkr)}
Discount: -${_formatLkr(widget.order.discountLkr)}
Total Paid: ${_formatLkr(widget.order.grandTotalLkr)}
Payment Method: ${widget.order.paymentMethod}
Status: PAID ✅

Thank you for ordering with Bonchi Cloud Kitchens! 🛵
Verify: https://bonchi.lk/orders/${widget.order.orderId}
''';

    Clipboard.setData(ClipboardData(text: summary));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Receipt text summary copied to clipboard! Ready to share on WhatsApp 📲',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Digital Tax Invoice 📄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareReceiptSummary,
            tooltip: 'Share Receipt',
          ),
        ],
      ),
      body: GlassAmbientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Visual Authentic Paper Receipt
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Receipt Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/bonchi_logo.png',
                              width: 38,
                              height: 38,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 28),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BONCHI CLOUD KITCHENS',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryGreen),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Official Electronic Tax Invoice & Receipt',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Tax ID: VAT-7729103-01 • Reg: PV 00294821',
                                  style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PAID',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Receipt Body Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meta Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('INVOICE NO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                                  Text('#${order.orderId}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textPrimary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('ORDER DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                                  Text(dateFormatter.format(order.orderTime), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),

                          // Customer & Restaurant Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('DELIVER TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                    Text(order.deliveryAddress, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    Text('Ph: ${order.customerPhone}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('KITCHEN DISPATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                    Text('Rider: ${order.riderName}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    Text('Mode: ${order.paymentMethod}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Itemized table header
                          const Row(
                            children: [
                              Expanded(flex: 5, child: Text('ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted))),
                              Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted))),
                              Expanded(flex: 3, child: Text('AMOUNT', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted))),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Items
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.foodItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(
                                          'Spice: ${item.selectedSpiceLevel?.name ?? "Regular"}${item.specialInstructions.isNotEmpty ? " • ${item.specialInstructions}" : ""}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _formatLkr(item.totalPriceLkr),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 20),

                          // Financial breakdown
                          _buildReceiptPriceRow('Subtotal', _formatLkr(order.subtotalLkr)),
                          const SizedBox(height: 6),
                          _buildReceiptPriceRow(
                            'Delivery Fee',
                            order.deliveryFeeLkr == 0 ? 'FREE' : _formatLkr(order.deliveryFeeLkr),
                          ),
                          if (order.discountLkr > 0) ...[
                            const SizedBox(height: 6),
                            _buildReceiptPriceRow('Discount & Coins', '- ${_formatLkr(order.discountLkr)}', isDiscount: true),
                          ],
                          const Divider(height: 20),
                          _buildReceiptPriceRow('Grand Total', _formatLkr(order.grandTotalLkr), isTotal: true),

                          const SizedBox(height: 20),

                          // Barcode Graphic Block
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('SECURITY BARCODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                                      const SizedBox(height: 4),
                                      Text(
                                        '||| | | |||| || ||| ||||||| ${order.orderId}',
                                        style: const TextStyle(fontFamily: 'Courier', fontSize: 11.5, letterSpacing: 0.8, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Scan for instant kitchen verification',
                                        style: TextStyle(fontSize: 9.5, color: AppTheme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Icon(Icons.qr_code_2_rounded, size: 34, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons Row (Download PDF & Share)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isGeneratingPdf ? null : _handleDownloadPdf,
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded, size: 20),
                      label: Text(
                        _isGeneratingPdf ? 'Generating PDF...' : 'Download PDF Receipt 📥',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _shareReceiptSummary,
                    child: const Icon(Icons.share_outlined, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptPriceRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 12.5,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDiscount
                ? AppTheme.accentRed
                : isTotal
                    ? AppTheme.primaryGreen
                    : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
