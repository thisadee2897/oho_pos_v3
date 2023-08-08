import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  int countProductInBusket;
  int countProductInOrder;
  List productInBusket = [];

  CounterProvider({
    this.countProductInBusket = 0,
    this.countProductInOrder = 0,
  });

  void setValueProductDataInBusket(List productDataInBusket) {
    productInBusket = productDataInBusket;
    notifyListeners();
  }

  void addValueCountProductInBusket(int sum) {
    countProductInBusket += sum;
    notifyListeners();
  }

  void resetCountProductInBusket() {
    countProductInBusket = 0;
  }

  void deleteCountProductInBusket(int delete) {
    countProductInBusket -= delete;
    notifyListeners();
  }

  void addValueCountProductInOrder(int sum) {
    countProductInOrder += sum;
    notifyListeners();
  }

  void resetCountProductInOrder() {
    countProductInOrder = 0;
  }

  void deleteCountProductInOrder(int delete) {
    countProductInOrder -= delete;
    notifyListeners();
  }

  void resetCountProduct() {
    countProductInOrder = 0;
    countProductInBusket = 0;
  }

  get getCountInBusket => countProductInBusket;
  get getCountInorder => countProductInOrder;
}
