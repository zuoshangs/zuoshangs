#401未结清的贷款每月至少报送1条
#当满足如下条件时：贷款基础数据表中的账户状态不为3-结清；
#对如下内容进行校验：开户日期所在月到到期日所在月之间，每个月均要有一条数据。

SELECT "Rule401",a.business_no,account_state,
	TIMESTAMPDIFF(MONTH,str_to_date( account_date, '%Y%m%d' ),if(str_to_date( order_deadline, '%Y%m%d' )>now(),str_to_date( order_deadline, '%Y%m%d' ),now())) chayue,
	count( 1 ) qishu 
FROM
	tt_rh_user_base_info  a
WHERE
	a.business_no in (select t.business_no from (select max(id) maxid,business_no from tt_rh_user_base_info group by business_no )t join tt_rh_user_base_info t1 on t.maxid=t1.id where t1.account_state !=3 )
GROUP BY
	business_no having chayue-qishu<=1;
	
	
	

	#402当数据内容满足如下条件时：贷款基础数据表中的贷款类型，发生地点，开户日期，到期日期，授信额度，担保方式，还款频率，还款月数，证件号码均相同；
#对如下内容进行校验：贷款基础数据表中的业务号不同。



SELECT
"Rule402",
	business_no,
	count( 1 ) 
FROM
	tt_rh_user_base_info 
GROUP BY
	business_type,
	loan_address,
	account_date,
	order_deadline,
	credit_money,
	guarantee_mode,
	repay_month,
	id_card_no;
	
#403当账户处于结清状态时，上报利率应大于等于实际利率（APR），且小于36%。当数据内容满足如下条件时：当账户状态为‘结清’时；
#对如下内容进行校验：上报利率应该大于等于实际利率（APR），同时小于36%。
#注:利率计算目前使用APR计算方法，即：((本月应还款金额*还款月数-授信额度)/授信额度/账期天数)*365*100%。
#若账户未结清，那么利率应按照账户的还款计划上报。
#如果账户已结清，那么APR=((所有本月实际还款金额总和-授信额度)/授信额度/账期天数)*365*100%。账期天数=最新一条账期的结算应还款日期dbillingdate）-开户日期（ddateopened）

select "Rule403",business_no,((sum(plan_repay_money)-credit_money)/credit_money/DATEDIFF(max(plan_dealine),account_date))*365*100 inte from tt_rh_user_base_info where 1=1
#and business_no='T100023U20180903151848'
group by business_no having inte >36;

	
	#404当数据内容满足如下条件时：首次报送的数据，结算应还款日期月开户日期所在的月相等。
#对如下内容进行校验：本月应还款金额应为0，本月实际还款金额应为0，24个还款状态最后一位应为‘*’


SELECT
	"Rule404",a.id,a.business_no,account_date,plan_dealine,order_deadline,plan_repay_money,real_repay_money,a.account_repayment_state
FROM
	tt_rh_user_base_info a
WHERE 1=1
	#business_no = 'T312673U20190504134101' 
	AND substring(account_date,1,6) = substring(plan_dealine,1,6)  
	AND (
		plan_repay_money != 0 
		OR real_repay_money != 0
	OR substring( account_repayment_state, 24, 1 )!= '*' 
	);
	
	# 405如果账户状态为逾期，逾期利息和违约金之和不能超过24%
	#当数据内容满足如下条件时：如果账户状态为“逾期”。对如下内容进行校验：逾期利息和违约金之和应小于24%。
#注:计算方法：((最近一期的当前逾期总额+所有本月实际还款金额-授信额度)/授信额度/账期天数)*365*100%。账期天数=最新一条账期的结算应还款日期（dbillingdate）-开户日期（ddateopened）

select "Rule405",id,business_no,current_overdue_money,plan_repay_money,plan_repay_money,365*100*((current_overdue_money+sum(real_repay_money)-credit_money)/credit_money/DATEDIFF(max(plan_dealine),account_date)) yuqi
from tt_rh_user_base_info where account_state='2' 
group by business_no having yuqi>24
