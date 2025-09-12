import 'dart:math';
import 'web_scraper_service.dart';

class ContentRewriterService {
  static ContentRewriterService? _instance;
  static ContentRewriterService get instance => _instance ??= ContentRewriterService._();
  
  ContentRewriterService._();
  
  /// Reescribir noticia automáticamente para evitar problemas legales
  Future<RewrittenContent> rewriteNews(String originalTitle, String originalContent, String category) async {
    try {
      print('🔄 Reescribiendo noticia: $originalTitle');
      
      // En producción, aquí se usaría una API de IA real (OpenAI, Claude, etc.)
      // Por ahora, usamos transformaciones automáticas avanzadas
      
      final rewrittenTitle = _rewriteTitle(originalTitle);
      final rewrittenContent = _rewriteContent(originalContent);
      final summary = _generateSummary(rewrittenContent);
      final imageUrl = _getRelevantImage(category);
      
      print('✅ Noticia reescrita exitosamente');
      
      return RewrittenContent(
        title: rewrittenTitle,
        content: rewrittenContent,
        summary: summary,
        imageUrl: imageUrl,
        originalTitle: originalTitle,
        originalContent: originalContent,
      );
    } catch (e) {
      print('❌ Error reescribiendo noticia: $e');
      // Fallback: devolver contenido original con cambios mínimos
      return RewrittenContent(
        title: _rewriteTitle(originalTitle),
        content: _rewriteContent(originalContent),
        summary: _generateSummary(originalContent),
        imageUrl: _getRelevantImage(category),
        originalTitle: originalTitle,
        originalContent: originalContent,
      );
    }
  }
  
  /// Reescribir título
  String _rewriteTitle(String originalTitle) {
    String title = originalTitle;
    
    // Reemplazos de palabras clave
    final titleReplacements = {
      'Otaola': 'Presentador cubano',
      'Alexander Otaola': 'Presentador cubano',
      'cubaenmiami.com': 'CubaLink Noticias',
      'Cuba en Miami': 'CubaLink Noticias',
      'Miami Web Marketing': 'CubaLink Noticias',
    };
    
    titleReplacements.forEach((original, replacement) {
      title = title.replaceAll(original, replacement);
    });
    
    // Agregar prefijo de marca
    if (!title.startsWith('CubaLink Noticias:')) {
      title = 'CubaLink Noticias: $title';
    }
    
    return title;
  }
  
  /// Reescribir contenido
  String _rewriteContent(String originalContent) {
    String content = originalContent;
    
    // Reemplazos de palabras clave
    final contentReplacements = {
      'Otaola': 'el presentador cubano',
      'Alexander Otaola': 'el presentador cubano',
      'cubaenmiami.com': 'CubaLink Noticias',
      'Cuba en Miami': 'CubaLink Noticias',
      'Miami Web Marketing': 'CubaLink Noticias',
      'EE.UU.': 'Estados Unidos',
      'EE.UU': 'Estados Unidos',
    };
    
    contentReplacements.forEach((original, replacement) {
      content = content.replaceAll(original, replacement);
    });
    
    // Expandir contenido con párrafos adicionales
    content = _expandContent(content);
    
    return content;
  }
  
  /// Expandir contenido con párrafos adicionales
  String _expandContent(String content) {
    final paragraphs = content.split('\n\n');
    final expandedParagraphs = <String>[];
    
    for (int i = 0; i < paragraphs.length; i++) {
      expandedParagraphs.add(paragraphs[i]);
      
      // Agregar párrafo adicional cada 2 párrafos
      if (i % 2 == 1 && i < paragraphs.length - 1) {
        final additionalParagraph = _generateAdditionalParagraph(paragraphs[i]);
        if (additionalParagraph.isNotEmpty) {
          expandedParagraphs.add(additionalParagraph);
        }
      }
    }
    
    return expandedParagraphs.join('\n\n');
  }
  
  /// Generar párrafo adicional
  String _generateAdditionalParagraph(String context) {
    final additionalPhrases = [
      'Esta situación ha generado diversas reacciones en la comunidad cubana residente en Estados Unidos.',
      'Los expertos en la materia han analizado las implicaciones de esta decisión para las relaciones bilaterales.',
      'La medida ha sido recibida con expectativa por parte de los sectores económicos afectados.',
      'Las autoridades competentes han enfatizado la importancia de cumplir con todos los requisitos establecidos.',
      'Esta decisión forma parte de una serie de medidas implementadas recientemente por las autoridades.',
      'Los analistas han señalado que esta medida podría tener un impacto significativo en el sector.',
      'La implementación de esta política está sujeta a ciertas regulaciones y controles específicos.',
      'Los representantes de la comunidad han expresado su opinión sobre esta importante decisión.',
    ];
    
    final random = Random();
    return additionalPhrases[random.nextInt(additionalPhrases.length)];
  }
  
  /// Generar resumen
  String _generateSummary(String content) {
    final sentences = content.split('.');
    if (sentences.length >= 2) {
      return '${sentences[0].trim()}.';
    }
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }
  
  /// Obtener imagen relevante según categoría
  String _getRelevantImage(String category) {
    final categoryImages = {
      'Política': [
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=200&fit=crop',
      ],
      'Sociedad': [
        'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=200&fit=crop',
      ],
      'Inmigración': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&h=200&fit=crop',
      ],
      'Noticias de Miami': [
        'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=200&fit=crop',
      ],
      'Economía': [
        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&h=200&fit=crop',
        'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=400&h=200&fit=crop',
      ],
    };
    
    final images = categoryImages[category] ?? categoryImages['Política']!;
    final random = Random();
    return images[random.nextInt(images.length)];
  }
  
  /// Reescribir múltiples noticias
  Future<List<RewrittenContent>> rewriteMultipleNews(List<ScrapedNews> scrapedNews) async {
    final rewrittenNews = <RewrittenContent>[];
    
    for (final news in scrapedNews) {
      final rewritten = await rewriteNews(news.title, news.content, news.category);
      rewrittenNews.add(rewritten);
    }
    
    return rewrittenNews;
  }
}

class RewrittenContent {
  final String title;
  final String content;
  final String summary;
  final String imageUrl;
  final String originalTitle;
  final String originalContent;
  
  RewrittenContent({
    required this.title,
    required this.content,
    required this.summary,
    required this.imageUrl,
    required this.originalTitle,
    required this.originalContent,
  });
}
