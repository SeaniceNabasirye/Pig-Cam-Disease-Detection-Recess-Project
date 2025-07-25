class CameraDevice {
  final String id;
  final String name;
  final String ipAddress;

  CameraDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
  });

  CameraDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
  }) {
    return CameraDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}
