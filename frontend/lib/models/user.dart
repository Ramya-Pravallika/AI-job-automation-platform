class UserProfile {
  final int? id;
  final int? userId;
  final String? skills;
  final String? experience;
  final String? location;
  final String? preferredRoles;
  final String? remotePreference;

  UserProfile({
    this.id,
    this.userId,
    this.skills,
    this.experience,
    this.location,
    this.preferredRoles,
    this.remotePreference,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      skills: json['skills'] as String?,
      experience: json['experience'] as String?,
      location: json['location'] as String?,
      preferredRoles: json['preferred_roles'] as String?,
      remotePreference: json['remote_preference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills,
      'experience': experience,
      'location': location,
      'preferred_roles': preferredRoles,
      'remote_preference': remotePreference,
    };
  }
}

class User {
  final int id;
  final String email;
  final DateTime? createdAt;
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    this.createdAt,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }
}
