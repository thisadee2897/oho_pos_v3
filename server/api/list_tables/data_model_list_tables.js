const pool = require('../../connectdb.js');

class modelListTables{
    fetchZoneData(req, res){
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT master_order_zone_id,
                           master_order_zone_name
                      FROM master_data.master_order_zone
                      WHERE master_branch_id = ${branch_id} AND master_company_id = ${company_id}
                      AND master_order_zone_active = true
                      ORDER BY master_order_zone_id 
                      `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    fetchTableData(req, res, io){
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT * from "saledata"."fn_app_get_table_data"(${company_id}, ${branch_id});
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            // io.emit('table_data', result.rows);
            res.json(result.rows);
        });
    }

    createOrder(req, res){
        const zone_id = req.body.zone_id;
        const table_id = req.body.table_id;
        const num_of_customers = req.body.num_of_customers;
        const emp_id = req.body.emp_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        let print_qr_code = req.body.print_qr_code == true ? false : true;
        pool.query(`SELECT "saledata"."fn_report_check_shift_open"(${company_id}, ${branch_id}, now()::date);   
                    `, 
            (err, result)=>{
            if(err){
                throw err;
            }
                if(result.rows[0].fn_report_check_shift_open == true){
                    pool.query(`SELECT saledata.fn_app_create_orderhd(${company_id}, ${branch_id}, ${emp_id}, ${zone_id}, ${num_of_customers}, ${table_id}, ${print_qr_code});
                                `, 
                    (err, result)=>{
                        if(err){
                            throw err;
                        }
                        res.json({status: 1});
                    });   
                }else{
                    res.json({status: 0});
                }
        
            });
        
    }

    fetchOrderData(req, res){
        const table_id = req.body.table_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`SELECT orderhd.orderhd_id,
                           orderhd.orderhd_docuno                              
                    FROM saledata.orderhd
                    WHERE orderhd_status_id = 1
                    AND master_order_table_id = ${table_id}
                    AND master_company_id = ${company_id}
                    AND master_branch_id = ${branch_id}
                    AND orderhd_docudate::date >= (select shift_transaction_docudate::date 
                                                from saledata.shift_transaction
                                                where shift_transaction_status_id = 1
                                                and master_company_id = ${company_id}
                                                and master_branch_id = ${branch_id})
                      `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            if(result.rows.length == 0){
                pool.query(` UPDATE master_data.master_order_table
                             SET master_table_status_id = 1
                             WHERE master_order_table_id = ${table_id}
                             AND master_company_id = ${company_id}
                             AND master_branch_id = ${branch_id}
                            `, 
                (err, result)=>{
                    if(err){
                        throw err;
                    }
                    res.json([]);
                });
            }else{
                res.json(result.rows);
            }
        });
    }

    fetchHistoryOrderData(req, res){
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        const select_date = req.body.select_date;
        pool.query(`SELECT orderhd.orderhd_id, 
					orderhd.orderhd_docuno, 
					orderdt.orderhd_netamnt,
					orderhd.orderhd_customer_quantity,
					orderhd.savetime,
					string_agg('โต๊ะ '||ordertable.master_table_name  ,',')  master_table_name,
					orderzone.master_order_zone_name,
                    (select coalesce(array_to_json(array_agg(row_to_json(yy))), '[]')
                            from 
                            (
                                select x.orderhd_attachfile_id                                       
                                from saledata.orderhd_attachfile x                            
                                where x.orderhd_id = orderhd.orderhd_id
                                and x.orderhd_attachfile_active = true
                                and x.master_branch_id = ${branch_id}
                                and x.master_company_id = ${company_id}
                            )yy 
                        ) as images_file
					FROM saledata.orderhd orderhd
					left JOIN master_data.master_order_zone  orderzone ON orderhd.master_order_zone_id = orderzone.master_order_zone_id
					left JOIN saledata.orderhd_multitable  multitable ON orderhd.orderhd_id = multitable.orderhd_id
					left JOIN master_data.master_order_table  ordertable ON multitable.master_order_table_id = ordertable.master_order_table_id                
					left join (
					   SELECT x.orderhd_id,SUM(x.orderdt_netamnt)  as orderhd_netamnt
					   FROM saledata.orderdt  x
					   WHERE x.savetime::date = '${select_date}'
					   and x.orderdt_status_id IN (3,4) 
					   group by x.orderhd_id
						) orderdt on orderhd.orderhd_id = orderdt.orderhd_id
					WHERE orderhd.orderhd_status_id IN (2,4) 
					AND orderhd.master_branch_id = ${branch_id}
					AND orderhd.master_company_id = ${company_id} 
					AND orderhd.orderhd_docudate = '${select_date}'
					GROUP BY  orderhd.orderhd_id, orderzone.master_order_zone_name,orderdt.orderhd_netamnt
					ORDER BY  orderhd.orderhd_id DESC        
                      `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }


    fetchOrderDataInMoveTable(req, res){
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id; 
        pool.query(`SELECT orderhd.orderhd_id,
                             orderhd.orderhd_docuno,
                             orderhd_multitable.master_order_table_id,
                             master_order_zone.master_order_zone_name,
                             emp_employeemaster.firstname,
                             emp_employeemaster.lastname,
                             string_agg('โต๊ะ '||master_order_table.master_table_name  ,',')  master_table_name                     
                        FROM saledata.orderhd AS orderhd
                        INNER JOIN master_data.master_order_zone AS master_order_zone ON orderhd.master_order_zone_id = master_order_zone.master_order_zone_id
                        INNER JOIN security.emp_employeemaster AS emp_employeemaster ON orderhd.emp_employeemasterid = emp_employeemaster.emp_employeemasterid
                        INNER JOIN saledata.orderhd_multitable AS orderhd_multitable ON orderhd.orderhd_id = orderhd_multitable.orderhd_id
                        INNER JOIN master_data.master_order_table AS master_order_table ON orderhd_multitable.master_order_table_id = master_order_table.master_order_table_id
                        WHERE orderhd.orderhd_status_id = 1 
                        AND orderhd.master_branch_id = ${branch_id} 
                        AND orderhd.master_company_id = ${company_id}
                        AND orderhd.orderhd_docudate::Date = now()::date
                        AND master_order_table.master_order_table_active = true       
                        GROUP BY orderhd.orderhd_id, 
                        master_order_zone.master_order_zone_name, 
                        emp_employeemaster.firstname, 
                        emp_employeemaster.lastname, 
                        orderhd_multitable.master_order_table_id
                        ORDER BY orderhd.orderhd_id DESC
                        `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    autocompleteEmptyTable(req, res){
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT string_agg('โต๊ะ '||x.master_table_name  ,',')  master_table_name,
                           x.master_order_table_id
                    FROM master_data.master_order_table x
                    left join master_data.master_order_zone y on x.master_order_zone_id = y.master_order_zone_id 
                    WHERE x.master_branch_id = ${branch_id} 
                    AND x.master_company_id = ${company_id}
                    AND x.master_table_status_id = 1
                    AND x.master_order_table_active = true
                    AND y.master_order_zone_active = true
                    GROUP BY x.master_order_table_id 
                      `, 
        (err, result)=>{
            if(err){
                throw err;
            }
                res.json(result.rows);
            });
    }

    moveTable(req, res){
        const old_table_id = req.body.old_table_id;
        const new_table_id = req.body.new_table_id;
        const orderhd_id = req.body.orderhd_id;
        const emp_id = req.body.emp_id;
        const remark = req.body.remark;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const reason_move_table_id = req.body.reason_move_table_id;
        try{
           if(remark != undefined && remark != 'undefined'){
                pool.query(`SELECT orderhd_id
                            FROM saledata.orderhd
                            WHERE orderhd_docudate::date = now()::date
                            AND master_company_id = ${company_id}
                            AND master_branch_id = ${branch_id}
                            AND orderhd_status_id = 1
                            AND master_order_table_id = ${new_table_id}
                        `, 
                (err, result)=>{
                    if(err){
                        throw err;
                    }
                    if(result.rows.length == 0){
                        pool.query(`select saledata.fn_change_table(${orderhd_id}, ${new_table_id}, ${old_table_id}, ${emp_id}, '${remark}', ${company_id}, ${branch_id}, ${reason_move_table_id})     
                                `, 
                        (err, result)=>{
                            if(err){
                                throw err;
                            }
                            res.json({status: 1, message: 'success'});
                        });
                    }else{
                        res.json({status: 0, message: 'error'});
                    }                
                });
   
           }
        }catch(err){
            throw err;
        }
    }

    fetchRestoreOrderData(req, res){
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT orderhd.orderhd_id, 
                            orderhd.orderhd_docuno, 
                            orderhd.orderhd_netamnt,
                            orderhd.orderhd_customer_quantity,
                            orderhd.savetime,
                            string_agg('โต๊ะ '||ordertable.master_table_name  ,',')  master_table_name,
                            ordertable.master_order_table_id,
                            orderzone.master_order_zone_name
                    FROM saledata.orderhd orderhd
                    left JOIN master_data.master_order_zone  orderzone ON orderhd.master_order_zone_id = orderzone.master_order_zone_id
                    left JOIN saledata.orderhd_multitable  multitable ON orderhd.orderhd_id = multitable.orderhd_id
                    left JOIN master_data.master_order_table  ordertable ON multitable.master_order_table_id = ordertable.master_order_table_id
                    WHERE orderhd.orderhd_status_id = 2 
                    AND orderhd.master_branch_id = ${branch_id}
                    AND orderhd.master_company_id = ${company_id}
                    AND orderhd.orderhd_docudate::date = now()::date
                    GROUP BY  orderhd.orderhd_id, orderzone.master_order_zone_name, ordertable.master_order_table_id
                    ORDER BY  orderhd.orderhd_id DESC
                      `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    restoreOrder(req, res){
        const table_id = req.body.table_id;
        const orderhd_id = req.body.orderhd_id;
        const emp_id = req.body.emp_id;
        const remark = req.body.remark;
        const reason_change_status_order_id = req.body.reason_change_status_order_id;
        let status_id;
        try{
            if(remark != undefined && remark != 'undefined'){
                pool.query(`SELECT master_table_status_id
                     FROM master_data.master_order_table
                     WHERE master_order_table_id = ${table_id}
                    `, 
                (err, result)=>{
                    if(err){
                        throw err;
                    }
                    status_id = result.rows[0].master_table_status_id
                    if(status_id == 1){
                        pool.query(`INSERT INTO saledata.orderhd_change_status (
                                    orderhd_id, 
                                    orderhd_change_status_remark, 
                                    employee_change_status_id,
                                    master_reason_status_order_id
                                    ) VALUES (
                                        ${orderhd_id},
                                        (select master_reason_status_order_name from master_data.master_reason_status_order where master_reason_status_order_id = ${reason_change_status_order_id}),
                                        ${emp_id},
                                        ${reason_change_status_order_id}
                                    );
                        
                                    UPDATE master_data.master_order_table
                                    SET master_table_status_id = 3
                                    WHERE master_order_table_id = ${table_id}
                                    AND master_table_status_id = 1;
                                    
                                    UPDATE saledata.orderhd
                                    SET orderhd_status_id = 1
                                    WHERE orderhd_id = ${orderhd_id}
                                    AND orderhd_status_id = 2;
                                    `, 
                        (err, result)=>{
                            if(err){
                                throw err;
                            }
                            res.json([{'status': true}]);
                        });
                    }else{
                        res.json([{'status': false}]);
                    }
                });
            }
        }catch(err){
            throw err;
        }
        
    }

    fetchScoreData(req, res){
       const company_id = req.body.company_id;
       const phone_number = req.body.phone_number;
       const year = req.body.year;
        pool.query(`SELECT 
                    x.arcustomer_id, 
                    x.arcustomer_code, 
                    x.arcustomer_name,
                    x.point_quantity
                    FROM promotion.fn_report_point_sum('${year}', ${company_id},'${phone_number}') x        
                      `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    fetchLatestFoodListData(req, res){
        const company_id = req.body.company_id;
        const phone_number = req.body.phone_number;
        const year = req.body.year;
         pool.query(` SELECT x.salehd_docudate,
                        x.salehd_docuno,
                        x.saledt_listno,
                        x.saledt_master_product_billname 
                        FROM "promotion"."fn_report_last_products"(${company_id},'${phone_number}') x      
                       `, 
         (err, result)=>{
             if(err){
                 throw err;
             }
             res.json(result.rows);
         });
     }

     checkShiftOpen(req, res){
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`SELECT "saledata"."fn_report_check_shift_open"(${company_id}, ${branch_id}, now()::date);   
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json({status_shift_open: result.rows[0].fn_report_check_shift_open});
        });
     }

     fetchReasonMoveTableData(req, res){
        const company_id = req.body.company_id;
        pool.query(`SELECT * 
                    FROM "master_data"."master_reason_move_table"
                    WHERE master_reason_move_table_active = true
                    AND master_company_id = ${company_id}
                    order by master_reason_move_table_id
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            
            res.json(result.rows);
        });
    }

    fetchPackegeId(req, res){
        const company_id = req.body.company_id;
        pool.query(`SELECT package_id 
                    FROM master_data_all.master_company
                    WHERE master_company_id = ${company_id}
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }

            res.json(result.rows);
        });
    }

    cancelOrder(req, res){
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const table_id = req.body.table_id;
        pool.query(`update saledata.orderhd
                    set orderhd_status_id = 3
                    where orderhd_id = (
                                        select orderhd_id
                                        from saledata.orderhd
                                        where master_order_table_id = ${table_id}
                                        and master_company_id = ${company_id}
                                        and master_branch_id = ${branch_id}
                                        and orderhd_status_id = 1
                                        and orderhd_docudate::date >= (select shift_transaction_docudate::date 
                                                                            from saledata.shift_transaction
                                                                            where shift_transaction_status_id = 1
                                                                            and master_company_id = ${company_id}
                                                                            and master_branch_id = ${branch_id})
                                                                        );
                    
                    update master_data.master_order_table
                    set master_table_status_id = 1
                    where master_order_table_id = ${table_id};
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json({message: 1});
        });
    }

    fetchReasonChangeStatusOrderData(req, res){
        const company_id = req.body.company_id;
        pool.query(`select * 
                    from master_data.master_reason_status_order
                    where master_company_id = ${company_id}
                    and master_reason_status_order_active = true
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    fetchRequestData(req, res){
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`select x.orderhd_request_id,
                           x.orderhd_id,
                           y.master_request_name,
                           hd.master_table_name
                    from saledata.orderhd_request x
                    INNER JOIN master_data.master_request y ON x.master_request_id = y.master_request_id
                    LEFT JOIN (
                        SELECT hd.orderhd_id,
                               tb.master_table_name,
                               hd.orderhd_status_id
                        FROM saledata.orderhd hd
                        INNER JOIN master_data.master_order_table tb ON hd.master_order_table_id = tb.master_order_table_id
                        AND hd.master_company_id = ${company_id}
                        AND hd.master_branch_id = ${branch_id}
                        AND hd.orderhd_docudate::date = now()::date
                        AND hd.orderhd_status_id = 1
                    ) hd ON x.orderhd_id = hd.orderhd_id
                    where x.master_company_id = ${company_id}
                    and x.master_branch_id = ${branch_id}
                    and x.orderhd_request_confirm = false
                    and x.save_time::date = now()::date
                    and hd.orderhd_status_id = 1
                    GROUP BY y.master_request_name,
                             x.orderhd_request_confirm,
                             x.orderhd_id,
                             x.orderhd_request_id,
                             hd.master_table_name
                    ORDER BY x.orderhd_request_id DESC
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    acknowledgeRequest(req, res){
        const request_id = req.body.request_id;
        const orderhd_id = req.body.orderhd_id;
        pool.query(`UPDATE saledata.orderhd_request
                    SET orderhd_request_confirm = TRUE
                    WHERE orderhd_request_id = ${request_id}
                    AND orderhd_id = ${orderhd_id}
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json({message: 1});
        });
    }

    fetchImageReceiptData(req, res){
        const company_id = req.body.company_id;
        const orderhd_id = req.body.orderhd_id;
        const branch_id = req.body.branch_id;
        pool.query(`select orderhd_attachfile_id,
                           orderhd_attachfile_name 
                    from saledata.orderhd_attachfile
                    where orderhd_id = ${orderhd_id}
                    and master_branch_id = ${branch_id}
                    and master_company_id = ${company_id}
                    and orderhd_attachfile_active = true
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

    deleteImageReceiptData(req, res){
        const company_id = req.body.company_id;
        const orderhd_id = req.body.orderhd_id;
        const branch_id = req.body.branch_id;
        const orderhd_attach_file_id = req.body.orderhd_attach_file_id;
        pool.query(`update saledata.orderhd_attachfile
                    set orderhd_attachfile_active = false
                    where orderhd_attachfile_id = ${orderhd_attach_file_id}               
                    `, 
        (err, result)=>{
            if(err){
                throw err;
            }
            res.json(result.rows);
        });
    }

}

module.exports = modelListTables;