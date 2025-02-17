import 'package:flutter/material.dart';

class PageBody extends StatelessWidget {
  const PageBody({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.pageNum,
    required this.color,
  }) : super(key: key);
  final String image;
  final String title;
  final String subtitle;
  final int pageNum;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Image.asset(
              image,
            ),
          ),
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 22),
              textAlign: TextAlign.center,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                subtitle,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(
            height: 90,
          ),
          Text(
            '$pageNum/3',
            style: Theme.of(context).textTheme.titleSmall,
          )
        ],
      ),
    );
  }
}
