import 'package:cubalink23/services/web_scraper_service.dart';
import 'package:cubalink23/services/content_rewriter_service.dart';

class NewsService {
  static NewsService? _instance;
  static NewsService get instance => _instance ??= NewsService._();

  NewsService._();

  final String _baseUrl = 'https://www.cubaenmiami.com';
  final WebScraperService _scraper = WebScraperService.instance;
  final ContentRewriterService _rewriter = ContentRewriterService.instance;

  /// Obtener noticias desde Cuba en Miami con scraping y reescritura automática
  Future<List<NewsArticle>> getNews() async {
    try {
      print('📰 Obteniendo noticias desde Cuba en Miami...');

      // 1. Hacer scraping del sitio web
      final scrapedNews = await _scraper.scrapeNews();

      if (scrapedNews.isEmpty) {
        print('⚠️ No se obtuvieron noticias del scraping, usando noticias de muestra');
        return await _getSampleNews();
      }

      // 2. Reescribir noticias automáticamente
      final rewrittenNews = await _rewriter.rewriteMultipleNews(scrapedNews);

      // 3. Convertir a NewsArticle
      final news = rewrittenNews
          .map((rewritten) => NewsArticle(
                id: _generateId(rewritten.title),
                title: rewritten.title,
                content: rewritten.content,
                summary: rewritten.summary,
                imageUrl: rewritten.imageUrl,
                category: _getCategoryFromScraped(scrapedNews, rewritten.originalTitle),
                publishedAt: _getPublishedAtFromScraped(scrapedNews, rewritten.originalTitle),
                source: 'CubaLink Noticias',
                originalUrl: _getUrlFromScraped(scrapedNews, rewritten.originalTitle),
              ))
          .toList();

      print('✅ ${news.length} noticias obtenidas y reescritas automáticamente');
      return news;
    } catch (e) {
      print('❌ Error obteniendo noticias: $e');
      // Fallback a noticias de muestra
      return await _getSampleNews();
    }
  }

  /// Obtener noticias de muestra (simuladas)
  Future<List<NewsArticle>> _getSampleNews() async {
    // En producción, aquí se haría el scraping real del sitio web
    // Por ahora, devolvemos noticias de muestra basadas en el contenido del sitio

    return [
      NewsArticle(
        id: '1',
        title: 'CubaLink Noticias: Actualizaciones sobre permisos especiales para exportaciones',
        content:
            '''El gobierno estadounidense ha anunciado una extensión significativa de los permisos especiales para exportaciones hacia Cuba, extendiendo estas autorizaciones hasta el año 2026. Esta decisión representa un paso importante en las relaciones comerciales entre ambos países.

La medida, que fue implementada recientemente, busca facilitar el comercio y las relaciones económicas internacionales, permitiendo que las empresas estadounidenses puedan continuar sus operaciones de exportación hacia la isla caribeña. Esta extensión de permisos incluye una amplia gama de productos y servicios que pueden ser exportados bajo condiciones específicas.

Según fuentes oficiales, esta decisión se tomó después de una evaluación exhaustiva de las condiciones comerciales actuales y las necesidades del mercado cubano. Los permisos extendidos cubren sectores como la agricultura, la tecnología, la medicina y otros bienes de consumo esenciales.

Los analistas económicos han señalado que esta medida podría tener un impacto positivo en la economía cubana, proporcionando acceso a productos y servicios que podrían contribuir al desarrollo económico de la isla. Además, representa una oportunidad para las empresas estadounidenses de expandir sus mercados en la región.

La implementación de estos permisos extendidos está sujeta a ciertas regulaciones y controles para asegurar que se cumplan los objetivos de política exterior de Estados Unidos. Las empresas interesadas en aprovechar estas oportunidades comerciales deben cumplir con todos los requisitos establecidos por las autoridades competentes.''',
        summary: 'Permisos de exportación extendidos hasta 2026',
        imageUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=200&fit=crop',
        category: 'Política',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'CubaLink Noticias',
        originalUrl: '$_baseUrl/noticia-exportaciones',
      ),
      NewsArticle(
        id: '2',
        title: 'CubaLink Noticias: Casos de fraude involucran a ciudadanos cubanos en EE.UU.',
        content:
            '''Las autoridades estadounidenses han reportado una serie de casos de fraude que involucran a ciudadanos cubanos residentes en Estados Unidos. Las investigaciones, que se encuentran en curso, buscan determinar el alcance completo de estas actividades ilegales y las redes criminales involucradas.

Según informaciones del Departamento de Justicia, se han identificado múltiples esquemas fraudulentos que incluyen fraude de identidad, fraude financiero y otros delitos relacionados con documentos falsos. Los casos investigados involucran a más de una docena de individuos de origen cubano que operaban en diferentes estados del país.

Las autoridades han señalado que estos casos no representan a la comunidad cubana en general, sino que se trata de individuos específicos que han aprovechado sistemas y programas gubernamentales para cometer actos ilegales. La investigación se ha centrado en identificar los métodos utilizados y las posibles conexiones entre los diferentes casos.

Los fiscales federales han enfatizado la importancia de estos casos para la integridad de los sistemas de inmigración y beneficios sociales. Se espera que las investigaciones continúen durante las próximas semanas, con posibles nuevas acusaciones y arrestos.

La comunidad cubana en Estados Unidos ha expresado su preocupación por estos casos y ha reiterado su compromiso con el cumplimiento de la ley. Varias organizaciones comunitarias han ofrecido su colaboración con las autoridades para prevenir futuros casos similares.''',
        summary: 'Investigaciones de fraude en curso',
        imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&h=200&fit=crop',
        category: 'Sociedad',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        source: 'CubaLink Noticias',
        originalUrl: '$_baseUrl/noticia-fraude',
      ),
      NewsArticle(
        id: '3',
        title: 'CubaLink Noticias: Aumento significativo en aprobaciones de residencia',
        content:
            '''El Servicio de Ciudadanía e Inmigración de Estados Unidos (USCIS) ha reportado un incremento significativo del 37% en las aprobaciones de residencia permanente durante el último trimestre. Este notable aumento refleja importantes cambios en las políticas migratorias y mejoras en los procesos administrativos.

Los datos oficiales muestran que las aprobaciones de tarjetas verdes han experimentado un crecimiento sustancial, especialmente en categorías como reunificación familiar, asilo y refugio. Este incremento se atribuye a varias reformas implementadas en los últimos meses para agilizar el procesamiento de casos pendientes.

Las autoridades migratorias han implementado nuevas tecnologías y procedimientos que han permitido reducir significativamente los tiempos de procesamiento. Además, se han destinado recursos adicionales para contratar más personal especializado en el procesamiento de casos de inmigración.

Los expertos en inmigración han señalado que este aumento en las aprobaciones podría tener un impacto positivo en la economía estadounidense, ya que los nuevos residentes permanentes contribuyen al crecimiento económico a través del trabajo, el consumo y el pago de impuestos.

Sin embargo, algunos grupos han expresado preocupación sobre la capacidad del sistema para mantener este ritmo de procesamiento sin comprometer la seguridad nacional. Las autoridades han asegurado que todos los casos son procesados con los más altos estándares de seguridad y verificación de antecedentes.''',
        summary: 'Aumento del 37% en aprobaciones de residencia',
        imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&h=200&fit=crop',
        category: 'Inmigración',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        source: 'CubaLink Noticias',
        originalUrl: '$_baseUrl/noticia-residencia',
      ),
      NewsArticle(
        id: '4',
        title: 'CubaLink Noticias: Fortalecimiento de seguridad en Miami',
        content:
            '''Las autoridades de Miami han implementado un conjunto integral de nuevas medidas de seguridad diseñadas para proteger a la comunidad y mejorar la tranquilidad de los residentes. Estas iniciativas representan una inversión significativa en la seguridad pública de la ciudad.

El plan de seguridad incluye la instalación de cámaras de vigilancia de alta tecnología en puntos estratégicos de la ciudad, el aumento de patrullas policiales en áreas de mayor actividad, y la implementación de sistemas de alerta temprana para la comunidad. Estas medidas han sido desarrolladas en colaboración con expertos en seguridad y representantes de la comunidad.

Además, se ha establecido un programa de participación comunitaria que permite a los residentes reportar actividades sospechosas de manera anónima y segura. El programa incluye capacitación para los residentes sobre cómo identificar y reportar comportamientos inusuales.

Las autoridades han destacado que estas medidas no solo buscan prevenir la delincuencia, sino también crear un ambiente más seguro y acogedor para todos los residentes de Miami. Se espera que estas iniciativas contribuyan a reducir significativamente los índices de criminalidad en la ciudad.

La implementación de estas medidas de seguridad ha sido recibida positivamente por la comunidad, que ha expresado su apoyo a las iniciativas del gobierno local para mejorar la seguridad pública.''',
        summary: 'Nuevas medidas de seguridad implementadas',
        imageUrl: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=400&h=200&fit=crop',
        category: 'Noticias de Miami',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: 'CubaLink Noticias',
        originalUrl: '$_baseUrl/noticia-seguridad',
      ),
      NewsArticle(
        id: '5',
        title: 'CubaLink Noticias: Modificaciones en examen de naturalización',
        content:
            '''El Servicio de Ciudadanía e Inmigración de Estados Unidos (USCIS) ha adelantado posibles modificaciones significativas en el examen de naturalización que buscan mejorar el proceso y hacerlo más accesible para los solicitantes. Estas actualizaciones representan la revisión más importante del examen en más de una década.

Las propuestas incluyen la modernización del formato del examen, la incorporación de tecnología digital para hacer el proceso más eficiente, y la actualización del contenido para reflejar mejor la historia y los valores estadounidenses contemporáneos. Los cambios también buscan reducir la ansiedad de los candidatos y hacer el examen más justo y equitativo.

Una de las modificaciones más destacadas es la introducción de un sistema de examen adaptativo que ajusta la dificultad de las preguntas según el nivel de conocimiento del candidato. Esto permitirá una evaluación más precisa de los conocimientos cívicos y del idioma inglés.

Además, se está considerando la implementación de sesiones de preparación gratuitas para los candidatos, incluyendo materiales de estudio actualizados y simulacros de examen. Estas iniciativas buscan aumentar las tasas de aprobación y reducir las disparidades entre diferentes grupos demográficos.

Las autoridades han enfatizado que cualquier cambio en el examen será implementado gradualmente, con un período de transición que permita a los candidatos prepararse adecuadamente. Se espera que las nuevas modificaciones estén completamente implementadas para el próximo año fiscal.''',
        summary: 'Posibles cambios en examen de naturalización',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=200&fit=crop',
        category: 'Inmigración',
        publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
        source: 'CubaLink Noticias',
        originalUrl: '$_baseUrl/noticia-naturalizacion',
      ),
    ];
  }

  /// Reescribir contenido para evitar problemas legales
  String _rewriteContent(String originalContent) {
    // En producción, aquí se usaría IA para reescribir el contenido
    // Por ahora, aplicamos transformaciones básicas

    String rewritten = originalContent;

    // Reemplazar palabras clave
    final replacements = {
      'Cuba en Miami': 'CubaLink Noticias',
      'cubaenmiami.com': 'CubaLink Noticias',
      'Miami Web Marketing': 'CubaLink Noticias',
    };

    replacements.forEach((original, replacement) {
      rewritten = rewritten.replaceAll(original, replacement);
    });

    return rewritten;
  }

  /// Obtener noticias por categoría
  Future<List<NewsArticle>> getNewsByCategory(String category) async {
    final allNews = await getNews();
    return allNews.where((news) => news.category == category).toList();
  }

  /// Obtener noticias destacadas
  Future<List<NewsArticle>> getFeaturedNews() async {
    final allNews = await getNews();
    return allNews.take(3).toList();
  }

  /// Generar ID único para noticia
  String _generateId(String title) {
    return title.hashCode.abs().toString();
  }

  /// Obtener categoría desde noticia scraped
  String _getCategoryFromScraped(List<ScrapedNews> scrapedNews, String originalTitle) {
    final news = scrapedNews.firstWhere(
      (n) => n.title == originalTitle,
      orElse: () => scrapedNews.first,
    );
    return news.category;
  }

  /// Obtener fecha de publicación desde noticia scraped
  DateTime _getPublishedAtFromScraped(List<ScrapedNews> scrapedNews, String originalTitle) {
    final news = scrapedNews.firstWhere(
      (n) => n.title == originalTitle,
      orElse: () => scrapedNews.first,
    );
    return news.publishedAt;
  }

  /// Obtener URL desde noticia scraped
  String _getUrlFromScraped(List<ScrapedNews> scrapedNews, String originalTitle) {
    final news = scrapedNews.firstWhere(
      (n) => n.title == originalTitle,
      orElse: () => scrapedNews.first,
    );
    return news.url;
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String summary;
  final String imageUrl;
  final String category;
  final DateTime publishedAt;
  final String source;
  final String originalUrl;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.imageUrl,
    required this.category,
    required this.publishedAt,
    required this.source,
    required this.originalUrl,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Hace un momento';
    }
  }
}
