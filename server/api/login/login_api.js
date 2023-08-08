const express = require('express');
const { json } = require('express/lib/response');
const router = express.Router();
const models = require('./data_models_login');
const data_models = new models();


router.post('/login',(req, res)=>{
    data_models.login(req, res);
});

router.post('/get_company_data',(req, res)=>{
    data_models.fetchCompanyData(req, res);
});

router.post('/check_version',(req, res)=>{
   res.json({version: '2.6'});
});

router.get('/',(req, res)=>{
    res.send('Hello');
});

module.exports = router;
