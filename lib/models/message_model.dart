class MessageModel {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isFromUser => role == 'user';

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
