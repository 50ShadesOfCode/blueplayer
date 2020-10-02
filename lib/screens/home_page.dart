import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:blue_player/screens/bluetooth_app.dart';
import 'package:blue_player/screens/file_upload.dart';
import 'package:blue_player/screens/play.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      navBarStyle: NavBarStyle.style2,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.amber,
      ),
      popAllScreensOnTapOfSelectedTab: true,
    );
  }
}

List<Widget> _buildScreens() {
  return [AudioScreen(), BluetoothApp(), UploadFile()];
}

List<PersistentBottomNavBarItem> _navBarItems() {
  return [
    PersistentBottomNavBarItem(
      icon: Icon(CupertinoIcons.play_arrow),
      title: ("Player"),
      activeColor: Colors.red,
      inactiveColor: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(CupertinoIcons.bluetooth),
      title: ("Media Control"),
      activeColor: CupertinoColors.activeBlue,
      inactiveColor: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.cloud_upload),
        title: ("Upload"),
        activeColor: CupertinoColors.activeGreen,
        inactiveColor: CupertinoColors.systemGrey)
  ];
}
