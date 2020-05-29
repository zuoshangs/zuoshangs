-- 201 在非开户当月的情况下，还款频率为按月还款，最近一次实际还款日期与结算/应还款日期相差在1个月之内，则本月实际还款金额不应为0；（超过30算差一个月）①开户日期与结算/应还款日期不再同一个月（即两个日期的月份不同）；②还款频率为“03”；最近一次实际还款日期与结算/应还款日期相差在一个月内（即两个日期之间相差在一个月内）；对如下内容进行校验：本月实际还款金额不应为0。
#当满足如下条件时：①开户日期与结算/应还款日期不再同一个月（即两个日期的月份不同）；②还款频率为“03”；最近一次实际还款日期与结算/应还款日期相差在一个月内（即两个日期之间相差在一个月内）；
#对如下内容进行校验：本月实际还款金额不应为0。

SELECT "Rule201",a.* from  tt_rh_user_base_info a where repay_cycle='03' and real_repay_money = 0
and TIMESTAMPDIFF(MONTH,recently_repay_time,plan_dealine) = 0 
-- 自然月 CAST(DATE_FORMAT(recently_repay_time, '%Y%m')as SIGNED)-CAST(DATE_FORMAT(plan_dealine, '%Y%m')as SIGNED),recently_repay_time,plan_dealine
and DATE_FORMAT(account_date, '%Y-%m') <> DATE_FORMAT(plan_dealine, '%Y-%m');

-- Rule_202 还款频率的间隔高于“按月”的，除开户月和结清月外，"结算应还款日期"都应该取每月最后一天
SELECT "Rul2202",a.* from  tt_rh_user_base_info a where DATE_FORMAT(account_date, '%Y-%m') <> DATE_FORMAT(plan_dealine, '%Y-%m') and account_state <>'3' and repay_cycle in ('04','05','06','07','08','99') and plan_dealine <> last_day(plan_dealine);
-- 验证SQL
#SELECT account_date,plan_dealine,account_state,repay_cycle,last_day(plan_dealine) from  tt_rh_user_base_info where DATE_FORMAT(account_date, '%Y-%m') <> DATE_FORMAT(plan_dealine, '%Y-%m') and account_state <>'3' and repay_cycle in ('04','05','06','07','08','99') and plan_dealine <> last_day(plan_dealine);

-- Rule_203 在“本月应还款金额”或“本月实际还款金额”不为0的情况下，24月（贷款）还款状态不应为星号
SELECT "Rule203",business_no,plan_repay_money,plan_repay_money,account_repayment_state from  tt_rh_user_base_info where (CAST(plan_repay_money as DECIMAL) <> 0 or CAST(real_repay_money as DECIMAL) <> 0) and substring(account_repayment_state ,24,1) = '*';
-- 验证SQL
#SELECT plan_repay_money,real_repay_money,account_repayment_state from  tt_rh_user_base_info where (CAST(plan_repay_money as DECIMAL) <> 0 or CAST(real_repay_money as DECIMAL) <> 0) and substring(account_repayment_state ,-1) <> '*';


#204 上月正常还款，当月逾期未还款时，当前逾期总额应该等于"本月应还款金额"与"实际还款金额"之差。 
#贷款基础数据段
#24月（贷款）还款状态、账户状态、本月应还款金额、实际还款金额、当前逾期总额
#当满足如下条件时：①当“账户状态”为“2-逾期”；②24月（贷款）还款状态的第23位为N或者*；对如下内容进行校验： "本月应还款金额"-"实际还款金额"-“当前逾期总额”的结果的绝对值应小于2。
#cast(ST_CLASS as SIGNED INTEGER)
select "Rule204",id,business_no,account_state,account_repayment_state,plan_repay_money,real_repay_money,current_overdue_money,(plan_repay_money-real_repay_money-current_overdue_money) cha from tt_rh_user_base_info  where account_state='2' and substring(account_repayment_state,23,1) in ('N','*') and (plan_repay_money-real_repay_money-current_overdue_money)>=2; 

#205  按月还款除开户外,“本月应还款金额”不应该为0
#贷款基础数据段
#还款频率、本月应还款金额、结算/应还款日、开户日期
#当满足如下条件时：①当“还款频率”为“03-月”；②“结算/应还款日” plan_dealine 与“开户日期” account_date 不在同一月；对如下内容进行校验：“本月应还款金额”应该大于0。
select "Rule205",id,business_no,repay_cycle,plan_dealine,account_date,plan_repay_money from tt_rh_user_base_info  where repay_cycle='03' and substring(plan_dealine,1,6) <>substring(account_date,1,6) and plan_repay_money<=0; 

--  ---------------未完成
#206 业务到期后未结清，"结算/应还款日期"应该等于月底
#贷款基础数据段
#结算/应还款日 plan_dealine、到期日期 order_deadline、账户状态 account_state
#当满足如下条件时：①当“结算/应还款日期”晚于 “到期日期”所在的月份；②“账户状态”为“2-逾期”；对如下内容进行校验：“结算/应还款日期”应该等于所在月的最后一天。
#206 业务到期后未结清，"结算/应还款日期"应该等于月底
#贷款基础数据段
#结算/应还款日 plan_dealine、到期日期 order_deadline、账户状态 account_state
#当满足如下条件时：①当“结算/应还款日期”晚于 “到期日期”所在的月份；②“账户状态”为“2-逾期”；对如下内容进行校验：“结算/应还款日期”应该等于所在月的最后一天。
select "Rule206",id,business_no,plan_dealine,order_deadline,account_state,DATE_FORMAT(last_day(plan_dealine),'%Y%m%d')  from tt_rh_user_base_info  where account_state='2' and substring(plan_dealine,1,6)>substring(order_deadline,1,6) and  plan_dealine <> DATE_FORMAT(last_day(plan_dealine),'%Y%m%d');
#DATE_FORMAT(account_date, '%Y-%m') <> DATE_FORMAT(plan_dealine, '%Y-%m') and account_state <>'3' and repay_cycle in ('04','05','06','07','08','99') and plan_dealine <> last_day(plan_dealine); 
#select extract( day from now())
 #select date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract( day from now()) day),interval 0 month)f
 
 
#207 到期后未结清的情况下，当前逾期总额不应5小于余额
#贷款基础数据段
#到期日期，结算/应还款日期，账户状态，当前逾期总额及余额 current_overdue_money    
#当满足如下条件时：①结算/应还款日期所在月>到期日期所在月，②账户状态不为3-结清；对如下内容进行校验：当前逾期总额应大于等于余额 balance。
#207 到期后未结清的情况下，当前逾期总额不应5小于余额
#贷款基础数据段
#到期日期，结算/应还款日期，账户状态，当前逾期总额及余额 current_overdue_money    
#当满足如下条件时：①结算/应还款日期所在月>到期日期所在月，②账户状态不为3-结清；对如下内容进行校验：当前逾期总额应大于等于余额 balance。
select "Rule207",id,plan_dealine,order_deadline,account_state,current_overdue_money,balance  from tt_rh_user_base_info  where account_state<>'3' and substring(plan_dealine,1,6)>substring(order_deadline,1,6) and current_overdue_money<balance; 


#208 还款频率为月、季、半年、年时，当前逾期期数和累计逾期期数不应大于还款月数
#贷款基础数据段
#还款频率，当前逾期期数 current_overdue_period，累计逾期期数 total_overdue_period，还款月数 repay_month
#当满足如下条件时：①还款频率为03-月、04-季、05-半年、06-年；对如下内容进行校验：贷款业务数据内容应满足当前逾期期数<=还款月数，且累计逾期期数<=还款月数。
select "Rule208",id,current_overdue_period,total_overdue_period,repay_month ,repay_cycle from tt_rh_user_base_info  where repay_cycle='03' and (current_overdue_period> repay_month or total_overdue_period>repay_month);

#209 结算应还款日期是否晚于报文加载日期
#贷款基础数据段,系统加载日期
#结算/应还款日期 plan_dealine 、系统加载日期
#报文加载时对如下内容进行校验：贷款业务段中结算应还款日期不能晚于报文加载时间。
select "Rule209",id,plan_dealine,NOW(),DATEDIFF(NOW(),plan_dealine) from tt_rh_user_base_info  where DATEDIFF(NOW(),plan_dealine)<0;


#210 贷款开户日期是否在合理范围区间
#开户日期 account_date
#报文加载时对如下内容进行校验：贷款开户日期应晚于1990年，不晚于报文加载日期。
select "Rule210",id,account_date,NOW(), DATEDIFF(account_date,'1990-01-01'),DATEDIFF(NOW(),account_date) from tt_rh_user_base_info  where DATEDIFF(account_date,'1990-01-01')<0 or  DATEDIFF(NOW(),account_date)<0;

-- -------没有出生日期字段
#211 出生日期是否在合理范围内
#出生日期 id_card_no、报文加载日期
#报文加载时对如下内容进行校验：出生日期晚于1900年，早于报文加载日期。
select "Ruee211",id,id_card_no,substring(id_card_no,7,6),NOW(), DATEDIFF(substring(id_card_no,7,8),'1900-01-01'),DATEDIFF(NOW(),substring(id_card_no,7,8)) from tt_rh_user_base_info  where DATEDIFF(substring(id_card_no,7,8),'1900-01-01')<0 or DATEDIFF(NOW(),substring(id_card_no,7,8))<0;


-- -------没有出生日期字段
#212 出生日期和身份证号码上日期是否匹配
#证件类型、证件号码、出生日期
#当满足如下条件时：①证件类型为0-身份证且位数为18位时；对如下内容进行校验：个人基本信息中证件号码第7-14位与出生日期应保持一致。
select "Rule212",null;

#213 贷款到期后且逾期，本月应还款金额与本月实际还款金额校验
#到期日期 order_deadline、结算应还款日期 plan_dealine、账户状态 account_state、本月应还款金额 plan_repay_money、本月实际还款金额 real_repay_money
#当满足如下条件时：①结算应还款日期所在月晚于到期日期所在月；②账户状态为逾期；对如下内容进行校验：①本月应还款金额不应为零；②本月实际还款金额应小于本月应还款金额。
select "Rule213",id,business_no,order_deadline,plan_dealine,account_state, plan_repay_money,real_repay_money 
from tt_rh_user_base_info where substring(plan_dealine,1,6) > substring(order_deadline,1,6) and account_state='2' and (plan_repay_money<=0 or real_repay_money>=plan_repay_money);


#214 24月（贷款）还款状态最后一位是N,最近一次还款日期与结算应还款日期在同一结算周期内
#结算应还款日期、最近一次还款日期 recently_repay_time、24月（贷款）还款状态 account_repayment_state
#当满足如下条件时：①24月（贷款）还款状态最后一位为N；对如下内容进行校验：①最近一次实际还款日期应晚于结算应还款日期所对应的上一个月的日期（若该日期不存在，则直接对应为月末最后一日）。
select "Rule214",id, plan_dealine, recently_repay_time,account_repayment_state , date_sub(date_sub(plan_dealine,interval extract( day from plan_dealine) day),interval 0 month) ,
if(plan_dealine is null, date_sub(date_sub(plan_dealine,interval extract( day from plan_dealine) day),interval 0 month), date_sub(plan_dealine,interval 1 month))
from tt_rh_user_base_info where  substring(account_repayment_state, 24)='N' 
and recently_repay_time<=if(plan_dealine is null, date_sub(date_sub(plan_dealine,interval extract( day from plan_dealine) day),interval 0 month), date_sub(plan_dealine,interval 1 month))
;
#and DATEDIFF(date_sub(date_sub(plan_dealine,interval extract( day from plan_dealine) day),interval 0 month),recently_repay_time )>0;


#215 贷款未到期剩余还款月数不应为零
#结算应还款日期、到期日期、剩余还款月数
#当满足如下条件时：①结算应还款日期所在月早于到期日期所在月；对如下内容进行校验：①剩余还款月数不应为0。

select "Rule215",id,business_no,plan_dealine,order_deadline,surplus_repay_month 
from tt_rh_user_base_info where substring(plan_dealine,1,6) < substring(order_deadline,1,6) and surplus_repay_month<=0;


-- -------没有配偶证件类型、配偶证件号码
#216 证件号码不应和配偶证件号码相同
#证件类型、证件号码、配偶证件类型、配偶证件号码
#当满足如下条件时：①证件类型为0-身份证且位数为18位时；②配偶证件类型为0-身份证且位数为18位时；对如下内容进行校验：个人基本信息中证件号码不应与配偶的证件号码相同。
select "Rule216",null;

/**
  rule_217
  当满足如下条件时：①婚姻状况为10；
  对如下内容进行校验：配偶姓名、配偶证件号码、配偶工作单位、配偶联系电话其中一项不为空。
  备注：没有婚姻状况字段
  **/
select "Rule217",null;

/**
  rule_218
  当满足如下条件时：
  ①最近一次实际还款日期等于开户日期；
  ②账户状态为1-正常
  对如下内容进行校验：24月还款状态最后一位应为“*”。
  **/
select "Rule218",id from tt_rh_user_base_info where recently_repay_time=account_date and account_state='1' and substring(account_repayment_state, 24) <> '*';

/**
  rule_219
  当满足如下条件时：①24月还款状态最后一位为N；
  对如下内容进行校验：本月应还款金额小于等于本月实际还款金额。
  **/
select "Rule219",id,business_no,plan_dealine,order_deadline,account_repayment_state,plan_repay_money,real_repay_money from tt_rh_user_base_info where substring(account_repayment_state, 24)='N' and plan_repay_money>real_repay_money;

/**
  rule_220
  当满足如下条件时：①账户余额为零；②当前逾期总额为零。对如下内容进行校验：24个月还款状态最后一位应为“C”。
  **/
select "Rule220",id,business_no,balance,current_overdue_money,account_repayment_state from tt_rh_user_base_info where balance=0 and current_overdue_money=0 and substring(account_repayment_state, 24)!='C';

/**
  rule_221
  当满足如下条件时：①证件类型为0-身份证且位数为18位时；对如下内容进行校验：个人基本信息中证件号码与性别是否匹配。
  备注：没有性别字段
  **/
select "Rule221",id from tt_rh_user_base_info where document_type='0' and length(id_card_no)!=18 ;

/**
  rule_222
  当满足如下条件时：①还款频率为“07-一次性”；②当前实际还款金额不等于应还款金额。对如下内容进行校验：账户状态不应为3。
  **/
select "Rule222",id from tt_rh_user_base_info where repay_cycle='07' and real_repay_money<>plan_repay_money and account_state='3';

/**
  rule_223
  当满足如下条件时：①贷款基础数据表中还款频率为“08”；对如下内容进行校验：剩余还款月数和还款月数均应为“U”。
  **/
select "Rule223",id from tt_rh_user_base_info where repay_cycle='08' and (repay_month<>'U' or surplus_repay_month<>'U');

/**
  rule_224
  当满足如下条件时：①贷款基础数据表中还款频率为“07”；对如下内容进行校验：①剩余还款月数和还款月数均用“O”填充；②最高逾期期数应小于等于1；③当前逾期期数应小于等于1。
  **/
select "Rule224",id,business_no from tt_rh_user_base_info where repay_cycle='07' and (surplus_repay_month<>'0' or repay_month<>'0' or max_overdue_period>1 or current_overdue_period>1);

/**
  rule_225
  当满足如下条件时：贷款基础数据表中当前逾期期数为0；对如下内容进行校验：①24个月还款状态最后一位不能为1-7的数字；②账户状态不为“2”或“4”。
  **/
select "Rule225",id,business_no from tt_rh_user_base_info where current_overdue_period=0 and ((substring(account_repayment_state, 24) in ('1','2','3','4','5','6','7') or account_state in ('2', '4')));

/**
  rule_226
  当满足如下条件时：①贷款基础数据表中当前逾期期数为0；②当前逾期总额为0；③结算应还款日期大于等于到期日期，对如下内容进行校验：贷款余额为0。
  **/
select "Rule226",id,business_no from tt_rh_user_base_info where current_overdue_period=0 and current_overdue_money=0 and plan_dealine>=order_deadline and balance<>0;
