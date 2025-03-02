class Exercise {

  late String name;
  late int duration;
  late int calBurned;

  Exercise (String title, int minutes) {
    name = title;
    duration = minutes;

    var calValues = {
      'RUN': 11,
      'WALK': 4,
      'SWIM': 13
    };

    calBurned = calValues[name]! * minutes;
  }

  Exercise.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      duration = json['duration'] as int,
      calBurned = json['calBurned'] as int;

  Map<String, dynamic> toJson() => {
    'name' : name,
    'duration' : duration,
    'calBurned' : calBurned
  };

}