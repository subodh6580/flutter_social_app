// import 'package:foap/helper/common_import.dart';
//
// class TrendingOnTwitter extends StatefulWidget {
//   const TrendingOnTwitter({Key? key}) : super(key: key);
//
//   @override
//   _TrendingOnTwitterState createState() => _TrendingOnTwitterState();
// }
//
// class _TrendingOnTwitterState extends State<TrendingOnTwitter> {
//   List<NewsModel> allNews =
//       NewsModel.dummyData().map((e) => NewsModel.fromJson(e)).toList();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BackNavigationBar(
//         title: trendingAtTwitter,
//         centerTitle: true,
//       ),
//       backgroundColor: AppTheme().secondaryBackgroundColor,
//       body: ListView.separated(
//           padding: const EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
//           itemBuilder: (BuildContext context, index) {
//             return TwitterCard1(
//               model: allNews[index],
//               itemCallBack: () {},
//               likeBtnCallBack: () {},
//               messageBtnCallBack: () {},
//               profileCallBack: () {},
//               shareBtnCallBack: () {},
//             ).ripple(() {
//               NavigationService.instance.navigateToRoute(MaterialPageRoute(
//                   builder: (context) => NewsFullDetail(model: allNews[index])));
//             });
//           },
//           separatorBuilder: (BuildContext context, index) {
//             return const SizedBox(
//               height: 20,
//             );
//           },
//           itemCount: allNews.length),
//     );
//   }
// }
