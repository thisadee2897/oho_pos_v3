const express = require('express');
const router = express.Router();
const models = require('./data_model_main_menu');
const data_models = new models();


router.post('/get_category_data',(req, res)=>{
    data_models.fetchCategoryData(req, res);
});

router.post('/get_probuffet_data',(req, res)=>{
    data_models.fetchProbuffetData(req, res);
});

router.post('/get_product_inbuffet_data',(req, res)=>{
    data_models.fetchProductDataInBuffet(req, res);
});

router.post('/get_all_products_data',(req, res)=>{
    data_models.fetchAllProductsData(req, res);
});

router.post('/get_product_data',(req, res)=>{
    data_models.fetchProductData(req, res);
});

router.post('/get_remark_data',(req, res)=>{
    data_models.fetchRemarkData(req, res);
});

router.post('/get_location_type_data',(req, res)=>{
    data_models.fetchLocationTypeData(req, res);
});

router.post('/add_product_data',(req, res)=>{
    data_models.addProductData(req, res);
});

router.post('/get_product_data_in_busket',(req, res)=>{
    data_models.fetchProductDataInBusket(req, res);
});

router.post('/delete_product_data_in_busket',(req, res)=>{
    data_models.deleteProductDataInBusket(req, res);
});

router.post('/confirm_product_order',(req, res)=>{
    data_models.confirmProductOrder(req, res);
});

router.post('/get_remark_data_in_busket',(req, res)=>{
    data_models.fetchRemarkDataInBusket(req, res);
});

router.post('/get_location_type_data_in_busket',(req, res)=>{
    data_models.fetchLocationTypyDataInBusket(req, res);
});

router.post('/get_product_data_in_order',(req, res)=>{
    data_models.fetchProductDataInOrder(req, res);
});

router.post('/update_status_product_data',(req, res)=>{
    data_models.updateStatusProductData(req, res);
});

router.post('/update_product_qty',(req, res)=>{
    data_models.updateProductDataQty(req, res);
});

router.post('/get_product_data_in_payment',(req, res)=>{
    data_models.fetchProductDataInPayment(req, res);
});

router.post('/autocomplete_table_data',(req, res)=>{
    data_models.autocompleteTableData(req, res);
});

router.post('/move_product_data_all',(req, res)=>{
    data_models.moveProductDataAll(req, res);
});

router.post('/move_product_data_qty',(req, res)=>{
    data_models.moveProductDataQty(req, res);
});

router.post('/bill_check',(req, res)=>{
    data_models.billCheck(req, res);
});

router.post('/get_topping_data',(req, res)=>{
    data_models.fetchToppingData(req, res);
});

router.post('/add_product_data_in_buffet',(req, res)=>{
    data_models.addProductDataInBuffet(req, res);
});

router.post('/order_buffet',(req, res)=>{
    data_models.orderBuffet(req, res);
});

router.post('/get_order_buffet_data',(req, res)=>{
    data_models.fetchOrderbuffetData(req, res);
});

// router.post('/get_buffet_in_payment',(req, res)=>{
//     data_models.fetchBuffetInPayment(req, res);
// });

router.post('/get_orderdt_buffet_data',(req, res)=>{
    data_models.fetchOrderdtBuffetData(req, res);
});

router.post('/get_end_time_data',(req, res)=>{
    data_models.fetchEndTimeData(req, res);
});

router.post('/update_qty_product',(req, res)=>{
    data_models.updateProductQty(req, res);
});

router.post('/get_service_charge_data',(req, res)=>{
    data_models.fetchServiceChargeData(req, res);
});

router.post('/get_reason_cancel_data',(req, res)=>{
    data_models.fetchReasonCancelData(req, res);
});

router.post('/get_reason_move_order_data',(req, res)=>{
    data_models.fetchReasonMoveOrder(req, res);
});

router.post('/get_category_buffet_data',(req, res)=>{
    data_models.fetchCategoryBuffetData(req, res);
});

router.post('/get_all_product_inbuffet_data',(req, res)=>{
    data_models.fetchAllProductInBuffetData(req, res);
});


module.exports = router;