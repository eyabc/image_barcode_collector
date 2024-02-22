class Pageable {

  final int size;
  int page;

  Pageable({required this.size, required this.page});

  int offset() {
    return (page) * size;
  }

  int nextOffset() {
    return (page) * size + size;
  }

  void increasePage() {
    page += 1;
  }

  Pageable setOffset(int offset) {
    return Pageable(size: size, page: offset ~/ size);
  }


}