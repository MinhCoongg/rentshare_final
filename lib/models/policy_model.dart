class PolicyModel {
  final String type;
  final String content;

  PolicyModel({
    required this.type,
    required this.content,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      type: json['policyType'] ?? '',
      content: json['content'] ?? '',
    );
  }
  
  Map<String, String> toJson() => {
    'type': type, 
    'content': content
  };
}