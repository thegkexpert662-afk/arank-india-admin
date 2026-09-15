class BannerModel {
  String id;
  String title;
  String subtitle;
  String buttonText;
  String buttonAction;
  String backgroundColor;
  String textColor;
  String openUrl;
  bool active;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonAction,
    required this.backgroundColor,
    required this.textColor,
    required this.openUrl,
    required this.active,
  });
}

List<BannerModel> dummyBanners = [
  BannerModel(
    id: "banner_1",
    title: "Practice Set",
    subtitle: "10000+ Questions",
    buttonText: "Start",
    buttonAction: "practice",
    backgroundColor: "blue",
    textColor: "white",
    openUrl: "",
    active: true,
  ),
  BannerModel(
    id: "banner_2",
    title: "Mock Test",
    subtitle: "Daily Mock",
    buttonText: "Start",
    buttonAction: "mock_test",
    backgroundColor: "green",
    textColor: "white",
    openUrl: "",
    active: true,
  ),
  BannerModel(
    id: "banner_3",
    title: "Live Test",
    subtitle: "Compete Live",
    buttonText: "Join",
    buttonAction: "live_test",
    backgroundColor: "red",
    textColor: "white",
    openUrl: "",
    active: false,
  ),
];