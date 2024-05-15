import 'package:foap/apiHandler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/competition_model.dart';

class CompetitionApi {
  static getCompetitions(
      {required int page,
      required Function(List<CompetitionModel>, APIMetaData) resultCallback}) {
    var url = '${NetworkConstantsUtil.getCompetitions}&page=$page';

    EasyLoading.show(status: loadingString.tr);
    ApiWrapper().getApi(url: url).then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        var items = result!.data['competition']['items'];

          resultCallback(
              List<CompetitionModel>.from(
                  items.map((x) => CompetitionModel.fromJson(x))),
              APIMetaData.fromJson(result.data['competition']['_meta']));

      }
    });
  }

  static getCompetitionsDetail(
      {required int id,
      required Function(CompetitionModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getCompetitionDetail;

    url = url.replaceFirst('{{id}}', id.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(CompetitionModel.fromJson(result!.data['competition']));
      }
    });
  }

  static joinCompetition(int competitionId,
      {required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.joinCompetition;

    EasyLoading.show(status: loadingString.tr);
    ApiWrapper().postApi(
        url: url,
        param: {"competition_id": competitionId.toString()}).then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        resultCallback();
      }
    });
  }
}
