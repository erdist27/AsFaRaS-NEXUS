//+------------------------------------------------------------------+
//|                AsFaRaS NEXUS Trading System v1.2                 |
//|         "Beş Sembol. Sonsuz Döngü. Sıfır Zarar."                |
//|                    — AsFaRaS NEXUS —                             |
//+------------------------------------------------------------------+
#property copyright   "AsFaRaS NEXUS System v1.2"
#property link        "https://github.com/erdist27/AsFaRaS-NEXUS"
#property version     "1.20"
#property strict
#property description "Bes Sembol. Sonsuz Dongu. Sifir Zarar."

//+------------------------------------------------------------------+
//| SABİTLER                                                         |
//+------------------------------------------------------------------+
#define NEXUS_VERSION          "1.2.0"
#define NEXUS_SYMBOLS_COUNT    5
#define SYM_GOLD               0
#define SYM_SILVER             1
#define SYM_EURUSD             2
#define SYM_BITCOIN            3
#define SYM_ETHEREUM           4
#define NEXUS_MAGIC_BASE       100000
#define VOLUME_CHECK_START     10
#define VOLUME_CHECK_END       20
#define MAX_SLIPPAGE_MULT      0.5
#define RECOVERY_LOT_BONUS     0.20
#define MAX_RETRY_COUNT        3
#define PROFIT_TARGET_PCT      0.100
#define TRAILING_STOP_PCT      0.050
#define HEALTH_CRITICAL        30
#define HEALTH_WEAK            50
#define HEALTH_NORMAL          75
#define DASH_PREFIX            "NEXUS_"

// Renkler
#define CLR_PANEL_BG           C'24,26,32'
#define CLR_BORDER             C'40,44,52'
#define CLR_TEXT_PRIMARY       C'220,220,230'
#define CLR_TEXT_SECONDARY     C'140,144,152'
#define CLR_PROFIT             C'0,200,100'
#define CLR_LOSS               C'220,50,50'
#define CLR_WARNING            C'255,180,0'
#define CLR_BOOST              C'255,100,0'
#define CLR_HEALTH_HIGH        C'0,200,100'
#define CLR_ACCENT             C'64,128,255'
#define CLR_HEADER             C'30,34,44'

//+------------------------------------------------------------------+
//| INPUT PARAMETRELERİ                                               |
//+------------------------------------------------------------------+
input group "=== SEMBOL AYARLARI ==="
input string  InpSymbolGold      = "XAUUSD";
input string  InpSymbolSilver    = "XAGUSD";
input string  InpSymbolEURUSD    = "EURUSD";
input string  InpSymbolBitcoin   = "BTCUSD";
input string  InpSymbolEthereum  = "ETHUSD";

input group "=== RİSK AYARLARI ==="
input double  InpRiskPercent     = 0.5;
input double  InpMaxDrawdown     = 20.0;
input double  InpDailyLossLimit  = 2.0;
input double  InpMinLot          = 0.01;
input double  InpMaxLot          = 5.0;

input group "=== BOOST AYARLARI ==="
input double  InpBoostThreshPct  = 1.0;
input double  InpBoostX9StopPct  = 10.0;
input double  InpBoostX27StopPct = 20.0;
input double  InpBoostX27ClosePct= 30.0;

input group "=== PIYASA SAĞLIK ==="
input int     InpHealthPeriod    = 20;
input double  InpMinHealthScore  = 30.0;

input group "=== TELEGRAM ==="
input string  InpTelegramToken   = "";
input string  InpTelegramChatID  = "";
input bool    InpTelegramActive  = true;
input int     InpHourlyReport    = 1;
input bool    InpDailyReport     = true;

input group "=== DASHBOARD ==="
input bool    InpShowMiniDash    = true;
input bool    InpShowFullDash    = true;
input int     InpDashX           = 10;
input int     InpDashY           = 30;

input group "=== SİSTEM ==="
input bool    InpDebugMode       = true;
input string  InpLogFileName     = "NEXUS_LOG";
input bool    InpBrokerAutoTest  = true;
input int     InpMagicOffset     = 0;

//+------------------------------------------------------------------+
//| ENUM TANIMLARI                                                    |
//+------------------------------------------------------------------+
enum ENUM_SYSTEM_STATE {
   STATE_INIT,
   STATE_BROKER_TEST,
   STATE_SCANNING,
   STATE_PACKET_OPEN,
   STATE_BOOST_X3,
   STATE_BOOST_X9,
   STATE_BOOST_X27,
   STATE_RECOVERY,
   STATE_PAUSED,
   STATE_ERROR,
   STATE_NEWS_FILTER
};

enum ENUM_MARKET_HEALTH {
   HEALTH_STATE_CRITICAL,
   HEALTH_STATE_WEAK,
   HEALTH_STATE_NORMAL,
   HEALTH_STATE_STRONG
};

enum ENUM_BOOST_STATE {
   BOOST_NONE,
   BOOST_X3_ACTIVE,
   BOOST_X9_ACTIVE,
   BOOST_X27_ACTIVE,
   BOOST_COMPLETED,
   BOOST_FAILED
};

enum ENUM_SYMBOL_CATEGORY {
   CATEGORY_FOREX,
   CATEGORY_METALS,
   CATEGORY_CRYPTO
};

enum ENUM_LOG_LEVEL {
   LOG_DEBUG,
   LOG_INFO,
   LOG_WARNING,
   LOG_ERROR,
   LOG_CRITICAL
};

enum ENUM_TRAILING_LEVEL {
   TRAIL_NONE,
   TRAIL_LEVEL_1,
   TRAIL_LEVEL_2,
   TRAIL_LEVEL_3,
   TRAIL_LEVEL_4,
   TRAIL_COMPLETED
};

enum ENUM_TRAIL_TRIGGER {
   TRIGGER_NONE,
   TRIGGER_BREAKEVEN,
   TRIGGER_LEVEL_UP,
   TRIGGER_STOPPED
};

//+------------------------------------------------------------------+
//| STRUCT TANIMLARI (String içermez - FileWriteStruct uyumlu)       |
//+------------------------------------------------------------------+
struct PacketState {
   ulong             magicID;
   int               symbolIndex;
   double            baseLot;
   int               boostLevel;
   double            buyTicket;
   double            sellTicket;
   double            boostTicket;
   double            openPrice;
   double            spreadAtOpen;
   datetime          openTime;
   datetime          lastUpdateTime;
   bool              isRecovery;
   double            recoveryTarget;
   int               boostState;
   bool              isFirstPacket;
   int               mumDevretCount;
};

struct MarketData {
   double   spread;
   double   avgSpread;
   double   spreadRatio;
   double   atr;
   double   avgVolume;
   double   currentVolume;
   double   healthScore;
   double   bidPrice;
   double   askPrice;
   double   pipValue;
   double   pointValue;
   int      digits;
   double   tickSize;
   double   contractSize;
   int      healthState;
   int      category;
   datetime lastUpdate;
};

struct AccountData {
   double   balance;
   double   equity;
   double   freeMargin;
   double   marginLevel;
   double   drawdown;
   double   dailyPnL;
   double   weeklyPnL;
   double   monthlyPnL;
   double   reserveFund;
   double   totalSpreadPaid;
   double   totalCommission;
   double   totalSwap;
   int      totalPackets;
   int      successPackets;
   int      failedPackets;
   datetime sessionStart;
};

struct StatisticsData {
   int      boostX3Count;
   int      boostX9Count;
   int      boostX27Count;
   int      recoveryCount;
   double   maxDrawdownReached;
   double   bestDayPnL;
   double   worstDayPnL;
   datetime systemStartTime;
};

struct TrailingProfile {
   double   level1TriggerPct;
   double   level2TriggerPct;
   double   level3TriggerPct;
   double   level4TriggerPct;
   double   atrMultLondon;
   double   atrMultNY;
   double   atrMultAsia;
   double   atrMultNight;
   double   minDistancePip;
   double   maxDistancePip;
   int      spikeFilterTicks;
   double   spikeThresholdPct;
   int      mode;
};

struct TrailingState {
   ulong    ticket;
   int      symbolIndex;
   bool     isActive;
   double   peakProfit;
   double   currentProfit;
   double   lockedProfit;
   double   initialProfit;
   double   currentSL;
   double   previousSL;
   double   openPrice;
   double   breakEvenPrice;
   int      level;
   bool     level1Hit;
   bool     level2Hit;
   bool     level3Hit;
   bool     level4Hit;
   double   tickHistory[5];
   int      tickCount;
   datetime activeSince;
   datetime lastUpdate;
   datetime lastLevelUp;
   int      updateCount;
   int      levelUpCount;
   int      lastTrigger;
};

struct TrailingStats {
   int      totalActivations;
   int      breakevenHits;
   int      level2Hits;
   int      level3Hits;
   int      level4Hits;
   int      stoppedByTrail;
   double   totalLockedProfit;
};

struct BrokerCapabilities {
   bool     hedgeAllowed;
   double   minLot;
   double   maxLot;
   double   lotStep;
   int      stopLevel;
   bool     testPassed;
};

//+------------------------------------------------------------------+
//| GLOBAL DEĞİŞKENLER                                               |
//+------------------------------------------------------------------+
string             g_symbols[NEXUS_SYMBOLS_COUNT];
AccountData        g_account;
StatisticsData     g_stats;
BrokerCapabilities g_broker;
ulong              g_magicIDs[NEXUS_SYMBOLS_COUNT];
ENUM_SYSTEM_STATE  g_systemStates[NEXUS_SYMBOLS_COUNT];
MarketData         g_marketData[NEXUS_SYMBOLS_COUNT];
PacketState        g_packets[NEXUS_SYMBOLS_COUNT];
TrailingProfile    g_trailingProfiles[NEXUS_SYMBOLS_COUNT];
TrailingState      g_trailingStates[NEXUS_SYMBOLS_COUNT];
TrailingStats      g_trailingStats;
datetime           g_lastM5Time[NEXUS_SYMBOLS_COUNT];
datetime           g_lastHourlyReport;
datetime           g_lastDailyReport;
datetime           g_systemStartTime;
bool               g_isInitialized  = false;
bool               g_systemPaused   = false;
bool               g_emergencyStop  = false;
int                g_logFileHandle  = INVALID_HANDLE;
datetime           g_lastDashUpdate = 0;

// Motivasyon
string   g_currentQuote   = "";
datetime g_lastQuoteTime  = 0;
int      g_currentQuoteIdx= 0;

string g_quotesSabir[] = {
   "Sabir, basarinin sessiz ama en guclu motorudur.",
   "Dogru an icin beklemek, aceleci kaybetmekten iyidir.",
   "Piyasa test eder. Sabir kazanir.",
   "Her bekleme ani, bir sonraki firsat icin hazirlanmaktir.",
   "Sabir bir erdem degil, bir stratejidir.",
   "En iyi islemler zorla degil, bekleyerek gelir.",
   "Durmak zayiflik degil, dogru ani kollamaktir.",
   "Firsat kapiya vurmaz, sen ona hazir olursun."
};
string g_quotesGuc[] = {
   "Sistem calisir. Sen sisteme guven.",
   "Her pip, disiplinin bir oduludur.",
   "Guclu sistem, guclu sonuc uretir.",
   "Korkma. Sistem seni koruyor.",
   "Simdi odaklan. Kalanini sistem halleder.",
   "Her mumda bir firsat var. Sistem gorur.",
   "Algoritma yorulmaz. Sen de yorulma.",
   "Guc, belirsizlik icinde sakin kalmaktir."
};
string g_quotesDisipl[] = {
   "Kural bozulmaz. Sistem bozulmaz.",
   "Disiplin, en karli yatirimdir.",
   "Duygular satar. Sistem kazanir.",
   "Plan ne diyorsa o olur. Sapma yok.",
   "Bir islem degil, bir sistem insa ediyoruz.",
   "Bugunku disiplin, yarinin ozgurluğudur.",
   "Her kapanan mum yeni bir kuralin ispatidir.",
   "Sistem konustu. Karar verildi."
};
string g_quotesVizyon[] = {
   "Bugun ekilenler yarin bicilenlerdir.",
   "Buyuk resmi gormeyen kucuk kayipte bogulur.",
   "Her islem bir adim. Yolculuk suruyor.",
   "Kucuk karlar, buyuk hayallerin tuglalaridir.",
   "Bak nereye gittigine, nereden geldigini bilirsin.",
   "Her gece kapanis bir sonraki safagin baslangicidir.",
   "Zaman, en iyi ortaginizdir.",
   "Vizyon olmadan sistem calisir ama nereye?"
};
string g_quotesGece[] = {
   "Sistem uyumaz. Sen uyu, o calisir.",
   "Gece sessizligi, piyasanin derin nefesidir.",
   "Her sabah sifirdan baslamak bir avantajdir.",
   "Karanlikta cok isler olur. Sistem gozetler.",
   "Dinlenmek de bir stratejidir.",
   "Algoritma gece de dusunur.",
   "Uyurken sistem buyur.",
   "Sabah geldiginde sistem hazir olacak."
};
string g_quotesRecovery[] = {
   "Firtina ne kadar surerse surSun, gunes hep dogar.",
   "Dusmek utanc degil, kalkmamak utanctir.",
   "Her zarar, bir sonraki kazancin ogretmenidir.",
   "Sistem bir kez dustu, bin kez kalkar.",
   "Geri cekilmek bazen en ileri adimdir.",
   "Kriz, sistemi daha guclu yapar.",
   "Bu da gecer. Sistem devam eder.",
   "En buyuk kazananlar en cok dusup kalkanlardir."
};
string g_quotesBoost[] = {
   "Firsat yakalandi. Sistem devrede!",
   "Boost aktif. Guven tam.",
   "Sistem gucunu gosteriyor!",
   "Bu an icin tasarlandik.",
   "Algoritma devrede. Sonuc gelecek.",
   "x katli guc, x katli ozguven.",
   "Sistem savasiyor. Sen izle.",
   "Hazirlik bu anin icindi."
};

//+------------------------------------------------------------------+
//| YARDIMCI FONKSİYONLAR                                            |
//+------------------------------------------------------------------+
ulong GenerateMagicID(int symbolIndex) {
   ulong timeSeed=(ulong)(TimeCurrent()%9999);
   return NEXUS_MAGIC_BASE+
          (ulong)(symbolIndex*10000)+
          timeSeed+
          (ulong)InpMagicOffset;
}

ENUM_SYMBOL_CATEGORY GetSymbolCategory(string symbol) {
   string sym=symbol;
   StringToUpper(sym);
   if(StringFind(sym,"XAU")>=0||StringFind(sym,"XAG")>=0||
      StringFind(sym,"GOLD")>=0||StringFind(sym,"SILVER")>=0)
      return CATEGORY_METALS;
   if(StringFind(sym,"BTC")>=0||StringFind(sym,"ETH")>=0||
      StringFind(sym,"BITCOIN")>=0||StringFind(sym,"ETHEREUM")>=0)
      return CATEGORY_CRYPTO;
   return CATEGORY_FOREX;
}

double GetPipValue(string symbol) {
   double tickValue=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize =SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double point    =SymbolInfoDouble(symbol,SYMBOL_POINT);
   int    digits   =(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double pipSize  =(digits==3||digits==5)?point*10:point;
   if(tickSize<=0) return 0;
   return (tickValue/tickSize)*pipSize;
}

double GetCurrentSpread(string symbol) {
   double ask  =SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid  =SymbolInfoDouble(symbol,SYMBOL_BID);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0) return 0;
   return (ask-bid)/point;
}

double NormalizeLot(string symbol,double lot) {
   double minLot =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double maxLot =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double lotStep=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   if(lotStep<=0) lotStep=0.01;
   lot=MathMax(lot,MathMax(minLot,InpMinLot));
   lot=MathMin(lot,MathMin(maxLot,InpMaxLot));
   lot=MathRound(lot/lotStep)*lotStep;
   return NormalizeDouble(lot,2);
}

double CalculateBaseLot(string symbol,bool isRecovery=false) {
   double balance =AccountInfoDouble(ACCOUNT_BALANCE);
   double pipValue=GetPipValue(symbol);
   if(pipValue<=0) return InpMinLot;
   double riskPct =InpRiskPercent/100.0;
   double maxPip  =30.0;
   ENUM_SYMBOL_CATEGORY cat=GetSymbolCategory(symbol);
   if(cat==CATEGORY_CRYPTO)      {maxPip=50.0;riskPct*=0.7;}
   else if(cat==CATEGORY_METALS)  maxPip=35.0;
   double baseLot=(balance*riskPct)/(maxPip*pipValue*27.0);
   if(isRecovery) baseLot*=(1.0+RECOVERY_LOT_BONUS);
   return NormalizeLot(symbol,baseLot);
}

string IntStr(int val) {
   return IntegerToString(val);
}

string StringRepeat(string s,int count) {
   string r="";
   for(int i=0;i<count;i++) r+=s;
   return r;
}

string DrawProgressBar(double value,double maxVal,int barLen) {
   int filled=(int)MathRound((value/maxVal)*barLen);
   filled=MathMax(0,MathMin(barLen,filled));
   string bar="[";
   for(int i=0;i<barLen;i++) bar+=(i<filled)?"█":"░";
   return bar+"]";
}

//+------------------------------------------------------------------+
//| LOG SİSTEMİ                                                      |
//+------------------------------------------------------------------+
void NexusLog(ENUM_LOG_LEVEL level,string symbol,string message) {
   if(!InpDebugMode&&level==LOG_DEBUG) return;
   string levelStr,prefix;
   switch(level) {
      case LOG_DEBUG:    levelStr="DEBUG"; prefix="[D]"; break;
      case LOG_INFO:     levelStr="INFO "; prefix="[I]"; break;
      case LOG_WARNING:  levelStr="WARN "; prefix="[W]"; break;
      case LOG_ERROR:    levelStr="ERROR"; prefix="[E]"; break;
      case LOG_CRITICAL: levelStr="CRIT "; prefix="[!]"; break;
      default:           levelStr="UNKN "; prefix="[?]"; break;
   }
   string timeStr=TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   string logLine=StringFormat("[%s][%-6s][%s] %s %s",
                  timeStr,symbol,levelStr,prefix,message);
   Print(logLine);
   if(g_logFileHandle!=INVALID_HANDLE) {
      FileWrite(g_logFileHandle,logLine);
      FileFlush(g_logFileHandle);
   }
   if(level==LOG_CRITICAL) {
      string teleMsg=StringFormat(
         "ASFARAS NEXUS KRITIK\n%s\n%s\n%s",
         symbol,message,timeStr);
      SendTelegramMessage(teleMsg);
   }
}

void OpenLogFile() {
   string fileName=StringFormat("%s.log",InpLogFileName);
   g_logFileHandle=FileOpen(fileName,
                  FILE_WRITE|FILE_READ|FILE_TXT|
                  FILE_ANSI|FILE_SHARE_READ);
   if(g_logFileHandle==INVALID_HANDLE) return;
   FileSeek(g_logFileHandle,0,SEEK_END);
   FileWrite(g_logFileHandle,
      "=== AsFaRaS NEXUS v"+NEXUS_VERSION+" LOG ===");
   FileFlush(g_logFileHandle);
}

//+------------------------------------------------------------------+
//| TELEGRAM                                                          |
//+------------------------------------------------------------------+
void SendTelegramMessage(string message) {
   if(!InpTelegramActive) return;
   if(InpTelegramToken==""||InpTelegramChatID=="") return;
   string url=StringFormat(
      "https://api.telegram.org/bot%s/sendMessage",
      InpTelegramToken);
   string body=StringFormat(
      "chat_id=%s&text=%s&parse_mode=HTML",
      InpTelegramChatID,message);
   char postData[],resultData[];
   string resultHeaders;
   StringToCharArray(body,postData,0,StringLen(body),CP_UTF8);
   string headers="Content-Type: "
                  "application/x-www-form-urlencoded\r\n";
   int res=WebRequest("POST",url,headers,5000,
                      postData,resultData,resultHeaders);
   if(res==-1)
      NexusLog(LOG_WARNING,"TELEGRAM",
         StringFormat("Hata:%d",GetLastError()));
}

void SendTelegramAlert(int symIdx,string title,bool isCritical) {
   string symName=GetSymbolShortName(symIdx);
   double health =g_marketData[symIdx].healthScore;
   double pnl    =GetPacketPnL(symIdx);
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   string icon   =isCritical?"[KRİTİK]":"[UYARI]";
   string msg=StringFormat(
      "%s AsFaRaS NEXUS\n"
      "Sembol: %s\n"
      "Durum: %s\n"
      "P&L: %+.2f$\n"
      "Bakiye: $%.2f\n"
      "Saglik: %.0f/100\n"
      "Boost: %s\n"
      "%s",
      icon,symName,title,pnl,balance,health,
      GetBoostString(symIdx),
      TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   SendTelegramMessage(msg);
}

void SendHourlyReport() {
   datetime now=TimeCurrent();
   if((int)(now-g_lastHourlyReport)<InpHourlyReport*3600) return;
   g_lastHourlyReport=now;
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double equity =AccountInfoDouble(ACCOUNT_EQUITY);
   int total     =g_account.totalPackets;
   int success   =g_account.successPackets;
   double wr     =total>0?(double)success/total*100:0;
   string symInfo="";
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      double h  =g_marketData[i].healthScore;
      double pnl=GetPacketPnL(i);
      symInfo+=StringFormat("%s: Saglik=%.0f P&L=%+.2f$\n",
               GetSymbolShortName(i),h,pnl);
   }
   string msg=StringFormat(
      "AsFaRaS NEXUS SAATLIK RAPOR\n"
      "%s\n\n"
      "Bakiye: $%.2f\n"
      "Equity: $%.2f\n\n"
      "%s\n"
      "Boost x3/x9/x27: %d/%d/%d\n"
      "Basari: %d/%d (%.1f%%)\n"
      "Recovery: %d\n\n"
      "%s\n"
      "AsFaRaS NEXUS",
      TimeToString(now,TIME_DATE|TIME_MINUTES),
      balance,equity,symInfo,
      g_stats.boostX3Count,
      g_stats.boostX9Count,
      g_stats.boostX27Count,
      success,total,wr,
      g_stats.recoveryCount,
      g_currentQuote);
   SendTelegramMessage(msg);
}

void SendDailyReport() {
   if(!InpDailyReport) return;
   MqlDateTime dtNow,dtLast;
   TimeToStruct(TimeCurrent(),dtNow);
   TimeToStruct(g_lastDailyReport,dtLast);
   if(dtNow.day==dtLast.day&&dtNow.mon==dtLast.mon) return;
   g_lastDailyReport=TimeCurrent();
   double balance =AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyPnL=g_account.dailyPnL;
   string icon    =dailyPnL>=0?"[+]":"[-]";
   string msg=StringFormat(
      "AsFaRaS NEXUS GUNLUK RAPOR\n"
      "%s\n\n"
      "%s Gunluk P&L: %+.2f$\n"
      "Bakiye: $%.2f\n"
      "Max DD: %.2f%%\n"
      "Basari: %.1f%%\n"
      "Recovery: %d\n\n"
      "%s\n"
      "AsFaRaS NEXUS",
      TimeToString(TimeCurrent(),TIME_DATE),
      icon,dailyPnL,balance,
      g_stats.maxDrawdownReached,
      g_account.totalPackets>0?
      (double)g_account.successPackets/
       g_account.totalPackets*100:0,
      g_stats.recoveryCount,
      g_currentQuote);
   SendTelegramMessage(msg);
}

//+------------------------------------------------------------------+
//| PİYASA SAĞLIK                                                    |
//+------------------------------------------------------------------+
double CalcSpreadFactor(int symIdx) {
   double curSpread=GetCurrentSpread(g_symbols[symIdx]);
   double avgSpread=g_marketData[symIdx].avgSpread;
   if(avgSpread<=0) avgSpread=curSpread;
   if(curSpread<=0) return 0;
   double ratio=MathMax(0.1,MathMin(2.0,avgSpread/curSpread));
   return MathMax(0,MathMin(25.0,(ratio/2.0)*25.0));
}

double CalcVolumeFactor(int symIdx) {
   long curVolume=iVolume(g_symbols[symIdx],PERIOD_M5,0);
   double avgVol =g_marketData[symIdx].avgVolume;
   if(avgVol<=0) avgVol=(double)curVolume;
   if(curVolume<=0) return 12.5;
   double ratio=MathMax(0.1,MathMin(3.0,(double)curVolume/avgVol));
   double score;
   if(ratio>=0.5&&ratio<=1.5)  score=25.0;
   else if(ratio<0.5)          score=ratio*2.0*25.0;
   else                        score=MathMax(10.0,25.0-(ratio-1.5)*10.0);
   return MathMax(0,MathMin(25.0,score));
}

double CalcVolatilityFactor(int symIdx) {
   string symbol=g_symbols[symIdx];
   int atrHandle=iATR(symbol,PERIOD_M5,InpHealthPeriod);
   if(atrHandle==INVALID_HANDLE) return 12.5;
   double atrBuf[];
   ArraySetAsSeries(atrBuf,true);
   double curATR=0;
   if(CopyBuffer(atrHandle,0,0,2,atrBuf)>=2)
      curATR=atrBuf[0];
   IndicatorRelease(atrHandle);
   if(curATR<=0) return 12.5;
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   g_marketData[symIdx].atr=curATR;
   double idealMin,idealMax;
   int cat=g_marketData[symIdx].category;
   if(cat==CATEGORY_CRYPTO)      {idealMin=point*100;idealMax=point*500;}
   else if(cat==CATEGORY_METALS) {idealMin=point*50; idealMax=point*200;}
   else                          {idealMin=point*5;  idealMax=point*20; }
   double score;
   if(curATR>=idealMin&&curATR<=idealMax) score=25.0;
   else if(curATR<idealMin) score=(curATR/idealMin)*25.0;
   else score=MathMax(5.0,25.0-((curATR-idealMax)/idealMax)*15.0);
   return MathMax(0,MathMin(25.0,score));
}

double CalcMomentumFactor(int symIdx) {
   string symbol=g_symbols[symIdx];
   double closeArr[];
   ArraySetAsSeries(closeArr,true);
   if(CopyClose(symbol,PERIOD_M5,0,5,closeArr)<5) return 12.5;
   double momentum=0;
   for(int i=0;i<4;i++)
      momentum+=MathAbs(closeArr[i]-closeArr[i+1]);
   double point   =SymbolInfoDouble(symbol,SYMBOL_POINT);
   double avgMove =momentum/4.0;
   double idealMove;
   int cat=g_marketData[symIdx].category;
   if(cat==CATEGORY_CRYPTO)      idealMove=point*50;
   else if(cat==CATEGORY_METALS) idealMove=point*20;
   else                          idealMove=point*3;
   if(idealMove<=0) return 12.5;
   double ratio=MathMax(0.1,MathMin(3.0,avgMove/idealMove));
   double score;
   if(ratio>=0.5&&ratio<=1.5)  score=25.0;
   else if(ratio<0.5)          score=ratio*2.0*25.0;
   else                        score=MathMax(5.0,25.0-(ratio-1.5)*15.0);
   return MathMax(0,MathMin(25.0,score));
}

double GetSessionMultiplier(int symIdx) {
   MqlDateTime dt;
   TimeToStruct(TimeGMT(),dt);
   int hour=dt.hour;
   int dow =dt.day_of_week;
   int cat =g_marketData[symIdx].category;
   if(cat==CATEGORY_CRYPTO) {
      if(dow==0||dow==6){if(hour<6)return 0.5;return 0.75;}
      if(hour<6)          return 0.7;
      if(hour>=14&&hour<22) return 1.0;
      return 0.85;
   }
   if(dow==0||dow==6)       return 0.2;
   if(hour<6)               return 0.4;
   if(hour>=6 &&hour<8)     return 0.6;
   if(hour>=8 &&hour<17)    return 1.0;
   if(hour>=17&&hour<20)    return 0.9;
   return 0.7;
}

double CalculateHealthScore(int symIdx) {
   double total=(CalcSpreadFactor(symIdx)+
                 CalcVolumeFactor(symIdx)+
                 CalcVolatilityFactor(symIdx)+
                 CalcMomentumFactor(symIdx))*
                 GetSessionMultiplier(symIdx);
   total=MathMax(0,MathMin(100.0,total));
   g_marketData[symIdx].healthScore=total;
   if(total<=HEALTH_CRITICAL)
      g_marketData[symIdx].healthState=HEALTH_STATE_CRITICAL;
   else if(total<=HEALTH_WEAK)
      g_marketData[symIdx].healthState=HEALTH_STATE_WEAK;
   else if(total<=HEALTH_NORMAL)
      g_marketData[symIdx].healthState=HEALTH_STATE_NORMAL;
   else
      g_marketData[symIdx].healthState=HEALTH_STATE_STRONG;
   return total;
}

void UpdateAverageSpread(int symIdx) {
   double cur=GetCurrentSpread(g_symbols[symIdx]);
   double alpha=0.1;
   if(g_marketData[symIdx].avgSpread<=0)
      g_marketData[symIdx].avgSpread=cur;
   else
      g_marketData[symIdx].avgSpread=
         alpha*cur+(1.0-alpha)*g_marketData[symIdx].avgSpread;
   g_marketData[symIdx].spread=cur;
   if(g_marketData[symIdx].avgSpread>0)
      g_marketData[symIdx].spreadRatio=
         cur/g_marketData[symIdx].avgSpread;
}

void UpdateAverageVolume(int symIdx) {
   long curVol=iVolume(g_symbols[symIdx],PERIOD_M5,1);
   double alpha=0.1;
   if(g_marketData[symIdx].avgVolume<=0)
      g_marketData[symIdx].avgVolume=(double)curVol;
   else
      g_marketData[symIdx].avgVolume=
         alpha*(double)curVol+
         (1.0-alpha)*g_marketData[symIdx].avgVolume;
   g_marketData[symIdx].currentVolume=(double)curVol;
}

double CalculateBoostThreshold(int symIdx) {
   double spread     =g_marketData[symIdx].spread;
   double healthScore=g_marketData[symIdx].healthScore;
   double baseThresh =spread*InpBoostThreshPct;
   double healthMult =0.5+(healthScore/100.0);
   double threshold  =baseThresh*healthMult;
   int cat=g_marketData[symIdx].category;
   if(cat==CATEGORY_CRYPTO)      threshold*=2.0;
   else if(cat==CATEGORY_METALS) threshold*=1.3;
   return MathMax(threshold,spread*0.5);
}

bool IsVolumeDipDetected(int symIdx) {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   int sec=dt.sec;
   if(sec<VOLUME_CHECK_START||sec>VOLUME_CHECK_END) return false;
   long curVolume=iVolume(g_symbols[symIdx],PERIOD_M1,0);
   double avgVol =g_marketData[symIdx].avgVolume;
   if(avgVol<=0) return true;
   return (curVolume<avgVol*0.30);
}

//+------------------------------------------------------------------+
//| PAKET YÖNETİMİ                                                   |
//+------------------------------------------------------------------+
bool HasActivePacket(int symIdx) {
   string symbol=g_symbols[symIdx];
   ulong  magic =g_magicIDs[symIdx];
   for(int i=PositionsTotal()-1;i>=0;i--) {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)==symbol&&
         PositionGetInteger(POSITION_MAGIC)==(long)magic)
         return true;
   }
   return false;
}

double GetPacketPnL(int symIdx) {
   string symbol=g_symbols[symIdx];
   ulong  magic =g_magicIDs[symIdx];
   double total =0;
   for(int i=PositionsTotal()-1;i>=0;i--) {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)==symbol&&
         PositionGetInteger(POSITION_MAGIC)==(long)magic)
         total+=PositionGetDouble(POSITION_PROFIT)+
                PositionGetDouble(POSITION_SWAP);
   }
   return total;
}

ulong OpenOrder(string symbol,ENUM_ORDER_TYPE type,
                double lot,string comment,ulong magic,
                double sl=0,double tp=0) {
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);
   double price=(type==ORDER_TYPE_BUY)?
                SymbolInfoDouble(symbol,SYMBOL_ASK):
                SymbolInfoDouble(symbol,SYMBOL_BID);
   double spread=SymbolInfoDouble(symbol,SYMBOL_ASK)-
                 SymbolInfoDouble(symbol,SYMBOL_BID);
   double point =SymbolInfoDouble(symbol,SYMBOL_POINT);
   int slipPoints=point>0?
                  (int)MathMax(3,(spread*MAX_SLIPPAGE_MULT)/point):3;
   request.action   =TRADE_ACTION_DEAL;
   request.symbol   =symbol;
   request.volume   =lot;
   request.type     =type;
   request.price    =price;
   request.deviation=slipPoints;
   request.magic    =magic;
   request.comment  =comment;
   request.type_filling=ORDER_FILLING_IOC;
   if(sl>0) request.sl=sl;
   if(tp>0) request.tp=tp;
   for(int retry=0;retry<MAX_RETRY_COUNT;retry++) {
      if(OrderSend(request,result)&&
         result.retcode==TRADE_RETCODE_DONE) {
         NexusLog(LOG_INFO,symbol,
            StringFormat("Acildi %s Lot:%.2f T:%d",
            type==ORDER_TYPE_BUY?"BUY":"SELL",
            lot,(int)result.deal));
         return result.deal;
      }
      Sleep(500);
      price=(type==ORDER_TYPE_BUY)?
             SymbolInfoDouble(symbol,SYMBOL_ASK):
             SymbolInfoDouble(symbol,SYMBOL_BID);
      request.price=price;
   }
   NexusLog(LOG_ERROR,symbol,
      StringFormat("Acilamadi! Hata:%d",result.retcode));
   return 0;
}

bool CloseOrder(string symbol,ulong ticket,string reason) {
   if(!PositionSelectByTicket(ticket)) return false;
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);
   ENUM_POSITION_TYPE posType=
      (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   request.action  =TRADE_ACTION_DEAL;
   request.symbol  =symbol;
   request.volume  =PositionGetDouble(POSITION_VOLUME);
   request.type    =(posType==POSITION_TYPE_BUY)?
                    ORDER_TYPE_SELL:ORDER_TYPE_BUY;
   request.price   =(posType==POSITION_TYPE_BUY)?
                    SymbolInfoDouble(symbol,SYMBOL_BID):
                    SymbolInfoDouble(symbol,SYMBOL_ASK);
   request.position=ticket;
   request.deviation=10;
   request.comment ="ANX:"+reason;
   request.type_filling=ORDER_FILLING_IOC;
   for(int retry=0;retry<MAX_RETRY_COUNT;retry++) {
      if(OrderSend(request,result)&&
         result.retcode==TRADE_RETCODE_DONE) return true;
      Sleep(300);
      request.price=(posType==POSITION_TYPE_BUY)?
                    SymbolInfoDouble(symbol,SYMBOL_BID):
                    SymbolInfoDouble(symbol,SYMBOL_ASK);
   }
   return false;
}

bool CloseAllPacketOrders(int symIdx,string reason) {
   string symbol=g_symbols[symIdx];
   ulong  magic =g_magicIDs[symIdx];
   bool   allOK =true;
   for(int i=PositionsTotal()-1;i>=0;i--) {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=(long)magic) continue;
      if(!CloseOrder(symbol,ticket,reason)) allOK=false;
   }
   if(allOK) {
      g_packets[symIdx].boostState =BOOST_NONE;
      g_packets[symIdx].buyTicket  =0;
      g_packets[symIdx].sellTicket =0;
      g_packets[symIdx].boostTicket=0;
      g_systemStates[symIdx]=STATE_SCANNING;
   }
   return allOK;
}

bool CheckLossLimits() {
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double equity =AccountInfoDouble(ACCOUNT_EQUITY);
   if(balance<=0) return false;
   double drawdown=(balance-equity)/balance*100.0;
   if(drawdown>=InpMaxDrawdown) {
      NexusLog(LOG_CRITICAL,"SYSTEM",
         StringFormat("MAX DRAWDOWN! %.2f%%",drawdown));
      g_emergencyStop=true;
      return false;
   }
   double dailyLimit=balance*(InpDailyLossLimit/100.0);
   if(g_account.dailyPnL<-dailyLimit) {
      NexusLog(LOG_ERROR,"SYSTEM","Gunluk zarar limiti!");
      return false;
   }
   return true;
}

bool CheckMarginSafety(int symIdx) {
   double freeMargin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double balance   =AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance<=0) return false;
   double minRequired=balance*0.20;
   if(freeMargin<minRequired) {
      NexusLog(LOG_WARNING,g_symbols[symIdx],
         StringFormat("Dusuk Margin! $%.2f",freeMargin));
      return false;
   }
   return true;
}

bool OpenInitialPacket(int symIdx) {
   string symbol=g_symbols[symIdx];
   ulong  magic =g_magicIDs[symIdx];
   if(HasActivePacket(symIdx)) return false;
   double lot=0.01;
   ulong buyT =OpenOrder(symbol,ORDER_TYPE_BUY, lot,"ANX_INIT_BUY",magic);
   ulong sellT=OpenOrder(symbol,ORDER_TYPE_SELL,lot,"ANX_INIT_SEL",magic);
   if(buyT>0&&sellT>0) {
      g_packets[symIdx].buyTicket    =(double)buyT;
      g_packets[symIdx].sellTicket   =(double)sellT;
      g_packets[symIdx].baseLot      =lot;
      g_packets[symIdx].openTime     =TimeCurrent();
      g_packets[symIdx].isFirstPacket=true;
      g_packets[symIdx].boostState   =BOOST_NONE;
      g_packets[symIdx].spreadAtOpen =GetCurrentSpread(symbol);
      g_packets[symIdx].mumDevretCount=0;
      g_systemStates[symIdx]=STATE_PACKET_OPEN;
      g_account.totalPackets++;
      NexusLog(LOG_INFO,symbol,"Ilk paket acildi (0.01 lot)");
      return true;
   }
   return false;
}

bool OpenNormalPacket(int symIdx) {
   string symbol=g_symbols[symIdx];
   ulong  magic =g_magicIDs[symIdx];
   if(HasActivePacket(symIdx)) return false;
   if(g_marketData[symIdx].healthScore<InpMinHealthScore) {
      g_systemStates[symIdx]=STATE_PAUSED;
      return false;
   }
   if(!CheckLossLimits())       return false;
   if(!CheckMarginSafety(symIdx)) return false;
   bool isRecovery=(g_systemStates[symIdx]==STATE_RECOVERY);
   double lot=CalculateBaseLot(symbol,isRecovery);
   ulong buyT =OpenOrder(symbol,ORDER_TYPE_BUY,lot,
               isRecovery?"ANX_REC_BUY":"ANX_BUY",magic);
   ulong sellT=OpenOrder(symbol,ORDER_TYPE_SELL,lot,
               isRecovery?"ANX_REC_SEL":"ANX_SELL",magic);
   if(buyT>0&&sellT>0) {
      g_packets[symIdx].buyTicket    =(double)buyT;
      g_packets[symIdx].sellTicket   =(double)sellT;
      g_packets[symIdx].baseLot      =lot;
      g_packets[symIdx].openTime     =TimeCurrent();
      g_packets[symIdx].isFirstPacket=false;
      g_packets[symIdx].boostState   =BOOST_NONE;
      g_packets[symIdx].spreadAtOpen =GetCurrentSpread(symbol);
      g_packets[symIdx].mumDevretCount=0;
      g_systemStates[symIdx]=STATE_PACKET_OPEN;
      g_account.totalPackets++;
      return true;
   }
   return false;
}

bool OpenBoostX3(int symIdx) {
   string symbol  =g_symbols[symIdx];
   ulong  magic   =g_magicIDs[symIdx];
   double boostLot=NormalizeLot(symbol,
                   g_packets[symIdx].baseLot*3.0);
   ulong  buyTkt  =(ulong)g_packets[symIdx].buyTicket;
   ulong  sellTkt =(ulong)g_packets[symIdx].sellTicket;
   double buyPnL=0,sellPnL=0;
   if(PositionSelectByTicket(buyTkt))
      buyPnL =PositionGetDouble(POSITION_PROFIT);
   if(PositionSelectByTicket(sellTkt))
      sellPnL=PositionGetDouble(POSITION_PROFIT);
   ENUM_ORDER_TYPE boostType=
      (buyPnL<sellPnL)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
   ulong boostT=OpenOrder(symbol,boostType,boostLot,
                "ANX_BST_X3",magic);
   if(boostT>0) {
      g_packets[symIdx].boostTicket=(double)boostT;
      g_packets[symIdx].boostLevel =3;
      g_packets[symIdx].boostState =BOOST_X3_ACTIVE;
      g_systemStates[symIdx]       =STATE_BOOST_X3;
      g_stats.boostX3Count++;
      SendTelegramAlert(symIdx,"x3 BOOST AKTIF",false);
      return true;
   }
   return false;
}

bool OpenBoostX9(int symIdx) {
   string symbol  =g_symbols[symIdx];
   ulong  magic   =g_magicIDs[symIdx];
   double boostLot=NormalizeLot(symbol,
                   g_packets[symIdx].baseLot*9.0);
   ulong  prevBoost=(ulong)g_packets[symIdx].boostTicket;
   ENUM_ORDER_TYPE boostType=ORDER_TYPE_BUY;
   if(PositionSelectByTicket(prevBoost)) {
      ENUM_POSITION_TYPE pt=
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      boostType=(pt==POSITION_TYPE_BUY)?
                 ORDER_TYPE_SELL:ORDER_TYPE_BUY;
   }
   if(prevBoost>0) CloseOrder(symbol,prevBoost,"x3_x9");
   ulong boostT=OpenOrder(symbol,boostType,boostLot,
                "ANX_BST_X9",magic);
   if(boostT>0) {
      g_packets[symIdx].boostTicket=(double)boostT;
      g_packets[symIdx].boostLevel =9;
      g_packets[symIdx].boostState =BOOST_X9_ACTIVE;
      g_systemStates[symIdx]       =STATE_BOOST_X9;
      g_stats.boostX9Count++;
      SendTelegramAlert(symIdx,"x9 BOOST DIKKAT!",true);
      return true;
   }
   return false;
}

bool OpenBoostX27(int symIdx) {
   string symbol  =g_symbols[symIdx];
   ulong  magic   =g_magicIDs[symIdx];
   double boostLot=NormalizeLot(symbol,
                   g_packets[symIdx].baseLot*27.0);
   ulong  prevBoost=(ulong)g_packets[symIdx].boostTicket;
   ENUM_ORDER_TYPE boostType=ORDER_TYPE_BUY;
   if(PositionSelectByTicket(prevBoost)) {
      ENUM_POSITION_TYPE pt=
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      boostType=(pt==POSITION_TYPE_BUY)?
                 ORDER_TYPE_SELL:ORDER_TYPE_BUY;
   }
   if(prevBoost>0) CloseOrder(symbol,prevBoost,"x9_x27");
   ulong boostT=OpenOrder(symbol,boostType,boostLot,
                "ANX_BST_X27",magic);
   if(boostT>0) {
      g_packets[symIdx].boostTicket=(double)boostT;
      g_packets[symIdx].boostLevel =27;
      g_packets[symIdx].boostState =BOOST_X27_ACTIVE;
      g_systemStates[symIdx]       =STATE_BOOST_X27;
      g_stats.boostX27Count++;
      SendTelegramAlert(symIdx,"KRITIK x27 BOOST!",true);
      return true;
   }
   return false;
}

void CheckBoostTrigger(int symIdx) {
   if(g_packets[symIdx].boostState!=BOOST_NONE)  return;
   if(g_systemStates[symIdx]!=STATE_PACKET_OPEN) return;
   double threshold=CalculateBoostThreshold(symIdx);
   ulong  buyTkt =(ulong)g_packets[symIdx].buyTicket;
   ulong  sellTkt=(ulong)g_packets[symIdx].sellTicket;
   double buyOpen=0,sellOpen=0;
   if(PositionSelectByTicket(buyTkt))
      buyOpen =PositionGetDouble(POSITION_PRICE_OPEN);
   if(PositionSelectByTicket(sellTkt))
      sellOpen=PositionGetDouble(POSITION_PRICE_OPEN);
   if(buyOpen<=0||sellOpen<=0) return;
   if(MathAbs(buyOpen-sellOpen)>=threshold)
      OpenBoostX3(symIdx);
}

bool UpdatePositionSL(int symIdx,ulong ticket,double newSL) {
   string symbol=g_symbols[symIdx];
   if(!PositionSelectByTicket(ticket)) return false;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   newSL=NormalizeDouble(newSL,digits);
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);
   request.action  =TRADE_ACTION_SLTP;
   request.symbol  =symbol;
   request.position=ticket;
   request.sl      =newSL;
   request.tp      =PositionGetDouble(POSITION_TP);
   return (OrderSend(request,result)&&
           result.retcode==TRADE_RETCODE_DONE);
}

void CheckBoostConditions(int symIdx) {
   int bs=g_packets[symIdx].boostState;
   if(bs==BOOST_NONE||bs==BOOST_COMPLETED||
      bs==BOOST_FAILED) return;
   string symbol  =g_symbols[symIdx];
   double spread  =g_marketData[symIdx].spread;
   double point   =g_marketData[symIdx].pointValue;
   double baseLot =g_packets[symIdx].baseLot;
   ulong  boostTkt=(ulong)g_packets[symIdx].boostTicket;
   ulong  buyTkt  =(ulong)g_packets[symIdx].buyTicket;
   ulong  sellTkt =(ulong)g_packets[symIdx].sellTicket;
   double boostPnL=0;
   ENUM_POSITION_TYPE boostPosType=POSITION_TYPE_BUY;
   if(PositionSelectByTicket(boostTkt)) {
      boostPnL   =PositionGetDouble(POSITION_PROFIT);
      boostPosType=(ENUM_POSITION_TYPE)
                   PositionGetInteger(POSITION_TYPE);
   }
   double buyPnL=0,sellPnL=0;
   if(PositionSelectByTicket(buyTkt))
      buyPnL =PositionGetDouble(POSITION_PROFIT);
   if(PositionSelectByTicket(sellTkt))
      sellPnL=PositionGetDouble(POSITION_PROFIT);
   double mainPnL=buyPnL+sellPnL;
   double pipSize =(g_marketData[symIdx].digits==3||
                    g_marketData[symIdx].digits==5)?
                    point*10:point;
   double curPrice=SymbolInfoDouble(symbol,
      boostPosType==POSITION_TYPE_BUY?SYMBOL_BID:SYMBOL_ASK);
   double targetProfit=spread*pipSize*baseLot*
                       (1.0+PROFIT_TARGET_PCT);
   if(bs==BOOST_X3_ACTIVE) {
      double totalPnL=mainPnL+boostPnL;
      if(totalPnL>=targetProfit) {
         CloseOrder(symbol,buyTkt, "BST_OK_MAIN");
         CloseOrder(symbol,sellTkt,"BST_OK_MAIN");
         double trailP=boostPosType==POSITION_TYPE_BUY?
                       curPrice-(pipSize*TRAILING_STOP_PCT*100):
                       curPrice+(pipSize*TRAILING_STOP_PCT*100);
         UpdatePositionSL(symIdx,boostTkt,trailP);
         g_packets[symIdx].boostState=BOOST_COMPLETED;
         g_systemStates[symIdx]      =STATE_SCANNING;
         g_account.successPackets++;
         InitTrailingState(symIdx,boostTkt,targetProfit);
         return;
      }
      double lossThr=spread*pipSize*InpBoostX9StopPct/100.0;
      if(boostPnL<=-lossThr) OpenBoostX9(symIdx);
   }
   else if(bs==BOOST_X9_ACTIVE) {
      double totalPnL=mainPnL+boostPnL;
      if(totalPnL>=targetProfit) {
         CloseOrder(symbol,buyTkt, "x9_OK");
         CloseOrder(symbol,sellTkt,"x9_OK");
         g_packets[symIdx].boostState=BOOST_COMPLETED;
         g_systemStates[symIdx]      =STATE_SCANNING;
         g_account.successPackets++;
         return;
      }
      double lossThr=spread*pipSize*InpBoostX27StopPct/100.0;
      if(boostPnL<=-lossThr) OpenBoostX27(symIdx);
   }
   else if(bs==BOOST_X27_ACTIVE) {
      double totalPnL=mainPnL+boostPnL;
      if(totalPnL>=0) {
         CloseAllPacketOrders(symIdx,"x27_OK");
         g_account.successPackets++;
         return;
      }
      double closeThr=spread*pipSize*InpBoostX27ClosePct/100.0;
      if(boostPnL<=-closeThr) {
         CloseAllPacketOrders(symIdx,"x27_FAIL");
         g_account.failedPackets++;
         g_stats.recoveryCount++;
         g_systemStates[symIdx]      =STATE_RECOVERY;
         g_packets[symIdx].isRecovery=true;
         g_packets[symIdx].recoveryTarget=
            MathAbs(GetPacketPnL(symIdx))*1.1;
         SendTelegramAlert(symIdx,"ZARAR Recovery Aktif!",true);
      }
   }
}

//+------------------------------------------------------------------+
//| TRAİLİNG STOP                                                    |
//+------------------------------------------------------------------+
void InitTrailingProfiles() {
   for(int s=0;s<NEXUS_SYMBOLS_COUNT;s++) {
      g_trailingProfiles[s].level1TriggerPct=25.0;
      g_trailingProfiles[s].level2TriggerPct=50.0;
      g_trailingProfiles[s].level3TriggerPct=75.0;
      g_trailingProfiles[s].level4TriggerPct=100.0;
      g_trailingProfiles[s].spikeFilterTicks=3;
      g_trailingProfiles[s].spikeThresholdPct=0.20;
      g_trailingProfiles[s].mode=0;
   }
   // GOLD
   g_trailingProfiles[SYM_GOLD].atrMultLondon =0.30;
   g_trailingProfiles[SYM_GOLD].atrMultNY     =0.45;
   g_trailingProfiles[SYM_GOLD].atrMultAsia   =0.70;
   g_trailingProfiles[SYM_GOLD].atrMultNight  =0.90;
   g_trailingProfiles[SYM_GOLD].minDistancePip=5.0;
   g_trailingProfiles[SYM_GOLD].maxDistancePip=50.0;
   // SILVER
   g_trailingProfiles[SYM_SILVER].atrMultLondon =0.35;
   g_trailingProfiles[SYM_SILVER].atrMultNY     =0.50;
   g_trailingProfiles[SYM_SILVER].atrMultAsia   =0.75;
   g_trailingProfiles[SYM_SILVER].atrMultNight  =1.00;
   g_trailingProfiles[SYM_SILVER].minDistancePip=8.0;
   g_trailingProfiles[SYM_SILVER].maxDistancePip=80.0;
   // EURUSD
   g_trailingProfiles[SYM_EURUSD].atrMultLondon =0.25;
   g_trailingProfiles[SYM_EURUSD].atrMultNY     =0.35;
   g_trailingProfiles[SYM_EURUSD].atrMultAsia   =0.65;
   g_trailingProfiles[SYM_EURUSD].atrMultNight  =0.85;
   g_trailingProfiles[SYM_EURUSD].minDistancePip=3.0;
   g_trailingProfiles[SYM_EURUSD].maxDistancePip=25.0;
   // BITCOIN
   g_trailingProfiles[SYM_BITCOIN].atrMultLondon =0.50;
   g_trailingProfiles[SYM_BITCOIN].atrMultNY     =0.60;
   g_trailingProfiles[SYM_BITCOIN].atrMultAsia   =0.80;
   g_trailingProfiles[SYM_BITCOIN].atrMultNight  =1.00;
   g_trailingProfiles[SYM_BITCOIN].minDistancePip=50.0;
   g_trailingProfiles[SYM_BITCOIN].maxDistancePip=500.0;
   g_trailingProfiles[SYM_BITCOIN].spikeFilterTicks=5;
   g_trailingProfiles[SYM_BITCOIN].spikeThresholdPct=0.50;
   // ETHEREUM
   g_trailingProfiles[SYM_ETHEREUM].atrMultLondon =0.55;
   g_trailingProfiles[SYM_ETHEREUM].atrMultNY     =0.65;
   g_trailingProfiles[SYM_ETHEREUM].atrMultAsia   =0.85;
   g_trailingProfiles[SYM_ETHEREUM].atrMultNight  =1.10;
   g_trailingProfiles[SYM_ETHEREUM].minDistancePip=30.0;
   g_trailingProfiles[SYM_ETHEREUM].maxDistancePip=400.0;
   g_trailingProfiles[SYM_ETHEREUM].spikeFilterTicks=5;
   g_trailingProfiles[SYM_ETHEREUM].spikeThresholdPct=0.60;
}

double GetSessionATRMult(int symIdx) {
   MqlDateTime dt;
   TimeToStruct(TimeGMT(),dt);
   int hour=dt.hour;
   int dow =dt.day_of_week;
   int cat =g_marketData[symIdx].category;
   double atrMultLondon=g_trailingProfiles[symIdx].atrMultLondon;
   double atrMultNY    =g_trailingProfiles[symIdx].atrMultNY;
   double atrMultAsia  =g_trailingProfiles[symIdx].atrMultAsia;
   double atrMultNight =g_trailingProfiles[symIdx].atrMultNight;
   if(cat==CATEGORY_CRYPTO) {
      if(dow==0||dow==6)      return atrMultNight;
      if(hour<6)              return atrMultNight;
      if(hour>=14&&hour<22)   return atrMultLondon;
      return atrMultAsia;
   }
   if(hour<6)           return atrMultNight;
   if(hour>=6&&hour<8)  return atrMultAsia;
   if(hour>=8&&hour<17) return atrMultLondon;
   if(hour>=17&&hour<20)return atrMultNY;
   return atrMultNight;
}

double GetATRTrailingStep(int symIdx) {
   string symbol=g_symbols[symIdx];
   double minPip=g_trailingProfiles[symIdx].minDistancePip;
   double maxPip=g_trailingProfiles[symIdx].maxDistancePip;
   int atrHandle=iATR(symbol,PERIOD_M5,14);
   double atrValue=0;
   if(atrHandle!=INVALID_HANDLE) {
      double atrBuf[];
      ArraySetAsSeries(atrBuf,true);
      if(CopyBuffer(atrHandle,0,0,3,atrBuf)>=3)
         atrValue=(atrBuf[0]+atrBuf[1]+atrBuf[2])/3.0;
      IndicatorRelease(atrHandle);
   }
   double point  =SymbolInfoDouble(symbol,SYMBOL_POINT);
   double pipSize=(g_marketData[symIdx].digits==3||
                   g_marketData[symIdx].digits==5)?
                   point*10:point;
   if(atrValue<=0||pipSize<=0) return minPip*pipSize;
   double step    =atrValue*GetSessionATRMult(symIdx);
   double stepPips=step/pipSize;
   stepPips=MathMax(stepPips,minPip);
   stepPips=MathMin(stepPips,maxPip);
   return stepPips*pipSize;
}

bool IsPriceSpike(int symIdx,double currentPrice) {
   int maxTicks=MathMax(1,
                g_trailingProfiles[symIdx].spikeFilterTicks);
   int idx=g_trailingStates[symIdx].tickCount%maxTicks;
   g_trailingStates[symIdx].tickHistory[idx]=currentPrice;
   g_trailingStates[symIdx].tickCount++;
   if(g_trailingStates[symIdx].tickCount<maxTicks) return false;
   double avg=0;
   for(int i=0;i<maxTicks;i++)
      avg+=g_trailingStates[symIdx].tickHistory[i];
   avg/=maxTicks;
   if(avg<=0) return false;
   double thresh=g_trailingProfiles[symIdx].spikeThresholdPct/100.0;
   return (MathAbs(currentPrice-avg)/avg>thresh);
}

double CalculateSafeSL(string symbol,double price,
                        double desiredSL,bool isBuy) {
   int    stopLvl=(int)SymbolInfoInteger(symbol,
                  SYMBOL_TRADE_STOPS_LEVEL);
   double point  =SymbolInfoDouble(symbol,SYMBOL_POINT);
   double spread =SymbolInfoDouble(symbol,SYMBOL_ASK)-
                  SymbolInfoDouble(symbol,SYMBOL_BID);
   double minDist=(stopLvl*point)+(spread*1.5);
   double safeSL;
   if(isBuy) {
      safeSL=price-minDist;
      if(desiredSL<safeSL) safeSL=desiredSL;
   } else {
      safeSL=price+minDist;
      if(desiredSL>safeSL) safeSL=desiredSL;
   }
   return NormalizeDouble(safeSL,
          (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
}

bool IsValidSLDistance(string symbol,double price,
                        double sl,bool isBuy) {
   int    stopLvl=(int)SymbolInfoInteger(symbol,
                  SYMBOL_TRADE_STOPS_LEVEL);
   double point  =SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(stopLvl<=0) return true;
   double curDist=isBuy?price-sl:sl-price;
   return (curDist>=stopLvl*point);
}

void InitTrailingState(int symIdx,ulong ticket,
                        double targetProfit) {
   if(!PositionSelectByTicket(ticket)) return;
   g_trailingStates[symIdx].ticket       =ticket;
   g_trailingStates[symIdx].symbolIndex  =symIdx;
   g_trailingStates[symIdx].isActive     =true;
   g_trailingStates[symIdx].openPrice    =
      PositionGetDouble(POSITION_PRICE_OPEN);
   g_trailingStates[symIdx].currentSL    =
      PositionGetDouble(POSITION_SL);
   g_trailingStates[symIdx].previousSL   =
      g_trailingStates[symIdx].currentSL;
   g_trailingStates[symIdx].initialProfit=targetProfit;
   g_trailingStates[symIdx].peakProfit   =0;
   g_trailingStates[symIdx].lockedProfit =0;
   g_trailingStates[symIdx].level        =TRAIL_NONE;
   g_trailingStates[symIdx].level1Hit    =false;
   g_trailingStates[symIdx].level2Hit    =false;
   g_trailingStates[symIdx].level3Hit    =false;
   g_trailingStates[symIdx].level4Hit    =false;
   g_trailingStates[symIdx].activeSince  =TimeCurrent();
   g_trailingStates[symIdx].lastUpdate   =TimeCurrent();
   g_trailingStates[symIdx].tickCount    =0;
   g_trailingStates[symIdx].updateCount  =0;
   g_trailingStates[symIdx].levelUpCount =0;
   double spread=GetCurrentSpread(g_symbols[symIdx])*
                 SymbolInfoDouble(g_symbols[symIdx],SYMBOL_POINT);
   bool isBuy=(PositionGetInteger(POSITION_TYPE)==
               POSITION_TYPE_BUY);
   g_trailingStates[symIdx].breakEvenPrice=isBuy?
      g_trailingStates[symIdx].openPrice+spread*1.2:
      g_trailingStates[symIdx].openPrice-spread*1.2;
   double curPrice=isBuy?
      SymbolInfoDouble(g_symbols[symIdx],SYMBOL_BID):
      SymbolInfoDouble(g_symbols[symIdx],SYMBOL_ASK);
   for(int i=0;i<5;i++)
      g_trailingStates[symIdx].tickHistory[i]=curPrice;
   g_trailingStats.totalActivations++;
   NexusLog(LOG_INFO,g_symbols[symIdx],
      StringFormat("Trailing basladi T:%d",(int)ticket));
}

bool ApplyBreakEven(int symIdx,bool isBuy,double curPrice) {
   string symbol=g_symbols[symIdx];
   double spread=GetCurrentSpread(symbol)*
                 SymbolInfoDouble(symbol,SYMBOL_POINT);
   double openP =g_trailingStates[symIdx].openPrice;
   double newSL =isBuy?openP+spread*1.2:openP-spread*1.2;
   if(!IsValidSLDistance(symbol,curPrice,newSL,isBuy))
      return false;
   double curSL=g_trailingStates[symIdx].currentSL;
   if(isBuy &&curSL>=newSL) return true;
   if(!isBuy&&curSL<=newSL&&curSL>0) return true;
   ulong ticket=g_trailingStates[symIdx].ticket;
   if(UpdatePositionSL(symIdx,ticket,newSL)) {
      g_trailingStates[symIdx].previousSL  =curSL;
      g_trailingStates[symIdx].currentSL   =newSL;
      g_trailingStates[symIdx].lastTrigger =TRIGGER_BREAKEVEN;
      g_trailingStates[symIdx].lockedProfit=0;
      NexusLog(LOG_INFO,symbol,
         StringFormat("BREAKEVEN SL:%.5f",newSL));
      g_trailingStats.breakevenHits++;
      SendTrailingNotification(symIdx,1,
         g_trailingStates[symIdx].currentProfit,0);
      return true;
   }
   return false;
}

bool ApplyTrailingLevel(int symIdx,double lockPct,
                         int newLevel,bool isBuy,
                         double curPrice,double curProfit) {
   string symbol   =g_symbols[symIdx];
   double lockAmount=curProfit*(lockPct/100.0);
   double trailStep =GetATRTrailingStep(symIdx);
   double newSL;
   double curSL=g_trailingStates[symIdx].currentSL;
   if(isBuy) {
      newSL=curPrice-trailStep;
      if(newSL<=curSL) newSL=curSL+trailStep*0.5;
   } else {
      newSL=curPrice+trailStep;
      if(newSL>=curSL&&curSL>0) newSL=curSL-trailStep*0.5;
   }
   newSL=CalculateSafeSL(symbol,curPrice,newSL,isBuy);
   if(!IsValidSLDistance(symbol,curPrice,newSL,isBuy))
      return false;
   ulong ticket=g_trailingStates[symIdx].ticket;
   if(UpdatePositionSL(symIdx,ticket,newSL)) {
      g_trailingStates[symIdx].previousSL  =curSL;
      g_trailingStates[symIdx].currentSL   =newSL;
      g_trailingStates[symIdx].level       =newLevel;
      g_trailingStates[symIdx].lockedProfit=lockAmount;
      g_trailingStates[symIdx].lastLevelUp =TimeCurrent();
      g_trailingStates[symIdx].lastTrigger =TRIGGER_LEVEL_UP;
      g_trailingStats.totalLockedProfit+=lockAmount;
      if(newLevel==TRAIL_LEVEL_2) g_trailingStats.level2Hits++;
      if(newLevel==TRAIL_LEVEL_3) g_trailingStats.level3Hits++;
      if(newLevel==TRAIL_LEVEL_4) g_trailingStats.level4Hits++;
      NexusLog(LOG_INFO,symbol,
         StringFormat("L%d AKTIF SL:%.5f Kilitli:$%.2f",
                      newLevel,newSL,lockAmount));
      SendTrailingNotification(symIdx,newLevel,
         curProfit,lockAmount);
      return true;
   }
   return false;
}

void UpdateContinuousTrailing(int symIdx,bool isBuy,
                               double curPrice,double curProfit) {
   string symbol   =g_symbols[symIdx];
   double trailStep=GetATRTrailingStep(symIdx);
   double curSL    =g_trailingStates[symIdx].currentSL;
   double peakProfit=g_trailingStates[symIdx].peakProfit;
   double newSL;
   bool shouldUpdate=false;
   if(isBuy) {
      newSL=curPrice-trailStep;
      if(newSL>curSL+trailStep*0.1) shouldUpdate=true;
   } else {
      newSL=curPrice+trailStep;
      if(newSL<curSL-trailStep*0.1&&curSL>0) shouldUpdate=true;
   }
   if(!shouldUpdate) return;
   if(peakProfit>0&&curProfit<peakProfit*0.85) {
      trailStep*=0.6;
      newSL=isBuy?curPrice-trailStep:curPrice+trailStep;
   }
   newSL=CalculateSafeSL(symbol,curPrice,newSL,isBuy);
   if(!IsValidSLDistance(symbol,curPrice,newSL,isBuy)) return;
   ulong ticket=g_trailingStates[symIdx].ticket;
   if(UpdatePositionSL(symIdx,ticket,newSL)) {
      int lvl=g_trailingStates[symIdx].level;
      g_trailingStates[symIdx].lockedProfit=curProfit*
         (lvl==TRAIL_LEVEL_2?0.25:
          lvl==TRAIL_LEVEL_3?0.50:
          lvl==TRAIL_LEVEL_4?0.75:0.0);
      g_trailingStates[symIdx].previousSL=curSL;
      g_trailingStates[symIdx].currentSL =newSL;
   }
}

void UpdateTrailing(int symIdx) {
   if(!g_trailingStates[symIdx].isActive) return;
   ulong ticket=g_trailingStates[symIdx].ticket;
   if(ticket<=0) return;
   if(!PositionSelectByTicket(ticket)) {
      g_trailingStates[symIdx].isActive=false;
      g_trailingStates[symIdx].level   =TRAIL_COMPLETED;
      return;
   }
   string symbol=g_symbols[symIdx];
   bool   isBuy =(PositionGetInteger(POSITION_TYPE)==
                  POSITION_TYPE_BUY);
   double curPrice=isBuy?
      SymbolInfoDouble(symbol,SYMBOL_BID):
      SymbolInfoDouble(symbol,SYMBOL_ASK);
   double curProfit=PositionGetDouble(POSITION_PROFIT)+
                    PositionGetDouble(POSITION_SWAP);
   if(IsPriceSpike(symIdx,curPrice)) return;
   g_trailingStates[symIdx].currentProfit=curProfit;
   g_trailingStates[symIdx].lastUpdate   =TimeCurrent();
   if(curProfit>g_trailingStates[symIdx].peakProfit)
      g_trailingStates[symIdx].peakProfit=curProfit;
   double initP=g_trailingStates[symIdx].initialProfit;
   if(initP<=0) return;
   double pct=(curProfit/initP)*100.0;
   double l1=g_trailingProfiles[symIdx].level1TriggerPct;
   double l2=g_trailingProfiles[symIdx].level2TriggerPct;
   double l3=g_trailingProfiles[symIdx].level3TriggerPct;
   double l4=g_trailingProfiles[symIdx].level4TriggerPct;
   if(!g_trailingStates[symIdx].level4Hit&&pct>=l4) {
      if(ApplyTrailingLevel(symIdx,75.0,TRAIL_LEVEL_4,
         isBuy,curPrice,curProfit))
         g_trailingStates[symIdx].level4Hit=true;
      return;
   }
   if(!g_trailingStates[symIdx].level3Hit&&pct>=l3) {
      if(ApplyTrailingLevel(symIdx,50.0,TRAIL_LEVEL_3,
         isBuy,curPrice,curProfit))
         g_trailingStates[symIdx].level3Hit=true;
      return;
   }
   if(!g_trailingStates[symIdx].level2Hit&&pct>=l2) {
      if(ApplyTrailingLevel(symIdx,25.0,TRAIL_LEVEL_2,
         isBuy,curPrice,curProfit))
         g_trailingStates[symIdx].level2Hit=true;
      return;
   }
   if(!g_trailingStates[symIdx].level1Hit&&pct>=l1) {
      if(ApplyBreakEven(symIdx,isBuy,curPrice))
         g_trailingStates[symIdx].level1Hit=true;
      return;
   }
   if(g_trailingStates[symIdx].level2Hit)
      UpdateContinuousTrailing(symIdx,isBuy,curPrice,curProfit);
   g_trailingStates[symIdx].updateCount++;
}

void SendTrailingNotification(int symIdx,int level,
                               double curProfit,
                               double lockedProfit) {
   string symName=GetSymbolShortName(symIdx);
   string levelMsg,lockMsg;
   switch(level) {
      case 1:
         levelMsg="BREAKEVEN AKTIF!";
         lockMsg ="Artik zarar riski YOK!"; break;
      case 2:
         levelMsg="SEVIYE-2 AKTIF!";
         lockMsg =StringFormat("25%% kilitlendi: +$%.2f",
                  lockedProfit); break;
      case 3:
         levelMsg="SEVIYE-3 AKTIF!";
         lockMsg =StringFormat("50%% kilitlendi: +$%.2f",
                  lockedProfit); break;
      default:
         levelMsg="SEVIYE-4 AKTIF!";
         lockMsg =StringFormat("75%% kilitlendi: +$%.2f",
                  lockedProfit); break;
   }
   string msg=StringFormat(
      "AsFaRaS NEXUS TRAILING\n"
      "Sembol: %s\n"
      "%s\n"
      "Kar: +$%.2f\n"
      "%s\n"
      "SL: %.5f\n"
      "%s",
      symName,levelMsg,curProfit,lockMsg,
      g_trailingStates[symIdx].currentSL,
      TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   SendTelegramMessage(msg);
}

string GetTrailingStatsReport() {
   return StringFormat(
      "Trailing: Akt=%d BE=%d L2=%d L3=%d L4=%d",
      g_trailingStats.totalActivations,
      g_trailingStats.breakevenHits,
      g_trailingStats.level2Hits,
      g_trailingStats.level3Hits,
      g_trailingStats.level4Hits);
}

//+------------------------------------------------------------------+
//| MOTİVASYON                                                       |
//+------------------------------------------------------------------+
string SelectMotivationQuote() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   int hour=dt.hour;
   bool anyRec=false,anyBst=false;
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      if(g_systemStates[i]==STATE_RECOVERY) anyRec=true;
      if(g_systemStates[i]==STATE_BOOST_X3||
         g_systemStates[i]==STATE_BOOST_X9||
         g_systemStates[i]==STATE_BOOST_X27) anyBst=true;
   }
   int idx;
   if(anyRec){idx=g_currentQuoteIdx%ArraySize(g_quotesRecovery);
              return g_quotesRecovery[idx];}
   if(anyBst){idx=g_currentQuoteIdx%ArraySize(g_quotesBoost);
              return g_quotesBoost[idx];}
   if(hour>=8 &&hour<12){idx=g_currentQuoteIdx%
      ArraySize(g_quotesSabir);  return g_quotesSabir[idx];}
   if(hour>=12&&hour<17){idx=g_currentQuoteIdx%
      ArraySize(g_quotesGuc);    return g_quotesGuc[idx];}
   if(hour>=17&&hour<20){idx=g_currentQuoteIdx%
      ArraySize(g_quotesDisipl); return g_quotesDisipl[idx];}
   if(hour>=20&&hour<24){idx=g_currentQuoteIdx%
      ArraySize(g_quotesVizyon); return g_quotesVizyon[idx];}
   idx=g_currentQuoteIdx%ArraySize(g_quotesGece);
   return g_quotesGece[idx];
}

void UpdateMotivationQuote() {
   MqlDateTime dtN,dtL;
   TimeToStruct(TimeCurrent(),dtN);
   TimeToStruct(g_lastQuoteTime,dtL);
   if(g_lastQuoteTime==0||dtN.hour!=dtL.hour||
      g_currentQuote=="") {
      g_currentQuoteIdx++;
      g_currentQuote =SelectMotivationQuote();
      g_lastQuoteTime=TimeCurrent();
   }
}

string GetNextQuoteCountdown() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   return StringFormat("%02d:%02d",59-dt.min,59-dt.sec);
}

string GetQuoteCategoryEmoji() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   int hour=dt.hour;
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      if(g_systemStates[i]==STATE_RECOVERY) return "[R]";
      if(g_systemStates[i]==STATE_BOOST_X3||
         g_systemStates[i]==STATE_BOOST_X9||
         g_systemStates[i]==STATE_BOOST_X27) return "[B]";
   }
   if(hour>=8 &&hour<12) return "[S]";
   if(hour>=12&&hour<17) return "[G]";
   if(hour>=17&&hour<20) return "[D]";
   if(hour>=20&&hour<24) return "[V]";
   return "[N]";
}

//+------------------------------------------------------------------+
//| DASHBOARD                                                         |
//+------------------------------------------------------------------+
void CreateLabel(string name,string text,int x,int y,
                 int fontSize,color clr,
                 ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER) {
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0, name,OBJPROP_FONT,"Consolas");
   ObjectSetString(0, name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
}

void CreateRect(string name,int x,int y,int w,int h,
                color bgColor,color borderColor=CLR_NONE) {
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,
      borderColor==CLR_NONE?bgColor:borderColor);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
}

string GetSymbolShortName(int symIdx) {
   if(symIdx==SYM_GOLD)     return "GOLD ";
   if(symIdx==SYM_SILVER)   return "SILV ";
   if(symIdx==SYM_EURUSD)   return "EUUSD";
   if(symIdx==SYM_BITCOIN)  return "BTC  ";
   if(symIdx==SYM_ETHEREUM) return "ETH  ";
   return StringSubstr(g_symbols[symIdx],0,5);
}

color GetHealthColor(double score) {
   if(score<=HEALTH_CRITICAL) return CLR_LOSS;
   if(score<=HEALTH_WEAK)     return CLR_WARNING;
   if(score<=HEALTH_NORMAL)   return CLR_HEALTH_HIGH;
   return CLR_ACCENT;
}

string GetHealthEmoji(double score) {
   if(score<=HEALTH_CRITICAL) return "RD";
   if(score<=HEALTH_WEAK)     return "YL";
   if(score<=HEALTH_NORMAL)   return "GR";
   return "BL";
}

string GetBoostString(int symIdx) {
   int bs=g_packets[symIdx].boostState;
   if(bs==BOOST_X3_ACTIVE)  return "x3  ";
   if(bs==BOOST_X9_ACTIVE)  return "x9  ";
   if(bs==BOOST_X27_ACTIVE) return "x27 ";
   if(bs==BOOST_COMPLETED)  return "OK  ";
   return "  - ";
}

color GetBoostColor(int symIdx) {
   int bs=g_packets[symIdx].boostState;
   if(bs==BOOST_X3_ACTIVE)  return CLR_WARNING;
   if(bs==BOOST_X9_ACTIVE)  return CLR_BOOST;
   if(bs==BOOST_X27_ACTIVE) return CLR_LOSS;
   if(bs==BOOST_COMPLETED)  return CLR_PROFIT;
   return CLR_TEXT_SECONDARY;
}

string GetStateString(int symIdx) {
   ENUM_SYSTEM_STATE st=g_systemStates[symIdx];
   if(st==STATE_INIT)        return "INIT ";
   if(st==STATE_SCANNING)    return "SCAN ";
   if(st==STATE_PACKET_OPEN) return "AKTIF";
   if(st==STATE_BOOST_X3)    return "BST3 ";
   if(st==STATE_BOOST_X9)    return "BST9 ";
   if(st==STATE_BOOST_X27)   return "B27  ";
   if(st==STATE_RECOVERY)    return "RECOV";
   if(st==STATE_PAUSED)      return "PAUSE";
   if(st==STATE_ERROR)       return "HATA ";
   return "?    ";
}

color GetStateColor(int symIdx) {
   ENUM_SYSTEM_STATE st=g_systemStates[symIdx];
   if(st==STATE_PACKET_OPEN||
      st==STATE_SCANNING)   return CLR_PROFIT;
   if(st==STATE_BOOST_X3)   return CLR_WARNING;
   if(st==STATE_BOOST_X9)   return CLR_BOOST;
   if(st==STATE_BOOST_X27||
      st==STATE_ERROR)      return CLR_LOSS;
   if(st==STATE_RECOVERY)   return CLR_WARNING;
   return CLR_TEXT_SECONDARY;
}

string GetTrailingMiniStatus(int symIdx) {
   if(!g_trailingStates[symIdx].isActive) return "  -  ";
   int lvl=MathMax(0,MathMin(5,
           g_trailingStates[symIdx].level));
   string icons[6]={"W","BE","L2","L3","L4","OK"};
   return StringFormat("%s",icons[lvl]);
}

void DrawMiniDashboard() {
   if(!InpShowMiniDash) return;
   int x=InpDashX,y=InpDashY;
   int w=460,rowH=22,headerH=38;
   int totalH=headerH+(NEXUS_SYMBOLS_COUNT*rowH)+12;
   CreateRect(DASH_PREFIX+"MINI_BG",x,y,w,totalH,
              CLR_PANEL_BG,CLR_BORDER);
   CreateRect(DASH_PREFIX+"MINI_HDR",x,y,w,headerH,
              CLR_HEADER,CLR_BORDER);
   CreateLabel(DASH_PREFIX+"MINI_NAME",
               "AsFaRaS NEXUS v"+NEXUS_VERSION,
               x+8,y+4,10,CLR_ACCENT);
   CreateLabel(DASH_PREFIX+"MINI_LIVE",
               "[CANLI] "+TimeToString(TimeCurrent(),TIME_SECONDS),
               x+8,y+22,7,CLR_PROFIT);
   CreateLabel(DASH_PREFIX+"MINI_SLG",
               "Bes Sembol. Sonsuz Dongu. Sifir Zarar.",
               x+200,y+22,7,CLR_TEXT_SECONDARY);
   int hy=y+headerH+2;
   CreateLabel(DASH_PREFIX+"C0","SEMBOL",x+5,  hy,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"C1","SAGLIK",x+80, hy,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"C2","LOT",   x+145,hy,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"C3","P&L",   x+200,hy,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"C4","BOOST", x+265,hy,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"C5","TRAIL", x+320,hy,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"C6","DURUM", x+375,hy,7,CLR_TEXT_SECONDARY);
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      int ry=y+headerH+rowH+(i*rowH)+2;
      string si=IntegerToString(i);
      color rowBg=(i%2==0)?CLR_PANEL_BG:C'20,22,28';
      CreateRect(DASH_PREFIX+"RBG"+si,x+1,ry-1,w-2,rowH-1,rowBg);
      CreateLabel(DASH_PREFIX+"RS"+si,
                  GetSymbolShortName(i),x+5,ry,8,CLR_TEXT_PRIMARY);
      double health=g_marketData[i].healthScore;
      CreateLabel(DASH_PREFIX+"RH"+si,
                  StringFormat("%s %.0f",GetHealthEmoji(health),health),
                  x+80,ry,8,GetHealthColor(health));
      string lotStr=HasActivePacket(i)?
                    StringFormat("%.2f",g_packets[i].baseLot):"--";
      CreateLabel(DASH_PREFIX+"RL"+si,
                  lotStr,x+145,ry,8,CLR_TEXT_PRIMARY);
      double pnl=GetPacketPnL(i);
      CreateLabel(DASH_PREFIX+"RP"+si,
                  HasActivePacket(i)?
                  StringFormat("%+.2f$",pnl):"--",
                  x+200,ry,8,pnl>=0?CLR_PROFIT:CLR_LOSS);
      CreateLabel(DASH_PREFIX+"RB"+si,
                  GetBoostString(i),x+265,ry,8,GetBoostColor(i));
      CreateLabel(DASH_PREFIX+"RT"+si,
                  GetTrailingMiniStatus(i),x+320,ry,8,
                  CLR_TEXT_SECONDARY);
      CreateLabel(DASH_PREFIX+"RST"+si,
                  GetStateString(i),x+375,ry,7,GetStateColor(i));
   }
   ChartRedraw(0);
}

void DrawFullDashboard(int symIdx) {
   if(!InpShowFullDash) return;
   int chartW=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int pw=290,px=chartW-pw-5,py=InpDashY;
   int chartH=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   int ph=chartH-py-10;
   CreateRect(DASH_PREFIX+"FB",px,py,pw,ph,CLR_PANEL_BG,CLR_BORDER);
   CreateRect(DASH_PREFIX+"FH",px,py,pw,52,CLR_HEADER,CLR_BORDER);
   CreateLabel(DASH_PREFIX+"FHN","AsFaRaS NEXUS",
               px+8,py+4,11,CLR_ACCENT);
   CreateLabel(DASH_PREFIX+"FHV","v"+NEXUS_VERSION,
               px+pw-45,py+8,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"FHS",
               "Bes Sembol. Sonsuz Dongu. Sifir Zarar.",
               px+8,py+26,7,CLR_TEXT_SECONDARY);
   CreateLabel(DASH_PREFIX+"FHL",
               "[CANLI] "+TimeToString(TimeCurrent(),TIME_SECONDS),
               px+8,py+40,7,CLR_PROFIT);
   int cy=py+60;
   // Sağlık
   double health=g_marketData[symIdx].healthScore;
   CreateLabel(DASH_PREFIX+"FHT","PIYASA SAGLIK:",
               px+8,cy,8,CLR_TEXT_SECONDARY); cy+=16;
   CreateLabel(DASH_PREFIX+"FHB",
               StringFormat("%s %.0f/100",
               DrawProgressBar(health,100.0,18),health),
               px+8,cy,8,GetHealthColor(health)); cy+=18;
   CreateLabel(DASH_PREFIX+"FSP",
               StringFormat("Sprd:%.1f Ort:%.1f",
               g_marketData[symIdx].spread,
               g_marketData[symIdx].avgSpread),
               px+8,cy,7,CLR_TEXT_SECONDARY); cy+=18;
   CreateLabel(DASH_PREFIX+"FS1",StringRepeat("-",32),
               px+8,cy,7,CLR_BORDER); cy+=12;
   // Paket
   CreateLabel(DASH_PREFIX+"FPT","AKTIF PAKET",
               px+8,cy,8,CLR_ACCENT); cy+=14;
   if(HasActivePacket(symIdx)) {
      ulong buyTkt=(ulong)g_packets[symIdx].buyTicket;
      if(buyTkt>0&&PositionSelectByTicket(buyTkt)) {
         double bO=PositionGetDouble(POSITION_PRICE_OPEN);
         double bP=PositionGetDouble(POSITION_PROFIT);
         double bL=PositionGetDouble(POSITION_VOLUME);
         CreateLabel(DASH_PREFIX+"FB1",
            StringFormat("BUY %.2f @ %.5f",bL,bO),
            px+8,cy,8,CLR_PROFIT); cy+=14;
         CreateLabel(DASH_PREFIX+"FB2",
            StringFormat("  P&L: %+.2f$",bP),
            px+8,cy,8,bP>=0?CLR_PROFIT:CLR_LOSS); cy+=14;
      }
      ulong sellTkt=(ulong)g_packets[symIdx].sellTicket;
      if(sellTkt>0&&PositionSelectByTicket(sellTkt)) {
         double sO=PositionGetDouble(POSITION_PRICE_OPEN);
         double sP=PositionGetDouble(POSITION_PROFIT);
         double sL=PositionGetDouble(POSITION_VOLUME);
         CreateLabel(DASH_PREFIX+"FS2",
            StringFormat("SELL %.2f @ %.5f",sL,sO),
            px+8,cy,8,CLR_LOSS); cy+=14;
         CreateLabel(DASH_PREFIX+"FS3",
            StringFormat("  P&L: %+.2f$",sP),
            px+8,cy,8,sP>=0?CLR_PROFIT:CLR_LOSS); cy+=14;
      }
      double net=GetPacketPnL(symIdx);
      CreateLabel(DASH_PREFIX+"FNT",
         StringFormat("NET: %+.2f$",net),
         px+8,cy,9,net>=0?CLR_PROFIT:CLR_LOSS); cy+=18;
   } else {
      CreateLabel(DASH_PREFIX+"FNP","Paket Bekleniyor...",
                  px+8,cy,8,CLR_TEXT_SECONDARY); cy+=18;
   }
   CreateLabel(DASH_PREFIX+"FS4",StringRepeat("-",32),
               px+8,cy,7,CLR_BORDER); cy+=12;
   // Trailing
   CreateLabel(DASH_PREFIX+"FTT","TRAILING STOP",
               px+8,cy,8,CLR_ACCENT); cy+=14;
   if(g_trailingStates[symIdx].isActive) {
      int lvl=MathMax(0,MathMin(4,
              g_trailingStates[symIdx].level));
      string lvlBar="[";
      for(int i=1;i<=4;i++) lvlBar+=(i<=lvl)?"X":".";
      lvlBar+=StringFormat("] L%d/4",lvl);
      CreateLabel(DASH_PREFIX+"FTL",lvlBar,
                  px+8,cy,8,CLR_PROFIT); cy+=14;
      double tp=g_trailingStates[symIdx].currentProfit;
      double pk=g_trailingStates[symIdx].peakProfit;
      CreateLabel(DASH_PREFIX+"FTP",
         StringFormat("Kar:%+.2f Peak:+%.2f",tp,pk),
         px+8,cy,8,CLR_TEXT_PRIMARY); cy+=14;
      double lk=g_trailingStates[symIdx].lockedProfit;
      if(lk>0) {
         CreateLabel(DASH_PREFIX+"FTK",
            StringFormat("Kilitli:+$%.2f",lk),
            px+8,cy,8,CLR_PROFIT); cy+=14;
      }
      CreateLabel(DASH_PREFIX+"FTS",
         StringFormat("SL:%.5f",
         g_trailingStates[symIdx].currentSL),
         px+8,cy,8,CLR_TEXT_SECONDARY); cy+=14;
   } else {
      CreateLabel(DASH_PREFIX+"FTN","Trail Bekleniyor",
                  px+8,cy,8,CLR_TEXT_SECONDARY); cy+=14;
   }
   CreateLabel(DASH_PREFIX+"FS5",StringRepeat("-",32),
               px+8,cy,7,CLR_BORDER); cy+=12;
   // Hesap
   CreateLabel(DASH_PREFIX+"FAT","HESAP",
               px+8,cy,8,CLR_ACCENT); cy+=14;
   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   double eq =AccountInfoDouble(ACCOUNT_EQUITY);
   double dd =g_account.drawdown;
   CreateLabel(DASH_PREFIX+"FAB",
      StringFormat("Bakiye: $%.2f",bal),
      px+8,cy,8,CLR_TEXT_PRIMARY); cy+=14;
   CreateLabel(DASH_PREFIX+"FAE",
      StringFormat("Equity: $%.2f",eq),
      px+8,cy,8,eq>=bal?CLR_PROFIT:CLR_LOSS); cy+=14;
   CreateLabel(DASH_PREFIX+"FAD",
      StringFormat("Drawdown: %.2f%%",dd),
      px+8,cy,8,dd<5?CLR_PROFIT:dd<10?CLR_WARNING:CLR_LOSS);
   cy+=18;
   CreateLabel(DASH_PREFIX+"FS6",StringRepeat("-",32),
               px+8,cy,7,CLR_BORDER); cy+=12;
   // Motivasyon
   UpdateMotivationQuote();
   bool anyRec=false,anyBst=false;
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      if(g_systemStates[i]==STATE_RECOVERY) anyRec=true;
      if(g_systemStates[i]==STATE_BOOST_X3||
         g_systemStates[i]==STATE_BOOST_X9||
         g_systemStates[i]==STATE_BOOST_X27) anyBst=true;
   }
   color motBg    =anyRec?C'35,20,20':anyBst?C'30,25,10':C'20,25,35';
   color motBorder=anyRec?CLR_LOSS:anyBst?CLR_WARNING:CLR_ACCENT;
   CreateRect(DASH_PREFIX+"FMB",px+2,cy,pw-4,72,motBg,motBorder);
   CreateLabel(DASH_PREFIX+"FMT",
      GetQuoteCategoryEmoji()+" GUNUN SOZU",
      px+10,cy+5,8,motBorder);
   CreateLabel(DASH_PREFIX+"FMC",
      "Sonraki:"+GetNextQuoteCountdown(),
      px+pw-95,cy+5,7,CLR_TEXT_SECONDARY);
   string q=g_currentQuote;
   if(StringLen(q)<=38) {
      CreateLabel(DASH_PREFIX+"FM1",
         "\""+q+"\"",px+10,cy+20,8,CLR_TEXT_PRIMARY);
   } else {
      int sp=38;
      while(sp>10&&StringGetCharacter(q,sp)!=' ') sp--;
      CreateLabel(DASH_PREFIX+"FM1",
         "\""+StringSubstr(q,0,sp),
         px+10,cy+20,8,CLR_TEXT_PRIMARY);
      CreateLabel(DASH_PREFIX+"FM2",
         StringSubstr(q,sp+1)+"\"",
         px+10,cy+34,8,CLR_TEXT_PRIMARY);
   }
   CreateLabel(DASH_PREFIX+"FMA",
      "-- AsFaRaS NEXUS --",
      px+pw-145,cy+56,7,motBorder);
   cy+=78;
   if(g_packets[symIdx].isRecovery) {
      CreateRect(DASH_PREFIX+"FRB",px+2,cy,pw-4,26,
                 C'40,20,20',CLR_LOSS);
      CreateLabel(DASH_PREFIX+"FRL",
         StringFormat("RECOVERY: Hedef $%.2f",
         g_packets[symIdx].recoveryTarget),
         px+8,cy+6,8,CLR_WARNING);
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| CRASH RECOVERY - Manuel Kayıt (String içeren struct'sız)        |
//+------------------------------------------------------------------+
void SaveSystemState() {
   int handle=FileOpen("ANX_STATE.bin",
               FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(handle==INVALID_HANDLE) return;
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      // PacketState - string alanlar hariç
      FileWriteDouble(handle,g_packets[i].magicID);
      FileWriteDouble(handle,g_packets[i].baseLot);
      FileWriteDouble(handle,g_packets[i].buyTicket);
      FileWriteDouble(handle,g_packets[i].sellTicket);
      FileWriteDouble(handle,g_packets[i].boostTicket);
      FileWriteDouble(handle,g_packets[i].openPrice);
      FileWriteDouble(handle,g_packets[i].spreadAtOpen);
      FileWriteDouble(handle,g_packets[i].recoveryTarget);
      FileWriteInteger(handle,g_packets[i].boostLevel);
      FileWriteInteger(handle,g_packets[i].boostState);
      FileWriteInteger(handle,g_packets[i].mumDevretCount);
      FileWriteInteger(handle,(int)g_packets[i].isRecovery);
      FileWriteInteger(handle,(int)g_packets[i].isFirstPacket);
      FileWriteInteger(handle,(int)g_packets[i].openTime);
      // Sistem durumu
      FileWriteInteger(handle,(int)g_systemStates[i]);
      // TrailingState
      FileWriteDouble(handle,(double)g_trailingStates[i].ticket);
      FileWriteInteger(handle,(int)g_trailingStates[i].isActive);
      FileWriteDouble(handle,g_trailingStates[i].peakProfit);
      FileWriteDouble(handle,g_trailingStates[i].currentProfit);
      FileWriteDouble(handle,g_trailingStates[i].lockedProfit);
      FileWriteDouble(handle,g_trailingStates[i].initialProfit);
      FileWriteDouble(handle,g_trailingStates[i].currentSL);
      FileWriteDouble(handle,g_trailingStates[i].openPrice);
      FileWriteInteger(handle,g_trailingStates[i].level);
      FileWriteInteger(handle,(int)g_trailingStates[i].level1Hit);
      FileWriteInteger(handle,(int)g_trailingStates[i].level2Hit);
      FileWriteInteger(handle,(int)g_trailingStates[i].level3Hit);
      FileWriteInteger(handle,(int)g_trailingStates[i].level4Hit);
   }
   // Hesap ve istatistik
   FileWriteDouble(handle,g_account.balance);
   FileWriteDouble(handle,g_account.equity);
   FileWriteDouble(handle,g_account.dailyPnL);
   FileWriteInteger(handle,g_account.totalPackets);
   FileWriteInteger(handle,g_account.successPackets);
   FileWriteInteger(handle,g_account.failedPackets);
   FileWriteInteger(handle,g_stats.boostX3Count);
   FileWriteInteger(handle,g_stats.boostX9Count);
   FileWriteInteger(handle,g_stats.boostX27Count);
   FileWriteInteger(handle,g_stats.recoveryCount);
   FileWriteInteger(handle,g_trailingStats.totalActivations);
   FileWriteInteger(handle,g_trailingStats.breakevenHits);
   FileWriteDouble(handle,g_trailingStats.totalLockedProfit);
   FileClose(handle);
}

bool LoadSystemState() {
   if(!FileIsExist("ANX_STATE.bin",FILE_COMMON)) return false;
   int handle=FileOpen("ANX_STATE.bin",
               FILE_READ|FILE_BIN|FILE_COMMON);
   if(handle==INVALID_HANDLE) return false;
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      g_packets[i].magicID       =(ulong)FileReadDouble(handle);
      g_packets[i].baseLot       =FileReadDouble(handle);
      g_packets[i].buyTicket     =FileReadDouble(handle);
      g_packets[i].sellTicket    =FileReadDouble(handle);
      g_packets[i].boostTicket   =FileReadDouble(handle);
      g_packets[i].openPrice     =FileReadDouble(handle);
      g_packets[i].spreadAtOpen  =FileReadDouble(handle);
      g_packets[i].recoveryTarget=FileReadDouble(handle);
      g_packets[i].boostLevel    =FileReadInteger(handle);
      g_packets[i].boostState    =FileReadInteger(handle);
      g_packets[i].mumDevretCount=FileReadInteger(handle);
      g_packets[i].isRecovery    =(bool)FileReadInteger(handle);
      g_packets[i].isFirstPacket =(bool)FileReadInteger(handle);
      g_packets[i].openTime      =(datetime)FileReadInteger(handle);
      int state=FileReadInteger(handle);
      if(state>=0&&state<=(int)STATE_NEWS_FILTER)
         g_systemStates[i]=(ENUM_SYSTEM_STATE)state;
      g_trailingStates[i].ticket      =(ulong)FileReadDouble(handle);
      g_trailingStates[i].isActive    =(bool)FileReadInteger(handle);
      g_trailingStates[i].peakProfit  =FileReadDouble(handle);
      g_trailingStates[i].currentProfit=FileReadDouble(handle);
      g_trailingStates[i].lockedProfit=FileReadDouble(handle);
      g_trailingStates[i].initialProfit=FileReadDouble(handle);
      g_trailingStates[i].currentSL  =FileReadDouble(handle);
      g_trailingStates[i].openPrice  =FileReadDouble(handle);
      g_trailingStates[i].level      =FileReadInteger(handle);
      g_trailingStates[i].level1Hit  =(bool)FileReadInteger(handle);
      g_trailingStates[i].level2Hit  =(bool)FileReadInteger(handle);
      g_trailingStates[i].level3Hit  =(bool)FileReadInteger(handle);
      g_trailingStates[i].level4Hit  =(bool)FileReadInteger(handle);
   }
   g_account.balance        =FileReadDouble(handle);
   g_account.equity         =FileReadDouble(handle);
   g_account.dailyPnL       =FileReadDouble(handle);
   g_account.totalPackets   =FileReadInteger(handle);
   g_account.successPackets =FileReadInteger(handle);
   g_account.failedPackets  =FileReadInteger(handle);
   g_stats.boostX3Count     =FileReadInteger(handle);
   g_stats.boostX9Count     =FileReadInteger(handle);
   g_stats.boostX27Count    =FileReadInteger(handle);
   g_stats.recoveryCount    =FileReadInteger(handle);
   g_trailingStats.totalActivations=FileReadInteger(handle);
   g_trailingStats.breakevenHits   =FileReadInteger(handle);
   g_trailingStats.totalLockedProfit=FileReadDouble(handle);
   FileClose(handle);
   NexusLog(LOG_INFO,"SYSTEM","Sistem durumu kurtarildi!");
   SendTelegramMessage(
      "AsFaRaS NEXUS YENIDEN BASLADI\n"
      "Durum kurtarildi.\n"+
      TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return true;
}

//+------------------------------------------------------------------+
//| YARDIMCI FONKSİYONLAR                                            |
//+------------------------------------------------------------------+
bool IsNewM5Candle(int symIdx) {
   datetime curBarTime=iTime(g_symbols[symIdx],PERIOD_M5,0);
   if(curBarTime!=g_lastM5Time[symIdx]) {
      g_lastM5Time[symIdx]=curBarTime;
      return true;
   }
   return false;
}

void UpdateAccountData() {
   double balance =AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  =AccountInfoDouble(ACCOUNT_EQUITY);
   double freeMarj=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   g_account.balance   =balance;
   g_account.equity    =equity;
   g_account.freeMargin=freeMarj;
   if(balance>0) {
      g_account.marginLevel=(equity/balance)*100.0;
      g_account.drawdown=MathMax(0,
         (balance-equity)/balance*100.0);
   }
}

bool RunBrokerTest(string symbol) {
   Print("=== AsFaRaS NEXUS BROKER TEST ===");
   bool ok=true;
   bool symOK=SymbolSelect(symbol,true);
   Print("[1] Sembol: ",symOK?"OK":"FAIL");
   if(!symOK) ok=false;
   bool hedgeOK=(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==
                 ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   g_broker.hedgeAllowed=hedgeOK;
   Print("[2] Hedge: ",hedgeOK?"OK":"WARN");
   double minLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   g_broker.minLot=minLot;
   Print("[3] MinLot(",minLot,"): ",minLot<=0.01?"OK":"WARN");
   int stopLvl=(int)SymbolInfoInteger(symbol,
               SYMBOL_TRADE_STOPS_LEVEL);
   g_broker.stopLevel=stopLvl;
   Print("[4] StopLevel(",stopLvl,"): ",stopLvl<=10?"OK":"WARN");
   bool tradeOK=(bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
   Print("[5] Trade: ",tradeOK?"OK":"FAIL");
   if(!tradeOK) ok=false;
   g_broker.maxLot =SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   g_broker.lotStep=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   g_broker.testPassed=ok;
   Print("[SONUC]: ",ok?"BASARILI":"UYARI VAR");
   return ok;
}

bool InitializeGlobals() {
   g_symbols[SYM_GOLD]    =InpSymbolGold;
   g_symbols[SYM_SILVER]  =InpSymbolSilver;
   g_symbols[SYM_EURUSD]  =InpSymbolEURUSD;
   g_symbols[SYM_BITCOIN] =InpSymbolBitcoin;
   g_symbols[SYM_ETHEREUM]=InpSymbolEthereum;
   g_systemStartTime=TimeCurrent();
   ZeroMemory(g_stats);
   g_stats.systemStartTime=g_systemStartTime;
   UpdateAccountData();
   g_account.sessionStart=TimeCurrent();
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
      if(!SymbolSelect(g_symbols[i],true)) {
         Print("HATA: Sembol bulunamadi: ",g_symbols[i]);
         return false;
      }
      g_magicIDs[i]    =GenerateMagicID(i);
      g_systemStates[i]=STATE_INIT;
      ZeroMemory(g_marketData[i]);
      g_marketData[i].category=
         (int)GetSymbolCategory(g_symbols[i]);
      g_marketData[i].digits=(int)SymbolInfoInteger(
                              g_symbols[i],SYMBOL_DIGITS);
      g_marketData[i].pipValue   =GetPipValue(g_symbols[i]);
      g_marketData[i].pointValue =SymbolInfoDouble(
                                  g_symbols[i],SYMBOL_POINT);
      g_marketData[i].tickSize   =SymbolInfoDouble(
                              g_symbols[i],SYMBOL_TRADE_TICK_SIZE);
      g_marketData[i].contractSize=SymbolInfoDouble(
                              g_symbols[i],SYMBOL_TRADE_CONTRACT_SIZE);
      ZeroMemory(g_packets[i]);
      g_packets[i].symbolIndex=i;
      g_packets[i].magicID    =g_magicIDs[i];
      g_packets[i].boostState =BOOST_NONE;
      ZeroMemory(g_trailingStates[i]);
      g_trailingStates[i].isActive   =false;
      g_trailingStates[i].symbolIndex=i;
      g_lastM5Time[i]=0;
      Print("OK [",IntegerToString(i),"] ",g_symbols[i],
            " Magic:",IntegerToString((int)g_magicIDs[i]));
   }
   g_lastHourlyReport=TimeCurrent();
   g_lastDailyReport =TimeCurrent();
   g_isInitialized=true;
   return true;
}

//+------------------------------------------------------------------+
//| ANA SEMBOL DÖNGÜSÜ                                               |
//+------------------------------------------------------------------+
void ProcessSymbol(int symIdx) {
   if(g_emergencyStop) return;
   string symbol=g_symbols[symIdx];
   UpdateAverageSpread(symIdx);
   UpdateAverageVolume(symIdx);
   CalculateHealthScore(symIdx);
   g_marketData[symIdx].bidPrice=
      SymbolInfoDouble(symbol,SYMBOL_BID);
   g_marketData[symIdx].askPrice=
      SymbolInfoDouble(symbol,SYMBOL_ASK);
   ENUM_SYSTEM_STATE state=g_systemStates[symIdx];
   if(state==STATE_INIT) {
      if(InpBrokerAutoTest) RunBrokerTest(symbol);
      if(OpenInitialPacket(symIdx))
         g_systemStates[symIdx]=STATE_PACKET_OPEN;
      else
         g_systemStates[symIdx]=STATE_ERROR;
      return;
   }
   if(state==STATE_ERROR) {
      static datetime lastRetry[];
      if(ArraySize(lastRetry)<NEXUS_SYMBOLS_COUNT)
         ArrayResize(lastRetry,NEXUS_SYMBOLS_COUNT);
      if(TimeCurrent()-lastRetry[symIdx]>300) {
         lastRetry[symIdx]=TimeCurrent();
         g_systemStates[symIdx]=STATE_SCANNING;
      }
      return;
   }
   if(state==STATE_PAUSED||state==STATE_NEWS_FILTER) {
      if(g_marketData[symIdx].healthScore>=InpMinHealthScore&&
         !g_systemPaused)
         g_systemStates[symIdx]=STATE_SCANNING;
      return;
   }
   if(state==STATE_SCANNING||state==STATE_RECOVERY) {
      if(!IsNewM5Candle(symIdx)) return;
      if(!IsVolumeDipDetected(symIdx)) return;
      if(g_marketData[symIdx].healthScore<InpMinHealthScore) {
         g_systemStates[symIdx]=STATE_PAUSED;
         return;
      }
      if(!CheckLossLimits())       return;
      if(!CheckMarginSafety(symIdx)) return;
      OpenNormalPacket(symIdx);
      return;
   }
   if(state==STATE_PACKET_OPEN||
      state==STATE_BOOST_X3   ||
      state==STATE_BOOST_X9   ||
      state==STATE_BOOST_X27) {
      CheckBoostTrigger(symIdx);
      CheckBoostConditions(symIdx);
      if(!HasActivePacket(symIdx)) {
         g_systemStates[symIdx]=STATE_SCANNING;
         SaveSystemState();
      }
      if(IsNewM5Candle(symIdx)&&
         g_packets[symIdx].boostState==BOOST_NONE&&
         state==STATE_PACKET_OPEN)
         g_packets[symIdx].mumDevretCount++;
   }
   if(g_trailingStates[symIdx].isActive)
      UpdateTrailing(symIdx);
}

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit() {
   Print("===========================================");
   Print("  AsFaRaS NEXUS Trading System v",NEXUS_VERSION);
   Print("  Bes Sembol. Sonsuz Dongu. Sifir Zarar.");
   Print("  -- AsFaRaS NEXUS --");
   Print("===========================================");
   OpenLogFile();
   NexusLog(LOG_INFO,"SYSTEM","AsFaRaS NEXUS baslatiliyor...");
   if(!InitializeGlobals()) {
      NexusLog(LOG_ERROR,"SYSTEM","Baslatma basarisiz!");
      return INIT_FAILED;
   }
   InitTrailingProfiles();
   ZeroMemory(g_trailingStats);
   if(LoadSystemState())
      NexusLog(LOG_INFO,"SYSTEM","Onceki durum kurtarildi!");
   UpdateMotivationQuote();
   EventSetTimer(1);
   string startMsg=StringFormat(
      "AsFaRaS NEXUS BASLIYOR v%s\n"
      "\"Bes Sembol. Sonsuz Dongu. Sifir Zarar.\"\n"
      "GOLD | SILVER | EURUSD | BTC | ETH\n"
      "Moduller: Hedge+Boost+Trailing+Recovery\n"
      "%s\n"
      "Gunun Sozu: %s\n"
      "-- AsFaRaS NEXUS --",
      NEXUS_VERSION,
      TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
      g_currentQuote);
   SendTelegramMessage(startMsg);
   NexusLog(LOG_INFO,"SYSTEM","AsFaRaS NEXUS hazir!");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   SaveSystemState();
   ObjectsDeleteAll(0,DASH_PREFIX);
   string reasonStr=
      reason==REASON_REMOVE   ?"EA Kaldirildi":
      reason==REASON_RECOMPILE?"Yeniden Derlendi":
      reason==REASON_CHARTCLOSE?"Chart Kapatildi":
      StringFormat("Sebep(%d)",reason);
   if(g_logFileHandle!=INVALID_HANDLE) {
      NexusLog(LOG_INFO,"SYSTEM",
         "AsFaRaS NEXUS durduruldu: "+reasonStr);
      FileClose(g_logFileHandle);
   }
   SendTelegramMessage(StringFormat(
      "AsFaRaS NEXUS DURDURULDU\n%s\n%s\n-- AsFaRaS NEXUS --",
      reasonStr,
      TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)));
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick() {
   if(!g_isInitialized||g_emergencyStop) return;
   UpdateAccountData();
   if(g_account.drawdown>=InpMaxDrawdown) {
      NexusLog(LOG_CRITICAL,"SYSTEM",
         StringFormat("EMERGENCY STOP! DD:%.2f%%",
                      g_account.drawdown));
      g_emergencyStop=true;
      SendTelegramMessage(
         "EMERGENCY STOP!\n"
         "Drawdown limiti asildi!\n"
         "Manuel mudahale gerekli!\n"
         "-- AsFaRaS NEXUS --");
      return;
   }
   for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++)
      ProcessSymbol(i);
   if(TimeCurrent()-g_lastDashUpdate>=2) {
      g_lastDashUpdate=TimeCurrent();
      DrawMiniDashboard();
      string curChart=Symbol();
      for(int i=0;i<NEXUS_SYMBOLS_COUNT;i++) {
         if(g_symbols[i]==curChart) {
            DrawFullDashboard(i);
            break;
         }
      }
   }
   static datetime lastSave=0;
   if(TimeCurrent()-lastSave>=30) {
      lastSave=TimeCurrent();
      SaveSystemState();
   }
}

//+------------------------------------------------------------------+
//| ONTIMER                                                           |
//+------------------------------------------------------------------+
void OnTimer() {
   if(!g_isInitialized) return;
   SendHourlyReport();
   SendDailyReport();
   if(g_account.drawdown>g_stats.maxDrawdownReached)
      g_stats.maxDrawdownReached=g_account.drawdown;
}

//+------------------------------------------------------------------+
//| ONTRADE                                                           |
//+------------------------------------------------------------------+
void OnTrade() {
   SaveSystemState();
   UpdateAccountData();
}
//+------------------------------------------------------------------+
//|       AsFaRaS NEXUS Trading System v1.2 - TAMAMLANDI            |
//|   "Beş Sembol. Sonsuz Döngü. Sıfır Zarar."                     |
//|                 — AsFaRaS NEXUS —                               |
//+------------------------------------------------------------------+
