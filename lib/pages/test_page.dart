import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedButton(
              text: 'Warning Dialog',
              color: Colors.orange,
              pressEvent: () {
                AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.topSlide,
                        showCloseIcon: false,
                        title: 'Dikkat!',
                        desc: 'Seçili Hisse Silinecektir.Onaylıyor Musunuz ?',
                        btnCancelText: 'İptal',
                        btnOkText: 'Sil',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {})
                    .show();
              },
            )
          ],
        ),
      ),
    );
  }
}
