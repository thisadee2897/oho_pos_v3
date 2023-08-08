import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:badges/badges.dart' as badges;
import 'package:oho_pos_v3/url_api/url_api_other.dart';
import 'package:provider/src/provider.dart';
import '../../CounterProvider.dart';
import 'busket_detail.dart';
import 'model_data_category_detail/autocomplete_product_data.dart';
import 'model_data_category_detail/model_data_products.dart';

class CategoryDetail extends StatefulWidget {
  final String? tableId;
  final String? orderId;
  final String? categoryId;
  final String? categoryName;
  final String? tableName;
  final String? branchId;
  final String? tableTypeId;
  final String? empId;
  final String? companyId;
  final bool? buffetActive;
  final bool? alacarteActive;
  final int? packageId;
  const CategoryDetail({
    Key? key,
    this.categoryId,
    this.categoryName,
    this.orderId,
    this.tableId,
    this.tableName,
    this.branchId,
    this.tableTypeId,
    this.empId,
    this.companyId,
    required this.buffetActive,
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  bool loading = true;
  List<ProductDataModel> productData = [];
  List<AutocompleteProductsModel> productDataAutocomplete = [];
  fetchProductData() async {
    final url = '${UrlApi().url}get_product_data';
    final body = jsonEncode({
      'category_id': widget.categoryId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      setState(() {
        productData = productModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<AutocompleteProductsModel>> autocompleteProducts(
      String query) async {
    final url = '${UrlApi().url}get_product_data';
    final body = jsonEncode({
      'category_id': widget.categoryId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    setState(() {
      loading = false;
      productDataAutocomplete = autocompleteProductModelFromJson(
        jsonEncode(response.data),
      );
    });
    AlertDialogs().progressDialog(context, loading);
    return productDataAutocomplete.where((products) {
      final productName = products.productName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return productName.contains(queryLower);
    }).toList();
  }

  @override
  void initState() {
    fetchProductData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'หมวดหมู่ ${widget.categoryName!}',
          style: FontStyle().h2Style(0xffFFFFFF, 20),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            label: const Text(
              'กลับ',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TypeAheadField<AutocompleteProductsModel>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                ),
                textFieldConfiguration: TextFieldConfiguration(
                  style: const TextStyle(fontFamily: 'Kanit'),
                  autofocus: false,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(29),
                      borderSide:
                          BorderSide(color: MyStyle().lightColor, width: 1),
                    ),
                    label: Text(
                      'ค้นหารายการอาหาร',
                      style: FontStyle().h2Style(0xff778899, 16),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                ),
                suggestionsCallback: autocompleteProducts,
                minCharsForSuggestions: 1,
                itemBuilder: (context, AutocompleteProductsModel suggestion) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '${UrlApiOther().apiShowProductImage}${suggestion.imgName}',
                        width: 50,
                        height: 50,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/a-la-carte.png',
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                    ),
                    title: Text(
                      '${suggestion.productName}',
                      style: FontStyle().h2Style(0xff000000, 16),
                    ),
                    subtitle: Text(
                      'ราคา ${NumberFormat.currency(name: '').format(double.parse(suggestion.productPrice))} บาท',
                      style: FontStyle().h2Style(0, 14),
                    ),
                  );
                },
                onSuggestionSelected: (AutocompleteProductsModel suggestion) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrderProduct(
                        productId: suggestion.productId,
                        productName: suggestion.productName,
                        productPrice: double.parse(suggestion.productPrice),
                        orderId: widget.orderId,
                        tableId: widget.tableId,
                        productGroupId: suggestion.productGroupId,
                        tableTypeId: widget.tableTypeId,
                        empId: widget.empId,
                        companyId: widget.companyId,
                        branchId: widget.branchId,
                      ),
                    ),
                  );
                },
                noItemsFoundBuilder: (contex) => Center(
                  child: Text('ไม่พบรายการอาหารที่ค้นหา',
                      style: FontStyle().h2Style(0, 20)),
                ),
              ),
            ),
            Expanded(
              child: productData.isNotEmpty
                  ? _buildListViewProducts()
                  : const Center(
                      child: Text(
                        'ไม่มีรายการอาหารในหมวดหมู่นี้',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BusketDetail(
                tableId: widget.tableId,
                tableName: widget.tableName,
                orderId: widget.orderId,
                tableTypeId: widget.tableTypeId,
                companyId: widget.companyId,
                branchId: widget.branchId,
                buffetActive: widget.buffetActive,
                alacarteActive: widget.alacarteActive,
                page: widget.packageId == 9 ? 2 : 1,
              ),
            ),
          );
        },
        child: badges.Badge(
          // shape: BadgeShape.circle,
          position: badges.BadgePosition.topEnd(),
          badgeContent: Text(
            '${context.watch<CounterProvider>().countProductInBusket}',
            style: FontStyle().h2Style(0xffFFFFFF, 14),
          ),
          // borderRadius: BorderRadius.circular(100),
          child: const Icon(Icons.shopping_basket),
        ),
      ),
    );
  }

  ListView _buildListViewProducts() {
    return ListView.builder(
      itemCount: productData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: ListTile(
            mouseCursor: null,
            hoverColor: Colors.blue[100],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderProduct(
                    productId: productData[index].productId,
                    productName: productData[index].productName,
                    productPrice:
                        double.parse(productData[index].productPrice!),
                    orderId: widget.orderId,
                    tableId: widget.tableId,
                    productGroupId: productData[index].productGropId,
                    tableTypeId: widget.tableTypeId,
                    empId: widget.empId,
                    companyId: widget.companyId,
                    branchId: widget.branchId,
                  ),
                ),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${UrlApiOther().apiShowProductImage}${productData[index].imgName}',
                width: 80,
                height: 80,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/images/a-la-carte.png',
                    width: 80,
                    height: 80,
                  );
                },
              ),
            ),
            title: Text(
              productData[index].productName!,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            subtitle: Text(
              'ราคา ${NumberFormat.currency(name: '').format(double.parse(productData[index].productPrice!))} บาท',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff778899),
              ),
            ),
            trailing: const Text(
              'เลือก',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        );
      },
    );
  }
}
