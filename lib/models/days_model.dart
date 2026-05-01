class DaysModel{
   dynamic days;  

  DaysModel({
    this.days,
  });

  Map<String, dynamic> toJson() => {
        "days": days,        
      };
}