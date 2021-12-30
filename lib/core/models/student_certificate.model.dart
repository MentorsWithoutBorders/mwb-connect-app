class StudentCertificate {
  bool? isCertificateSent;

  StudentCertificate({this.isCertificateSent});

  StudentCertificate.fromJson(Map<String, dynamic> json) :
    isCertificateSent = json['isCertificateSent'] ?? false;

  Map<String, Object?> toJson() {
    return {
      'isCertificateSent': isCertificateSent
    };
  }
}