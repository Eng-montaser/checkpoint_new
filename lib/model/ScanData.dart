class ScanData {
  String? qr_text;
  String? is_manually;
  String? reason_for_missing;
  String? lat;
  String? long;
  String? start_at;
  String? end_at;
  ScanData(
      {this.lat,
      this.end_at,
      this.is_manually,
      this.long,
      this.qr_text,
      this.reason_for_missing,
      this.start_at});
  getBody() {
    return {
      "qr_text": qr_text,
      "is_manually": is_manually,
      "reason_for_missing": reason_for_missing,
      "lat": lat,
      "long": long,
      "start_at": start_at,
      "end_at": end_at
    };
  }
}
