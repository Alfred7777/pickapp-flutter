import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SearchLoading extends StatelessWidget {
  final String query;

  const SearchLoading({
    @required this.query,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(
            top: 0.03 * screenSize.width,
          ),
          child: ShimmerLoading(
            height: 0.16 * screenSize.width,
            width: 0.9 * screenSize.width,
            time: 1400,
          ),
        );
      },
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double width;
  final double time;

  const ShimmerLoading({
    @required this.height,
    @required this.width,
    @required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[200],
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 0.04 * width),
              child: Container(
                height: height,
                width: height,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(0.5 * height)),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 0.015 * width),
                  child: Container(
                    height: 0.18 * height,
                    width: width - 0.04 * width - height,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0.015 * width),
                  child: Container(
                    height: 0.18 * height,
                    width: width - 0.04 * width - height,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0.015 * width),
                  child: Container(
                    height: 0.18 * height,
                    width: 0.4 * (width - 0.04 * width - height),
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
