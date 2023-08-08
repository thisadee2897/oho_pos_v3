// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';

class ListProductWidget extends StatefulWidget {
  final dynamic productData;
  final bool? isCheckedAllProduct;
  final Function toggleSelectAll;
  final bool? isServed;
  const ListProductWidget({
    Key? key,
    required this.productData,
    this.isCheckedAllProduct,
    required this.toggleSelectAll,
    this.isServed,
  }) : super(key: key);

  @override
  _ListProductWidgetState createState() => _ListProductWidgetState();
}

class _ListProductWidgetState extends State<ListProductWidget> {
  bool isCheckedAllProduct = false;
  void toggleCheckbox() {
    setState(() {
      widget.productData.isChecked = !widget.productData.isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: widget.productData.orderdtStatusId == '2'
                    ? Colors.blue
                    : widget.productData.orderdtStatusId == '3'
                        ? Colors.orange
                        : widget.productData.orderdtStatusId == '4'
                            ? Colors.green
                            : const Color(0xffff616f),
                width: 8,
              ),
            ),
          ),
          child: ListTile(
            leading: Column(
              children: [
                Checkbox(
                  checkColor: Colors.white,
                  value:
                      widget.isCheckedAllProduct ?? widget.productData.checked,
                  onChanged: (bool? value) {
                    widget.toggleSelectAll();
                  },
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.productData.orderdtQty,
                      style: FontStyle().h2Style(0xff4fc3f7, 20),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              widget.productData.productName,
              style: const TextStyle(fontSize: 20),
            ),
            isThreeLine: true,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'หน่วยละ ${NumberFormat.currency(name: '').format(double.parse(widget.productData.orderdtSalePrice!))} บาท',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                widget.productData.topping.isNotEmpty
                    ? const Text(
                        'Topping',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )
                    : Container(),
                widget.productData.orderdtTypeId == "1"
                    ? Column(
                        children: List.generate(
                          widget.productData.topping.length,
                          (index) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${widget.productData.topping[index]['topping_name']} ${widget.productData.topping[index]['topping_qty']}'),
                              Text(
                                  ' - ราคา/ต่อหน่วย ${widget.productData.topping[index]['topping_price']} : รวม ${widget.productData.topping[index]['total_price_tpping']} บาท'),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          widget.productData.buffet.length,
                          (index) => Text(
                              'รายการอาหาร : ${widget.productData.buffet[index]['master_buffet_hd_name']}'),
                        ),
                      ),
                widget.productData.option.isNotEmpty
                    ? const Text(
                        'ตัวเลือกเพิ่มเติม',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      )
                    : Container(),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      widget.productData.option.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                              '${widget.productData.option![index]['option_group_name']} : ${widget.productData.option![index]['option_name']}'),
                        );
                      },
                    ),
                  ),
                ),
                widget.productData.orderdtRemark != 'ไม่มีหมายเหตุ'
                    ? Text(
                        'หมายเหตุ : ${widget.productData.orderdtRemark}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      )
                    : Container(),
                Text(
                  'เวลาที่สั่ง ${widget.productData.saveTime}',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  '${widget.productData.firstName} (${widget.productData.nickName})',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  '(${widget.productData.locationType})',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            trailing: Text(
              NumberFormat.currency(name: '').format(
                int.parse(widget.productData.orderdtNetAmnt),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
