class CardItem {
  final int id;
  final String content;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.id,
    required this.content,
    this.isFlipped = false,
    this.isMatched = false,
  });

  CardItem copyWith({
    int? id,
    String? content,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}