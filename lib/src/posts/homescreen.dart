import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

/// Displays detailed information about a SampleItem.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Create Post'),
      ),
      body: const Center(
        child: TextFormFieldDemo(),
      ),
    );
  }
}

class TextFormFieldDemo extends StatefulWidget {
  const TextFormFieldDemo({Key? key}) : super(key: key);

  @override
  TextFormFieldDemoState createState() => TextFormFieldDemoState();
}

class CommentData {
  String? title = '';
}

class TextFormFieldDemoState extends State<TextFormFieldDemo>
    with RestorationMixin {
  CommentData comment = CommentData();
  var url = Uri.http('localhost:3000', '/posts');
  var urlTest = Uri.https('gorest.co.in', '/public/v2/users');

  late FocusNode _title;

  @override
  void initState() {
    super.initState();

    _title = FocusNode();
  }

  @override
  void dispose() {
    _title.dispose();

    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  String get restorationId => 'text_field_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateModeIndex, 'autovalidate_mode');
  }

  final RestorableInt _autoValidateModeIndex =
      RestorableInt(AutovalidateMode.disabled.index);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleSubmitted() async {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateModeIndex.value =
          AutovalidateMode.always.index; // Start validating on every change.
      showInSnackBar(
        "invalid comment: ${comment.title}",
      );
    } else {
      form.save();
      Response? response;
      Uri currentUrl;
      if (comment.title == "test") {
        currentUrl = urlTest;
      } else {
        currentUrl = url;
      }
      try {
        Map<String, String> headers = {
          "Content-Type": "application/json",
        };
        //var response1 = await http.post(url, body: comment.title);
        response = await http.get(currentUrl, headers: headers);

        showInSnackBar(
            "sent comment: ${comment.title}, response:${response.body}");
      } on Exception catch (e) {
        showInSnackBar("Error reaching $currentUrl  ${e.toString()}");
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "field required";
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return "OnlyAlphabeticalChars";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.values[_autoValidateModeIndex.value],
      child: Scrollbar(
        child: SingleChildScrollView(
          restorationId: 'text_field_demo_scroll_view',
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              sizedBoxSpace,
              TextFormField(
                restorationId: 'name_field',
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: "Comment Title (test)",
                  labelText: "NameField",
                ),
                onSaved: (value) {
                  comment.title = value;
                },
                validator: _validateName,
              ),
              sizedBoxSpace,
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmitted,
                  child: const Text("Submit"),
                ),
              ),
              sizedBoxSpace,
            ],
          ),
        ),
      ),
    );
  }
}
