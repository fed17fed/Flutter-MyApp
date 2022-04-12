class Show {
  //final String author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  // final String content;

  Show({
    //required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    //required this.content
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      //author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      //urlToImage: json['urlToImage'] != null ? new urlToImage.json['urlToImage'] : null;
      // content: json['content'],
    );
  }
}
