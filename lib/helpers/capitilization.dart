extension SentenceCase on String {
  String sentenceCase() => substring(0, 1).toUpperCase() + substring(1).toLowerCase();
}