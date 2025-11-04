import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../cart/domain/entities/cart_item.dart';

class WhatsAppService {
  static final String _phoneNumber = dotenv.env['WHATSAPP_PHONE_NUMBER'] ?? '529681520437';

  static Future<bool> sendOrder(List<CartItem> items, double total) async {
    if (items.isEmpty) return false;

    final message = _buildOrderMessage(items, total);
    final url = Uri.parse('https://wa.me/$_phoneNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static String _buildOrderMessage(List<CartItem> items, double total) {
    final buffer = StringBuffer();
    buffer.writeln('🍽️ *Nuevo Pedido - Deliv*\n');

    for (var item in items) {
      buffer.writeln('*${item.name}*');
      buffer.writeln('Cantidad: ${item.quantity}');
      buffer.writeln('Precio: \$${item.price.toStringAsFixed(2)}');
      buffer.writeln('Subtotal: \$${item.subtotal.toStringAsFixed(2)}\n');
    }

    buffer.writeln('---');
    buffer.writeln('*Total: \$${total.toStringAsFixed(2)}*');

    return buffer.toString();
  }
}