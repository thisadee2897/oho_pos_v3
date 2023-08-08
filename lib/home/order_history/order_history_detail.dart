// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/%E0%B8%B7number_format/number_format.dart';
import 'package:oho_pos_v3/%E0%B8%B7number_format/number_format_decimal.dart';
import 'package:oho_pos_v3/%E0%B8%B7number_format/number_format_down.dart';
import 'package:oho_pos_v3/%E0%B8%B7number_format/number_format_standard.dart';
import 'package:oho_pos_v3/%E0%B8%B7number_format/number_format_up.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:oho_pos_v3/url_api/url_api_other.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'model_data_order_history/model_data_order_history_detail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class OrderHistoryDetail extends StatefulWidget {
  final String orderId;
  final String orderDocuno;
  final String? branchId;
  final String? companyId;
  const OrderHistoryDetail({
    Key? key,
    required this.orderId,
    required this.orderDocuno,
    required this.branchId,
    required this.companyId,
  }) : super(key: key);

  @override
  _OrderHistoryDetailState createState() => _OrderHistoryDetailState();
}

class _OrderHistoryDetailState extends State<OrderHistoryDetail> {
  List<OrderHistoryDetailModel> orderHistoryDetail = [];
  List imageReceiptData = [];
  bool loading = true;
  int total = 0;
  double totalPrice = 0;
  double serviceChargeDi = 0;
  double serviceChargeTk = 0;
  double vat = 0;
  List serviceChargeData = [];
  final ImagePicker picker = ImagePicker();
  List<File> listImageShow = [];
  List<String> listImageUpload = [];
  File? image;
  var rounding;
  List<Uint8List> listImageShowInWeb = [];

  fetchProductDataInOrderHistory() async {
    final url = '${UrlApi().url}get_product_data_in_payment';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        orderHistoryDetail = orderHistoryDetailModelFromJson(
          jsonEncode(response.data),
        );
        loading = false;
      });
      fetchImageReceiptData();
      fetchServiceChargeData();
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchImageReceiptData() async {
    final url = '${UrlApi().url}get_image_receipt_data';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.statusCode == 200) {
      setState(() {
        imageReceiptData = response.data;
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  deleteImageReceiptData(attachfileId) async {
    final url = '${UrlApi().url}delete_image_receipt_data';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'orderhd_attach_file_id': attachfileId
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.statusCode == 200) {
      setState(() {
        fetchImageReceiptData();
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchServiceChargeData() async {
    final url = '${UrlApi().url}get_service_charge_data';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        serviceChargeData = response.data;
        loading = false;
      });
      if (serviceChargeData[0]['master_rounding_id'] == 1) {
        rounding = NumberFormatStandard().numberFormatStandard;
      } else if (serviceChargeData[0]['master_rounding_id'] == 2) {
        rounding = NumberFormatUp().numberFormatUp;
      } else if (serviceChargeData[0]['master_rounding_id'] == 3) {
        rounding = NumberFormatDown().numberFormatDown;
      } else {
        rounding = NumberFormatDecimal().numberFormatDecimal;
      }
      for (var item in orderHistoryDetail) {
        total += int.parse(item.orderdtQty!);
        totalPrice += rounding(double.parse(item.orderdtNetAmnt!));
        totalPrice += rounding(double.parse(item.totalPriceTopping!));
      }
      for (var item in orderHistoryDetail) {
        if (item.locationTypeId == 1) {
          serviceChargeDi += rounding(
            (double.parse(item.orderdtNetAmnt!) *
                (serviceChargeData[0]['di_rate'] / 100)),
          );
          for (var items in item.topping!) {
            serviceChargeDi += rounding(
              (items['total_price_topping'] *
                  (serviceChargeData[0]['di_rate'] / 100)),
            );
          }
        } else {
          serviceChargeTk += rounding(
            (double.parse(item.orderdtNetAmnt!) *
                (serviceChargeData[0]['tk_rate'] / 100)),
          );
          for (var items in item.topping!) {
            serviceChargeTk += rounding(
              (items['total_price_topping'] *
                  (serviceChargeData[0]['tk_rate'] / 100)),
            );
          }
        }
      }
      vat = (totalPrice + serviceChargeDi + serviceChargeTk) *
          (serviceChargeData[0]['master_vat_rate'] / 100);
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  // fetchBuffetInPayment() async {
  //   final url = '${UrlApi().url}get_buffet_in_payment';
  //   final body = jsonEncode({
  //     'orderhd_id': widget.orderId,
  //     'company_id': widget.companyId,
  //     'branch_id': widget.branchId
  //   });
  //   final response = await HttpRequests().httpRequest(url, body, context);
  //   List newData = [];
  //   if (response.data.isNotEmpty || response.statusCode == 200) {
  //     setState(() {
  //       newData = response.data;
  //       loading = false;
  //     });
  //     fetchProductDataInOrderHistory(newData);
  //   }
  //   await AlertDialogs().progressDialog(context, loading);
  // }

  uplaodReceiptImage() async {
    final url = UrlApiOther().apiUploadReceiptImage;
    // final url =
    //     '${UrlApi().url}upload_receipt_image'; //'${UrlApi().url}upload_receipt_image'
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'images': listImageUpload,
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.statusCode == 200) {
      listImageShow = [];
      listImageUpload = [];
      listImageShowInWeb = [];
      fetchImageReceiptData();
      loading = false;
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  openGallery() async {
    List<XFile>? picked = await picker.pickMultiImage(imageQuality: 30);
    setState(() {
      listImageShow = picked.map((e) => File(e.path)).toList();
      listImageUpload = picked
          .map(
            (e) => base64Encode(
              File(e.path).readAsBytesSync(),
            ).toString(),
          )
          .toList();
    });
  }

  openGalleryWeb() async {
    XFile? picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    Uint8List file = await picked!.readAsBytes();
    setState(() {
      listImageShowInWeb.add(file);
      listImageUpload.add(
        base64Encode(file).toString(),
      );
    });
  }

  openCamera() async {
    XFile? selectImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
    );
    if (selectImage != null) {
      Uint8List bytes = await selectImage.readAsBytes();
      var formatter = DateFormat('yyyy-MM-dd');
      String imageName =
          '${formatter.format(DateTime.now())}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await ImageGallerySaver.saveImage(bytes, quality: 100, name: imageName);
    }
    setState(() {
      listImageShow.add(
        File(selectImage!.path),
      );
      listImageUpload.add(
        base64Encode(
          File(selectImage.path).readAsBytesSync(),
        ).toString(),
      );
    });
  }

  @override
  void initState() {
    fetchProductDataInOrderHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'รายละเอียด',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            label: const Text(
              'ปิด',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              widget.orderDocuno,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Container(
                        child: screenWidth < 1500
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // SizedBox(
                                  //   width: 25,
                                  //   child: Text(
                                  //     '#',
                                  //     style:
                                  //         FontStyle().h2Style(0xff000000, 13),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      'รายการ',
                                      style:
                                          FontStyle().h2Style(0xff000000, 13),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'ราคา/หน่วย',
                                      style:
                                          FontStyle().h2Style(0xff000000, 13),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      'จำนวน',
                                      style:
                                          FontStyle().h2Style(0xff000000, 13),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      'รวม',
                                      style:
                                          FontStyle().h2Style(0xff000000, 13),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(240, 10, 190, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // SizedBox(
                                    //   width: 50,
                                    //   child: Text(
                                    //     '#',
                                    //     style: FontStyle()
                                    //         .h2Style(0xff000000, 20),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      width: 400,
                                      child: Text('รายการ',
                                          style: FontStyle()
                                              .h2Style(0xff000000, 20)),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Text('ราคา/หน่วย',
                                          style: FontStyle()
                                              .h2Style(0xff000000, 20)),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Text('จำนวน',
                                          style: FontStyle()
                                              .h2Style(0xff000000, 20)),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        'รวม',
                                        style: FontStyle()
                                            .h2Style(0xff000000, 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: orderHistoryDetail.length,
                              itemBuilder: (context, int index) {
                                return Container(
                                  child: screenWidth < 1500
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                child: ListTile(
                                                  dense: true,
                                                  visualDensity:
                                                      const VisualDensity(
                                                    horizontal: 0,
                                                    vertical: -4,
                                                  ),
                                                  minLeadingWidth: 2,
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        ' ${index + 1}.   ${orderHistoryDetail[index].productName!} ${orderHistoryDetail[index].orderdtTypeId == 1 ? '(${orderHistoryDetail[index].locationType!})' : ""}',
                                                        style: FontStyle()
                                                            .h2Style(
                                                                0xff000000, 12),
                                                      ),
                                                      orderHistoryDetail[index]
                                                                  .orderdtTypeId ==
                                                              2
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 20),
                                                              child: Text(
                                                                '(บุฟเฟต์)',
                                                                style: FontStyle()
                                                                    .h2Style(
                                                                        0xff000000,
                                                                        12),
                                                              ),
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: List.generate(
                                                      orderHistoryDetail[index]
                                                          .topping!
                                                          .length,
                                                      (indexs) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          '- ${orderHistoryDetail[index].topping![indexs]['topping_name']} ${NumberFormat.currency(name: '').format(orderHistoryDetail[index].topping![indexs]['total_price_topping']!)} บาท',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  NumberFormat.currency(
                                                          name: '')
                                                      .format(
                                                    double.parse(
                                                        orderHistoryDetail[
                                                                index]
                                                            .orderdtSalePrice!),
                                                  ),
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 12),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 40,
                                                child: Text(
                                                  orderHistoryDetail[index]
                                                      .orderdtQty!,
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 12),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Text(
                                                  NumberFormat.currency(
                                                          name: '')
                                                      .format(
                                                    double.parse(
                                                        orderHistoryDetail[
                                                                index]
                                                            .orderdtNetAmnt!),
                                                  ),
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              240, 20, 190, 0),
                                          child: SizedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 500,
                                                  child: ListTile(
                                                    dense: true,
                                                    visualDensity:
                                                        const VisualDensity(
                                                      horizontal: 0,
                                                      vertical: -4,
                                                    ),
                                                    title: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          ' ${index + 1}.   ${orderHistoryDetail[index].productName!} ${orderHistoryDetail[index].orderdtTypeId == 1 ? '(${orderHistoryDetail[index].locationType!})' : ""}',
                                                          style: FontStyle()
                                                              .h2Style(
                                                                  0xff000000,
                                                                  20),
                                                        ),
                                                        orderHistoryDetail[
                                                                        index]
                                                                    .orderdtTypeId ==
                                                                2
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            30),
                                                                child: Text(
                                                                  '(บุฟเฟต์)',
                                                                  style: FontStyle()
                                                                      .h2Style(
                                                                          0xff000000,
                                                                          20),
                                                                ),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                    subtitle: Column(
                                                      children: List.generate(
                                                        orderHistoryDetail[
                                                                index]
                                                            .topping!
                                                            .length,
                                                        (indexs) => ListTile(
                                                          dense: true,
                                                          visualDensity:
                                                              const VisualDensity(
                                                            horizontal: 0,
                                                            vertical: -4,
                                                          ),
                                                          title: Text(
                                                            '- ${orderHistoryDetail[index].topping![indexs]['topping_name']} ${NumberFormat.currency(name: '').format(orderHistoryDetail[index].topping![indexs]['topping_price'] * double.parse(orderHistoryDetail[index].orderdtQty!))} บาท',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    NumberFormat.currency(
                                                            name: '')
                                                        .format(
                                                      double.parse(
                                                          orderHistoryDetail[
                                                                  index]
                                                              .orderdtSalePrice!),
                                                    ),
                                                    style: FontStyle().h2Style(
                                                        0xff000000, 20),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    orderHistoryDetail[index]
                                                        .orderdtQty!,
                                                    style: FontStyle().h2Style(
                                                        0xff000000, 20),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    NumberFormat.currency(
                                                            name: '')
                                                        .format(
                                                      double.parse(
                                                          orderHistoryDetail[
                                                                  index]
                                                              .orderdtNetAmnt!),
                                                    ),
                                                    style: FontStyle().h2Style(
                                                        0xff000000, 20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: screenWidth < 1500
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 30, 0),
                              child: Column(
                                children: [
                                  serviceChargeData[0]['master_vat_group_id'] ==
                                          4
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'ทั้งหมด ${orderHistoryDetail.length} รายการ',
                                                ),
                                                Text(
                                                  'รวมค่าสินค้า ${NumberFormat.currency(name: '').format(totalPrice)}',
                                                ),
                                              ],
                                            ),
                                            (serviceChargeDi +
                                                        serviceChargeTk) >
                                                    0
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'ค่าบริการ',
                                                      ),
                                                      Text(
                                                        ' ${NumberFormat.currency(name: '').format(serviceChargeDi + serviceChargeTk)}',
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'รวมมูลค่าสินค้าและภาษีมูลค่าเพิ่ม 7%',
                                                ),
                                                Text(
                                                  ' ${NumberFormat.currency(name: '').format(totalPrice + (serviceChargeTk + serviceChargeDi))}',
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'รวมจำนวนสินค้า ${orderHistoryDetail.length} รายการ',
                                                ),
                                                Text(
                                                  'รวมค่าสินค้า ${NumberFormats().numberFormats(rounding(totalPrice))}',
                                                ),
                                              ],
                                            ),
                                            (serviceChargeDi +
                                                        serviceChargeTk) >
                                                    0
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        'ค่าบริการ',
                                                      ),
                                                      Text(
                                                        ' ${NumberFormats().numberFormats(rounding(serviceChargeDi + serviceChargeTk))}',
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'รวมมูลค่าสินค้าก่อนภาษีมูลค่าเพิ่ม 7%',
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding(totalPrice + (serviceChargeTk + serviceChargeDi)))}',
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                    'ภาษีมูลค่าเพิ่ม 7%'),
                                                Text(
                                                    ' ${NumberFormats().numberFormats(vat)}')
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'รวมทั้งสิน',
                                                  style: TextStyle(
                                                    color: Color(0xff4fc3f7),
                                                  ),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding((totalPrice + (serviceChargeTk + serviceChargeDi)) + vat))}',
                                                  style: const TextStyle(
                                                    color: Color(0xff4fc3f7),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                  Container(
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(241, 30, 311, 0),
                              child: Column(
                                children: [
                                  serviceChargeData[0]['master_vat_group_id'] ==
                                          4
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'รวมจำนวนสินค้า ${orderHistoryDetail.length} รายการ',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  'รวมค่าสินค้า ${NumberFormats().numberFormats(rounding(totalPrice))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'ค่าบริการ',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding(serviceChargeDi + serviceChargeTk))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'รวมมูลค่าสินค้าและภาษีมูลค่าเพิ่ม 7%',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding(totalPrice + (serviceChargeTk + serviceChargeDi)))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'รวมจำนวนสินค้า ${orderHistoryDetail.length} รายการ',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  'รวมค่าสินค้า ${NumberFormats().numberFormats(rounding(totalPrice))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'ค่าบริการ',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding(serviceChargeDi + serviceChargeTk))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'รวมมูลค่าสินค้าก่อนภาษีมูลค่าเพิ่ม 7%',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding(totalPrice + (serviceChargeTk + serviceChargeDi)))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'ภาษีมูลค่าเพิ่ม 7%',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(vat)}',
                                                  style: FontStyle()
                                                      .h2Style(0xff000000, 20),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'รวมทั้งสิน',
                                                  style: FontStyle()
                                                      .h2Style(0xff4fc3f7, 20),
                                                ),
                                                Text(
                                                  ' ${NumberFormats().numberFormats(rounding((totalPrice + (serviceChargeTk + serviceChargeDi)) + vat))}',
                                                  style: FontStyle()
                                                      .h2Style(0xff4fc3f7, 20),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                  Container(
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: screenWidth < 1500
                          ? Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageReceiptData.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            alignment: WrapAlignment.start,
                                            spacing: 5,
                                            runSpacing: 5,
                                            runAlignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            children: List.generate(
                                              imageReceiptData.length,
                                              (index) {
                                                return Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showImageFromUrl(
                                                            '${UrlApiOther().apiShowReceiptImage}${imageReceiptData[index]['orderhd_attachfile_name']}');
                                                      },
                                                      child: Image.network(
                                                        '${UrlApiOther().apiShowReceiptImage}${imageReceiptData[index]['orderhd_attachfile_name']}',
                                                        fit: BoxFit.cover,
                                                        height: 80,
                                                        width: 80,
                                                        errorBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Object
                                                                    exception,
                                                                StackTrace?
                                                                    stackTrace) {
                                                          return Column(
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/icon_error.png',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              const Text(
                                                                'ไม่พบรูปภาพ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: -10,
                                                      top: -12,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          confirmDelete(
                                                              imageReceiptData[
                                                                      index][
                                                                  'orderhd_attachfile_id']);
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Text(
                                    '${orderHistoryDetail[0].firstName} ${orderHistoryDetail[0].lastName} (ออกออเดอร์)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${orderHistoryDetail[0].firstNameReceive} ${orderHistoryDetail[0].lastNameReceive} (เก็บเงิน)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 20),
                                    child: Text(
                                      'หมายเหตุ: ${orderHistoryDetail[0].remark}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: defaultTargetPlatform ==
                                                  TargetPlatform.android
                                              ? 30
                                              : 0,
                                        ),
                                        child: FloatingActionButton(
                                          onPressed: () {
                                            if (defaultTargetPlatform ==
                                                TargetPlatform.android) {
                                              openGallery();
                                            } else {
                                              openGalleryWeb();
                                            }
                                          },
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      defaultTargetPlatform ==
                                              TargetPlatform.android
                                          ? FloatingActionButton(
                                              onPressed: () {
                                                openCamera();
                                              },
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 15),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.start,
                                      spacing: 5,
                                      runSpacing: 5,
                                      runAlignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: List.generate(
                                          listImageShow.length, (index) {
                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showImage(listImageShow[index]);
                                              },
                                              child: Image.file(
                                                listImageShow[index],
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 80,
                                              ),
                                            ),
                                            Positioned(
                                              right: -10,
                                              top: -12,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    listImageShow
                                                        .removeAt(index);
                                                    listImageUpload
                                                        .removeAt(index);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 15),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.start,
                                      spacing: 5,
                                      runSpacing: 5,
                                      runAlignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: List.generate(
                                          listImageShowInWeb.length, (index) {
                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showImageWeb(
                                                    listImageShowInWeb[index]);
                                              },
                                              child: Image.memory(
                                                listImageShowInWeb[index],
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                            Positioned(
                                              right: -10,
                                              top: -12,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    listImageShowInWeb
                                                        .removeAt(index);
                                                    listImageUpload
                                                        .removeAt(index);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: SizedBox(
                                        width: 200,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              listImageUpload.isEmpty
                                                  ? Colors.grey
                                                  : Colors.blue,
                                            ),
                                          ),
                                          onPressed: () {
                                            if (listImageUpload.isNotEmpty) {
                                              confirmUpload();
                                            }
                                            null;
                                          },
                                          child: const Text('อัพโหลด'),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(240, 20, 310, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageReceiptData.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            alignment: WrapAlignment.start,
                                            spacing: 5,
                                            runSpacing: 5,
                                            runAlignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            children: List.generate(
                                              imageReceiptData.length,
                                              (index) {
                                                return Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showImageFromUrl(
                                                            '${UrlApiOther().apiShowReceiptImage}${imageReceiptData[index]['orderhd_attachfile_name']}');
                                                      },
                                                      child: Image.network(
                                                        '${UrlApiOther().apiShowReceiptImage}${imageReceiptData[index]['orderhd_attachfile_name']}',
                                                        fit: BoxFit.cover,
                                                        height: 120,
                                                        width: 120,
                                                        errorBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Object
                                                                    exception,
                                                                StackTrace?
                                                                    stackTrace) {
                                                          return Column(
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/icon_error.png',
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              const Text(
                                                                'ไม่พบรูปภาพ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10),
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: -10,
                                                      top: -12,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          confirmDelete(
                                                              imageReceiptData[
                                                                      index][
                                                                  'orderhd_attachfile_id']);
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Text(
                                    '${orderHistoryDetail[0].firstName} ${orderHistoryDetail[0].lastName} (ออกออเดอร์)',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${orderHistoryDetail[0].firstNameReceive} ${orderHistoryDetail[0].lastNameReceive} (เก็บเงิน)',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'หมายเหตุ: ${orderHistoryDetail[0].remark}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FloatingActionButton(
                                        onPressed: () {
                                          openGalleryWeb();
                                        },
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 15),
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.start,
                                      spacing: 5,
                                      runSpacing: 5,
                                      runAlignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: List.generate(
                                          listImageShowInWeb.length, (index) {
                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showImageWeb(
                                                    listImageShowInWeb[index]);
                                              },
                                              child: Image.memory(
                                                listImageShowInWeb[index],
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                            Positioned(
                                              right: -10,
                                              top: -12,
                                              child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    listImageShowInWeb
                                                        .removeAt(index);
                                                    listImageUpload
                                                        .removeAt(index);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: SizedBox(
                                        width: 200,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              listImageUpload.isEmpty
                                                  ? Colors.grey
                                                  : Colors.blue,
                                            ),
                                          ),
                                          onPressed: () {
                                            if (listImageUpload.isNotEmpty) {
                                              confirmUpload();
                                            }
                                            null;
                                          },
                                          child: const Text('อัพโหลด'),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  showImageWeb(Uint8List image) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Image.memory(
            image,
            fit: BoxFit.cover,
            height: 500,
            width: 500,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Image.asset(
                'assets/images/icon_error.png',
                width: 50,
                height: 50,
              );
            },
          ),
        ],
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show();
  }

  confirmDelete(attachfileId) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Text(
            'ยืนยันการลบรูปภาพนี้',
            style: FontStyle().h2Style(0xff000000, 16),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(
            Radius.circular(20),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            Navigator.of(context).pop();
            deleteImageReceiptData(attachfileId);
          },
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }

  confirmUpload() {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Text(
            'ยืนยันการอัพโหลดรูปภาพ',
            style: FontStyle().h2Style(0xff000000, 16),
          ),
        ],
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(
            Radius.circular(20),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            Navigator.of(context).pop();
            uplaodReceiptImage();
          },
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }

  showImageFromUrl(String image) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Image.network(
            image,
            fit: BoxFit.cover,
            height: 500,
            width: 500,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Image.asset(
                'assets/images/icon_error.png',
                width: 50,
                height: 50,
              );
            },
          ),
        ],
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show();
  }

  showImage(File image) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Image.file(
            image,
            fit: BoxFit.cover,
            height: 500,
            width: 500,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show();
  }
}
