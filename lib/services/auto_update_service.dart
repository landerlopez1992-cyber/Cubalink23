import 'dart:async';
import 'package:cubalink23/services/news_service.dart';
import 'package:cubalink23/services/web_scraper_service.dart';
import 'package:cubalink23/services/content_rewriter_service.dart';

class AutoUpdateService {
  static AutoUpdateService? _instance;
  static AutoUpdateService get instance => _instance ??= AutoUpdateService._();
  
  AutoUpdateService._();
  
  Timer? _updateTimer;
  final NewsService _newsService = NewsService.instance;
  final WebScraperService _scraper = WebScraperService.instance;
  final ContentRewriterService _rewriter = ContentRewriterService.instance;
  
  /// Iniciar actualización automática diaria
  void startAutoUpdate() {
    print('🔄 Iniciando actualización automática de noticias...');
    
    // Actualizar inmediatamente
    _performUpdate();
    
    // Programar actualización cada 24 horas
    _updateTimer = Timer.periodic(Duration(hours: 24), (timer) {
      _performUpdate();
    });
    
    print('✅ Actualización automática programada cada 24 horas');
  }
  
  /// Detener actualización automática
  void stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
    print('⏹️ Actualización automática detenida');
  }
  
  /// Realizar actualización manual
  Future<void> performManualUpdate() async {
    print('🔄 Realizando actualización manual de noticias...');
    await _performUpdate();
  }
  
  /// Ejecutar actualización
  Future<void> _performUpdate() async {
    try {
      print('📰 Iniciando actualización de noticias...');
      
      // 1. Hacer scraping del sitio web
      final scrapedNews = await _scraper.scrapeNews();
      
      if (scrapedNews.isEmpty) {
        print('⚠️ No se obtuvieron noticias del scraping');
        return;
      }
      
      // 2. Reescribir noticias automáticamente
      final rewrittenNews = await _rewriter.rewriteMultipleNews(scrapedNews);
      
      // 3. Guardar en cache local (opcional)
      await _saveToCache(rewrittenNews);
      
      print('✅ Actualización completada: ${rewrittenNews.length} noticias procesadas');
      
    } catch (e) {
      print('❌ Error en actualización automática: $e');
    }
  }
  
  /// Guardar noticias en cache local
  Future<void> _saveToCache(List<RewrittenContent> news) async {
    try {
      // Aquí se implementaría el guardado en cache local
      // Por ejemplo, usando SharedPreferences o una base de datos local
      print('💾 Guardando ${news.length} noticias en cache local');
      
      // Implementación futura:
      // final prefs = await SharedPreferences.getInstance();
      // final newsJson = jsonEncode(news.map((n) => n.toJson()).toList());
      // await prefs.setString('cached_news', newsJson);
      
    } catch (e) {
      print('❌ Error guardando en cache: $e');
    }
  }
  
  /// Cargar noticias desde cache local
  Future<List<RewrittenContent>> loadFromCache() async {
    try {
      // Implementación futura:
      // final prefs = await SharedPreferences.getInstance();
      // final newsJson = prefs.getString('cached_news');
      // if (newsJson != null) {
      //   final List<dynamic> newsList = jsonDecode(newsJson);
      //   return newsList.map((json) => RewrittenContent.fromJson(json)).toList();
      // }
      
      return [];
    } catch (e) {
      print('❌ Error cargando desde cache: $e');
      return [];
    }
  }
  
  /// Verificar si hay actualizaciones disponibles
  Future<bool> checkForUpdates() async {
    try {
      final scrapedNews = await _scraper.scrapeNews();
      final cachedNews = await loadFromCache();
      
      // Comparar fechas de publicación
      if (scrapedNews.isNotEmpty && cachedNews.isNotEmpty) {
        final latestScraped = scrapedNews.map((n) => n.publishedAt).reduce((a, b) => a.isAfter(b) ? a : b);
        final latestCached = cachedNews.map((n) => DateTime.now()).reduce((a, b) => a.isAfter(b) ? a : b);
        
        return latestScraped.isAfter(latestCached);
      }
      
      return scrapedNews.isNotEmpty;
    } catch (e) {
      print('❌ Error verificando actualizaciones: $e');
      return false;
    }
  }
  
  /// Obtener estadísticas de actualización
  Map<String, dynamic> getUpdateStats() {
    return {
      'isRunning': _updateTimer?.isActive ?? false,
      'lastUpdate': DateTime.now(), // En producción se guardaría la fecha real
      'updateInterval': '24 horas',
      'nextUpdate': _updateTimer?.isActive == true 
          ? DateTime.now().add(Duration(hours: 24))
          : null,
    };
  }
}






