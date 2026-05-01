import 'dart:convert';

BankDetailsModel bankDetailsModelFromJson(dynamic str) =>
    BankDetailsModel.fromJson(json.decode(str));

dynamic bankDetailsModelToJson(BankDetailsModel data) =>
    json.encode(data.toJson());

class BankDetailsModel {
  dynamic address;
  dynamic centre;
  dynamic contact;
  dynamic micr;
  dynamic swift;
  dynamic district;
  dynamic iso3166;
  dynamic city;
  bool? neft;
  bool? imps;
  bool? upi;
  dynamic branch;
  bool? rtgs;
  dynamic state;
  dynamic bank;
  dynamic bankcode;
  dynamic ifsc;

  BankDetailsModel({
    this.address,
    this.centre,
    this.contact,
    this.micr,
    this.swift,
    this.district,
    this.iso3166,
    this.city,
    this.neft,
    this.imps,
    this.upi,
    this.branch,
    this.rtgs,
    this.state,
    this.bank,
    this.bankcode,
    this.ifsc,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) =>
      BankDetailsModel(
        address: json["ADDRESS"],
        centre: json["CENTRE"],
        contact: json["CONTACT"],
        micr: json["MICR"],
        swift: json["SWIFT"],
        district: json["DISTRICT"],
        iso3166: json["ISO3166"],
        city: json["CITY"],
        neft: json["NEFT"],
        imps: json["IMPS"],
        upi: json["UPI"],
        branch: json["BRANCH"],
        rtgs: json["RTGS"],
        state: json["STATE"],
        bank: json["BANK"],
        bankcode: json["BANKCODE"],
        ifsc: json["IFSC"],
      );

  Map<String, dynamic> toJson() => {
        "ADDRESS": address,
        "CENTRE": centre,
        "CONTACT": contact,
        "MICR": micr,
        "SWIFT": swift,
        "DISTRICT": district,
        "ISO3166": iso3166,
        "CITY": city,
        "NEFT": neft,
        "IMPS": imps,
        "UPI": upi,
        "BRANCH": branch,
        "RTGS": rtgs,
        "STATE": state,
        "BANK": bank,
        "BANKCODE": bankcode,
        "IFSC": ifsc,
      };
}
