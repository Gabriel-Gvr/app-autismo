
class Share {
  final int id;
  final String viewerEmail;
  final String escopo;
  final String? expiraEm; 

  Share({
    required this.id,
    required this.viewerEmail,
    required this.escopo,
    this.expiraEm,
  });

  factory Share.fromJson(Map<String, dynamic> json) {
    return Share(
      id: json['id'],
      viewerEmail: json['viewer_email'],
      escopo: json['escopo'],
      expiraEm: json['expira_em'],
    );
  }
}