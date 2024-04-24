import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_project/youtube/VedioPlayer.dart';

class YoutubeVideosScreen extends StatefulWidget {
  final String channelId;
  final String apiKey;

  const YoutubeVideosScreen(
      {Key? key, required this.channelId, required this.apiKey})
      : super(key: key);

  @override
  _YoutubeVideosScreenState createState() => _YoutubeVideosScreenState();
}

class _YoutubeVideosScreenState extends State<YoutubeVideosScreen> {
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  String? extractChannelId(String url) {
    RegExp regex = RegExp(r'@([a-zA-Z0-9_\-]+)');
    Match? match = regex.firstMatch(url);
    return match != null ? match.group(1) : null;
  }

  Future<List<dynamic>?> fetchVideos() async {
    String apiUrl =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCLa_4g63GJ96ouBvssbyLMw&maxResults=50&key=AIzaSyBT37F12mxmQMlnipNXNeL1zG9TKi2P61I';

    try {
      // Make the API request
      http.Response response = await http.get(Uri.parse(apiUrl));
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        videos = data['items'];

        for (var video in videos) {
          String title = video['snippet']['title'];
          String description = video['snippet']['description'];

          print('Title: $title');
          print('Description: $description');
          // Display other video details as needed
        }
        return videos;
      } else {
        // Handle API request error (e.g., print error message)
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle network or other errors (e.g., print error message)
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchVideos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (videos.length != 0) {
              return ListView.separated(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index + 1]['snippet'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                              videoUrl:
                                  videos[index]['id']?['videoId'].toString() ??
                                      ''),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                              height: 160,
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              width: double.infinity,
                              child: Image.network(
                                video['thumbnails']['medium']['url'],
                                fit: BoxFit.fill,
                              )),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.network(
                                  video['thumbnails']['default']['url']),
                            ),
                            title: Text(
                              video['title'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  video['channelTitle'],
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.green),
                                ),
                                Text(
                                  timeAgo(video['publishTime']).toString(),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  // ListTile(
                  //   leading: Image.network(video['thumbnails']['medium']['url']),
                  //   title: Text(video['title']),
                  //   subtitle: Text(video['channelTitle']),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => VideoPlayerScreen(
                  //             videoUrl:
                  //                 videos[index]['id']?['videoId'].toString() ??
                  //                     ''),
                  //       ),
                  //     );
                  //     // Handle video tap
                  //     // You can open the video in a WebView or use a video player package to play it.
                  //   },
                  // );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 15,
                  );
                },
              );
            } else {
              return Text('Try again after some time');
            }
          }),
    );
  }
}

String timeAgo(String timestamp) {
  // Parse the timestamp into a DateTime object
  DateTime publishTime = DateTime.parse(timestamp);

  // Calculate the time difference
  Duration difference = DateTime.now().difference(publishTime);

  // Convert the time difference to years, months, days, and hours
  int years = difference.inDays ~/ 365;
  int months = (difference.inDays % 365) ~/ 30;
  int days = (difference.inDays % 365) % 30;
  int hours = difference.inHours % 24;

  // Format the time difference
  if (years > 0) {
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  } else if (months > 0) {
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else if (days > 0) {
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  } else {
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }
}
