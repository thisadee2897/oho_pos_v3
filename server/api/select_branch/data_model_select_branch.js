const pool = require('../../connectdb.js');

class modelSelectBranch{
    fetchBranchData(req, res){
        const user_id = req.body.user_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT user_login_set_branch.master_branch_id, 
                            master_branch.master_branch_name,
                            master_branch.master_branch_prefix,
                            branch_type.master_branch_type_name,
                            branch_type.master_branch_type_id,
                            master_branch.master_branch_buffet_active as buffet_active,
                            master_branch_alacarte_active as alacarte_active,
                            role_group.role_group_id                
                    FROM security.user_login_set_branch AS user_login_set_branch
                    LEFT JOIN master_data.master_branch AS master_branch ON user_login_set_branch.master_branch_id = master_branch.master_branch_id
                    LEFT JOIN master_data.master_branch_type AS branch_type ON master_branch.master_branch_type_id = branch_type.master_branch_type_id
                    LEFT JOIN security.user_login_multi_role_group AS role_group ON user_login_set_branch.user_login_id = role_group.user_login_id
                    WHERE user_login_set_branch.user_login_id = ${user_id} 
                    AND user_login_set_branch.master_company_id = ${company_id}
                    AND master_branch.master_branch_type_id IN (1,2)
                    AND master_branch.master_branch_sale_flag = true
                    AND role_group.role_group_active = TRUE 
                    AND user_login_set_branch.master_branch_active_flag = true
                    AND role_group.master_company_id = ${company_id}
                    AND master_branch.master_branch_ho_flag = false
                    ORDER BY master_branch.master_branch_number             
                        `, 
        (err, result)=>{
            if(err){
                throw err;
            }
                res.json(result.rows);
            });
    }

    fetchDataAuthority(req, res){
        const user_id = req.body.user_id;
        const company_id = req.body.company_id;
        const menu_id = req.body.menu_id;
        pool.query(`SELECT role_group_id
                    FROM security.user_login_multi_role_group
                    WHERE user_login_id = ${user_id} 
                    AND master_company_id = ${company_id}
                    AND role_group_active = true
                        `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            pool.query(`SELECT "security"."fn_check_role_group_menu"(${company_id}, ${result.rows[0].role_group_id}, ${menu_id});
                        `, 
            (err, result)=>{
                if(err){
                    throw err;
                }
                res.json({status_menu: result.rows[0].fn_check_role_group_menu});
                });
            });
        
    }
}

module.exports = modelSelectBranch;