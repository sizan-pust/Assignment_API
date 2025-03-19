class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? json['headline'] ?? 'No Title',
      description: json['description'] ?? json['snippet'] ?? 'No Description',
      url: json['url'] ?? json['web_url'] ?? '',
      // Handle different image field names
      urlToImage: json['url_to_image'] ??
          json['image_url'] ??
          json['urlToImage'] ??
          'https://via.placeholder.com/150',
    );
  }
}
