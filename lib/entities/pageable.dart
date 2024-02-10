class Pageable {

  final int size;
  int page;

  Pageable({required this.size, required this.page});

  int offset() {
    return (page) * size;
  }

  void increasePage() {
    page += 1;
  }

}