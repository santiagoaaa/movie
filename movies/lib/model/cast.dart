class Cast {
  final int cast_id;
  final String character;
  final String credit_id;
  final int id;
  final String name;
  final String profile_path;

  Cast(
      {this.cast_id,
      this.character,
      this.credit_id,
      this.id,
      this.name,
      this.profile_path});

  Map<String, dynamic> toMap() {
    return {
      'cast_id': cast_id,
      'character': character,
      'credit_id': credit_id,
      'id': id,
      'name': name,
      'profile_path': profile_path
    };
  }
}
