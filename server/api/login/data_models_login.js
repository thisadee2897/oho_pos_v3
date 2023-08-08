const pool = require('../../connectdb.js');

class modelLogin{
    async login(req, res){
        let username = req.body.username;
        let password;
        pool.query(`SELECT pass_word FROM security.fn_encrypt_password('${req.body.password}')`, (err, result)=>{
            if(err){
                throw err;
            }
            password = result.rows[0].pass_word;
            pool.query(`SELECT user_login.user_login_id,
                                 user_login.emp_employeemasterid,
                                 user_login.user_name,
                                 user_login.role_group_id,
                                 user_login.master_company_id,
                                 emp_master.firstname,
                                 emp_master.lastname,
                                 emp_master.master_branch_id
                        FROM security.user_login AS user_login
                        INNER JOIN security.emp_employeemaster AS emp_master ON user_login.employeecode = emp_master.employeecode
                        INNER JOIN security.user_login_multi_role_group AS role_group ON user_login.user_login_id = role_group.user_login_id
                        WHERE user_login.user_name = '${username.trim()}' AND user_login.pass_word = '${password.trim()}'
                        AND user_login.user_active = true
                        LIMIT 1         
                        `, 
            (err, result)=>{
                if(err){
                    throw err;
                    
                }
                res.json(result.rows);
            }); 
        });
       
    }

    fetchCompanyData(req, res){
        const user_id = req.body.user_id;
        pool.query(`SELECT role_group.master_company_id,
                           master_company.master_company_name
                    FROM security.user_login_multi_role_group AS role_group
                    INNER JOIN master_data_all.master_company AS master_company ON role_group.master_company_id = master_company.master_company_id
                    WHERE  role_group.user_login_id = ${user_id}
                    AND role_group.role_group_active = TRUE             
                        `, 
        (err, result)=>{
            if(err){
                throw err;
            }
                res.json(result.rows);
            });
    }
}

module.exports = modelLogin;