class DeviceInfoLoginModel {
  DeviceInfoLoginModel({
    this.appId,
    this.appVersion,
    this.deviceId,
    this.deviceLocation,
    this.deviceManufacturer,
    this.deviceModel,
    this.fcmToken,
    this.onesignalSubscriptionID,

  });

  dynamic appId;
  dynamic deviceId;
  dynamic fcmToken;
  dynamic deviceLocation;
  dynamic deviceManufacturer;
  dynamic deviceModel;
  dynamic appVersion;
  dynamic onesignalSubscriptionID;
  

  factory DeviceInfoLoginModel.fromJson(Map<String, dynamic> json) => DeviceInfoLoginModel();

  Map<String, dynamic> toJson() => {
        "appId": appId ?? 2,
        "deviceId": deviceId,
        "fcmToken": fcmToken,
        "deviceLocation": deviceLocation ?? "",
        "deviceManufacturer": deviceManufacturer,
        "deviceModel": deviceModel,
        "appVersion": appVersion,
        "subscription_id": onesignalSubscriptionID,

      };
}
