enum CallType { incoming, outgoing }

enum CallStatus { completed, missed, rejected }

class CallModel {
  const CallModel({
    required this.id,
    required this.userName,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.durationInSeconds,
  });

  final String id;
  final String userName;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final int durationInSeconds;

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      type: CallType.values.byName(json['type'] as String),
      status: CallStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationInSeconds: (json['durationInSeconds'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'durationInSeconds': durationInSeconds,
    };
  }
}
