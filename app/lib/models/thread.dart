class Thread {
  final String id;
  final String title;
  final List<String> sessionIds;

  const Thread({
    required this.id,
    required this.title,
    required this.sessionIds,
  });
}
