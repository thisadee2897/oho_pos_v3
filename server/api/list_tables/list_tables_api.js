const express = require('express');
const router = express.Router();
const models = require('./data_model_list_tables');
const data_models = new models();



router.post('/get_zone_data',(req, res)=>{
    data_models.fetchZoneData(req, res);
});

router.post('/get_table_data',(req, res)=>{
    data_models.fetchTableData(req, res);
});

router.post('/create_order',(req, res)=>{
    data_models.createOrder(req, res);
});

router.post('/get_order_data',(req, res)=>{
    data_models.fetchOrderData(req, res);
});

router.post('/get_order_history_data',(req, res)=>{
    data_models.fetchHistoryOrderData(req, res);
});

router.post('/get_order_data_in_move_table',(req, res)=>{
    data_models.fetchOrderDataInMoveTable(req, res);
});

router.post('/autocomplete_empty_table',(req, res)=>{
    data_models.autocompleteEmptyTable(req, res);
});

router.post('/move_table',(req, res)=>{
    data_models.moveTable(req, res);
});

router.post('/get_order_restore_data',(req, res)=>{
    data_models.fetchRestoreOrderData(req, res);
});

router.post('/restore_order',(req, res)=>{
    data_models.restoreOrder(req, res);
});

router.post('/get_score_data',(req, res)=>{
    data_models.fetchScoreData(req, res);
});

router.post('/get_latest_foodlist_data',(req, res)=>{
    data_models.fetchLatestFoodListData(req, res);
});

router.post('/check_shift_open',(req, res)=>{
    data_models.checkShiftOpen(req, res);
});

router.post('/get_reason_move_table_data',(req, res)=>{
    data_models.fetchReasonMoveTableData(req, res);
});

router.post('/get_package_id',(req, res)=>{
    data_models.fetchPackegeId(req, res);
});

router.post('/cancel_table',(req, res)=>{
    data_models.cancelOrder(req, res);
});

router.post('/get_reason_change_status_order_data',(req, res)=>{
    data_models.fetchReasonChangeStatusOrderData(req, res);
});

router.post('/get_request_data',(req, res)=>{
    data_models.fetchRequestData(req, res);
});

router.post('/acknowledge_request',(req, res)=>{
    data_models.acknowledgeRequest(req, res);
});

router.post('/get_image_receipt_data',(req, res)=>{
    data_models.fetchImageReceiptData(req, res);
});

router.post('/delete_image_receipt_data',(req, res)=>{
    data_models.deleteImageReceiptData(req, res);
});

module.exports = router;