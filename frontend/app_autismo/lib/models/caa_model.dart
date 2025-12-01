
class CaaItem {
  final int id;
  final String texto;
  final String? imgUrl;
  final String? audioUrl;

  CaaItem({
    required this.id,
    required this.texto,
    this.imgUrl,
    this.audioUrl,
  });

  factory CaaItem.fromJson(Map<String, dynamic> json) {
    return CaaItem(
      id: json['id'],
      texto: json['texto'],
      imgUrl: json['img_url'],
      audioUrl: json['audio_url'],
    );
  }
}

class CaaBoard {
  final int id;
  final String nome;
  final List<CaaItem> items; 

  CaaBoard({
    required this.id,
    required this.nome,
    required this.items,
  });

  factory CaaBoard.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<CaaItem> items =
        itemsList.map((itemJson) => CaaItem.fromJson(itemJson)).toList();

    return CaaBoard(
      id: json['id'],
      nome: json['nome'],
      items: items,
    );
  }
}