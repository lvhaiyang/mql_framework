//+------------------------------------------------------------------+
//|                                               道氏法则判断趋势.mq5 |
//|                                Copyright 吕海洋 QQ交流群:157528427|
//|                            https://www.mql5.com/zh/signals/789037|
//+------------------------------------------------------------------+
#property copyright "Copyright 吕海洋 QQ交流群:157528427"
#property link      "https://www.mql5.com/zh/signals/789037"
#property version   "1.00"

// 上涨趋势：更高的高点和更高的低点
// 下跌趋势：更低的高点和更低的低点
// 思路：
// 1、找到最近的一个高点: 当前50日最高价 high1
// 2、找到第二个高点: 50天前的50日最高价 high2
// 1、找到最近的一个低点: 当前50日最低价 low1
// 2、找到第二个低点: 50天前的50日最低价 low2

string symbol = "EURUSD"
ENUM_TIMEFRAMES timeframe = PERIOD_H4;
int peroid = 50;

double high1 = iHigh(symbol, timeframe, iHighest(symbol,timeframe,MODE_HIGH,peroid,0));
double low1 = iLow(symbol, timeframe, iLowest(symbol,timeframe,MODE_LOW,peroid,0));
double high2 = iHigh(symbol, timeframe, iHighest(symbol,timeframe,MODE_HIGH,peroid,peroid));
double low2 = iLow(symbol, timeframe, iLowest(symbol,timeframe,MODE_LOW,peroid,peroid));

// 上涨趋势
if(high1 > high2 && low1 > low2)
   {
      // 上涨趋势策略
   }
// 下跌趋势
else if(high1 < high2 && low1 < low2)
   {
      // 下跌趋势策略
   }