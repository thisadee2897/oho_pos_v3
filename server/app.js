const express = require('express');
const cors = require('cors');
const app = express();
const loginRouter = require('./api/login/login_api');
const selectBranchRouter = require('./api/select_branch/select_branch_api');
const listTablesRouter = require('./api/list_tables/list_tables_api');
const mainMenuRouter = require('./api/main_menu/main_menu_api');

app.use(express.json());
app.use(cors());
app.use(loginRouter);
app.use(selectBranchRouter);
app.use(listTablesRouter);
app.use(mainMenuRouter);

module.exports = app;