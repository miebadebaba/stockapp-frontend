enum AiChatRole {
  user('user'),
  assistant('assistant');

  const AiChatRole(this.value);

  final String value;
}

class AiChatMessage {
  const AiChatMessage({required this.role, required this.content});

  final AiChatRole role;
  final String content;

  Map<String, String> toJson() => {'role': role.value, 'content': content};
}
