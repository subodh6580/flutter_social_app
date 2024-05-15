// import 'package:flutter/material.dart';
//
// GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
//
// class NavigationService {
//   static NavigationService instance = NavigationService();
//
//   // Future<dynamic> navigateToReplacement(String _rn) {
//   //   return navigationKey.currentState.pushReplacementNamed(_rn);
//   // }
//   //
//   // Future<dynamic> navigateTo(String _rn) {
//   //   return navigationKey.currentState.pushNamed(_rn);
//   // }
//
//   // Future<dynamic> navigateToRoute(MaterialPageRoute _rn) {
//   //   return navigationKey.currentState.push(_rn);
//   // }
//
//   BuildContext getCurrentStateContext() {
//     return navigationKey.currentState!.context;
//   }
//
//   // Future<dynamic> navigateToRouteWithScale(ScaleRoute _rn) {
//   //   return navigationKey.currentState!.push(_rn);
//   // }
//
//   Future<dynamic> navigateToRoute(MaterialPageRoute _rn) {
//     return navigationKey.currentState!.push(_rn);
//   }
//
//   Future<dynamic> navigateToReplacementWithScale(MaterialPageRoute _rn) {
//     navigationKey.currentState!.popUntil((route) => route.isFirst);
//     return navigationKey.currentState!.pushReplacement(_rn);
//   }
//
//   goBack() {
//     return navigationKey.currentState!.pop();
//   }
// }
