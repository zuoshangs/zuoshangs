#Rule_101 当满足如下条件：①“账户状态”为“2-逾期”或“4-呆账”；对如下内容进行校验：“当前逾期期数”不能为零。
select 'Rule_101',id from tt_rh_user_base_info where (account_state = '2' or account_state = '4') and current_overdue_period = '00';

#Rule_102 当满足如下条件：①“账户状态”为“2-逾期”或“4-呆账”；对如下内容进行校验：“当前逾期总额”不能为零。 
select 'Rule_102',id from tt_rh_user_base_info where (account_state = '2' or account_state = '4') and current_overdue_money = '0000000000';

#Rule_103 当满足如下条件：①“账户状态”为“2-逾期”或“4-呆账”；对如下内容进行校验：“累计逾期期数”不能为零。
select 'Rule_103',id from tt_rh_user_base_info where (account_state = '2' or account_state = '4') and total_overdue_period = '000';

#Rule_104 当满足如下条件：①“账户状态”为“2-逾期”或“4-呆账”；对如下内容进行校验：“最高逾期期数”不能为零。
select 'Rule_104',id from tt_rh_user_base_info where (account_state = '2' or account_state = '4') and max_overdue_period = '00';

#Rule_105 当满足如下条件：①“账户状态”为“2-逾期”；对如下内容进行校验：“24个月还款状态”相应月份值必须为1～7的数字且“24个月还款状态”中不包含C或G。
#当满足如下条件：①“账户状态”为“4-呆账”；对如下内容进行校验：“24个月还款状态”最后一个月的还款状态必须为1～7的数字或“G-结束”且“24个月还款状态”中不包含C。
select 'Rule_105',id,business_no,account_state,plan_dealine,account_repayment_state from tt_rh_user_base_info where account_state = '2' and 
(
SUBSTR(account_repayment_state FROM 24 FOR 1) not in ('1','2','3','4','5','6','7') 
or 
(LOCATE(account_repayment_state,'C') > 0 or LOCATE(account_repayment_state,'G') > 0)
) ;

#select 'Rule_105',id,business_no from tt_rh_user_base_info where account_state = '4' and !((SUBSTR(account_repayment_state FROM 24 FOR 1) in (1,2,3,4,5,6,7) or SUBSTR(account_repayment_state FROM 24 FOR 1) = 'G') and LOCATE(account_repayment_state,'C')  = 0);


#Rule_106 当满足如下条件：①“账户状态”为“3-结清”；对如下内容进行校验：“余额”必须为零。如果还款频率为“月”，那么“剩余还款月数”必须为零。
select 'Rule_106',id from tt_rh_user_base_info where account_state = '3' and (balance!=0 or  IF(repay_cycle = '03',surplus_repay_month != '0',true));

#Rule_107 当满足如下条件：①“账户状态”为“3-结清”；对如下内容进行校验：“当前逾期期数”必须为零。
select 'Rule_107',id from tt_rh_user_base_info where account_state = '3' and current_overdue_period != '00';

#Rule_108 当满足如下条件：①“账户状态”为“3-结清”；对如下内容进行校验：“当前逾期总额”必须为零。
select 'Rule_108',id from tt_rh_user_base_info where account_state = '3' and current_overdue_money  != '0000000000';

#Rule_109 当满足如下条件：①“账户状态”为“3-结清”；对如下内容进行校验：①“24个月（账户）还款状态”最后一个月的还款状态必须为“C”
select 'Rule_109',id,account_repayment_state from tt_rh_user_base_info where account_state = '3' and SUBSTR(account_repayment_state FROM 24 FOR 1) != 'C';

#Rule_110 当满足如下条件：①“账户状态”为“3-结清”；对如下内容进行校验：①本月实际还款金额应大于等于（本月应还款金额-2）；②本月实际还款金额不为0。
select 'Rule_110',id,business_no,plan_repay_money,real_repay_money from tt_rh_user_base_info where account_state = '3' and (CAST(real_repay_money AS DECIMAL)  < (CAST(plan_repay_money AS DECIMAL) - 2) or real_repay_money = 0);

#Rule_111 当满足如下条件：①“账户状态”为“1-正常”；对如下内容进行校验：“当前逾期期数”应为零。
select 'Rule_111',id,business_no,account_state,current_overdue_period from tt_rh_user_base_info where account_state = '1'  and current_overdue_period != '00';

#112当满足如下条件：①“账户状态”为“1-正常”；对如下内容进行校验：“当前逾期总额”应为零。
select 'Rule_112',id,business_no,account_state,current_overdue_period,current_overdue_money from tt_rh_user_base_info where account_state = '1'  and current_overdue_money != '0000000000';

-- Rule_113 若“账户状态”为“1-正常”，则“本月实际还款金额”应大于等于“（本月应还款金额-2）”。
SELECT 'Rule_113',a.* from  tt_rh_user_base_info a where account_state ='1' and CAST(real_repay_money as DECIMAL) < CAST(plan_repay_money as DECIMAL)-2  ;
-- 验证SQL
#SELECT account_state,real_repay_money,plan_repay_money from  tt_rh_user_base_info where account_state ='1' and CAST(real_repay_money as DECIMAL) < CAST(plan_repay_money as DECIMAL) ;
-- Rule_114 若“账户状态”为“1-正常”，则“24个月还款状态”相应月份值（即最后一位）不应出现数字“1-7”且“24个月还款状态”中不应出现“C”或“G”。
SELECT "Rule114",a.id,business_no,account_repayment_state from  tt_rh_user_base_info a where account_state ='1' and (substring(account_repayment_state ,-1) in ('1','2','3','4','5','6','7') 
or (account_repayment_state like '%C%' or account_repayment_state like '%G%' )) ;
-- 验证SQL
#SELECT account_state,account_repayment_state,account_repayment_state from  tt_rh_user_base_info where account_state ='1' and (substring(account_repayment_state ,-1) in ('1','2','3','4','5','6','7') 
#or (account_repayment_state like '%C%' or account_repayment_state like '%G%' ))  ;

-- Rule_115 若“账户状态”为“1-正常”，则结算/应还款日期应小于到期日期。
SELECT 'Rule_115',a.* from  tt_rh_user_base_info a where account_state ='1' and DATE_FORMAT(plan_dealine, '%Y-%m-%d') >= DATE_FORMAT(order_deadline, '%Y-%m-%d');
-- 验证SQL
#SELECT account_state,plan_dealine,order_deadline from  tt_rh_user_base_info where account_state ='1' and DATE_FORMAT(plan_dealine, '%Y-%m-%d') >= DATE_FORMAT(order_deadline, '%Y-%m-%d');

-- Rule_116 若“账户状态”不为“3-结清”,24月还款状态中不能有“C” 
SELECT 'Rule_116',a.* from  tt_rh_user_base_info a where account_state <>'3' and account_repayment_state like '%C%' ;
-- 验证SQL
#SELECT account_state,account_repayment_state from  tt_rh_user_base_info where account_state <>'3' and account_repayment_state like '%C%' ;

-- Rule_117 贷款逾期时账户状态不应为“正常”(只用于贷款)
-- 验证SQL
SELECT "Rule_117",id,business_no,account_state,account_repayment_state from  tt_rh_user_base_info where account_state in ('1','3','5') and (substring(account_repayment_state,24,1) like '%1%' or substring(account_repayment_state,24,1) like '%2%' or substring(account_repayment_state,24,1) like '%3%' or substring(account_repayment_state,24,1) like '%4%' or substring(account_repayment_state,24,1) like '%5%' or substring(account_repayment_state,24,1) like '%6%' or substring(account_repayment_state,24,1) like '%7%') ;


-- Rule_118 24月还款状态不能有多个C
SELECT "Rule_118",a.* from  tt_rh_user_base_info a where  LENGTH(account_repayment_state) - LENGTH( REPLACE(account_repayment_state,'C','')) >1 ;
-- 验证SQL
#SELECT account_repayment_state from  tt_rh_user_base_info  where  LENGTH(account_repayment_state) - LENGTH( REPLACE(account_repayment_state,'C','')) >1 ;

-- Rule_119 若余额为0，则状态应该为结清且当前逾期总额也要为0。

SELECT * from  tt_rh_user_base_info where CAST(balance as DECIMAL) =0 and (account_state <> '3' or  CAST(current_overdue_period as DECIMAL) >0);
-- 验证SQL
#SELECT balance,current_overdue_period from  tt_rh_user_base_info where CAST(balance as DECIMAL) =0 and (account_state <> '3' or  CAST(current_overdue_period as DECIMAL) >0);

-- Rule_120 24月还款状态中不能有“#”
SELECT * from  tt_rh_user_base_info where  account_repayment_state like '%#%' ;
-- 验证SQL
#SELECT account_repayment_state from  tt_rh_user_base_info where  account_repayment_state like '%#%' ;

-- Rule_121 开户日期应小于等于到期日期，并且开户日期应小于等于结算/应还款日期，最近一次实际还款日期应小于等于结算/应还款日期
SELECT * from  tt_rh_user_base_info where  DATE_FORMAT(account_date, '%Y-%m-%d') > DATE_FORMAT(order_deadline, '%Y-%m-%d') or DATE_FORMAT(account_date, '%Y-%m-%d') > DATE_FORMAT(plan_dealine, '%Y-%m-%d') or DATE_FORMAT(recently_repay_time, '%Y-%m-%d') > DATE_FORMAT(plan_dealine, '%Y-%m-%d') ;
-- 验证SQL
#SELECT account_date,order_deadline,recently_repay_time,plan_dealine from  tt_rh_user_base_info where  DATE_FORMAT(account_date, '%Y-%m-%d') > DATE_FORMAT(order_deadline, '%Y-%m-%d') or DATE_FORMAT(account_date, '%Y-%m-%d') > DATE_FORMAT(plan_dealine, '%Y-%m-%d') or DATE_FORMAT(recently_repay_time, '%Y-%m-%d') > DATE_FORMAT(plan_dealine, '%Y-%m-%d');
