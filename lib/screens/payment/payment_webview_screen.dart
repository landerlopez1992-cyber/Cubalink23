import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cubalink23/screens/payment/payment_success_screen.dart';

/// ====================== WEBVIEW PARA PAYMENT LINKS ======================
/// 
/// Abre Payment Links de Square DENTRO de la app
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentLinkId;
  final double amount;
  final double fee;
  final double total;

  const PaymentWebViewScreen({
    Key? key,
    required this.paymentUrl,
    required this.paymentLinkId,
    required this.amount,
    required this.fee,
    required this.total,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('🔄 WebView cargando: $url');
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            print('✅ WebView cargado: $url');
            
            // Verificar si llegó a página de éxito
            if (url.contains('payment-success') || url.contains('success')) {
              _handlePaymentSuccess();
            }
          },
          onNavigationRequest: (request) {
            print('🔗 Navegando a: ${request.url}');
            
            // Interceptar redirección de éxito
            if (request.url.contains('payment-success') || 
                request.url.contains('cubalink23-system.onrender.com/payment-success')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentSuccess() {
    print('✅ Pago completado exitosamente');
    
    // Navegar a pantalla de éxito
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: widget.amount,
          fee: widget.fee,
          total: widget.total,
          transactionId: widget.paymentLinkId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔒 Pago Seguro'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando pago seguro...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


