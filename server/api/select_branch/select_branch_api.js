const express = require('express');
const router = express.Router();
const models = require('./data_model_select_branch');
const data_models = new models();


router.post('/get_branch_data',(req, res)=>{
    data_models.fetchBranchData(req, res);
});

router.post('/get_data_authority',(req, res)=>{
    data_models.fetchDataAuthority(req, res);
});

module.exports = router;