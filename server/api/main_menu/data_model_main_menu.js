const pool = require('../../connectdb.js');
const moment = require('moment');
const fs = require('fs-extra');

class modelMainMenu {

    fetchCategoryData(req, res) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT xx.master_product_group_id,
                    xx.master_product_group_name,
                    xx.master_product_group_image_name as image_group_name,
                    coalesce(yy.count_product,0) count_product
                    FROM master_data.master_product_group xx
                    LEFT JOIN 
                            (
                            SELECT product.master_product_group_id,
                            COUNT(product.master_product_group_id) count_product
                            FROM
                                (
                                SELECT 
                                master_product.master_product_id, 
                                case when coalesce(master_product_price.sale_active,true) then master_product.master_product_name_bill 
                                else '**หมด**'||  master_product.master_product_name_bill end AS master_product_name,
                                master_product_price.master_product_price1,
                                master_product.master_product_group_id
                                FROM master_data.master_product AS master_product
                                INNER JOIN master_data.master_product_price AS master_product_price ON master_product.master_product_id = master_product_price.master_product_id
                                INNER JOIN master_data.master_product_group AS master_product_group ON master_product.master_product_group_id = master_product_group.master_product_group_id
                                WHERE master_product_group.sale_active = true
                                and coalesce(master_product_group.master_product_group_buffet_flag, false) = false
                                AND master_product_price.master_branch_id = ${branch_id}
                                AND  master_product.master_company_id = ${company_id}
                                AND master_product_price.sale_active = true
                                AND master_product_group.master_product_group_alacarte_active = true
                                GROUP BY coalesce(master_product_price.sale_active,true),master_product.master_product_name, master_product.master_product_id, master_product_price.master_product_price1
                                ) product
                            GROUP BY product.master_product_group_id
                            ) yy 
                    ON xx.master_product_group_id = yy.master_product_group_id
                    where xx.sale_active = true
                    and coalesce(xx.master_product_group_buffet_flag, false) = false
                    and xx.master_product_group_type_id <> 3
                    and xx.master_product_group_alacarte_active = true
                    and xx.master_company_id = ${company_id}
                    and yy.master_product_group_id is not null
                    ORDER BY xx.master_product_group_list_no					  
                      `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);

            });
    }

    fetchProbuffetData(req, res,) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        const orderhd_id = req.body.orderhd_id;
        pool.query(`select xx.master_product_id,
                           x.master_buffet_hd_id,
                           x.master_buffet_hd_name,
                           yy.master_product_price1,
                           x.master_buffet_hd_image_name,
                           case when x.master_buffet_hd_limit_order_qty = 0 then true else false end as buffethd_order_infinity,
                           coalesce(z.buffethd_order_qty, 0) as buffethd_order_qty,
                           case when  coalesce(z.buffethd_order_qty, 0) <> 0 then 
                           (x.master_buffet_hd_limit_order_qty * coalesce(z.buffethd_order_qty, 0))
                           else x.master_buffet_hd_limit_order_qty end as master_buffet_hd_limit_order_qty,
                           y.count_product,
                           (coalesce(x.master_buffet_hd_limit_order_qty, 0) * coalesce(z.buffethd_order_qty, 0)) - (select coalesce(sum(odt.orderdt_qty), 0)
                                                                                            from saledata.orderdt odt
                                                                                            where odt.orderhd_id = ${orderhd_id}
                                                                                            and odt.orderdt_status_id IN (1, 3, 4)
                                                                                            and odt.orderdt_buffet_flag = false
                                                                                            and odt.master_buffet_hd_id = x.master_buffet_hd_id
                                                                                            )
                            as balanch_qty, 
                           (
                            select coalesce(array_to_json(array_agg(row_to_json(yy))), '[]')
                            from 
                            (
                                select xx.*                                       
                                from saledata.orderhd_buffet xx
                                left join master_data.master_buffet_hd yyy on xx.master_buffet_hd_id = yyy.master_buffet_hd_id
                                left join saledata.orderhd zz on xx.orderhd_id = zz.orderhd_id
                                left join saledata.orderdt dt on xx.orderhd_id = dt.orderhd_id and xx.master_buffet_hd_id = dt.master_buffet_hd_id
                                where xx.master_buffet_hd_id = x.master_buffet_hd_id
                                and xx.orderhd_id = ${orderhd_id}
                                and zz.orderhd_status_id = 1
                                and dt.orderdt_status_id IN (1, 3, 4)
                                and zz.orderhd_docudate::date = now()::date
                            )yy 
                        ) as order_buffet
                    from master_data.master_buffet_hd x
                    left join master_data.master_product zz on x.master_buffet_hd_id = zz.master_buffet_hd_id
                    left join master_data.master_product_price yy on zz.master_product_id = yy.master_product_id
                    left join (
                        select count(master_buffet_dt_id) as count_product,
                               master_buffet_hd_id
                        from master_data.master_buffet_dt
                        where master_buffet_dt_active = true
                        group by master_buffet_hd_id
                    ) y on x.master_buffet_hd_id = y.master_buffet_hd_id
                    left join (
                        select coalesce(sum(bf.buffethd_order_qty), 0) as buffethd_order_qty,
                               bf.master_buffet_hd_id
                        from saledata.orderhd_buffet bf
                        left join saledata.orderdt dt on bf.orderhd_id = dt.orderhd_id and bf.master_buffet_hd_id = dt.master_buffet_hd_id
                        where bf.orderhd_id = ${orderhd_id}
                        and dt.orderdt_status_id IN (1, 3, 4)
                        group by bf.master_buffet_hd_id
                    ) z on x.master_buffet_hd_id = z.master_buffet_hd_id
                    left join master_data.master_product xx on x.master_buffet_hd_id = xx.master_buffet_hd_id
                    where yy.master_branch_id = ${branch_id}
                    and yy.sale_active = true
                    and x.master_buffet_hd_active = TRUE
                    and xx.master_buffet_hd_id IS NOT NULL
                    and x.master_company_id = ${company_id}
                    AND (CASE WHEN x.master_buffet_hd_use_datetime_active = TRUE THEN
                        x.master_buffet_hd_startdate <= CURRENT_DATE AND x.master_buffet_hd_enddate >= CURRENT_DATE
                        AND x.master_buffet_hd_starttime <= CURRENT_TIME :: TIME (0) AND x.master_buffet_hd_endtime >= CURRENT_TIME :: TIME (0)
                    ELSE TRUE
                    END)
                    ORDER BY x.master_buffet_hd_id desc	  
                      `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);

            });
    }

    fetchProductDataInBuffet(req, res) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        const buffethd_id = req.body.buffethd_id;
        const orderhd_id = req.body.orderhd_id;
        const product_group_id = req.body.product_group_id;
        const order_qty = req.body.order_qty;
        pool.query(`select x.master_buffet_dt_id,
                           x.master_buffet_hd_id,
                           x.master_buffet_dt_product_id,
                           x.master_buffet_dt_barcode_code,
                           x.master_buffet_dt_barcode_name,
                           x.master_buffet_dt_unit_price,
                           x.master_buffet_dt_order_qty,
                           xx.master_product_image_name,
                           'ไม่มีหมายเหตุ' as remark,
                           true as print_bill_flag,
                           '[]'::json as option_item,
                           case when x.master_buffet_dt_order_qty = 0 then true else false end as order_infinity,
                           case when yy.orderdt_qty <> 0 then coalesce((x.master_buffet_dt_order_qty * ${order_qty}) - yy.orderdt_qty, 0)
                           else x.master_buffet_dt_order_qty * ${order_qty} end as balanch_orderdt_qty,
                           coalesce(zz.all_balanch_orderdt_qty, 0) as all_balanch_orderdt_qty,
                           0 as buffetdt_qty
                    from master_data.master_buffet_dt x
                    left join (
                        select coalesce(sum(orderdt_qty), 0) as orderdt_qty,
                               orderdt_master_product_id
                        from saledata.orderdt
                        where master_buffet_hd_id = ${buffethd_id}
                        and orderdt_status_id IN (1, 3, 4)
                        and orderdt_buffet_flag = false
                        and orderhd_id = ${orderhd_id}
                        group by orderdt_master_product_id
                    ) yy on x.master_buffet_dt_product_id = yy.orderdt_master_product_id
                    left join (
                        select coalesce(sum(orderdt_qty), 0) as all_balanch_orderdt_qty,
                               master_buffet_hd_id
                        from saledata.orderdt
                        where master_buffet_hd_id = ${buffethd_id}
                        and orderdt_status_id IN (1, 3, 4)
                        and orderhd_id = ${orderhd_id}
                        and orderdt_buffet_flag = false
                        group by master_buffet_hd_id
                    ) zz on x.master_buffet_hd_id = zz.master_buffet_hd_id
                    left join master_data.master_product xx on x.master_buffet_dt_product_id = xx.master_product_id
                    left join master_data.master_product_price pdp on xx.master_product_id = pdp.master_product_id and pdp.master_branch_id = ${branch_id}
                    where x.master_buffet_hd_id = ${buffethd_id}
                    and x.master_buffet_dt_active = true
                    and xx.sale_activeflag = true
                    and pdp.sale_active = true
                    and xx.master_product_group_id = ${product_group_id}
                      `,
            (err, result) => {
                if (err) {
                    throw err;
                }

                res.json(result.rows);

            });
    }

    fetchAllProductsData(req, res) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        try {
            if (branch_id != undefined && branch_id != 'undefined') {
                pool.query(`SELECT master_product.master_product_id,
                                   master_product.master_product_image_name,
                                   case when coalesce(master_product_price.sale_active,true) then master_product.master_product_name_bill 
                                   else '**หมด**'||  master_product.master_product_name_bill end AS master_product_name,
                                   master_product_price.master_product_price1,
                                   master_product.master_product_group_id                          
                            FROM master_data.master_product AS master_product
                            LEFT JOIN master_data.master_product_price AS master_product_price ON master_product.master_product_id = master_product_price.master_product_id
                            LEFT JOIN master_data.master_product_group AS master_product_group ON master_product.master_product_group_id = master_product_group.master_product_group_id
                            WHERE master_product_group.sale_active = TRUE
                            AND master_product_price.master_branch_id = ${branch_id}
                            AND master_product_price.sale_active = TRUE
                            AND master_product.sale_activeflag = true
                            AND master_product_group.master_product_group_alacarte_active = true
                            AND master_product.master_buffet_hd_id IS NULL
                            AND master_product.master_company_id = ${company_id}
                            GROUP BY master_product_price.sale_active,
                                     master_product.master_product_name, 
                                     master_product.master_product_id, 
                                     master_product_price.master_product_price1                                     
                             `,
                    (err, result) => {
                        if (err) {
                            throw err;
                        }
                        res.json(result.rows);
                    });
            }

        } catch (error) {
            throw error;
        }

    }

    fetchProductData(req, res) {
        const category_id = req.body.category_id;
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        try {
            if (branch_id != undefined && branch_id != 'undefined') {
                pool.query(`SELECT master_product.master_product_id,
                                  master_product.master_product_image_name,
							case when coalesce(master_product_price.sale_active,true) then master_product.master_product_name_bill 
							else '**หมด**'||  master_product.master_product_name_bill end AS master_product_name,
									 master_product_price.master_product_price1,
									 master_product.master_product_group_id                          
							FROM master_data.master_product AS master_product
							INNER JOIN master_data.master_product_price AS master_product_price ON master_product.master_product_id = master_product_price.master_product_id
							INNER JOIN master_data.master_product_group AS master_product_group ON master_product.master_product_group_id = master_product_group.master_product_group_id
							WHERE master_product_group.sale_active = true 
                            AND master_product.master_product_group_id = ${category_id}
							and  master_product_price.master_branch_id = ${branch_id}
                            AND master_product_price.sale_active = true
                            AND master_product.sale_activeflag = true
                            AND master_product.master_company_id = ${company_id}
							GROUP BY coalesce(master_product_price.sale_active,true),
                                    master_product.master_product_name, 
                                    master_product.master_product_id, 
                                    master_product_price.master_product_price1
                            ORDER BY master_product.master_product_group_id,
                                     master_product.orderby_group_id                               
							`,
                    (err, result) => {
                        if (err) {
                            throw err;
                        }
                        res.json(result.rows);
                    });
            }
        } catch (error) {
            throw error;
        }
    }

    fetchRemarkData(req, res) {
        const product_group_id = req.body.product_group_id;
        const product_id = req.body.product_id;
        const company_id = req.body.company_id;
        pool.query(`SELECT y.master_product_option_group_name,
                           y.master_product_option_group_id,
                            (
                                select coalesce(array_to_json(array_agg(row_to_json(yy))), '[]')
                                from 
                                (
                                    select xx.master_product_option_items_id as option_items_id,
                                           xx.master_product_option_items_name as option_items_name                                       
                                    from master_data.master_product_option yy
                                    left join master_data.master_product_option_items xx on yy.master_product_option_items_id = xx.master_product_option_items_id
                                    where yy.master_product_option_group_id = y.master_product_option_group_id
                                    and yy.master_product_id = ${product_id}
                                    and xx.master_product_option_items_active = true
                                    and yy.master_product_option_items_active = true                                
                                )yy 
                            ) as option_item        
                    FROM master_data.master_product_option x
                    left join master_data.master_product_option_group y on x.master_product_option_group_id = y.master_product_option_group_id
                    where x.master_product_id = ${product_id}
                    and y.master_product_option_group_active = true
                    and x.master_product_option_group_active = true
                    and x.master_company_id = ${company_id}
                    group by x.master_product_option_group_id,
                             y.master_product_option_group_name,
                             y.master_product_option_group_id,
                             x.list_no
                    order by x.list_no                
                    
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchLocationTypeData(req, res) {//ไม่ต้อง where company_id
        pool.query(`SELECT master_order_location_type_id,
                           master_order_location_type_name                 
                    FROM master_data.master_order_location_type
                    ORDER BY master_order_location_type_id            
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    addProductData(req, res) {
        const location_type = req.body.location_type;
        const print_receipt = req.body.print_receipt;
        const remark_text = req.body.remark_text;
        const product_id = req.body.product_id;
        const orderhd_id = req.body.orderhd_id;
        const product_price = req.body.product_price;
        const qty = req.body.qty;
        const total_price = req.body.total_price;
        const table_id = req.body.table_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const emp_id = req.body.emp_id;
        const toppings = JSON.stringify(req.body.toppings);
        const option = JSON.stringify(req.body.option);
        pool.query(`select saledata.fn_app_add_product_to_busket
                    (
                        ${company_id}, 
                        ${branch_id}, 
                        ${orderhd_id}, 
                        '${remark_text}', 
                        ${qty}, 
                        ${product_price}, 
                        ${total_price}, 
                        ${product_id},
                        ${table_id},
                        ${0},
                        ${emp_id},
                        '${toppings}',
                        '${option}',
                        ${print_receipt},
                        ${location_type}
                    );
                `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });

    }

    fetchProductDataInBusket(req, res) {
        const orderhd_id = req.body.order_id;
        const table_id = req.body.table_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`select x.orderdt_id::int, 
                            x.orderdt_master_product_id::int,
                            x.orderdt_qty::int,
                            x.orderdt_saleprice,
                            x.orderdt_netamnt,
                            x.master_product_group_remark_id::int,
                            x.master_order_location_type_id::int,
                            x.print_bill_flag,
                            x.orderdt_remark,
                            x.master_product_group_remark_name,
                            x.master_order_location_type_name,
                            x.master_product_name,
                            x.master_orderdt_type_id::int,
                            case when x.option is null then '[]' else x.option end,
                            COALESCE(x.total_price_topping, 0) AS total_price_topping,
                            case when x.topping is null then '[]' else x.topping end 
                        from 
                        (
                                SELECT orderdt.orderdt_id, 
                                orderdt.orderdt_master_product_id,
                                orderdt.orderdt_qty,
                                orderdt.orderdt_saleprice,
                                orderdt.orderdt_netamnt,
                                orderdt.master_product_group_remark_id,
                                orderdt.master_order_location_type_id,
                                orderdt.print_bill_flag,
                                orderdt.orderdt_remark,
                                orderdt.master_orderdt_type_id,
                                COALESCE(rem.master_product_group_remark_name,'ไม่มีหมายเหตุ') AS master_product_group_remark_name,
                                loty.master_order_location_type_name AS master_order_location_type_name,
                                pro.master_product_name_bill AS master_product_name,
                                (
                                    select array_to_json(array_agg(row_to_json(yy)))
                                    from 
                                    (
                                        select  yy.master_product_option_items_name as option_name,
                                                zz.master_product_option_group_name as option_group_name
                                        from saledata.orderdt_option xx
                                        left join master_data.master_product_option_items yy on xx.master_product_option_items_id = yy.master_product_option_items_id
                                        left join master_data.master_product_option_group zz on yy.master_product_option_group_id = zz.master_product_option_group_id 
                                        where xx.orderdt_id = orderdt.orderdt_id
                                        order by xx.orderdt_option_id DESC
                                    )yy 
                                ) as option,
                                (select sum(orderdt_netamnt)
                                    from saledata.orderdt
                                    where orderhd_id = ${orderhd_id}
                                    and  orderdt_master_table_id = ${table_id}
                                    and master_product_group_type_id = 2
                                    and orderdt_status_id = 1
                                ) as total_price_topping,
                                (
                                    select array_to_json(array_agg(row_to_json(yy)))
                                    from 
                                    (
                                        select  xx.orderdt_id,
                                                xx.orderdt_master_product_billname as topping_name,
                                                xx.orderdt_saleprice as topping_price,
                                                xx.orderdt_netamnt as total_price_tpping,
                                                xx.orderdt_qty as topping_qty
                                        from saledata.orderdt xx 
                                        where xx.orderdt_id_main = orderdt.orderdt_id
                                        and xx.orderhd_id = ${orderhd_id}
                                        order by xx.orderdt_id
                                    )yy 
                                ) as topping          
                                FROM saledata.orderdt AS orderdt
                                LEFT JOIN master_data.master_product AS pro ON orderdt.orderdt_master_product_id = pro.master_product_id
                                LEFT JOIN master_data.master_product_group_remark AS rem ON orderdt.master_product_group_remark_id = rem.master_product_group_remark_id
                                LEFT JOIN master_data.master_order_location_type AS loty ON orderdt.master_order_location_type_id = loty.master_order_location_type_id
                                WHERE orderdt.orderhd_id = ${orderhd_id} 
                                AND orderdt.orderdt_status_id = 1
                                AND pro.master_company_id = ${company_id}
                                AND orderdt.orderdt_master_table_id = ${table_id}
                                AND orderdt.master_product_group_type_id = 1
                                ORDER BY orderdt.orderdt_id DESC
                        )x              
                      `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);

            });
    }

    deleteProductDataInBusket(req, res) {
        const orderdt_id = req.body.orderdt_id;
        const orderhd_id = req.body.orderhd_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`UPDATE saledata.orderdt
                    SET orderdt_status_id = 2
                    WHERE orderdt_id = ${orderdt_id}
                    AND orderhd_id = ${orderhd_id}
                    AND orderdt_status_id = 1;

                    UPDATE saledata.orderdt
                    SET orderdt_status_id = 2
                    WHERE orderdt_id_main = ${orderdt_id}
                    AND orderhd_id = ${orderhd_id}
                    AND orderdt_status_id = 1;
                    
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json({ message: 'success' });
            });

        // UPDATE saledata.orderhd
        // SET orderhd_netamnt = (SELECT coalesce(SUM(orderdt_netamnt),0) as sum_orderdt_netamnt 
        //                         FROM saledata.orderdt 
        //                         WHERE orderhd_id = ${orderhd_id}
        //                         AND orderdt_status_id IN (1,3,4)
        //                         )
        // WHERE orderhd_id = ${orderhd_id}
        // AND master_company_id = ${company_id}
        // AND master_branch_id = ${branch_id}     
    }

    confirmProductOrder(req, res) {
        const orderhd_id = req.body.orderhd_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const orderdt_data = JSON.stringify(req.body.orderdt_data);
        pool.query(`select saledata.fn_app_oho_pos_confirm_order(${company_id}, ${branch_id}, ${orderhd_id}, '${orderdt_data}');
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json({ message: 1 });
            });
    }

    fetchRemarkDataInBusket(req, res) {//ไม่ต้อง where company_id
        pool.query(`SELECT master_product_group_remark_id,
                            master_product_group_remark_name                 
                    FROM master_data.master_product_group_remark
                    ORDER BY master_product_group_remark_id            
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchLocationTypyDataInBusket(req, res) {//ไม่ต้อง where company_id
        pool.query(`SELECT master_order_location_type_id,
                                master_order_location_type_name                 
                        FROM master_data.master_order_location_type
                        ORDER BY master_order_location_type_id            
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchProductDataInOrder(req, res) {
        const orderhd_id = req.body.orderhd_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`select x.orderdt_id, 
                    x.orderdt_master_product_id,
                    x.orderdt_qty,
                    x.orderdt_saleprice,
                    x.orderdt_netamnt,
                    x.orderdt_status_id,
                    x.orderdt_remark,
                    x.employee_id,
                    x.firstname,
                    x.nickname,
                    x.master_product_name,
                    x.remark_name,
                    x.master_order_location_type_name,
                    x.savetime,
                    x.master_orderdt_type_id,
                    COALESCE(x.total_price_topping, 0) AS total_price_topping,
                    case when x.topping is null then '[]' else x.topping end,
                    case when x.buffet is null then '[]' else x.buffet end,
                    case when x.option is null then '[]' else x.option end
                    from (
                        SELECT orderdt.orderdt_id, 
                                orderdt.orderdt_master_product_id,
                                orderdt.orderdt_qty,
                                orderdt.orderdt_saleprice,
                                orderdt.orderdt_netamnt,    
                                orderdt.orderdt_status_id,
                                orderdt.orderdt_remark,
                                orderdt.employee_id,
                                orderdt.master_orderdt_type_id,
                                y.master_order_location_type_name,
                                emp_employeemaster.firstname,
                                emp_employeemaster.nickname,
                                master_product.master_product_name_bill AS master_product_name,
                                master_product_group_remark.master_product_group_remark_name as remark_name,
                                to_char(orderdt.savetime,'HH24:mi') || ' ผ่านไป : '||case when to_char(now() - orderdt.savetime,'HH24')::Integer != 0 
                                then to_char(now() - orderdt.savetime,'HH24')::Integer||' ชม.' else '' end
                                ||to_char(now() - orderdt.savetime,'mi')::integer || ' นาที' savetime,
                                (select sum(orderdt_netamnt)
                                    from saledata.orderdt
                                    where orderhd_id = ${orderhd_id}
                                    and master_product_group_type_id = 2
                                    and orderdt_status_id in (3,4)
                                ) as total_price_topping,
                                (
                                    select array_to_json(array_agg(row_to_json(yy)))
                                    from 
                                    (
                                        select xx.orderdt_master_product_billname as topping_name,
                                            xx.orderdt_saleprice as topping_price,
                                            xx.orderdt_netamnt as total_price_tpping,
                                            xx.orderdt_qty as topping_qty
                                        from saledata.orderdt xx 
                                        where xx.orderdt_id_main = orderdt.orderdt_id
                                        and xx.orderhd_id = ${orderhd_id}
                                        order by xx.orderdt_id
                                    )yy 
                                 ) as topping,
                                 (
                                    select array_to_json(array_agg(row_to_json(yy)))
                                    from 
                                    (
                                        select xx.master_buffet_hd_name,
                                               xx.master_buffet_hd_net_amount,
                                               sum(zz.buffethd_order_qty) as buffethd_order_qty,
                                               coalesce(xx.master_buffet_hd_net_amount) * coalesce(sum(zz.buffethd_order_qty)) as total_price 
                                        from master_data.master_buffet_hd xx
                                        left join saledata.orderhd_buffet zz on xx.master_buffet_hd_id = zz.master_buffet_hd_id 
                                        where xx.master_buffet_hd_id = orderdt.master_buffet_hd_id
                                        and zz.orderhd_id = ${orderhd_id}
                                        group by xx.master_buffet_hd_name,
                                                 xx.master_buffet_hd_net_amount,
                                                 xx.master_buffet_hd_id
                                        order by xx.master_buffet_hd_id
                                    )yy 
                                 ) as buffet,
                                 (
                                    select array_to_json(array_agg(row_to_json(yy)))
                                    from 
                                    (
                                        select  yy.master_product_option_items_name as option_name,
                                                zz.master_product_option_group_name as option_group_name
                                        from saledata.orderdt_option xx
                                        left join master_data.master_product_option_items yy on xx.master_product_option_items_id = yy.master_product_option_items_id
                                        left join master_data.master_product_option_group zz on yy.master_product_option_group_id = zz.master_product_option_group_id 
                                        where xx.orderdt_id = orderdt.orderdt_id
                                        order by xx.orderdt_option_id DESC
                                    )yy 
                                ) as option
                    FROM saledata.orderdt AS orderdt
                    LEFT JOIN master_data.master_product AS master_product ON orderdt.orderdt_master_product_id = master_product.master_product_id
                    LEFT JOIN security.emp_employeemaster AS emp_employeemaster ON orderdt.employee_id = emp_employeemaster.emp_employeemasterid
                    LEFT JOIN master_data.master_product_group_remark AS master_product_group_remark ON orderdt.master_product_group_remark_id = master_product_group_remark.master_product_group_remark_id
                    LEFT JOIN master_data.master_order_location_type y ON orderdt.master_order_location_type_id = y.master_order_location_type_id
                    WHERE orderdt.orderhd_id = ${orderhd_id}
                    AND master_product.master_company_id = ${company_id}
                    AND orderdt.orderdt_status_id IN (3,4,5)
                    AND orderdt.master_product_group_type_id = 1
                    ORDER BY orderdt.orderdt_id DESC
                    ) x  
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    updateStatusProductData(req, res) {
        const orderdt_id = req.body.orderdt_id;
        const status_id = req.body.status_id;
        const emp_id_cancel = req.body.emp_id_cancel;
        const remark = req.body.remark;
        const reason_cancel_id = req.body.reason_cancel_id;
        const orderhd_id = req.body.orderhd_id;
        try {
            if (reason_cancel_id != undefined && reason_cancel_id != 'undefined') {
                pool.query(`SELECT x.orderhd_status_id
                                FROM saledata.orderhd x                           
                                WHERE x.orderhd_id = ${orderhd_id}                                    
                                `,
                    (err, result) => {
                        if (err) {
                            throw err;
                        }
                        if (result.rows[0].orderhd_status_id == 1) {
                            if (status_id == 5) {
                                pool.query(`insert into saledata.orderdt_cancel(
                                            orderdt_id, 
                                            orderdt_cancel_remark, 
                                            employee_cancel_id,
                                            orderdt_cancel_qty,
                                            orderhd_id,
                                            master_reason_cancel_order_id
                                            )
                                            values(
                                            ${orderdt_id},
                                            (select master_reason_cancel_order_name from master_data.master_reason_cancel_order where master_reason_cancel_order_id = ${reason_cancel_id}),
                                            ${emp_id_cancel},
                                            (select orderdt_qty from saledata.orderdt where orderdt_id = ${orderdt_id}),
                                            (select orderhd_id from saledata.orderdt where orderdt_id = ${orderdt_id}),
                                            ${reason_cancel_id}
                                            );
                                                
                                            UPDATE saledata.orderdt
                                            SET orderdt_status_id = ${status_id},
                                            employee_cancel_id = ${emp_id_cancel},
                                            cancel_time = now()
                                            WHERE orderdt_id = ${orderdt_id}
                                            and orderhd_id = ${orderhd_id};

                                            UPDATE saledata.orderdt
                                            SET orderdt_status_id = ${status_id},
                                            employee_cancel_id = ${emp_id_cancel},
                                            cancel_time = now()
                                            WHERE orderdt_id_main = ${orderdt_id}
                                            and orderhd_id = ${orderhd_id};
                                                                                   
                                            UPDATE saledata.orderhd
                                            SET orderhd_netamnt = orderhd_netamnt - (SELECT orderdt_qty * orderdt_saleprice as sum_orderdt_netamnt 
                                                                                    FROM saledata.orderdt
                                                                                    where orderdt_id = ${orderdt_id}
                                                                                    and orderhd_id = ${orderhd_id}
                                                                                    )
                                            WHERE orderhd_id = ${orderhd_id};

                                            UPDATE saledata.orderhd
                                            SET orderhd_netamnt = orderhd_netamnt - (SELECT COALESCE(sum(orderdt_netamnt), 0) as sum_orderdt_topping  
                                                                                    FROM saledata.orderdt
                                                                                    where orderdt_id_main = ${orderdt_id}
                                                                                    and orderhd_id = ${orderhd_id}
                                                                                    )
                                            WHERE orderhd_id = ${orderhd_id};
                                            `,
                                    (err, result) => {
                                        if (err) {
                                            throw err;
                                        }
                                        res.json({ message: true });
                                    });

                            } else {
                                pool.query(`UPDATE saledata.orderdt
                                            SET orderdt_status_id = ${status_id},
                                                served_time = now()
                                            WHERE orderdt_id = ${orderdt_id}
                                            and orderhd_id = ${orderhd_id};

                                            UPDATE saledata.orderdt
                                            SET orderdt_status_id = ${status_id},
                                                served_time = now()
                                            WHERE orderdt_id_main = ${orderdt_id}
                                            and orderhd_id = ${orderhd_id};
                                            `,
                                    (err, result) => {
                                        if (err) {
                                            throw err;
                                        }
                                        res.json({ message: true });
                                    });
                            }
                        } else {
                            res.json({ message: false });
                        }

                    });
            }

        } catch (error) {
            throw error;
        }

    }


    updateProductDataQty(req, res) {
        const orderdt_id = req.body.orderdt_id;
        const emp_id_cancel = req.body.emp_id_cancel;
        const qty = req.body.qty;
        const remark = req.body.remark;
        const reason_cancel_id = req.body.reason_cancel_id;
        try {
            if (remark != undefined && remark != 'undefined') {
                pool.query(`UPDATE saledata.orderdt
                            SET orderdt_qty = orderdt_qty - ${qty},
                                orderdt_cancel_qty = orderdt_cancel_qty + ${qty},
                                orderdt_netamnt = orderdt_netamnt - orderdt_saleprice * ${qty} 
                                WHERE orderdt_id = ${orderdt_id};

                            UPDATE saledata.orderhd
                            SET orderhd_netamnt = orderhd_netamnt - (SELECT ${qty} * orderdt_saleprice as sum_orderdt_netamnt
                                                                    FROM saledata.orderdt
                                                                    where orderdt_id = ${orderdt_id})
                            WHERE orderhd_id = (select y.orderhd_id
                                                from saledata.orderdt x
                                                left join saledata.orderhd y on x.orderhd_id = y.orderhd_id
                                                where x.orderdt_id = ${orderdt_id});

                            insert into saledata.orderdt_cancel(
                            orderdt_id,
                            orderdt_cancel_remark, 
                            employee_cancel_id, 
                            orderdt_cancel_qty,
                            orderhd_id,
                            master_reason_cancel_order_id
                            )
                            values(
                                ${orderdt_id},
                                (select master_reason_cancel_order_name from master_data.master_reason_cancel_order where master_reason_cancel_order_id = ${reason_cancel_id}),
                                ${emp_id_cancel},
                                ${qty},
                                (select orderhd_id from saledata.orderdt where orderdt_id = ${orderdt_id}),
                                ${reason_cancel_id}
                            );
                            `,
                    (err, result) => {
                        if (err) {
                            throw err;
                        }
                        res.json({ message: 'success' });
                    });
            }

        } catch (error) {
            throw error;
        }

    }

    fetchProductDataInPayment(req, res) {
        const orderhd_id = req.body.orderhd_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`select * from saledata.fn_apppos_orderdt_topping(${company_id}, ${orderhd_id})            
                            `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    autocompleteTableData(req, res) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        const table_id = req.body.table_id;
        pool.query(`SELECT z.master_table_name master_table_name,
                            z.master_order_table_id,
                            x.orderhd_id,
                            x.orderhd_docuno,
                            e.firstname,
                            e.lastname
                    from saledata.orderhd x,
                    saledata.orderhd_multitable y,
                    master_data.master_order_table z,
                    security.emp_employeemaster e  
                    where x.orderhd_id = y.orderhd_id
                    and x.emp_employeemasterid = e.emp_employeemasterid
                    and  y.master_order_table_id = z.master_order_table_id
                    and z.master_order_table_id <> ${table_id}
                    and  x.orderhd_status_id = 1
                    and x.orderhd_docudate::date = now()::date
                    and x.master_branch_id = ${branch_id}
                    and x.master_company_id = ${company_id}     
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    moveProductDataAll(req, res) {
        const old_table_id = req.body.old_table_id;
        const new_table_id = req.body.new_table_id;
        const old_orderhd_id = req.body.old_orderhd_id;
        const new_orderhd_id = req.body.new_orderhd_id;
        const orderdt_id = req.body.orderdt_id;
        const remark = req.body.remark;
        const emp_id = req.body.emp_id;
        const reason_move_order_id = req.body.reason_move_order_id;
        pool.query(`SELECT y.orderhd_status_id
                    FROM saledata.orderdt x
                    LEFT JOIN saledata.orderhd y ON x.orderhd_id = y.orderhd_id
                    WHERE x.orderdt_id = ${orderdt_id}
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                if (result.rows[0].orderhd_status_id == 1) {
                    pool.query(`select saledata.fn_move_order_item(${old_orderhd_id}, ${new_orderhd_id}, ${old_table_id}, ${new_table_id}, ${orderdt_id}, '${remark}', ${emp_id}, ${reason_move_order_id})    
                            `,
                        (err, result) => {
                            if (err) {
                                throw err;
                            }

                            res.json({ message: true });
                        });
                } else {
                    res.json({ message: false });
                }
            });

    }

    moveProductDataQty(req, res) {
        const old_table_id = req.body.old_table_id;
        const new_table_id = req.body.new_table_id;
        const old_orderhd_id = req.body.old_orderhd_id;
        const new_orderhd_id = req.body.new_orderhd_id;
        const orderdt_id = req.body.orderdt_id;
        const remark = req.body.remark;
        const emp_id = req.body.emp_id;
        const qty = req.body.qty;
        const reason_move_order_id = req.body.reason_move_order_id;
        pool.query(`SELECT y.orderhd_status_id
                    FROM saledata.orderdt x
                    LEFT JOIN saledata.orderhd y ON x.orderhd_id = y.orderhd_id
                    WHERE x.orderdt_id = ${orderdt_id}
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                if (result.rows[0].orderhd_status_id == 1) {
                    pool.query(`select saledata.fn_move_order_item_qty(${old_orderhd_id}, ${new_orderhd_id}, ${old_table_id}, ${new_table_id}, ${orderdt_id}, '${remark}', ${emp_id}, ${qty}, ${reason_move_order_id})    
                            `,
                        (err, result) => {
                            if (err) {
                                throw err;
                            }
                            res.json({ message: true });
                        });
                } else {
                    res.json({ message: false });
                }
            });

    }

    billCheck(req, res) {
        const payment_type_id = req.body.payment_type;
        const remark = req.body.remark;
        const orderhd_id = req.body.orderhd_id;
        const emp_receive_id = req.body.emp_receive;
        pool.query(`select saledata.fn_bill_check(${orderhd_id}, ${payment_type_id}, ${emp_receive_id}, '${remark}')
                `,
            (err, result) => {
                if (err) {
                    res.json({ status: false });
                    throw err;
                }
                res.json({ status: true });
            });
    }

    // async billCheck(req, res){
    //     const payment_type_id = req.body.payment_type;
    //     const remark = req.body.remark;
    //     const orderhd_id = req.body.orderhd_id;
    //     const emp_receive_id = req.body.emp_receive;
    //     const company_id = req.body.company_id;
    //     const branch_id = req.body.branch_id;
    //     let realFile;
    //     const date = new Date();
    //     let imageName;
    //     let imageNames = [];
    //     const images = req.body.images;
    //     if(images.length > 0){
    //         await images.forEach(async (item, index)=>{
    //             realFile = Buffer.from(item,"base64");
    //             imageName = "RECEIPT" + "_" + moment().format('YYYYMMDD') + date.getTime().toString() +index+".jpg";
    //             const dir = `./images/receipt_${moment().format('YYYYMMDD')}/`;
    //             if (!fs.existsSync(dir)){
    //                 fs.mkdirSync(dir);
    //             }
    //             imageNames.push({image_name: `receipt_${moment().format('YYYYMMDD')}/`+imageName});
    //             await fs.writeFile(dir+ imageName, realFile, "utf-8");
    //         });

    //     }else{
    //         imageNames = [];
    //     }
    //     pool.query(`select saledata.fn_bill_check(${orderhd_id}, ${payment_type_id}, ${emp_receive_id}, '${remark}', ${company_id}, ${branch_id}, '${JSON.stringify(imageNames)}')
    //             `, 
    //     (err, result)=>{
    //         if(err){
    //             res.json({status: false});
    //             throw err;
    //         }
    //         res.json({status: true});
    //     });
    // }

    fetchToppingData(req, res) {
        const company_id = req.body.company_id;
        const product_id = req.body.product_id;
        const branch_id = req.body.branch_id;
        pool.query(`select x.master_product_id_topping as master_product_id,
                            y.master_product_name,
                            z.master_product_price1,
                            z.master_product_price1::float as total_price_topping,
                            false as status_check,
                            1 as topping_qty
                    from master_data.master_product_topping x
                    left join master_data.master_product y on x.master_product_id_topping = y.master_product_id
                    left join master_data.master_product_price z on x.master_product_id_topping = z.master_product_id
                    where x.master_product_id = ${product_id}
                    and z.master_branch_id = ${branch_id}
                    and z.sale_active = true
                    and x.master_product_topping_active = true
                    and y.master_company_id = ${company_id}
                    GROUP BY x.master_product_id_topping,
                             y.master_product_name,
                             z.master_product_price1

                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }


    addProductDataInBuffet(req, res) {
        const orderhd_id = req.body.order_id;
        const table_id = req.body.table_id;
        const user_id = req.body.user_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const limit_order_qty = req.body.limit_order_qty;
        const count_order = req.body.count_order;
        const buffethd_id = req.body.buffethd_id;
        const product_data = JSON.stringify(req.body.product_data);
        const limit_time = req.body.limit_time;
        const time_to_eat_infinity = req.body.time_to_eat_infinity;
        pool.query(`select * from saledata.fn_app_add_product_data_buffet_v1(
                        ${company_id},
                        ${branch_id}, 
                        ${orderhd_id},
                        ${user_id},
                        ${table_id},
                        ${buffethd_id},
                        '${product_data}',
                        ${limit_time},
                        ${time_to_eat_infinity},
                        ${limit_order_qty},
                        ${count_order}
                        );
                        `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json({ status: parseInt(result.rows[0]._status), message: result.rows[0]._message });
            });
    }


    orderBuffet(req, res) {
        const orderhd_id = req.body.orderhd_id;
        const buffethd_id = req.body.buffethd_id;
        const qty = req.body.qty;
        const emp_id = req.body.emp_id;
        const product_id = req.body.product_id;
        const table_id = req.body.table_id;
        const buffet_price = parseFloat(req.body.buffet_price);
        pool.query(`select * from "saledata"."fn_app_order_buffet"(${buffethd_id}, ${orderhd_id}, ${qty}, ${emp_id}, ${product_id}, ${table_id}, ${buffet_price})
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }


    fetchOrderbuffetData(req, res, io) {
        const company_id = req.body.orderhd_id;
        const branch_id = req.body.buffethd_id;
        const orderhd_id = req.body.orderhd_id;
        pool.query(`select x.*,
                           y.master_buffet_hd_name as buffet_name,
                           y.master_buffet_hd_net_amount as buffet_price
                    from saledata.orderhd_buffet x
                    left join master_data.master_buffet_hd y on x.master_buffet_hd_id = y.master_buffet_hd_id
                    left join saledata.orderhd z on x.orderhd_id = z.orderhd_id
                    where x.orderhd_id = ${orderhd_id}
                    and z.orderhd_status_id = 1
                    and z.orderhd_docudate::date = now()::date
                   
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    // fetchBuffetInPayment(req, res){
    //     const company_id = req.body.orderhd_id;
    //     const branch_id = req.body.buffethd_id;
    //     const orderhd_id = req.body.orderhd_id;
    //     pool.query(`select x.master_buffet_hd_id as orderdt_id,
    //                         x.orderhd_id as orderdt_master_product_id,			 
    //                         sum(x.buffethd_order_qty) as orderdt_qty,
    //                     y.master_buffet_hd_name as master_product_name,
    //                     y.master_buffet_hd_net_amount as orderdt_saleprice,
    //                     '[]'::json as topping,
    //                     '0' as total_price_topping,
    //                     (y.master_buffet_hd_net_amount * sum(x.buffethd_order_qty)) as orderdt_netamnt		
    //                 from saledata.orderhd_buffet x
    //                 left join (
    //                 select master_buffet_hd_name,
    //                             master_buffet_hd_net_amount,
    //                             master_buffet_hd_id
    //                 from  master_data.master_buffet_hd
    //                 ) y on x.master_buffet_hd_id = y.master_buffet_hd_id
    //                 where x.orderhd_id = ${orderhd_id}
    //                 GROUP BY x.master_buffet_hd_id,
    //                 x.orderhd_id,
    //                 y.master_buffet_hd_name,
    //                 y.master_buffet_hd_net_amount
    //                 `, 
    //     (err, result)=>{
    //         if(err){
    //             throw err;
    //         }
    //         res.json(result.rows);
    //     });
    // }

    fetchOrderdtBuffetData(req, res) {
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const orderhd_id = req.body.orderhd_id;
        const buffethd_id = req.body.buffethd_id;
        pool.query(`select coalesce(sum(orderdt_qty), 0) as orderdt_qty
                    from saledata.orderdt
                    where orderhd_id = ${orderhd_id}
                    and orderdt_status_id IN (1, 3, 4)
                    and orderdt_buffet_flag = false
                    and master_buffet_hd_id = ${buffethd_id}
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchEndTimeData(req, res) {
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const orderhd_id = req.body.orderhd_id;
        const buffethd_id = req.body.buffethd_id;
        pool.query(`select case when x.master_buffet_hd_time_to_eat_hr = 0 then true else false end as time_to_eat_infinity,
                            case when x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int <= 59 then to_char(yy.savetime, 'HH24')::int + x.master_buffet_hd_time_to_eat_hr
                            else (to_char(yy.savetime, 'HH24')::int + x.master_buffet_hd_time_to_eat_hr) + 1 end
                            ||':'||
                            case when x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int <= 59 then right('00'||(x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int), 2)
                            else right('00'||(x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int - 60), 2) end as end_time,
                            to_char(now(), 'HH24')::int * 60 as current_time_hr,
                            to_char(now(), 'mi')::int as current_time_mi,
                            case when x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int <= 59 then (to_char(yy.savetime, 'HH24')::int + x.master_buffet_hd_time_to_eat_hr)::int * 60
                            else (to_char(yy.savetime, 'HH24')::int + x.master_buffet_hd_time_to_eat_hr + 1)::int * 60 end as limit_hr,
                            case when x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int <= 59 then right('00'||(x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int), 2)::int
                            else right('00'||(x.master_buffet_hd_time_to_eat_mi + to_char(yy.savetime, 'mi')::int - 60), 2)::int end as limit_mi                               
                    from saledata.orderdt yy
                    left join master_data.master_buffet_hd x on x.master_buffet_hd_id = yy.master_buffet_hd_id
                    where yy.master_buffet_hd_id = ${buffethd_id}
                    and x.master_buffet_hd_active = TRUE
                    and yy.orderdt_id = (select MAX(orderdt_id) as orderdt_id  
                                        from saledata.orderdt
                                        where orderhd_id = ${orderhd_id}
                                        and master_buffet_hd_id = ${buffethd_id}
                                        and orderdt_buffet_flag = true
                                        )
                    and yy.orderhd_id = ${orderhd_id}
                    and yy.orderdt_buffet_flag = true
                    and yy.orderdt_status_id IN (3, 4)
                    and x.master_company_id = ${company_id}

                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    updateProductQty(req, res) {
        const orderdt_id = req.body.orderdt_id;
        const orderhd_id = req.body.orderhd_id;
        const qty = req.body.qty;
        pool.query(`UPDATE saledata.orderdt
                    SET orderdt_qty = ${qty},
                        orderdt_begin_qty = ${qty},
                        orderdt_netamnt = ${qty} * orderdt_saleprice
                    WHERE orderdt_id = ${orderdt_id}
                    AND orderhd_id = ${orderhd_id}
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }

                res.json({ message: 1 });
            });
    }

    fetchServiceChargeData(req, res) {
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        pool.query(`select y.master_service_charge_rate::float as di_rate,
                           z.master_service_charge_rate::float as tk_rate,
                           x.master_vat_group_id,
                           x.master_rounding_id,
                           xx.master_vat_rate::float                        
                    from master_data.master_branch x
                    left join master_data_all.master_service_charge y on x.master_service_charge_id = y.master_service_charge_id
                    left join master_data_all.master_service_charge z on x.master_service_charge_takeaway_id = z.master_service_charge_id
                    left join master_data_all.master_vat_group xx on x.master_vat_group_id = xx.master_vat_group_id
                    where x.master_branch_id = ${branch_id}
                    and x.master_company_id = ${company_id}
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchReasonCancelData(req, res) {
        const company_id = req.body.company_id;
        pool.query(`SELECT * 
                    FROM "master_data"."master_reason_cancel_order"
                    WHERE master_reason_cancel_order_active = true
                    AND master_company_id = ${company_id};
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchReasonMoveOrder(req, res) {
        const company_id = req.body.company_id;
        pool.query(`SELECT * 
                    FROM "master_data"."master_reason_move_order"
                    WHERE master_reason_move_order_active = true
                    AND master_company_id = ${company_id};
                    `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchCategoryBuffetData(req, res) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        const buffethd_id = req.body.buffethd_id;
        pool.query(`SELECT xx.master_product_group_id,
                           xx.master_product_group_name,
                           xx.master_product_group_image_name as image_group_name,
                           coalesce(yy.count_product, 0) count_product
                    FROM master_data.master_product_group xx
                     LEFT JOIN 
                            (
                            SELECT product.master_product_group_id,
                            COUNT(product.master_product_group_id) count_product
                            FROM
                                (
                                select x.master_buffet_dt_id,
                                       x.master_buffet_hd_id,
                                       z.master_product_group_id
                                from master_data.master_buffet_dt x
                                left join master_data.master_buffet_hd y on x.master_buffet_hd_id = y.master_buffet_hd_id
                                left join master_data.master_product z on x.master_buffet_dt_product_id = z.master_product_id
                                left join master_data.master_product_price pdp on z.master_product_id = pdp.master_product_id and pdp.master_branch_id = ${branch_id}
                                where y.master_buffet_hd_id = ${buffethd_id}
                                and y.master_company_id = ${company_id}
                                and x.master_buffet_dt_active = true
                                and z.sale_activeflag = true
                                and pdp.sale_active = true
                                ) product
                            GROUP BY product.master_product_group_id
                            ) yy 
                    ON xx.master_product_group_id = yy.master_product_group_id
                    where xx.sale_active = true
                    and xx.master_company_id = ${company_id}
                    and xx.master_product_group_buffet_flag = false
                    and xx.master_product_group_buffet_active = true
                    and yy.count_product is not null
                    ORDER BY xx.master_product_group_list_no					  
                      `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
            });
    }

    fetchAllProductInBuffetData(req, res) {
        const branch_id = req.body.branch_id;
        const company_id = req.body.company_id;
        const buffethd_id = req.body.buffethd_id;
        const orderhd_id = req.body.orderhd_id;
        const order_qty = req.body.order_qty;
        pool.query(`select x.master_buffet_dt_id,
                           x.master_buffet_hd_id,
                           x.master_buffet_dt_product_id,
                           x.master_buffet_dt_barcode_code,
                           x.master_buffet_dt_barcode_name,
                           x.master_buffet_dt_unit_price,
                           x.master_buffet_dt_order_qty,
                           xx.master_product_image_name,
                           'ไม่มีหมายเหตุ' as remark,
                           true as print_bill_flag,
                           '[]'::json as option_item,
                           ROW_NUMBER() OVER(ORDER BY x.master_buffet_dt_id ASC) - 1 as count_number,
                           case when x.master_buffet_dt_order_qty = 0 then true else false end as order_infinity,
                           case when yy.orderdt_qty <> 0 then coalesce((x.master_buffet_dt_order_qty * ${order_qty}) - yy.orderdt_qty, 0)
                           else x.master_buffet_dt_order_qty * ${order_qty} end as balanch_orderdt_qty,
                           coalesce(zz.all_balanch_orderdt_qty, 0) as all_balanch_orderdt_qty,
                           0 as buffetdt_qty
                    from master_data.master_buffet_dt x
                    left join (
                        select coalesce(sum(orderdt_qty), 0) as orderdt_qty,
                               orderdt_master_product_id
                        from saledata.orderdt
                        where master_buffet_hd_id = ${buffethd_id}
                        and orderdt_status_id IN (1, 3, 4)
                        and orderdt_buffet_flag = false
                        and orderhd_id = ${orderhd_id}
                        group by orderdt_master_product_id
                    ) yy on x.master_buffet_dt_product_id = yy.orderdt_master_product_id
                    left join (
                        select coalesce(sum(orderdt_qty), 0) as all_balanch_orderdt_qty,
                               master_buffet_hd_id
                        from saledata.orderdt
                        where master_buffet_hd_id = ${buffethd_id}
                        and orderdt_status_id IN (1, 3, 4)
                        and orderhd_id = ${orderhd_id}
                        and orderdt_buffet_flag = false
                        group by master_buffet_hd_id
                    ) zz on x.master_buffet_hd_id = zz.master_buffet_hd_id
                    left join master_data.master_product xx on x.master_buffet_dt_product_id = xx.master_product_id
                    left join master_data.master_product_group pdg on xx.master_product_group_id = pdg.master_product_group_id
                    left join master_data.master_product_price pdp on xx.master_product_id = pdp.master_product_id and pdp.master_branch_id = ${branch_id}
                    where x.master_buffet_hd_id = ${buffethd_id}
                    and pdg.master_product_group_buffet_active = true
                    and xx.sale_activeflag = true
                    and pdp.sale_active = true               
                    and x.master_buffet_dt_active = true
                      `,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);

            });
    }
    UpdateOrderStatus(req, res) {
        const orderhd_id = req.body.orderhd_id;
        const company_id = req.body.company_id;
        const branch_id = req.body.branch_id;
        const order_dt_id = req.body.order_dt_id;
        console.log(req.body)

        pool.query(`select "saledata"."fn_update_order_status"(${orderhd_id},${company_id}, ${branch_id}, array[${order_dt_id}])`,
            (err, result) => {
                if (err) {
                    throw err;
                }
                res.json(result.rows);
                console.log(result.rows)
            });
    }


}

module.exports = modelMainMenu;