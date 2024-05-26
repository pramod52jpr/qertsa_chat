import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:qertsa/controller/chat_bottom_bar_provider.dart';
import 'package:qertsa/controller/dashboard_screen_provider.dart';
import 'package:qertsa/main.dart';
import 'package:qertsa/notification_services.dart';
import 'package:qertsa/view/presentation/account_screen.dart';
import 'package:qertsa/view/presentation/calls_screen.dart';
import 'package:qertsa/view/presentation/chat_list_screen.dart';
import 'package:qertsa/view/presentation/contact_screen.dart';
import 'package:qertsa/view/presentation/groups_screen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod : onActionReceiveMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
    Provider.of<ChatBottomBarProvider>(context,listen: false).accessContacts().then((value) {
      Provider.of<ChatBottomBarProvider>(context,listen: false).accessContacts();
    });
  }
  final List<Widget> pages=[
    ChatListScreen(),
    const GroupsScreen(),
    const Offstage(),
    const CallsScreen(),
    AccountScreen(),
  ];

  final List<String> pageTitle=[
    "Chats",
    "Groups",
    "",
    "Calls",
    "My Account",
  ];

  @override
  Widget build(BuildContext context) {
    final dashboardScreenProvider=Provider.of<DashboardScreenProvider>(context,listen: false);
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.square(60), child: Consumer<DashboardScreenProvider>(builder: (context, value, child) {
        return appBarWidget(pageTitle[value.selectedPageIndex],showBack: false,color: Color(0xFF0C63EE),titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold),
        );
      },),),
      body: WillPopScope(
        onWillPop: () async{
          if(dashboardScreenProvider.selectedPageIndex!=0){
            dashboardScreenProvider.setSelectedPageIndex(0);
            return false;
          }else if(dashboardScreenProvider.showToast == false){
            toast("Tap Again to Exit The App");
            dashboardScreenProvider.changeShowToast();
            return false;
          }
          return true;
        },
        child: Consumer<DashboardScreenProvider>(builder: (context, value, child) {
          return pages[value.selectedPageIndex];
        },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 3)],
          borderRadius: BorderRadius.circular(100)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Consumer<DashboardScreenProvider>(builder: (context, value, child) {
            return NavigationBar(
              height: 55,
              indicatorColor: Colors.grey.shade300,
              surfaceTintColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              shadowColor: Colors.grey,
              selectedIndex: value.selectedPageIndex,
              onDestinationSelected: (value) {
                dashboardScreenProvider.setSelectedPageIndex(value);
              },
              destinations: [
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.rocketchat,color: Colors.black54,size: 20,),
                  label: "Chats",
                  selectedIcon: FaIcon(FontAwesomeIcons.rocketchat,color:Color(0xFF0C63EE),size: 20),
                  tooltip: "Chats",
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups,color: Colors.black54,size: 25,),
                  label: "Groups",
                  selectedIcon: Icon(Icons.groups,color:Color(0xFF0C63EE),size: 25,),
                  tooltip: "Groups",
                ),
                InkWell(
                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                  onTap: () {
                    ContactScreen().launch(context,pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                  child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0C63EE),
                        // borderRadius: BorderRadius.circular(100)
                      ),
                      child: Center(child: FaIcon(FontAwesomeIcons.plus,color: Colors.white,size: 25,))),
                ),
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.phone,color:Colors.black54,size: 20,),
                  label: "Calls",
                  selectedIcon: FaIcon(FontAwesomeIcons.phone,color:Color(0xFF0C63EE),size: 20,),
                  tooltip: "Calls",
                ),
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.user,color: Colors.black54,size: 20,),
                  label: "Account",
                  selectedIcon: FaIcon(FontAwesomeIcons.user,color:Color(0xFF0C63EE),size: 20,),
                  tooltip: "Account",
                ),
              ],
            );
          },)
        ),
      ),
    );
  }
}
