//+------------------------------------------------------------------+
//|                                                  mt5_ea_demo.mq5 |
//|                                Copyright 吕海洋 QQ交流群:157528427|
//|                            https://www.mql5.com/zh/signals/789037|
//+------------------------------------------------------------------+
#property copyright "Copyright 吕海洋 QQ交流群:157528427"
#property link      "https://www.mql5.com/zh/signals/789037"
#property version   "1.00"

#include <Trade\trade.mqh>
#include <Trade\PositionInfo.mqh>

//EA模板，封装了常用的订单操作，新建的类继承这个模板可以直接调用方法
class TradeSystem
   {
public:
   CTrade trade;
   //获取最后一笔历史订单获利
   //magic_number: 幻数（用来标记是EA建仓的单子）
   //symbol：货币名称
   //cmt: 订单注释信息
   //order_type: 订单类型 "BUY","SELL"
   double GetLastProfit(ulong magic_number, string symbol, string cmt, string order_type)
      {
         ENUM_DEAL_TYPE deal_type;
         
         if(order_type == "BUY")
            {
               deal_type = DEAL_TYPE_SELL;
            }
         else if(order_type == "SELL")
            {
               deal_type = DEAL_TYPE_BUY;
            }
         else return 0;
              
         ulong ticket;
         double last_profit = 0;
         //--- 请求交易历史记录 
         HistorySelect(0,TimeCurrent()); 
         //--- 当前挂单数量 
         int total=HistoryDealsTotal(); 
         //--- 循环检测通过订单 
         for(int i=total -1;i>=0;i--) 
           { 
            //--- 通过其列表中的位置返回订单报价 
               if((ticket=HistoryDealGetTicket(i))>0) 
                  {
                     if(HistoryDealGetInteger(ticket,DEAL_MAGIC)==magic_number && HistoryDealGetString(ticket,DEAL_SYMBOL)==symbol)
                        {
                           if(HistoryDealGetInteger(ticket,DEAL_TYPE)==deal_type && HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                              {
                                 last_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
                                 break;        
                              }
                        }
                  }
           }
           
         return last_profit;
      }

   //获取连续亏损次数
   //magic_number: 幻数（用来标记是EA建仓的单子）
   //symbol：货币名称
   //cmt: 订单注释信息
   //order_type: 订单类型 "BUY","SELL"
   int GetStopLossTimes(ulong magic_number, string symbol, string cmt, string order_type)
      {
         ENUM_DEAL_TYPE deal_type;
         
         if(order_type == "BUY")
            {
               deal_type = DEAL_TYPE_SELL;
            }
         else if(order_type == "SELL")
            {
               deal_type = DEAL_TYPE_BUY;
            } 
         else return 0;
         
         ulong ticket;
         int stop_loss_times = 0;
         //--- 请求交易历史记录 
         HistorySelect(0,TimeCurrent()); 
         //--- 当前挂单数量 
         int total=HistoryDealsTotal(); 
         //--- 循环检测通过订单 
         for(int i=total;i>=0;i--) 
           { 
            //--- 通过其列表中的位置返回订单报价 
               if((ticket=HistoryDealGetTicket(i))>0) 
                  {
                     if(HistoryDealGetInteger(ticket,DEAL_MAGIC)==magic_number && HistoryDealGetString(ticket,DEAL_SYMBOL)==symbol)
                        {
                           if(HistoryDealGetInteger(ticket,DEAL_TYPE)==deal_type && HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
                              {
                                 if(HistoryDealGetDouble(ticket,DEAL_PROFIT) < 0) stop_loss_times++;
                                 else break;        
                              }
                        }
                  }
           }
 
         return stop_loss_times;
      }

   //获取最后一笔历史订单获利
   //magic_number: 幻数（用来标记是EA建仓的单子）
   //symbol：货币名称
   //cmt: 订单注释信息
   //order_type: 订单类型 "BUY","SELL"
   double GetLastPrice(ulong magic_number, string symbol, string cmt, string order_type)
      {
         ENUM_POSITION_TYPE postion_type;
         ENUM_DEAL_TYPE deal_type;
         
         if(order_type == "BUY")
            {
               postion_type = POSITION_TYPE_BUY;
               deal_type = DEAL_TYPE_SELL;
            }
         else if(order_type == "SELL")
            {
               postion_type = POSITION_TYPE_SELL;
               deal_type = DEAL_TYPE_BUY;
            }
         else return 0;
            
         ulong ticket;
         double last_create_price = 0;

         int total = PositionsTotal();
         for(int i=total;i>=0;i--)
            {
               ticket=PositionGetTicket(i);
               if(PositionGetInteger(POSITION_MAGIC)==magic_number && PositionGetString(POSITION_SYMBOL)==symbol)
                  {
                      if(PositionGetInteger(POSITION_TYPE)==postion_type)
                           {
                              last_create_price = PositionGetDouble(POSITION_PRICE_OPEN);
                              break;    
                           }
                  }
            }
         
         return last_create_price;
      }
      
   //开立订单
   //magic_number: 幻数（用来标记是EA建仓的单子）
   //open_lots: 开仓手数
   //symbol：货币名称
   //cmt: 订单注释信息
   //order_type: 订单类型 "BUY","SELL"
   double OpenOrder(ulong magic_number, string symbol, double open_lots, string cmt, string string_order_type)
      {
         ENUM_ORDER_TYPE order_type;
         
         if(string_order_type == "BUY")
            {
               order_type = ORDER_TYPE_BUY;
            }
         else if(string_order_type == "SELL")
            {
               order_type = ORDER_TYPE_SELL;
            }
         else return 0;

         double open_price = 0;
         trade.SetExpertMagicNumber(magic_number);
         trade.PositionOpen(symbol,order_type,open_lots,0,0,0,cmt);
         string info = "【" + cmt + "】";
         if(order_type == ORDER_TYPE_BUY) info += "多单";
         else if(order_type == ORDER_TYPE_SELL) info += "空单";

         //获取返回状态描述信息      
         uint rel_code = trade.ResultRetcode();
         if(rel_code == 10009)
            {
               open_price = trade.ResultPrice();
               info += "开仓成功 : 价格 = " + string(open_price);
               info += ";仓位 = " + string(open_lots);
            }
         else
            {
               info += "开仓失败 : " + string(rel_code);
            }
            
         SendInformation(info);
         return open_price;
      }

   //平仓
   //magic_number: 幻数（用来标记是EA建仓的单子）
   //symbol：货币名称
   //cmt: 订单注释信息
   //order_type: 订单类型 "BUY","SELL"
   bool CloseOrder(ulong magic_number, string symbol, string cmt, string order_type)
      {
         ENUM_POSITION_TYPE postion_type;
         
         if(order_type == "BUY")
            {
               postion_type = POSITION_TYPE_BUY;
            }
         else if(order_type == "SELL")
            {
               postion_type = POSITION_TYPE_SELL;
            }
         else return false;

         double close_price = 0;
         trade.SetExpertMagicNumber(magic_number);
         int total = PositionsTotal();
         for(int i=total;i>=0;i--)
            {
               ulong ticket=PositionGetTicket(i);
               if(PositionGetInteger(POSITION_MAGIC)==magic_number && PositionGetString(POSITION_SYMBOL)==symbol)
                  {
                     if(PositionGetInteger(POSITION_TYPE)==postion_type)
                        {
                           trade.PositionClose(ticket);
                           
                           string info = "【" + cmt + "】";
                           if(postion_type == POSITION_TYPE_BUY) info += "多单";
                           else if(postion_type == POSITION_TYPE_SELL) info += "空单";
                           
                           //获取返回状态描述信息  
                           uint rel_code = trade.ResultRetcode();
                           if(rel_code == 10009)
                              {
                                 close_price = trade.ResultPrice();
                                 double vloume = trade.ResultVolume();
                                 info += "平仓成功 : 价格 = " + string(close_price);
                                 info += ";仓位 = " + string(vloume);
                                 SendInformation(info); 
                                 return true;
                              }
                          else
                              {
                                 info += "平仓失败 : " + string(rel_code);
                                 SendInformation(info);
                                 return false;
                              }   
                        }
                  }
            }
         return false;
      } 

   //获取仓位信息
   //magic_number: 幻数（用来标记是EA建仓的单子）
   //symbol：货币名称
   //cmt: 订单注释信息
   //order_type: 订单类型 "BUY","SELL"
    double GetTotalOrders(ulong magic_number, string symbol, string cmt, string order_type)
         {
         ENUM_POSITION_TYPE postion_type;
         
         if(order_type == "BUY")
            {
               postion_type = POSITION_TYPE_BUY;
            }
         else if(order_type == "SELL")
            {
               postion_type = POSITION_TYPE_SELL;
            }
         else return 0;
         
         ulong ticket;
         double volumes = 0;
         int total = PositionsTotal();
         for(int i=total;i>=0;i--)
            {
               ticket=PositionGetTicket(i);
               if(PositionGetInteger(POSITION_MAGIC)==magic_number && PositionGetString(POSITION_SYMBOL)==symbol)
                  {
                     if(PositionGetInteger(POSITION_TYPE)==postion_type)
                        {
                           volumes += 1;
                        }
                  }
            }
               
           return volumes;
         }
   
    //发送消息    
    //information：要推送手机端/打印的消息
    void SendInformation(string information)
        {
           Print(information);
           SendNotification(information);
        }
   };
 
//EA模板
//两根均线，金叉买入，死叉卖出
class DemoSystem: public TradeSystem
   {
public:
   double base_lots;//每次开仓的数量
   string cmt;//订单注释信息
   ulong magic;//幻数
   string symbol;//货币名字

   double buy_open_price;//多单开仓价格
   double sell_open_price;//空单开仓价格

   int ma_peroid1;//短期均线周期
   int ma_peroid2;//长期均线周期

   //初始化EA系统
   void init(ulong p_magic, double p_lots, int p_ma_period1, int p_ma_period2)
      {
         symbol = Symbol();
         base_lots = p_lots;
         cmt = symbol;
         magic = p_magic;
         ma_peroid1 = p_ma_period1;
         ma_peroid2 = p_ma_period2;

         //初始化信息
         string info = "【" + cmt + "】" + "初始化EA\n";
         info += "ma1:" + string(ma_peroid1) + ";ma2:" + string(ma_peroid2);
         SendInformation(info);
      }

   //多单开仓
   void OpenBuy()
      {
         //检查是否有多单仓位
         double buy_total_orders = GetTotalOrders(magic, symbol, cmt, "BUY");
         // 如果没有仓位就建仓
         if(buy_total_orders == 0)
            {
               buy_open_price = OpenOrder(magic, symbol, base_lots, cmt, "BUY");
            }
      }
   //多单平仓
   void CloseBuy()
      {  
         //检查是否有多单仓位
         double buy_total_orders = GetTotalOrders(magic, symbol, cmt, "BUY");
         //如果有仓位就平仓
         if(buy_total_orders > 0)
            {
               for(int i=0;i<=buy_total_orders;i++)
                  {
                     if(CloseOrder(magic, symbol, cmt, "BUY"))
                        {
                           buy_open_price = 0;
                        }
                  }
            }
      }
   //空单开仓
   void OpenSell()
      {
         //检查是否有空单仓位
         double sell_total_orders = GetTotalOrders(magic, symbol, cmt, "SELL");
         // 如果没有仓位就建仓
         if(sell_total_orders == 0)
            {
               sell_open_price = OpenOrder(magic, symbol, base_lots, cmt, "SELL");
            }
      }
   //空单平仓
   void CloseSell()
      {
         //检查是否有空单仓位
         double sell_total_orders = GetTotalOrders(magic, symbol, cmt, "SELL");
         //如果有仓位就平仓
         if(sell_total_orders > 0)
            {
               for(int i=0;i<=sell_total_orders;i++)
                  {
                     if(CloseOrder(magic, symbol, cmt, "SELL"))
                        {
                           sell_open_price = 0;
                        }
                  }
            }
      }

   //运行EA
   void run()
      {
         //获取行情数据
         double close1 = iClose(symbol, 0, 1);

          // 初始化数组存放ma1指标
         double Buffer_ma1[]; 
         // 时间序列化数组
         ArraySetAsSeries(Buffer_ma1,true);
         // 获取ma指标
         int handle_ma1 = iMA(symbol,0,ma_peroid1,0,MODE_SMA,PRICE_CLOSE);
         // 赋值指标值到数组maBuffer
			CopyBuffer(handle_ma1,0,0,10,Buffer_ma1);
         // 获取当前K线的ma值和上一根K线的ma值
			double ma1_1 = Buffer_ma1[1];
         double ma1_2 = Buffer_ma1[2];

          // 初始化数组存放ma2指标
         double Buffer_ma2[]; 
         // 时间序列化数组
         ArraySetAsSeries(Buffer_ma2,true);
         // 获取ma指标
         int handle_ma2 = iMA(symbol,0,ma_peroid2,0,MODE_SMA,PRICE_CLOSE);
         // 赋值指标值到数组maBuffer
			CopyBuffer(handle_ma2,0,0,10,Buffer_ma2);
         // 获取当前K线的ma值和上一根K线的ma值
			double ma2_1 = Buffer_ma2[1];
         double ma2_2 = Buffer_ma2[2];

         //金叉建多单
         if(ma1_2 < ma2_2 && ma1_1 > ma2_1)
            {
               CloseSell();
               OpenBuy();
            }
         //死叉建空单
         else if(ma1_2 > ma2_2 && ma1_1 < ma2_1)
            {
               CloseBuy();
               OpenSell();
            }
      }
   };

ulong input_magic = 20210101;//幻数
input double input_lots = 0.01;//仓位
input int input_ma_period1 = 10;//MA短周期
input int input_ma_period2 = 50;//MA长周期

// 实例化EA类
DemoSystem ds;

//初始化脚本的时候执行一次
int OnInit()
  {
      ds.init(input_magic, input_lots, input_ma_period1, input_ma_period2);
      return(INIT_SUCCEEDED);
  }

//价格每次变化执行一次
void OnTick()
  {
      ds.run();
  }