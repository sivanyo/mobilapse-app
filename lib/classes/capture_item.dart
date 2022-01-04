class CaptureItem {
  String name;
  DateTime creationDate;
  String downloadURL;
  DateTime? creationTimeInFirebase;

  @override
  String toString() {
    return 'CaptureItem{name: $name, creationDate: $creationDate, downloadURL: $downloadURL}';
  }

  CaptureItem(this.name, this.creationDate, this.downloadURL,
      this.creationTimeInFirebase);
}
