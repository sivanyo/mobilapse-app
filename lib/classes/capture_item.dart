class CaptureItem {
  String name;
  DateTime creationDate;
  String length;
  String downloadURL;
  DateTime? creationTimeInFirebase;

  @override
  String toString() {
    return 'CaptureItem{name: $name, creationDate: $creationDate, length: $length, downloadURL: $downloadURL}';
  }

  CaptureItem(this.name, this.creationDate, this.length, this.downloadURL, this.creationTimeInFirebase);
}
