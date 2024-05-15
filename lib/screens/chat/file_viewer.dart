import 'package:foap/helper/imports/common_import.dart';

class FileViewer extends StatefulWidget {
  final String filePath;

  const FileViewer({Key? key, required this.filePath}) : super(key: key);

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  @override
  void initState() {
    // load();
    super.initState();
  }

  // load() async {
  //   var isInit = await FilePreview.tbsHasInit();
  //
  //   if (!isInit) {
  //     await FilePreview.initTBS();
  //     return;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
