import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/category_detail/category_detail.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product_for_search.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:oho_pos_v3/url_api/url_api_other.dart';
import 'model_data_category/autocomplete.dart';
import 'model_data_category/model_data_category.dart';

class Category extends StatefulWidget {
  final String? tableId;
  final String? tableName;
  final String? zoneName;
  final String? branchId;
  final String? tableTypeId;
  final String? empId;
  final String? orderId;
  final String? companyId;
  final bool? buffetActive;
  final bool? alacarteActive;
  final int? packageId;
  const Category({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.zoneName,
    required this.branchId,
    required this.tableTypeId,
    required this.empId,
    required this.orderId,
    required this.companyId,
    required this.buffetActive,
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<CategoryDataModel> categoryData = [];
  List<AllProductsModel> allProductdata = [];
  String? orderhdId;
  bool loading = true;
  int orderType = 0;

  fetchCategoryData() async {
    final url = '${UrlApi().url}get_category_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty && response.statusCode == 200) {
      setState(() {
        loading = false;
        categoryData = categoryModelFromJson(jsonEncode(response.data));
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<AllProductsModel>> autocompleteAllProducts(String query) async {
    final url = '${UrlApi().url}get_all_products_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty && response.statusCode == 200) {
      setState(() {
        loading = false;
        allProductdata = productAllModelFromJson(jsonEncode(response.data));
      });
    }

    AlertDialogs().progressDialog(context, loading);
    return allProductdata.where((products) {
      final productName = products.productName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return productName.contains(queryLower);
    }).toList();
  }

  @override
  void initState() {
    fetchCategoryData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TypeAheadField<AllProductsModel>(
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
                suggestionsCallback: autocompleteAllProducts,
                minCharsForSuggestions: 1,
                itemBuilder: (context, AllProductsModel suggestion) {
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
                onSuggestionSelected: (AllProductsModel suggestion) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrderProductForSearch(
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
              child: _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: categoryData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: ListTile(
            mouseCursor: null,
            hoverColor: Colors.blue[100],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetail(
                    categoryId: categoryData[index].categoryId,
                    categoryName: categoryData[index].categoryName,
                    orderId: widget.orderId,
                    tableId: widget.tableId,
                    tableName: widget.tableName,
                    branchId: widget.branchId,
                    tableTypeId: widget.tableTypeId,
                    empId: widget.empId,
                    companyId: widget.companyId,
                    buffetActive: widget.buffetActive,
                    alacarteActive: widget.alacarteActive,
                    packageId: widget.packageId,
                  ),
                ),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${UrlApiOther().apiShowProductGroupImage}${categoryData[index].imageGroupname}',
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
              categoryData[index].categoryName!,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            subtitle: Text(categoryData[index].productQty!,
                style: const TextStyle(fontSize: 20, color: Color(0xff778899))),
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
