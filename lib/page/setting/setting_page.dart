import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        spacing: 10,
        crossAxisAlignment: .start,
        children: [
          Text(
            '- 网易云音乐 -',
            style: TextStyle(fontSize: 20),
          ),

          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(labelText: '端口号: 8686', contentPadding: EdgeInsets.all(10)),
            ),
          ),

          Wrap(
            spacing: 10,
            children: [
              FilledButton(
                onPressed: () {},
                child: Text('直接启动'),
              ),

              FilledButton(
                onPressed: () {},
                child: Text('生成快捷方式'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
