#301
#当满足如下条件时：①账户状态为3-结清；
#对如下内容进行校验：贷款基础数据段中的结算/应还款日期数据项应与最近一次实际还款日期数据项保持一致，即结算/应还款日期=最近一次实际还款日期。
select 'rule301',a.* from tt_rh_user_base_info a where account_state='3' and recently_repay_time!=plan_dealine;

#302当满足如下条件时：①开户日期与结算/应还款日期在同一个月（即两个日期的月份相同）；②本月实际还款金额，本月应还款金额皆为0；
#对如下内容进行校验：结算/应还款日期，开户日期，最近一次实际还款日期应完全一致。
select 'rule302',a.* from tt_rh_user_base_info a where substring(account_date,1,6)=substring(plan_dealine,1,6) and plan_repay_money=0 and real_repay_money=0 and (plan_dealine!=account_date or account_date!=recently_repay_time or plan_dealine!=recently_repay_time);


#303前一个账期还款状态为正常,本月实际还款金额不应大于本月应还款金额时，应报送特殊交易
#当满足如下条件时：① 24月（贷款）还款状态的倒数第二位为“N”；②本月实际还款金额大于本月应还款金额；
#对如下内容进行校验：机构是否报送了业务号与该笔贷款基础数据段中的业务号一致，交易类型是04或05的特殊交易数据段。
select 'rule303',t.* from(select business_no,account_repayment_state,plan_dealine,plan_repay_money,real_repay_money from tt_rh_user_base_info a where substring(a.account_repayment_state,23,1)='N' and real_repay_money>plan_repay_money)t left join tt_rh_special_info s on t.business_no=s.business_no where s.id is null;

#304 业务到期后未结清，"累计逾期期数"、"当前逾期期数"、"最高逾期期数"不应该继续累计
#当满足如下条件时：①当“结算/应还款日期”晚于 “到期日期”所在的月份；②“账户状态”为“2-逾期”；
#对如下内容进行校验："累计逾期期数"、"当前逾期期数"、"最高逾期期数"均不能大于前一账期的值。

select t.*,sum(current_overdue_period)/count(1)=max(current_overdue_period) c1,sum(total_overdue_period)/count(1)=max(total_overdue_period) c2,sum(max_overdue_period)/count(1)=max(max_overdue_period) c3 from (
select "Rule304",id,business_no,plan_dealine,order_deadline,current_overdue_period,total_overdue_period,max_overdue_period from tt_rh_user_base_info a where substring(a.plan_dealine,1,6)>substring(order_deadline,1,6) and account_state='2' order by business_no,plan_dealine)t group by business_no having (c1!=1 or c2 !=1 or c3!=1);

#305当满足如下条件时：①24月贷款还款状态第24位为1； 
#对如下内容进行校验：31-60日未归还本金、61-90日未归还本金、91-180日未归还本金/180天以上未归还本金应该全为0。
SELECT
'rule305',
	id,
	business_no,
	account_repayment_state,
	SUBSTR( account_repayment_state, 24 ),
	overdue_thirty_one_sixty,
	overdue_sixty_one_ninety,
	overdue_ninety_one 
FROM
	tt_rh_user_base_info 
WHERE
	1 = 1 
	#and business_no='T261686U20190317230302'
	
	AND SUBSTR( account_repayment_state, 24 )= '1' 
	AND (
		overdue_thirty_one_sixty != '0000000000' 
	OR overdue_sixty_one_ninety != '0000000000' 
	OR overdue_ninety_one != '0000000000');
	
	
#306
#当满足如下条件时：①实际还款金额大于等于本月应还款金额；②24月（贷款）还款状态的第23位为'*','#','/','N'
#对如下内容进行校验：24月（贷款）还款状态的第24位不应为1-7。

select 'rule306',a.id,business_no,plan_repay_money,real_repay_money,account_repayment_state from tt_rh_user_base_info a where 
1=1 
#and business_no='T363408U20190620152044'
#and a.account_repayment_state ='//////////////////////*1'
and a.real_repay_money>=a.plan_repay_money 
and SUBSTR(a.account_repayment_state,23,1) in ('*','#','/','N') 
 and SUBSTR(a.account_repayment_state,24,1) in ('1','2','3','4','5','6','7');
 

#307账户在未到期且上个月逾期本月账户正常的情况下，"实际还款金额"应该大于"本月应还款金额
#当满足如下条件时：①24月（贷款）还款状态的第23位为1-7；②当期账户状态为“1-正常”或“3-结清”； 
#对如下内容进行校验："实际还款金额"应该大于"本月应还款金额"。


SELECT
	'rule307',id,business_no,account_repayment_state,account_state,plan_repay_money,real_repay_money
FROM
	tt_rh_user_base_info a 
WHERE 1=1
#and a.business_no='T363408U20190620152044' 
and 
	substring( account_repayment_state, 23, 1 ) IN ( '1', '2', '3', '4', '5', '6', '7' ) 
	AND a.account_state IN ( '1', '3' ) and recently_repay_time<order_deadline
	AND real_repay_money <= plan_repay_money ;
	
#308当满足如下条件时：①担保方式为3-自然人保证、5-组合（含自然人保证）、7-农户联保；
#对如下内容进行校验：贷款基础数据表中的业务号应在担保信息表中出现。


select 'rule308',a.* from tt_rh_user_base_info a where 1=1
and a.guarantee_mode in ('3','5','7');


#309当满足如下条件时：
#对如下内容进行校验：贷款基础数据表中的发生地点应精确到地市级。

select 'rule309',id,business_no from tt_rh_user_base_info a where 1=1
and LENGTH(a.loan_address) !=6;

#310报文加载时对如下内容进行校验：贷款业务段中24月（贷款）还款状态连续两位状态后一位
#减前一位不能大于2，“*”、“N”以零计算。


select 'rule310',t.* from (
SELECT
	id,business_no,REPLACE(REPLACE(REPLACE(account_repayment_state,'*','0'),'N','0'),'/','0') c,
	account_repayment_state
FROM
	tt_rh_user_base_info a 
WHERE
	1 = 1 
	
	
	)t where SUBSTRING(t.c,24,1)-SUBSTRING(t.c,23,1)>2;
	
	
#311本月应还款金额为0，实还大于0，但24个月还款状态目前为星号，应该为N
#当满足如下条件时：①本月应还款金额为0；②实际还款金额大于0。对如下内容进行校验：24月（贷款）还款状态的第24位应为“N”。

SELECT
	'rule311',a.id,a.business_no,plan_repay_money,real_repay_money,account_repayment_state
FROM
	tt_rh_user_base_info a 
WHERE a.plan_repay_money=0 and a.real_repay_money>0 and substring(a.account_repayment_state,24,1)!='N';




