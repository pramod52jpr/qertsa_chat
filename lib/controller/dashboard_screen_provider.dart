import 'dart:async';

import 'package:flutter/material.dart';

class DashboardScreenProvider with ChangeNotifier{
  int _selectedPageIndex=0;
  int get selectedPageIndex => _selectedPageIndex;
  void setSelectedPageIndex(int index){
    _selectedPageIndex = index;
    notifyListeners();
  }

  bool _showToast = false;
  bool get showToast => _showToast;
  void changeShowToast(){
    _showToast=true;
    Timer(Duration(seconds: 2),() {
      _showToast=false;
    },);
    notifyListeners();
  }
}