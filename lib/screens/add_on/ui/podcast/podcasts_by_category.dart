// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:foap/components/custom_texts.dart';
// import 'package:foap/controllers/podcast/podcast_streaming_controller.dart';
// import 'package:foap/helper/extension.dart';
// import 'package:foap/model/category_model.dart';
// import 'package:foap/screens/add_on/model/podcast_model.dart';
// import 'package:foap/screens/add_on/ui/podcast/podcast_host_detail.dart';
// import 'package:foap/theme/theme_icon.dart';
// import 'package:foap/util/app_config_constants.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
//
// class PodcastListByCategory extends StatefulWidget {
//   final PodcastCategoryModel category;
//
//   const PodcastListByCategory({Key? key, required this.category})
//       : super(key: key);
//
//   @override
//   State<PodcastListByCategory> createState() => _PodcastListByCategoryState();
// }
//
// class _PodcastListByCategoryState extends State<PodcastListByCategory> {
//   final PodcastStreamingController _podcastStreamingController = Get.find();
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _podcastStreamingController.getHostsList(
//           categoryId: widget.category.id, callback: () {});
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _podcastStreamingController.clearHosts();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AppColorConstants.backgroundColor,
//         body: NestedScrollView(
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return <Widget>[
//               SliverOverlapAbsorber(
//                   handle:
//                       NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//                   sliver: SliverSafeArea(
//                     top: false,
//                     sliver: SliverPadding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         sliver: SliverAppBar(
//                           backgroundColor: AppColorConstants.backgroundColor,
//                           expandedHeight: 200.0,
//                           floating: true,
//                           pinned: true,
//                           forceElevated: true,
//                           leading: ThemeIconWidget(
//                             ThemeIcon.backArrow,
//                             size: 18,
//                             color: AppColorConstants.iconColor,
//                           ).ripple(() {
//                             Get.back();
//                           }),
//                           flexibleSpace: FlexibleSpaceBar(
//                               centerTitle: true,
//                               title: BodyLargeText(widget.category.name,
//                                   // textScaleFactor: 1,
//                                   color: Colors.white),
//                               background: CachedNetworkImage(
//                                 imageUrl: widget.category.coverImage,
//                                 fit: BoxFit.cover,
//                                 height: 170,
//                                 width: 180,
//                               )),
//                         )),
//                   )),
//             ];
//           },
//           body: CustomScrollView(
//             slivers: [
//               // Next, create a SliverList
//               GetBuilder<PodcastStreamingController>(
//                   init: _podcastStreamingController,
//                   builder: (ctx) {
//                     return _podcastStreamingController.hosts.isEmpty
//                         ? SliverToBoxAdapter(
//                             child: SizedBox(
//                                 height: (Get.height / 1.5),
//                                 width: (Get.width),
//                                 child: const Center(
//                                     child: CircularProgressIndicator())))
//                         : SliverGrid(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               mainAxisSpacing: 2,
//                               crossAxisSpacing: 2,
//                               mainAxisExtent: 140,
//                             ),
//                             delegate: SliverChildBuilderDelegate(
//                               (BuildContext context, int index) {
//                                 HostModel podcastModel =
//                                     _podcastStreamingController.hosts[index];
//                                 return Card(
//                                     margin: const EdgeInsets.all(1),
//                                     child: CachedNetworkImage(
//                                       imageUrl: podcastModel.image,
//                                       fit: BoxFit.fitHeight,
//                                       height: 230,
//                                     ).round(10).ripple(() {
//                                       Get.to(() => PodcastHostDetail(
//                                             podcastModel: podcastModel,
//                                           ));
//                                     })).round(5);
//                               },
//                               childCount:
//                                   _podcastStreamingController.hosts.length,
//                             ),
//                           );
//                   })
//             ],
//           ),
//         ));
//   }
// }
