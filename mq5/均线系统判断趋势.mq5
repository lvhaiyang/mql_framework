//+------------------------------------------------------------------+
//|                                               均线系统判断趋势.mq5 |
//|                                Copyright 吕海洋 QQ交流群:157528427|
//|                            https://www.mql5.com/zh/signals/789037|
//+------------------------------------------------------------------+
#property copyright "Copyright 吕海洋 QQ交流群:157528427"
#property link      "https://www.mql5.com/zh/signals/789037"
#property version   "1.00"

// 上涨趋势：均线多头排列
// 下跌趋势：均线空头排列
// 思路：
// 1、找到3个周期的均线 目前用 8,13,21 MA
// 2、利用均线系统判断趋势

string symbol = "EURUSD"
ENUM_TIMEFRAMES timeframe = PERIOD_H4;
int ma1_peroid = 8;
int ma2_peroid = 13;
int ma3_peroid = 21;

double ma1[]; 
ArraySetAsSeries(ma1,true);
int handle_ma1 = iMA(symbol,timeframe,ma1_peroid,0,MODE_SMA,PRICE_CLOSE);
CopyBuffer(handle_ma1,0,0,3,ma1);

double ma2[]; 
ArraySetAsSeries(ma2,true);
int handle_ma2 = iMA(symbol,timeframe,ma2_peroid,0,MODE_SMA,PRICE_CLOSE);
CopyBuffer(handle_ma2,0,0,3,ma2);

double ma3[]; 
ArraySetAsSeries(ma3,true);
int handle_ma3 = iMA(symbol,timeframe,ma3_peroid,0,MODE_SMA,PRICE_CLOSE);
CopyBuffer(handle_ma3,0,0,3,ma3);

// 上涨趋势
if(ma1[0] > ma2[0] && ma2[0] > ma3[0])
   {
      // 上涨趋势策略
   }
// 下跌趋势
else if(ma1[0] < ma2[0] && ma2[0] < ma3[0])
   {
      // 下跌趋势策略
   }