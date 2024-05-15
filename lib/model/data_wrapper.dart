import 'package:get/get.dart';

import 'api_meta_data.dart';

class DataWrapper {
  List<dynamic> items = [];
  int page = 1;
  RxBool haveMoreData = true.obs;
  RxBool isLoading = false.obs;
  RxInt totalRecords = 0.obs;

  DataWrapper();

  processCompletedWithData(APIMetaData metadata) {
    isLoading.value = false;
    haveMoreData.value = metadata.currentPage < metadata.pageCount;
    totalRecords.value = metadata.totalCount;
    isLoading.refresh();
    haveMoreData.refresh();
    totalRecords.refresh();
    page += 1;
  }
}
