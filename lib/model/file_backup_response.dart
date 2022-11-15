class FileBackupModel {
  BackupBody body;
  String status;

  FileBackupModel({this.body, this.status});

  FileBackupModel.fromJson(Map<String, dynamic> json) {
    body = json['body'] != null ? BackupBody.fromJson(json['body']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (body != null) {
      data['body'] = body.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class BackupBody {
  String backupUrl;

  BackupBody({this.backupUrl});

  BackupBody.fromJson(Map<String, dynamic> json) {
    backupUrl = json['backup_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['backup_url'] = backupUrl;
    return data;
  }
}
