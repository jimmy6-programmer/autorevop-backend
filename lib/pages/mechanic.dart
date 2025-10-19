class Mechanic {
  final String mongoId;
  final String id;
  final String name;
  final String phone;
  final String email;
  final String specialty;
  final String experience;
  final String status;
  final double rating;
  final int completedJobs;
  final String image;
  final String location;
  final List<Map<String, dynamic>> jobs;
  final int version;
  final String createdAt;
  final String updatedAt;

  Mechanic({
    required this.mongoId,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.specialty,
    required this.experience,
    required this.status,
    required this.rating,
    required this.completedJobs,
    required this.image,
    required this.location,
    required this.jobs,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      mongoId: json['_id'] ?? '',
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      specialty: json['specialtyKey'] ?? json['specialty'] ?? '',
      experience: json['experience'] ?? '',
      status: json['status'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedJobs: json['completedJobs'] ?? 0,
      image: json['imageAsset'] ?? json['image'] ?? '',
      location: json['location'] ?? '',
      jobs: json['jobs'] != null ? List<Map<String, dynamic>>.from(json['jobs']) : [],
      version: json['__v'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}