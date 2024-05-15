extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }

  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

  List<dynamic> getSublist(int offset, int limit) {
    // Check if the offset is greater than or equal to the length of dbMessages

    if (offset >= length) {

      // Handle the case where the offset exceeds the list length
      return [];
    } else {
      // Calculate the end index for the sublist
      int end = offset + limit <= length ? offset + limit : length;

      // Get the sublist using the valid range
      List<dynamic> sublist = this.sublist(offset, end);
      return sublist;
    }
  }

}