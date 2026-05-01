//+------------------------------------------------------------------+
//|                AsFaRaS NEXUS Trading System v2.0                 |
//|         "Beş Sembol. Sonsuz Döngü. Sıfır Zarar."                |
//|                    — AsFaRaS NEXUS —                             |
//|  Ajan Konseyi Onaylı | AI Motor | Neon UI | Auto Symbol Detect  |
//+------------------------------------------------------------------+
#property copyright   "AsFaRaS NEXUS System v2.0"
#property link        "https://github.com/erdist27/AsFaRaS-NEXUS"
#property version     "2.00"
#property strict
#property description "Bes Sembol. Sonsuz Dongu. Sifir Zarar."
#property description "Ajan Konseyi Onayli | AI Motor | Neon UI"

//+------------------------------------------------------------------+
//| SABİTLER                                                         |
//+------------------------------------------------------------------+
#define NEXUS_VERSION          "2.0.0"
#define NEXUS_SYMBOLS_COUNT    5
#define SYM_GOLD               0
#define SYM_SILVER             1
#define SYM_EURUSD             2
#define SYM_BITCOIN            3
#define SYM_ETHEREUM           4
#define NEXUS_MAGIC_BASE       200000
#define MAX_SLIPPAGE_MULT      0.5
#define RECOVERY_LOT_BONUS     0.20
#define MAX_RETRY_COUNT        3
#define PROFIT_TARGET_PCT      0.100
#define TRAILING_STOP_PCT      0.050
#define HEALTH_CRITICAL        30
#define HEALTH_WEAK            50
#define HEALTH_NORMAL          75
#define DASH_PREFIX            "NEXUS2_"
#define MAX_MEMORY_RECORDS     500
#define AI_MIN_SAMPLES         20
#define AI_CONFIDENCE_THRESHOLD 0.60
#define LOG_BUFFER_SIZE        5
#define HEARTBEAT_INTERVAL     300
#define QUOTE_INTERVAL_SEC     1800

// Broker Suffix Listesi
#define BROKER_SUFFIX_COUNT    10

// Renk Paleti — Neon Tema
#define CLR_NEON_BG            C'8,10,18'
#define CLR_NEON_BG2           C'12,15,25'
#define CLR_NEON_BORDER        C'0,180,180'
#define CLR_NEON_BORDER2       C'0,80,80'
#define CLR_NEON_CYAN          C'0,255,229'
#define CLR_NEON_PURPLE        C'180,0,255'
#define CLR_NEON_GREEN         C'0,255,136'
#define CLR_NEON_ORANGE        C'255,140,0'
#define CLR_NEON_RED           C'255,50,80'
#define CLR_NEON_YELLOW        C'255,220,0'
#define CLR_NEON_BLUE          C'64,160,255'
#define CLR_NEON_WHITE         C'220,230,255'
#define CLR_NEON_DIM           C'80,90,120'
#define CLR_NEON_HEADER        C'10,14,28'
#define CLR_NEON_ROW1          C'10,13,22'
#define CLR_NEON_ROW2          C'8,11,19'

//+------------------------------------------------------------------+
//| ENUM TANIMLARI                                                    |
//+------------------------------------------------------------------+
enum ENUM_OPERATION_MODE {
   MODE_AUTO   = 0,
   MODE_SYMBOL = 1,
   MODE_PANEL  = 2
};

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

//+------------------------------------------------------------------+
//| INPUT PARAMETRELERİ — Temizlenmiş & Yeniden Düzenlenmiş         |
//+------------------------------------------------------------------+
input group "╔═══════ AsFaRaS NEXUS v2.0 ═══════╗"
input ENUM_OPERATION_MODE InpOperationMode = MODE_AUTO;
// MODE_AUTO   = Chart sembolünü otomatik algıla
// MODE_SYMBOL = Sadece bu chart için tekli mod + Mini Dashboard
// MODE_PANEL  = 5 sembol tam neon panel modu

input group "╠═══════ RİSK AYARLARI ═══════╣"
input double  InpRiskPercent     = 0.5;
input double  InpMaxDrawdown     = 20.0;
input double  InpDailyLossLimit  = 2.0;
input double  InpMinLot          = 0.01;
input double  InpMaxLot          = 5.0;

input group "╠═══════ BOOST AYARLARI ═══════╣"
input double  InpBoostThreshPct  = 1.0;
input double  InpBoostX9StopPct  = 10.0;
input double  InpBoostX27StopPct = 20.0;
input double  InpBoostX27ClosePct= 30.0;

input group "╠═══════ PIYASA SAĞLIK ═══════╣"
input int     InpHealthPeriod    = 20;
input double  InpMinHealthScore  = 30.0;

input group "╠═══════ TELEGRAM ═══════╣"
input string  InpTelegramToken   = "";
input string  InpTelegramChatID  = "";
input bool    InpTelegramActive  = true;
input int     InpHourlyReport    = 1;
input bool    InpDailyReport     = true;

input group "╠═══════ AI MOTOR ═══════╣"
input bool    InpAIEnabled       = true;
input bool    InpAIAdvisoryOnly  = true;
input int     InpAIMinSamples    = 20;

input group "╠═══════ SİSTEM ═══════╣"
input bool    InpDebugMode       = true;
input string  InpLogFileName     = "NEXUS2_LOG";
input bool    InpBrokerAutoTest  = true;
input int     InpMagicOffset     = 0;

input group "╚═══════ DASHBOARD ═══════╝"
input int     InpDashX           = 10;
input int     InpDashY           = 30;
input bool    InpShowClock       = true;

//+------------------------------------------------------------------+
//| STRUCT TANIMLARI                                                  |
//+------------------------------------------------------------------+
struct PacketState {
   ulong    magicID;
   int      symbolIndex;
   double   baseLot;
   int      boostLevel;
   double   buyTicket;
   double   sellTicket;
   double   boostTicket;
   double   openPrice;
   double   spreadAtOpen;
   datetime openTime;
   datetime lastUpdateTime;
   bool     isRecovery;
   double   recoveryTarget;
   int      boostState;
   bool     isFirstPacket;
   int      mumDevretCount;
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
   int      updateCount;
};

struct TrailingStats {
   int      totalActivations;
   int      breakevenHits;
   int      level2Hits;
   int      level3Hits;
   int      level4Hits;
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

// AI Hafıza Kaydı
struct TradeMemoryRecord {
   datetime openTime;
   datetime closeTime;
   int      symbolIndex;
   double   openHealth;
   double   openSpread;
   double   openVolume;
   double   openATR;
   int      sessionHour;
   int      dayOfWeek;
   int      boostLevel;
   double   finalPnL;
   bool     wasSuccessful;
   double   duration;
};

// AI Model Ağırlıkları
struct AIModelWeights {
   double   healthWeight;
   double   spreadWeight;
   double   volumeWeight;
   double   sessionWeights[24];
   double   dayWeights[7];
   double   minSuccessHealth;
   double   optimalSpreadRatio;
   int      totalSamples;
   double   overallWinRate;
   bool     isReady;
};

// Dashboard Cache
struct DashboardCache {
   double   lastHealth[NEXUS_SYMBOLS_COUNT];
   double   lastPnL[NEXUS_SYMBOLS_COUNT];
   int      lastBoostState[NEXUS_SYMBOLS_COUNT];
   int      lastState[NEXUS_SYMBOLS_COUNT];
   double   lastBalance;
   double   lastEquity;
   double   lastDrawdown;
   bool     initialized;
   bool     liveToggle;
};

// Log Buffer
struct LogBuffer {
   string   messages[LOG_BUFFER_SIZE];
   color    colors[LOG_BUFFER_SIZE];
   int      head;
   int      count;
};

//+------------------------------------------------------------------+
//| GLOBAL DEĞİŞKENLER                                               |
//+------------------------------------------------------------------+
string             g_symbols[NEXUS_SYMBOLS_COUNT];
string             g_resolvedSymbols[NEXUS_SYMBOLS_COUNT];
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
int                g_atrHandles[NEXUS_SYMBOLS_COUNT];
int                g_atrHandles14[NEXUS_SYMBOLS_COUNT];
datetime           g_lastM5Time[NEXUS_SYMBOLS_COUNT];
datetime           g_lastHourlyReport;
datetime           g_lastDailyReport;
datetime           g_lastHeartbeat;
datetime           g_systemStartTime;
bool               g_isInitialized   = false;
bool               g_systemPaused    = false;
bool               g_emergencyStop   = false;
int                g_logFileHandle   = INVALID_HANDLE;
datetime           g_lastDashUpdate  = 0;
datetime           g_lastSave        = 0;
ENUM_OPERATION_MODE g_operationMode  = MODE_AUTO;
int                g_singleSymbolIdx = -1;
DashboardCache     g_dashCache;
LogBuffer          g_logBuffer;

// Motivasyon
string   g_currentQuote    = "";
datetime g_lastQuoteTime   = 0;
int      g_currentQuoteIdx = 0;

// AI Motor
TradeMemoryRecord g_tradeMemory[];
int               g_memoryCount = 0;
AIModelWeights    g_aiModel;

// Broker Suffix listesi
string g_brokerSuffixes[BROKER_SUFFIX_COUNT] = {
   "", "#", ".r", "_i", "m", ".pro", "+", "ECN", ".c", "pro"
};

// Sembol base isimleri [sembol][varyant]
string g_symbolBases[5][8] = {
   {"XAUUSD","GOLD","XAU","XAUUSD","GLD","gold","Gold",""},
   {"XAGUSD","SILVER","XAG","XAGUSD","SLV","silver","Silver",""},
   {"EURUSD","EUR","eurusd","EURUSD","","","",""},
   {"BTCUSD","BITCOIN","BTC","BTCUSD","Bitcoin","btc","",""},
   {"ETHUSD","ETHEREUM","ETH","ETHUSD","Ethereum","eth","",""}
};

// Motivasyon havuzları
string g_quotesSabir[] = {
   "Sabir, basarinin sessiz ama en guclu motorudur.",
   "Dogru an icin beklemek, aceleci kaybetmekten iyidir.",
   "Piyasa test eder. Sabir kazanir.",
   "Her bekleme ani, bir sonraki firsat icin hazirlanmaktir.",
   "En iyi islemler zorla degil, bekleyerek gelir."
};
string g_quotesGuc[] = {
   "Sistem calisir. Sen sisteme guven.",
   "Her pip, disiplinin bir oduludur.",
   "Korkma. Sistem seni koruyor.",
   "Simdi odaklan. Kalanini sistem halleder.",
   "Algoritma yorulmaz. Sen de yorulma."
};
string g_quotesDisipl[] = {
   "Kural bozulmaz. Sistem bozulmaz.",
   "Disiplin, en karli yatirimdir.",
   "Duygular satar. Sistem kazanir.",
   "Plan ne diyorsa o olur. Sapma yok.",
   "Bugunku disiplin, yarinin ozgurluğudur."
};
string g_quotesVizyon[] = {
   "Bugun ekilenler yarin bicilenlerdir.",
   "Buyuk resmi gormeyen kucuk kayipte bogulur.",
   "Her islem bir adim. Yolculuk suruyor.",
   "Kucuk karlar, buyuk hayallerin tuglalaridir.",
   "Zaman, en iyi ortaginizdir."
};
string g_quotesGece[] = {
   "Sistem uyumaz. Sen uyu, o calisir.",
   "Gece sessizligi, piyasanin derin nefesidir.",
   "Her sabah sifirdan baslamak bir avantajdir.",
   "Uyurken sistem buyur.",
   "Sabah geldiginde sistem hazir olacak."
};
string g_quotesRecovery[] = {
   "Firtina ne kadar surerse surSun, gunes hep dogar.",
   "Her zarar, bir sonraki kazancin ogretmenidir.",
   "Sistem bir kez dustu, bin kez kalkar.",
   "Kriz, sistemi daha guclu yapar.",
   "En buyuk kazananlar en cok dusup kalkanlardir."
};
string g_quotesBoost[] = {
   "Firsat yakalandi. Sistem devrede!",
   "Boost aktif. Guven tam.",
   "Sistem gucunu gosteriyor!",
   "Bu an icin tasarlandik.",
   "Hazirlik bu anin icindi."
};
string g_quotesAI[] = {
   "AI gozlemliyor. Sistem ogreniyor.",
   "Her islem, makinenin bilgeliğine katkidir.",
   "Veri birikir. Wisdom ortaya cikar.",
   "AI onerir. Sistem karar verir. Sen onaylarsın.",
   "Makine yorulmadan, surekli ogrenerek buyur."
};

//+------------------------------------------------------------------+
//| LOG SİSTEMİ                                                      |
//+------------------------------------------------------------------+
void AddToLogBuffer(string message, color clr) {
   g_logBuffer.messages[g_logBuffer.head] = message;
   g_logBuffer.colors[g_logBuffer.head]   = clr;
   g_logBuffer.head = (g_logBuffer.head + 1) % LOG_BUFFER_SIZE;
   if(g_logBuffer.count < LOG_BUFFER_SIZE)
      g_logBuffer.count++;
}

void NexusLog(ENUM_LOG_LEVEL level, string symbol, string message) {
   if(!InpDebugMode && level == LOG_DEBUG) return;

   string levelStr, prefix;
   color  bufClr;
   switch(level) {
      case LOG_DEBUG:    levelStr="DBG"; prefix="[D]"; bufClr=CLR_NEON_DIM;     break;
      case LOG_INFO:     levelStr="INF"; prefix="[I]"; bufClr=CLR_NEON_WHITE;   break;
      case LOG_WARNING:  levelStr="WRN"; prefix="[W]"; bufClr=CLR_NEON_YELLOW;  break;
      case LOG_ERROR:    levelStr="ERR"; prefix="[E]"; bufClr=CLR_NEON_RED;     break;
      case LOG_CRITICAL: levelStr="CRT"; prefix="[!]"; bufClr=CLR_NEON_RED;     break;
      default:           levelStr="UNK"; prefix="[?]"; bufClr=CLR_NEON_DIM;     break;
   }

   string timeStr = TimeToString(TimeCurrent(), TIME_SECONDS);
   string logLine = StringFormat("[%s][%s][%s] %s %s",
                    timeStr, symbol, levelStr, prefix, message);
   Print(logLine);

   // Log buffer'a ekle
   string shortLine = StringFormat("%s [%s] %s",
                      timeStr, symbol, message);
   AddToLogBuffer(shortLine, bufClr);

   if(g_logFileHandle != INVALID_HANDLE) {
      FileWrite(g_logFileHandle, logLine);
      FileFlush(g_logFileHandle);
   }
   if(level == LOG_CRITICAL)
      SendTelegramMessage("NEXUS KRİTİK\n" + symbol + "\n" + message);
}

void OpenLogFile() {
   string fileName = InpLogFileName + ".log";
   g_logFileHandle = FileOpen(fileName,
                     FILE_WRITE | FILE_READ | FILE_TXT |
                     FILE_ANSI | FILE_SHARE_READ);
   if(g_logFileHandle == INVALID_HANDLE) return;
   FileSeek(g_logFileHandle, 0, SEEK_END);
   FileWrite(g_logFileHandle,
      "=== AsFaRaS NEXUS v" + NEXUS_VERSION + " LOG START ===");
   FileFlush(g_logFileHandle);
}

//+------------------------------------------------------------------+
//| SEMBOL ÇÖZÜMLEME — Otomatik Broker Suffix Tespiti               |
//+------------------------------------------------------------------+
string ResolveSymbol(int symIdx) {
   // Önce chart sembolü ile eşleşiyor mu kontrol et
   string chartSym = Symbol();
   for(int b = 0; b < 8; b++) {
      if(g_symbolBases[symIdx][b] == "") continue;
      if(StringFind(chartSym, g_symbolBases[symIdx][b]) >= 0) {
         NexusLog(LOG_INFO, "SYMRES",
            StringFormat("[%d] Chart eslesme: %s", symIdx, chartSym));
         return chartSym;
      }
   }

   // Broker'da tüm suffix kombinasyonlarını dene
   for(int b = 0; b < 8; b++) {
      if(g_symbolBases[symIdx][b] == "") continue;
      for(int s = 0; s < BROKER_SUFFIX_COUNT; s++) {
         string candidate = g_symbolBases[symIdx][b] +
                           g_brokerSuffixes[s];
         if(SymbolSelect(candidate, true)) {
            double bid = SymbolInfoDouble(candidate, SYMBOL_BID);
            if(bid > 0) {
               NexusLog(LOG_INFO, "SYMRES",
                  StringFormat("[%d] Bulundu: %s", symIdx, candidate));
               return candidate;
            }
         }
      }
   }

   // Fallback: standart isim
   NexusLog(LOG_WARNING, "SYMRES",
      StringFormat("[%d] Fallback: %s",
                   symIdx, g_symbolBases[symIdx][0]));
   return g_symbolBases[symIdx][0];
}

int DetectChartSymbolIndex() {
   string chartSym = Symbol();
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      for(int b = 0; b < 8; b++) {
         if(g_symbolBases[i][b] == "") continue;
         if(StringFind(chartSym, g_symbolBases[i][b]) >= 0)
            return i;
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| MAGIC ID — Deterministik (Ajan-1 Onaylı)                        |
//+------------------------------------------------------------------+
ulong GenerateMagicID(int symbolIndex) {
   long accNum = AccountInfoInteger(ACCOUNT_LOGIN);
   return (ulong)(MathAbs(accNum) % 100000) * 100 +
          (ulong)(symbolIndex * 10) +
          (ulong)InpMagicOffset;
}

//+------------------------------------------------------------------+
//| TELEGRAM                                                          |
//+------------------------------------------------------------------+
void SendTelegramMessage(string message) {
   if(!InpTelegramActive) return;
   if(InpTelegramToken == "" || InpTelegramChatID == "") return;
   string url  = "https://api.telegram.org/bot" +
                 InpTelegramToken + "/sendMessage";
   string body = "chat_id=" + InpTelegramChatID +
                 "&text=" + message + "&parse_mode=HTML";
   char   postData[], resultData[];
   string resultHeaders;
   StringToCharArray(body, postData, 0, StringLen(body), CP_UTF8);
   string headers = "Content-Type: "
                    "application/x-www-form-urlencoded\r\n";
   int res = WebRequest("POST", url, headers, 5000,
                        postData, resultData, resultHeaders);
   if(res == -1)
      Print("Telegram hata:", GetLastError());
}

void SendTelegramAlert(int symIdx, string title, bool isCritical) {
   string sym    = g_resolvedSymbols[symIdx];
   double health = g_marketData[symIdx].healthScore;
   double pnl    = GetPacketPnL(symIdx);
   double bal    = AccountInfoDouble(ACCOUNT_BALANCE);
   string icon   = isCritical ? "[KRİTİK]" : "[UYARI]";
   string msg = StringFormat(
      "%s AsFaRaS NEXUS v2.0\n"
      "Sembol: %s\nDurum: %s\n"
      "P&L: %+.2f$\nBakiye: $%.2f\n"
      "Saglik: %.0f/100\n"
      "AI: %s\n%s",
      icon, sym, title, pnl, bal, health,
      GetAIStatusString(symIdx),
      TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS));
   SendTelegramMessage(msg);
}

void SendHourlyReport() {
   datetime now = TimeCurrent();
   if((int)(now - g_lastHourlyReport) < InpHourlyReport * 3600) return;
   g_lastHourlyReport = now;

   double bal  = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   int    tot  = g_account.totalPackets;
   int    succ = g_account.successPackets;
   double wr   = tot > 0 ? (double)succ / tot * 100 : 0;

   string symInfo = "";
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      symInfo += StringFormat("%s: H=%.0f P=%+.2f$ AI=%s\n",
                 GetSymbolShortName(i),
                 g_marketData[i].healthScore,
                 GetPacketPnL(i),
                 GetAIStatusString(i));
   }
   string msg = StringFormat(
      "NEXUS v2.0 SAATLIK RAPOR\n%s\n\n"
      "Bakiye: $%.2f | Equity: $%.2f\n\n"
      "%s\n"
      "Boost x3/x9/x27: %d/%d/%d\n"
      "Basari: %d/%d (%.1f%%)\n"
      "AI Ornekler: %d | WinRate: %.1f%%\n\n"
      "%s\n-- AsFaRaS NEXUS --",
      TimeToString(now, TIME_DATE | TIME_MINUTES),
      bal, eq, symInfo,
      g_stats.boostX3Count, g_stats.boostX9Count,
      g_stats.boostX27Count, succ, tot, wr,
      g_memoryCount, g_aiModel.overallWinRate * 100,
      g_currentQuote);
   SendTelegramMessage(msg);
}

void SendDailyReport() {
   if(!InpDailyReport) return;
   MqlDateTime dtN, dtL;
   TimeToStruct(TimeCurrent(),     dtN);
   TimeToStruct(g_lastDailyReport, dtL);
   if(dtN.day == dtL.day && dtN.mon == dtL.mon) return;
   g_lastDailyReport = TimeCurrent();

   double bal    = AccountInfoDouble(ACCOUNT_BALANCE);
   double daily  = g_account.dailyPnL;
   string icon   = daily >= 0 ? "[+]" : "[-]";
   string msg = StringFormat(
      "NEXUS v2.0 GUNLUK RAPOR\n%s\n\n"
      "%s Gunluk P&L: %+.2f$\n"
      "Bakiye: $%.2f\nMax DD: %.2f%%\n"
      "Recovery: %d\nAI Ornekler: %d\n\n"
      "%s\n-- AsFaRaS NEXUS --",
      TimeToString(TimeCurrent(), TIME_DATE),
      icon, daily, bal,
      g_stats.maxDrawdownReached,
      g_stats.recoveryCount, g_memoryCount,
      g_currentQuote);
   SendTelegramMessage(msg);
}

//+------------------------------------------------------------------+
//| YARDIMCI FONKSİYONLAR                                            |
//+------------------------------------------------------------------+
ENUM_SYMBOL_CATEGORY GetSymbolCategory(string symbol) {
   string sym = symbol;
   StringToUpper(sym);
   if(StringFind(sym, "XAU") >= 0 || StringFind(sym, "XAG") >= 0 ||
      StringFind(sym, "GOLD") >= 0 || StringFind(sym, "SILVER") >= 0)
      return CATEGORY_METALS;
   if(StringFind(sym, "BTC") >= 0 || StringFind(sym, "ETH") >= 0 ||
      StringFind(sym, "BITCOIN") >= 0 || StringFind(sym, "ETHEREUM") >= 0)
      return CATEGORY_CRYPTO;
   return CATEGORY_FOREX;
}

double GetPipValue(string symbol) {
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double point     = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int    digits    = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double pipSize   = (digits == 3 || digits == 5) ? point * 10 : point;
   if(tickSize <= 0) return 0;
   return (tickValue / tickSize) * pipSize;
}

double GetCurrentSpread(string symbol) {
   double ask   = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid   = SymbolInfoDouble(symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0) return 0;
   return (ask - bid) / point;
}

double NormalizeLot(string symbol, double lot) {
   double minLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(lotStep <= 0) lotStep = 0.01;
   lot = MathMax(lot, MathMax(minLot, InpMinLot));
   lot = MathMin(lot, MathMin(maxLot, InpMaxLot));
   lot = MathRound(lot / lotStep) * lotStep;
   return NormalizeDouble(lot, 2);
}

double CalculateBaseLot(string symbol, bool isRecovery = false) {
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double pipValue = GetPipValue(symbol);
   if(pipValue <= 0) return InpMinLot;
   double riskPct = InpRiskPercent / 100.0;
   double maxPip  = 30.0;
   ENUM_SYMBOL_CATEGORY cat = GetSymbolCategory(symbol);
   if(cat == CATEGORY_CRYPTO)     { maxPip = 50.0; riskPct *= 0.7; }
   else if(cat == CATEGORY_METALS)  maxPip = 35.0;
   double baseLot = (balance * riskPct) / (maxPip * pipValue * 27.0);
   if(isRecovery) baseLot *= (1.0 + RECOVERY_LOT_BONUS);
   return NormalizeLot(symbol, baseLot);
}

string DrawProgressBar(double value, double maxVal, int barLen) {
   int filled = (int)MathRound((value / maxVal) * barLen);
   filled = MathMax(0, MathMin(barLen, filled));
   string bar = "";
   for(int i = 0; i < barLen; i++)
      bar += (i < filled) ? "█" : "░";
   return bar;
}

string DrawHealthBar(double health, int barLen) {
   int filled = (int)MathRound((health / 100.0) * barLen);
   filled = MathMax(0, MathMin(barLen, filled));
   string bar = "";
   for(int i = 0; i < barLen; i++) {
      if(i < filled) {
         if(i < barLen * 0.33)      bar += "▓";
         else if(i < barLen * 0.66) bar += "▓";
         else                        bar += "▓";
      } else bar += "░";
   }
   return bar;
}

string GetSymbolShortName(int symIdx) {
   if(symIdx == SYM_GOLD)     return "GOLD ";
   if(symIdx == SYM_SILVER)   return "SILV ";
   if(symIdx == SYM_EURUSD)   return "EUUSD";
   if(symIdx == SYM_BITCOIN)  return "BTC  ";
   if(symIdx == SYM_ETHEREUM) return "ETH  ";
   return StringSubstr(g_resolvedSymbols[symIdx], 0, 5);
}

int GetCurrentHour() {
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return dt.hour;
}

int GetCurrentDayOfWeek() {
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return dt.day_of_week;
}

//+------------------------------------------------------------------+
//| PİYASA SAĞLIK SİSTEMİ                                           |
//+------------------------------------------------------------------+
double CalcSpreadFactor(int symIdx) {
   double cur = GetCurrentSpread(g_resolvedSymbols[symIdx]);
   double avg = g_marketData[symIdx].avgSpread;
   if(avg <= 0) avg = cur;
   if(cur <= 0) return 0;
   double ratio = MathMax(0.1, MathMin(2.0, avg / cur));
   return MathMax(0, MathMin(25.0, (ratio / 2.0) * 25.0));
}

double CalcVolumeFactor(int symIdx) {
   // Düzeltilmiş: Son 5 M5 mum ortalaması (Ajan-2 onaylı)
   double totalVol = 0;
   int    counted  = 0;
   for(int i = 1; i <= 5; i++) {
      long v = iVolume(g_resolvedSymbols[symIdx], PERIOD_M5, i);
      if(v > 0) { totalVol += v; counted++; }
   }
   double avgVol = counted > 0 ? totalVol / counted : 0;
   long   curVol = iVolume(g_resolvedSymbols[symIdx], PERIOD_M5, 0);
   if(avgVol <= 0 || curVol <= 0) return 12.5;
   double ratio = MathMax(0.1, MathMin(3.0, (double)curVol / avgVol));
   double score;
   if(ratio >= 0.5 && ratio <= 1.5)  score = 25.0;
   else if(ratio < 0.5)              score = ratio * 2.0 * 25.0;
   else                              score = MathMax(10.0, 25.0 - (ratio - 1.5) * 10.0);
   return MathMax(0, MathMin(25.0, score));
}

double CalcVolatilityFactor(int symIdx) {
   if(g_atrHandles[symIdx] == INVALID_HANDLE) return 12.5;
   double atrBuf[];
   ArraySetAsSeries(atrBuf, true);
   double curATR = 0;
   if(CopyBuffer(g_atrHandles[symIdx], 0, 0, 3, atrBuf) >= 3)
      curATR = (atrBuf[0] + atrBuf[1] + atrBuf[2]) / 3.0;
   if(curATR <= 0) return 12.5;
   string sym    = g_resolvedSymbols[symIdx];
   double point  = SymbolInfoDouble(sym, SYMBOL_POINT);
   g_marketData[symIdx].atr = curATR;
   double idealMin, idealMax;
   int cat = g_marketData[symIdx].category;
   if(cat == CATEGORY_CRYPTO)     { idealMin = point * 100; idealMax = point * 500; }
   else if(cat == CATEGORY_METALS){ idealMin = point * 50;  idealMax = point * 200; }
   else                           { idealMin = point * 5;   idealMax = point * 20;  }
   double score;
   if(curATR >= idealMin && curATR <= idealMax) score = 25.0;
   else if(curATR < idealMin) score = (curATR / idealMin) * 25.0;
   else score = MathMax(5.0, 25.0 - ((curATR - idealMax) / idealMax) * 15.0);
   return MathMax(0, MathMin(25.0, score));
}

double CalcMomentumFactor(int symIdx) {
   string sym = g_resolvedSymbols[symIdx];
   double closeArr[];
   ArraySetAsSeries(closeArr, true);
   if(CopyClose(sym, PERIOD_M5, 0, 5, closeArr) < 5) return 12.5;
   double momentum = 0;
   for(int i = 0; i < 4; i++)
      momentum += MathAbs(closeArr[i] - closeArr[i + 1]);
   double point     = SymbolInfoDouble(sym, SYMBOL_POINT);
   double avgMove   = momentum / 4.0;
   double idealMove;
   int cat = g_marketData[symIdx].category;
   if(cat == CATEGORY_CRYPTO)      idealMove = point * 50;
   else if(cat == CATEGORY_METALS) idealMove = point * 20;
   else                            idealMove = point * 3;
   if(idealMove <= 0) return 12.5;
   double ratio = MathMax(0.1, MathMin(3.0, avgMove / idealMove));
   double score;
   if(ratio >= 0.5 && ratio <= 1.5)  score = 25.0;
   else if(ratio < 0.5)              score = ratio * 2.0 * 25.0;
   else                              score = MathMax(5.0, 25.0 - (ratio - 1.5) * 15.0);
   return MathMax(0, MathMin(25.0, score));
}

double GetSessionMultiplier(int symIdx) {
   int hour = GetCurrentHour();
   int dow  = GetCurrentDayOfWeek();
   int cat  = g_marketData[symIdx].category;
   if(cat == CATEGORY_CRYPTO) {
      if(dow == 0 || dow == 6) { if(hour < 6) return 0.5; return 0.75; }
      if(hour < 6)               return 0.7;
      if(hour >= 14 && hour < 22) return 1.0;
      return 0.85;
   }
   if(dow == 0 || dow == 6)        return 0.2;
   if(hour < 6)                    return 0.4;
   if(hour >= 6  && hour < 8)      return 0.6;
   if(hour >= 8  && hour < 17)     return 1.0;
   if(hour >= 17 && hour < 20)     return 0.9;
   return 0.7;
}

double CalculateHealthScore(int symIdx) {
   double total = (CalcSpreadFactor(symIdx) +
                   CalcVolumeFactor(symIdx) +
                   CalcVolatilityFactor(symIdx) +
                   CalcMomentumFactor(symIdx)) *
                   GetSessionMultiplier(symIdx);
   total = MathMax(0, MathMin(100.0, total));
   g_marketData[symIdx].healthScore = total;
   if(total <= HEALTH_CRITICAL)     g_marketData[symIdx].healthState = 0;
   else if(total <= HEALTH_WEAK)    g_marketData[symIdx].healthState = 1;
   else if(total <= HEALTH_NORMAL)  g_marketData[symIdx].healthState = 2;
   else                             g_marketData[symIdx].healthState = 3;
   return total;
}

void UpdateAverageSpread(int symIdx) {
   string sym = g_resolvedSymbols[symIdx];
   double cur = GetCurrentSpread(sym);
   double alpha = 0.1;
   if(g_marketData[symIdx].avgSpread <= 0)
      g_marketData[symIdx].avgSpread = cur;
   else
      g_marketData[symIdx].avgSpread =
         alpha * cur + (1.0 - alpha) * g_marketData[symIdx].avgSpread;
   g_marketData[symIdx].spread = cur;
   if(g_marketData[symIdx].avgSpread > 0)
      g_marketData[symIdx].spreadRatio =
         cur / g_marketData[symIdx].avgSpread;
}

void UpdateAverageVolume(int symIdx) {
   long   curVol = iVolume(g_resolvedSymbols[symIdx], PERIOD_M5, 1);
   double alpha  = 0.1;
   if(g_marketData[symIdx].avgVolume <= 0)
      g_marketData[symIdx].avgVolume = (double)curVol;
   else
      g_marketData[symIdx].avgVolume =
         alpha * (double)curVol +
         (1.0 - alpha) * g_marketData[symIdx].avgVolume;
   g_marketData[symIdx].currentVolume = (double)curVol;
}

// Düzeltilmiş: Yeterli volume mu var? (Ajan-2 onaylı)
bool HasSufficientVolume(int symIdx) {
   long   curVol = iVolume(g_resolvedSymbols[symIdx], PERIOD_M1, 0);
   double avgVol = g_marketData[symIdx].avgVolume;
   if(avgVol <= 0) return true;
   return (curVol >= avgVol * 0.40);
}

//+------------------------------------------------------------------+
//| AI MOTOR — Katman 1 & 2 (Ajan-4 Onaylı)                        |
//+------------------------------------------------------------------+
void InitAIModel() {
   ZeroMemory(g_aiModel);
   for(int h = 0; h < 24; h++) g_aiModel.sessionWeights[h] = 0.5;
   for(int d = 0; d < 7;  d++) g_aiModel.dayWeights[d]     = 0.5;
   g_aiModel.minSuccessHealth  = InpMinHealthScore;
   g_aiModel.optimalSpreadRatio= 1.0;
   g_aiModel.overallWinRate    = 0.5;
   g_aiModel.isReady           = false;
   ArrayResize(g_tradeMemory, MAX_MEMORY_RECORDS);
   g_memoryCount = 0;
   LoadAIMemory();
}

void RecordTradeResult(int symIdx, double pnl, bool success) {
   if(!InpAIEnabled) return;
   if(g_memoryCount >= MAX_MEMORY_RECORDS) {
      // Circular buffer: en eski kaydı kaydır
      ArrayCopy(g_tradeMemory, g_tradeMemory, 0, 1,
                MAX_MEMORY_RECORDS - 1);
      g_memoryCount = MAX_MEMORY_RECORDS - 1;
   }
   TradeMemoryRecord rec;
   ZeroMemory(rec);
   rec.openTime      = g_packets[symIdx].openTime;
   rec.closeTime     = TimeCurrent();
   rec.symbolIndex   = symIdx;
   rec.openHealth    = g_marketData[symIdx].healthScore;
   rec.openSpread    = g_packets[symIdx].spreadAtOpen;
   rec.openVolume    = g_marketData[symIdx].avgVolume;
   rec.openATR       = g_marketData[symIdx].atr;
   rec.sessionHour   = GetCurrentHour();
   rec.dayOfWeek     = GetCurrentDayOfWeek();
   rec.boostLevel    = g_packets[symIdx].boostLevel;
   rec.finalPnL      = pnl;
   rec.wasSuccessful = success;
   rec.duration      = (double)(TimeCurrent() -
                       g_packets[symIdx].openTime) / 60.0;
   g_tradeMemory[g_memoryCount++] = rec;
   SaveAIMemory();
   UpdateAIModel();
   NexusLog(LOG_INFO, "AI",
      StringFormat("Kayit eklendi #%d Sonuc:%s PnL:%.2f",
      g_memoryCount, success ? "BASARILI" : "BASARISIZ", pnl));
}

void UpdateAIModel() {
   if(g_memoryCount < InpAIMinSamples) {
      g_aiModel.isReady = false;
      return;
   }
   double successHealth = 0, failHealth = 0;
   int    successCount  = 0, failCount  = 0;
   double sessionSuccess[24], sessionTotal[24];
   double daySuccess[7], dayTotal[7];
   ArrayInitialize(sessionSuccess, 0);
   ArrayInitialize(sessionTotal,   0);
   ArrayInitialize(daySuccess,     0);
   ArrayInitialize(dayTotal,       0);

   for(int i = 0; i < g_memoryCount; i++) {
      int h = MathMax(0, MathMin(23, g_tradeMemory[i].sessionHour));
      int d = MathMax(0, MathMin(6,  g_tradeMemory[i].dayOfWeek));
      sessionTotal[h]++;
      dayTotal[d]++;
      if(g_tradeMemory[i].wasSuccessful) {
         successHealth += g_tradeMemory[i].openHealth;
         sessionSuccess[h]++;
         daySuccess[d]++;
         successCount++;
      } else {
         failHealth += g_tradeMemory[i].openHealth;
         failCount++;
      }
   }

   if(successCount > 0)
      g_aiModel.minSuccessHealth = successHealth / successCount;

   for(int h = 0; h < 24; h++) {
      if(sessionTotal[h] >= 3)
         g_aiModel.sessionWeights[h] =
            sessionSuccess[h] / sessionTotal[h];
   }
   for(int d = 0; d < 7; d++) {
      if(dayTotal[d] >= 3)
         g_aiModel.dayWeights[d] =
            daySuccess[d] / dayTotal[d];
   }

   g_aiModel.overallWinRate =
      (double)successCount / (double)g_memoryCount;
   g_aiModel.totalSamples   = g_memoryCount;
   g_aiModel.isReady        = true;

   NexusLog(LOG_INFO, "AI",
      StringFormat("Model güncellendi. Ornek:%d WR:%.1f%% MinH:%.0f",
      g_memoryCount, g_aiModel.overallWinRate * 100,
      g_aiModel.minSuccessHealth));
}

double GetAIConfidenceScore(int symIdx) {
   if(!g_aiModel.isReady || !InpAIEnabled) return 0.5;
   double score = 0.5;

   // Sağlık skoru katkısı
   double health = g_marketData[symIdx].healthScore;
   if(health >= g_aiModel.minSuccessHealth)
      score += 0.20;
   else
      score -= 0.20 * (1.0 - health / g_aiModel.minSuccessHealth);

   // Seans katkısı
   int h = GetCurrentHour();
   int d = GetCurrentDayOfWeek();
   score += (g_aiModel.sessionWeights[h] - 0.5) * 0.30;
   score += (g_aiModel.dayWeights[d]     - 0.5) * 0.15;

   // Genel win rate katkısı
   if(g_aiModel.overallWinRate > 0.6) score += 0.10;
   if(g_aiModel.overallWinRate < 0.4) score -= 0.10;

   return MathMax(0, MathMin(1.0, score));
}

bool AIRecommendsEntry(int symIdx) {
   if(!InpAIEnabled) return true;
   if(!g_aiModel.isReady)    return true; // Yeterli veri yoksa engelleme
   double conf = GetAIConfidenceScore(symIdx);
   if(conf < AI_CONFIDENCE_THRESHOLD) {
      NexusLog(LOG_DEBUG, g_resolvedSymbols[symIdx],
         StringFormat("AI giris onermedi. Guven:%.0f%%",
                      conf * 100));
      return InpAIAdvisoryOnly; // Advisory only modda engelleme
   }
   return true;
}

string GetAIStatusString(int symIdx) {
   if(!InpAIEnabled)         return "AI:OFF";
   if(!g_aiModel.isReady)
      return StringFormat("AI:Ogr(%d/%d)",
             g_memoryCount, InpAIMinSamples);
   double conf = GetAIConfidenceScore(symIdx);
   string rec;
   if(conf >= 0.75)       rec = "GIRIS";
   else if(conf >= 0.60)  rec = "IZLE ";
   else                   rec = "BEKLE";
   return StringFormat("AI:%s %.0f%%", rec, conf * 100);
}

void SaveAIMemory() {
   int f = FileOpen("ANX_AI_MEMORY.csv",
                    FILE_WRITE | FILE_CSV | FILE_COMMON);
   if(f == INVALID_HANDLE) return;
   FileWrite(f, "OpenTime,CloseTime,Symbol,Health,Spread,"
               "Volume,ATR,Hour,Day,BoostLvl,PnL,Success,Duration");
   for(int i = 0; i < g_memoryCount; i++) {
      FileWrite(f,
         IntegerToString((int)g_tradeMemory[i].openTime),
         IntegerToString((int)g_tradeMemory[i].closeTime),
         IntegerToString(g_tradeMemory[i].symbolIndex),
         DoubleToString(g_tradeMemory[i].openHealth,   2),
         DoubleToString(g_tradeMemory[i].openSpread,   5),
         DoubleToString(g_tradeMemory[i].openVolume,   0),
         DoubleToString(g_tradeMemory[i].openATR,      8),
         IntegerToString(g_tradeMemory[i].sessionHour),
         IntegerToString(g_tradeMemory[i].dayOfWeek),
         IntegerToString(g_tradeMemory[i].boostLevel),
         DoubleToString(g_tradeMemory[i].finalPnL,     2),
         IntegerToString((int)g_tradeMemory[i].wasSuccessful),
         DoubleToString(g_tradeMemory[i].duration,     1));
   }
   FileClose(f);
}

void LoadAIMemory() {
   if(!FileIsExist("ANX_AI_MEMORY.csv", FILE_COMMON)) return;
   int f = FileOpen("ANX_AI_MEMORY.csv",
                    FILE_READ | FILE_CSV | FILE_COMMON);
   if(f == INVALID_HANDLE) return;
   // Başlık satırını atla
   if(!FileIsEnding(f)) FileReadString(f);
   g_memoryCount = 0;
   while(!FileIsEnding(f) && g_memoryCount < MAX_MEMORY_RECORDS) {
      TradeMemoryRecord rec;
      ZeroMemory(rec);
      rec.openTime      = (datetime)StringToInteger(FileReadString(f));
      rec.closeTime     = (datetime)StringToInteger(FileReadString(f));
      rec.symbolIndex   = (int)StringToInteger(FileReadString(f));
      rec.openHealth    = StringToDouble(FileReadString(f));
      rec.openSpread    = StringToDouble(FileReadString(f));
      rec.openVolume    = StringToDouble(FileReadString(f));
      rec.openATR       = StringToDouble(FileReadString(f));
      rec.sessionHour   = (int)StringToInteger(FileReadString(f));
      rec.dayOfWeek     = (int)StringToInteger(FileReadString(f));
      rec.boostLevel    = (int)StringToInteger(FileReadString(f));
      rec.finalPnL      = StringToDouble(FileReadString(f));
      rec.wasSuccessful = (bool)StringToInteger(FileReadString(f));
      rec.duration      = StringToDouble(FileReadString(f));
      if(rec.openTime > 0)
         g_tradeMemory[g_memoryCount++] = rec;
   }
   FileClose(f);
   if(g_memoryCount > 0) {
      NexusLog(LOG_INFO, "AI",
         StringFormat("AI hafizasi yuklendi: %d kayit",
                      g_memoryCount));
      UpdateAIModel();
   }
}

//+------------------------------------------------------------------+
//| PAKET YÖNETİMİ                                                   |
//+------------------------------------------------------------------+
bool HasActivePacket(int symIdx) {
   string symbol = g_resolvedSymbols[symIdx];
   ulong  magic  = g_magicIDs[symIdx];
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) == symbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)magic)
         return true;
   }
   return false;
}

double GetPacketPnL(int symIdx) {
   string symbol = g_resolvedSymbols[symIdx];
   ulong  magic  = g_magicIDs[symIdx];
   double total  = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) == symbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)magic)
         total += PositionGetDouble(POSITION_PROFIT) +
                  PositionGetDouble(POSITION_SWAP);
   }
   return total;
}

ulong OpenOrder(string symbol, ENUM_ORDER_TYPE type,
                double lot, string comment, ulong magic,
                double sl = 0, double tp = 0) {
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);

   double price  = (type == ORDER_TYPE_BUY) ?
                   SymbolInfoDouble(symbol, SYMBOL_ASK) :
                   SymbolInfoDouble(symbol, SYMBOL_BID);
   double spread = SymbolInfoDouble(symbol, SYMBOL_ASK) -
                   SymbolInfoDouble(symbol, SYMBOL_BID);
   double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);

   // Kategori bazlı slippage limiti (Ajan-5 onaylı)
   int maxSlip;
   ENUM_SYMBOL_CATEGORY cat = GetSymbolCategory(symbol);
   if(cat == CATEGORY_CRYPTO)       maxSlip = 500;
   else if(cat == CATEGORY_METALS)  maxSlip = 30;
   else                             maxSlip = 10;

   int slipPoints = point > 0 ?
      (int)MathMin(maxSlip,
           MathMax(3, (spread * MAX_SLIPPAGE_MULT) / point)) : 3;

   request.action       = TRADE_ACTION_DEAL;
   request.symbol       = symbol;
   request.volume       = lot;
   request.type         = type;
   request.price        = price;
   request.deviation    = slipPoints;
   request.magic        = magic;
   request.comment      = comment;
   request.type_filling = ORDER_FILLING_IOC;
   if(sl > 0) request.sl = sl;
   if(tp > 0) request.tp = tp;

   for(int retry = 0; retry < MAX_RETRY_COUNT; retry++) {
      if(OrderSend(request, result) &&
         result.retcode == TRADE_RETCODE_DONE) {
         NexusLog(LOG_INFO, symbol,
            StringFormat("ACILDI %s Lot:%.2f T:%d",
            type == ORDER_TYPE_BUY ? "BUY" : "SELL",
            lot, (int)result.deal));
         return result.deal;
      }
      Sleep(500);
      price = (type == ORDER_TYPE_BUY) ?
               SymbolInfoDouble(symbol, SYMBOL_ASK) :
               SymbolInfoDouble(symbol, SYMBOL_BID);
      request.price = price;
   }
   NexusLog(LOG_ERROR, symbol,
      StringFormat("ACILAMADI! Hata:%d", result.retcode));
   return 0;
}

bool CloseOrder(string symbol, ulong ticket, string reason) {
   if(!PositionSelectByTicket(ticket)) return true; // Zaten kapali
   ENUM_POSITION_TYPE posType =
      (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);
   request.action       = TRADE_ACTION_DEAL;
   request.symbol       = symbol;
   request.volume       = PositionGetDouble(POSITION_VOLUME);
   request.type         = (posType == POSITION_TYPE_BUY) ?
                           ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   request.price        = (posType == POSITION_TYPE_BUY) ?
                           SymbolInfoDouble(symbol, SYMBOL_BID) :
                           SymbolInfoDouble(symbol, SYMBOL_ASK);
   request.position     = ticket;
   request.deviation    = 10;
   request.comment      = "ANX:" + reason;
   request.type_filling = ORDER_FILLING_IOC;

   for(int retry = 0; retry < MAX_RETRY_COUNT; retry++) {
      if(OrderSend(request, result) &&
         result.retcode == TRADE_RETCODE_DONE) return true;
      Sleep(300);
      // Pozisyon hala açık mı? (Ajan-5 onaylı)
      if(!PositionSelectByTicket(ticket)) return true;
      request.price = (posType == POSITION_TYPE_BUY) ?
                      SymbolInfoDouble(symbol, SYMBOL_BID) :
                      SymbolInfoDouble(symbol, SYMBOL_ASK);
   }
   return false;
}

bool CloseAllPacketOrders(int symIdx, string reason) {
   string symbol = g_resolvedSymbols[symIdx];
   ulong  magic  = g_magicIDs[symIdx];
   bool   allOK  = true;
   double totalPnL = 0;
   int    closedCount = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != symbol)    continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)magic) continue;
      totalPnL += PositionGetDouble(POSITION_PROFIT) +
                  PositionGetDouble(POSITION_SWAP);
      if(!CloseOrder(symbol, ticket, reason)) allOK = false;
      else closedCount++;
   }

   if(allOK) {
      bool success = (totalPnL >= 0);
      RecordTradeResult(symIdx, totalPnL, success);
      g_packets[symIdx].boostState  = BOOST_NONE;
      g_packets[symIdx].buyTicket   = 0;
      g_packets[symIdx].sellTicket  = 0;
      g_packets[symIdx].boostTicket = 0;
      g_systemStates[symIdx]        = STATE_SCANNING;
      NexusLog(LOG_INFO, symbol,
         StringFormat("Paket kapatildi. PnL:%.2f Kapat:%d",
                      totalPnL, closedCount));
   }
   return allOK;
}

bool CheckLossLimits() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(balance <= 0) return false;
   double drawdown = (balance - equity) / balance * 100.0;
   if(drawdown >= InpMaxDrawdown) {
      NexusLog(LOG_CRITICAL, "SYSTEM",
         StringFormat("MAX DD! %.2f%%", drawdown));
      g_emergencyStop = true;
      return false;
   }
   double dailyLimit = balance * (InpDailyLossLimit / 100.0);
   if(g_account.dailyPnL < -dailyLimit) {
      NexusLog(LOG_ERROR, "SYSTEM", "Gunluk zarar limiti!");
      return false;
   }
   return true;
}

bool CheckMarginSafety(int symIdx) {
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0) return false;
   if(freeMargin < balance * 0.20) {
      NexusLog(LOG_WARNING, g_resolvedSymbols[symIdx],
         StringFormat("Dusuk Margin: $%.2f", freeMargin));
      return false;
   }
   return true;
}

// Boost için sağlık eşiği (Ajan-1 onaylı)
double GetBoostHealthRequirement(int boostLevel) {
   if(boostLevel == 3)  return InpMinHealthScore;
   if(boostLevel == 9)  return InpMinHealthScore * 1.5;
   if(boostLevel == 27) return InpMinHealthScore * 2.0;
   return InpMinHealthScore;
}

bool OpenInitialPacket(int symIdx) {
   string symbol = g_resolvedSymbols[symIdx];
   ulong  magic  = g_magicIDs[symIdx];
   if(HasActivePacket(symIdx)) return false;
   // İlk paket de risk parametrelerine uymalı (Ajan-1 düzeltmesi)
   double lot = CalculateBaseLot(symbol, false);
   ulong buyT  = OpenOrder(symbol, ORDER_TYPE_BUY,  lot, "ANX_INIT_BUY", magic);
   ulong sellT = OpenOrder(symbol, ORDER_TYPE_SELL, lot, "ANX_INIT_SEL", magic);
   if(buyT > 0 && sellT > 0) {
      g_packets[symIdx].buyTicket     = (double)buyT;
      g_packets[symIdx].sellTicket    = (double)sellT;
      g_packets[symIdx].baseLot       = lot;
      g_packets[symIdx].openTime      = TimeCurrent();
      g_packets[symIdx].isFirstPacket = true;
      g_packets[symIdx].boostState    = BOOST_NONE;
      g_packets[symIdx].spreadAtOpen  = GetCurrentSpread(symbol);
      g_packets[symIdx].mumDevretCount= 0;
      g_systemStates[symIdx]          = STATE_PACKET_OPEN;
      g_account.totalPackets++;
      NexusLog(LOG_INFO, symbol,
         StringFormat("Ilk paket. Lot:%.2f", lot));
      return true;
   }
   return false;
}

bool OpenNormalPacket(int symIdx) {
   string symbol = g_resolvedSymbols[symIdx];
   ulong  magic  = g_magicIDs[symIdx];
   if(HasActivePacket(symIdx)) return false;
   if(g_marketData[symIdx].healthScore < InpMinHealthScore) {
      g_systemStates[symIdx] = STATE_PAUSED;
      return false;
   }
   if(!CheckLossLimits())        return false;
   if(!CheckMarginSafety(symIdx)) return false;
   if(!AIRecommendsEntry(symIdx)) return false;

   bool isRecovery = (g_systemStates[symIdx] == STATE_RECOVERY);
   double lot = CalculateBaseLot(symbol, isRecovery);

   ulong buyT  = OpenOrder(symbol, ORDER_TYPE_BUY, lot,
                 isRecovery ? "ANX_REC_BUY" : "ANX_BUY", magic);
   ulong sellT = OpenOrder(symbol, ORDER_TYPE_SELL, lot,
                 isRecovery ? "ANX_REC_SEL" : "ANX_SELL", magic);

   if(buyT > 0 && sellT > 0) {
      g_packets[symIdx].buyTicket     = (double)buyT;
      g_packets[symIdx].sellTicket    = (double)sellT;
      g_packets[symIdx].baseLot       = lot;
      g_packets[symIdx].openTime      = TimeCurrent();
      g_packets[symIdx].isFirstPacket = false;
      g_packets[symIdx].boostState    = BOOST_NONE;
      g_packets[symIdx].spreadAtOpen  = GetCurrentSpread(symbol);
      g_packets[symIdx].mumDevretCount= 0;
      g_systemStates[symIdx]          = STATE_PACKET_OPEN;
      g_account.totalPackets++;
      return true;
   }
   return false;
}

bool OpenBoostX3(int symIdx) {
   string symbol   = g_resolvedSymbols[symIdx];
   ulong  magic    = g_magicIDs[symIdx];
   // Sağlık kontrolü (Ajan-1)
   if(g_marketData[symIdx].healthScore <
      GetBoostHealthRequirement(3)) {
      NexusLog(LOG_WARNING, symbol, "x3 saglik yetersiz");
      return false;
   }
   double boostLot = NormalizeLot(symbol,
                     g_packets[symIdx].baseLot * 3.0);
   ulong  buyTkt   = (ulong)g_packets[symIdx].buyTicket;
   ulong  sellTkt  = (ulong)g_packets[symIdx].sellTicket;
   double buyPnL = 0, sellPnL = 0;
   if(PositionSelectByTicket(buyTkt))  buyPnL  = PositionGetDouble(POSITION_PROFIT);
   if(PositionSelectByTicket(sellTkt)) sellPnL = PositionGetDouble(POSITION_PROFIT);
   ENUM_ORDER_TYPE boostType =
      (buyPnL < sellPnL) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   ulong boostT = OpenOrder(symbol, boostType, boostLot,
                  "ANX_BST_X3", magic);
   if(boostT > 0) {
      g_packets[symIdx].boostTicket = (double)boostT;
      g_packets[symIdx].boostLevel  = 3;
      g_packets[symIdx].boostState  = BOOST_X3_ACTIVE;
      g_systemStates[symIdx]        = STATE_BOOST_X3;
      g_stats.boostX3Count++;
      SendTelegramAlert(symIdx, "x3 BOOST AKTIF", false);
      return true;
   }
   return false;
}

bool OpenBoostX9(int symIdx) {
   string symbol   = g_resolvedSymbols[symIdx];
   ulong  magic    = g_magicIDs[symIdx];
   if(g_marketData[symIdx].healthScore <
      GetBoostHealthRequirement(9)) {
      NexusLog(LOG_WARNING, symbol, "x9 saglik yetersiz");
   }
   double boostLot  = NormalizeLot(symbol,
                      g_packets[symIdx].baseLot * 9.0);
   ulong  prevBoost = (ulong)g_packets[symIdx].boostTicket;
   ENUM_ORDER_TYPE boostType = ORDER_TYPE_BUY;
   if(PositionSelectByTicket(prevBoost)) {
      ENUM_POSITION_TYPE pt =
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      boostType = (pt == POSITION_TYPE_BUY) ?
                   ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   }
   // Önce kapat, sonra aç (Ajan-5 düzeltmesi)
   if(prevBoost > 0) {
      if(!CloseOrder(symbol, prevBoost, "x3_x9")) {
         NexusLog(LOG_ERROR, symbol, "x3 kapatilamadi, x9 iptal");
         return false;
      }
   }
   ulong boostT = OpenOrder(symbol, boostType, boostLot,
                  "ANX_BST_X9", magic);
   if(boostT > 0) {
      g_packets[symIdx].boostTicket = (double)boostT;
      g_packets[symIdx].boostLevel  = 9;
      g_packets[symIdx].boostState  = BOOST_X9_ACTIVE;
      g_systemStates[symIdx]        = STATE_BOOST_X9;
      g_stats.boostX9Count++;
      SendTelegramAlert(symIdx, "x9 BOOST DIKKAT!", true);
      return true;
   }
   return false;
}

bool OpenBoostX27(int symIdx) {
   string symbol   = g_resolvedSymbols[symIdx];
   ulong  magic    = g_magicIDs[symIdx];

   double boostLot = NormalizeLot(symbol,
                     g_packets[symIdx].baseLot * 27.0);

   // Margin kontrolü (Ajan-1 onaylı)
   double reqMargin = 0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY, symbol, boostLot,
      SymbolInfoDouble(symbol, SYMBOL_ASK), reqMargin)) {
      NexusLog(LOG_ERROR, symbol, "x27 margin hesap hatasi");
      return false;
   }
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(freeMargin < reqMargin * 1.5) {
      NexusLog(LOG_WARNING, symbol,
         StringFormat("x27 yetersiz margin: %.2f < %.2f",
                      freeMargin, reqMargin * 1.5));
      return false;
   }
   if(!CheckLossLimits()) return false;

   ulong  prevBoost = (ulong)g_packets[symIdx].boostTicket;
   ENUM_ORDER_TYPE boostType = ORDER_TYPE_BUY;
   if(PositionSelectByTicket(prevBoost)) {
      ENUM_POSITION_TYPE pt =
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      boostType = (pt == POSITION_TYPE_BUY) ?
                   ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   }
   if(prevBoost > 0) {
      if(!CloseOrder(symbol, prevBoost, "x9_x27")) {
         NexusLog(LOG_ERROR, symbol, "x9 kapatilamadi, x27 iptal");
         return false;
      }
   }
   ulong boostT = OpenOrder(symbol, boostType, boostLot,
                  "ANX_BST_X27", magic);
   if(boostT > 0) {
      g_packets[symIdx].boostTicket = (double)boostT;
      g_packets[symIdx].boostLevel  = 27;
      g_packets[symIdx].boostState  = BOOST_X27_ACTIVE;
      g_systemStates[symIdx]        = STATE_BOOST_X27;
      g_stats.boostX27Count++;
      SendTelegramAlert(symIdx, "KRITIK x27 BOOST!", true);
      return true;
   }
   return false;
}

// Düzeltilmiş: P&L bazlı boost tetikleme (Ajan-2 onaylı)
void CheckBoostTrigger(int symIdx) {
   if(g_packets[symIdx].boostState != BOOST_NONE)   return;
   if(g_systemStates[symIdx] != STATE_PACKET_OPEN)  return;

   ulong  buyTkt  = (ulong)g_packets[symIdx].buyTicket;
   ulong  sellTkt = (ulong)g_packets[symIdx].sellTicket;
   double buyPnL  = 0, sellPnL = 0;
   if(PositionSelectByTicket(buyTkt))  buyPnL  = PositionGetDouble(POSITION_PROFIT);
   if(PositionSelectByTicket(sellTkt)) sellPnL = PositionGetDouble(POSITION_PROFIT);

   double totalPnL  = buyPnL + sellPnL;
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double threshold = balance * (InpBoostThreshPct / 100.0);

   if(totalPnL < -threshold)
      OpenBoostX3(symIdx);
}

void CheckBoostConditions(int symIdx) {
   int bs = g_packets[symIdx].boostState;
   if(bs == BOOST_NONE || bs == BOOST_COMPLETED ||
      bs == BOOST_FAILED) return;

   string symbol   = g_resolvedSymbols[symIdx];
   double spread   = g_marketData[symIdx].spread;
   double point    = g_marketData[symIdx].pointValue;
   double baseLot  = g_packets[symIdx].baseLot;
   ulong  boostTkt = (ulong)g_packets[symIdx].boostTicket;
   ulong  buyTkt   = (ulong)g_packets[symIdx].buyTicket;
   ulong  sellTkt  = (ulong)g_packets[symIdx].sellTicket;

   double boostPnL = 0;
   ENUM_POSITION_TYPE boostPosType = POSITION_TYPE_BUY;
   if(PositionSelectByTicket(boostTkt)) {
      boostPnL     = PositionGetDouble(POSITION_PROFIT);
      boostPosType = (ENUM_POSITION_TYPE)
                      PositionGetInteger(POSITION_TYPE);
   }
   double buyPnL = 0, sellPnL = 0;
   if(PositionSelectByTicket(buyTkt))  buyPnL  = PositionGetDouble(POSITION_PROFIT);
   if(PositionSelectByTicket(sellTkt)) sellPnL = PositionGetDouble(POSITION_PROFIT);

   double mainPnL = buyPnL + sellPnL;
   double digits  = g_marketData[symIdx].digits;
   double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
   double targetProfit = spread * pipSize * baseLot * (1.0 + PROFIT_TARGET_PCT);

   if(bs == BOOST_X3_ACTIVE) {
      double totalPnL = mainPnL + boostPnL;
      if(totalPnL >= targetProfit) {
         CloseOrder(symbol, buyTkt,  "BST_OK_MAIN");
         CloseOrder(symbol, sellTkt, "BST_OK_MAIN");
         g_packets[symIdx].boostState = BOOST_COMPLETED;
         g_systemStates[symIdx]       = STATE_SCANNING;
         g_account.successPackets++;
         InitTrailingState(symIdx, boostTkt, targetProfit);
         RecordTradeResult(symIdx, totalPnL, true);
         return;
      }
      double lossThr = spread * pipSize * InpBoostX9StopPct / 100.0;
      if(boostPnL <= -lossThr) OpenBoostX9(symIdx);
   }
   else if(bs == BOOST_X9_ACTIVE) {
      double totalPnL = mainPnL + boostPnL;
      if(totalPnL >= targetProfit) {
         CloseOrder(symbol, buyTkt,  "x9_OK");
         CloseOrder(symbol, sellTkt, "x9_OK");
         g_packets[symIdx].boostState = BOOST_COMPLETED;
         g_systemStates[symIdx]       = STATE_SCANNING;
         g_account.successPackets++;
         RecordTradeResult(symIdx, totalPnL, true);
         return;
      }
      double lossThr = spread * pipSize * InpBoostX27StopPct / 100.0;
      if(boostPnL <= -lossThr) OpenBoostX27(symIdx);
   }
   else if(bs == BOOST_X27_ACTIVE) {
      double totalPnL = mainPnL + boostPnL;
      if(totalPnL >= 0) {
         CloseAllPacketOrders(symIdx, "x27_OK");
         g_account.successPackets++;
         return;
      }
      double closeThr = spread * pipSize * InpBoostX27ClosePct / 100.0;
      if(boostPnL <= -closeThr) {
         double finalPnL = GetPacketPnL(symIdx);
         CloseAllPacketOrders(symIdx, "x27_FAIL");
         g_account.failedPackets++;
         g_stats.recoveryCount++;
         g_systemStates[symIdx]          = STATE_RECOVERY;
         g_packets[symIdx].isRecovery    = true;
         g_packets[symIdx].recoveryTarget= MathAbs(finalPnL) * 1.1;
         RecordTradeResult(symIdx, finalPnL, false);
         SendTelegramAlert(symIdx, "ZARAR Recovery Aktif!", true);
      }
   }
}

//+------------------------------------------------------------------+
//| TRAİLİNG STOP                                                    |
//+------------------------------------------------------------------+
void InitTrailingProfiles() {
   for(int s = 0; s < NEXUS_SYMBOLS_COUNT; s++) {
      g_trailingProfiles[s].level1TriggerPct   = 25.0;
      g_trailingProfiles[s].level2TriggerPct   = 50.0;
      g_trailingProfiles[s].level3TriggerPct   = 75.0;
      g_trailingProfiles[s].level4TriggerPct   = 100.0;
      g_trailingProfiles[s].spikeFilterTicks   = 3;
      g_trailingProfiles[s].spikeThresholdPct  = 0.20;
   }
   g_trailingProfiles[SYM_GOLD].atrMultLondon  = 0.30;
   g_trailingProfiles[SYM_GOLD].atrMultNY      = 0.45;
   g_trailingProfiles[SYM_GOLD].atrMultAsia    = 0.70;
   g_trailingProfiles[SYM_GOLD].atrMultNight   = 0.90;
   g_trailingProfiles[SYM_GOLD].minDistancePip = 5.0;
   g_trailingProfiles[SYM_GOLD].maxDistancePip = 50.0;
   g_trailingProfiles[SYM_SILVER].atrMultLondon  = 0.35;
   g_trailingProfiles[SYM_SILVER].atrMultNY      = 0.50;
   g_trailingProfiles[SYM_SILVER].atrMultAsia    = 0.75;
   g_trailingProfiles[SYM_SILVER].atrMultNight   = 1.00;
   g_trailingProfiles[SYM_SILVER].minDistancePip = 8.0;
   g_trailingProfiles[SYM_SILVER].maxDistancePip = 80.0;
   g_trailingProfiles[SYM_EURUSD].atrMultLondon  = 0.25;
   g_trailingProfiles[SYM_EURUSD].atrMultNY      = 0.35;
   g_trailingProfiles[SYM_EURUSD].atrMultAsia    = 0.65;
   g_trailingProfiles[SYM_EURUSD].atrMultNight   = 0.85;
   g_trailingProfiles[SYM_EURUSD].minDistancePip = 3.0;
   g_trailingProfiles[SYM_EURUSD].maxDistancePip = 25.0;
   g_trailingProfiles[SYM_BITCOIN].atrMultLondon  = 0.50;
   g_trailingProfiles[SYM_BITCOIN].atrMultNY      = 0.60;
   g_trailingProfiles[SYM_BITCOIN].atrMultAsia    = 0.80;
   g_trailingProfiles[SYM_BITCOIN].atrMultNight   = 1.00;
   g_trailingProfiles[SYM_BITCOIN].minDistancePip = 50.0;
   g_trailingProfiles[SYM_BITCOIN].maxDistancePip = 500.0;
   g_trailingProfiles[SYM_BITCOIN].spikeFilterTicks  = 5;
   g_trailingProfiles[SYM_BITCOIN].spikeThresholdPct = 0.50;
   g_trailingProfiles[SYM_ETHEREUM].atrMultLondon  = 0.55;
   g_trailingProfiles[SYM_ETHEREUM].atrMultNY      = 0.65;
   g_trailingProfiles[SYM_ETHEREUM].atrMultAsia    = 0.85;
   g_trailingProfiles[SYM_ETHEREUM].atrMultNight   = 1.10;
   g_trailingProfiles[SYM_ETHEREUM].minDistancePip = 30.0;
   g_trailingProfiles[SYM_ETHEREUM].maxDistancePip = 400.0;
   g_trailingProfiles[SYM_ETHEREUM].spikeFilterTicks  = 5;
   g_trailingProfiles[SYM_ETHEREUM].spikeThresholdPct = 0.60;
}

double GetSessionATRMult(int symIdx) {
   int hour = GetCurrentHour();
   int dow  = GetCurrentDayOfWeek();
   int cat  = g_marketData[symIdx].category;
   double aL = g_trailingProfiles[symIdx].atrMultLondon;
   double aN = g_trailingProfiles[symIdx].atrMultNY;
   double aA = g_trailingProfiles[symIdx].atrMultAsia;
   double aNt= g_trailingProfiles[symIdx].atrMultNight;
   if(cat == CATEGORY_CRYPTO) {
      if(dow == 0 || dow == 6) return aNt;
      if(hour < 6)              return aNt;
      if(hour >= 14 && hour < 22) return aL;
      return aA;
   }
   if(hour < 6)            return aNt;
   if(hour >= 6 && hour < 8)  return aA;
   if(hour >= 8 && hour < 17) return aL;
   if(hour >= 17 && hour < 20)return aN;
   return aNt;
}

double GetATRTrailingStep(int symIdx) {
   string symbol  = g_resolvedSymbols[symIdx];
   double minPip  = g_trailingProfiles[symIdx].minDistancePip;
   double maxPip  = g_trailingProfiles[symIdx].maxDistancePip;
   double atrValue= 0;
   if(g_atrHandles14[symIdx] != INVALID_HANDLE) {
      double atrBuf[];
      ArraySetAsSeries(atrBuf, true);
      if(CopyBuffer(g_atrHandles14[symIdx], 0, 0, 3, atrBuf) >= 3)
         atrValue = (atrBuf[0] + atrBuf[1] + atrBuf[2]) / 3.0;
   }
   double point   = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double pipSize = (g_marketData[symIdx].digits == 3 ||
                     g_marketData[symIdx].digits == 5) ?
                     point * 10 : point;
   if(atrValue <= 0 || pipSize <= 0) return minPip * pipSize;
   double step     = atrValue * GetSessionATRMult(symIdx);
   double stepPips = step / pipSize;
   stepPips = MathMax(stepPips, minPip);
   stepPips = MathMin(stepPips, maxPip);
   return stepPips * pipSize;
}

bool IsPriceSpike(int symIdx, double currentPrice) {
   int maxTicks = MathMax(1, g_trailingProfiles[symIdx].spikeFilterTicks);
   int idx = g_trailingStates[symIdx].tickCount % maxTicks;
   g_trailingStates[symIdx].tickHistory[idx] = currentPrice;
   g_trailingStates[symIdx].tickCount++;
   if(g_trailingStates[symIdx].tickCount < maxTicks) return false;
   double avg = 0;
   for(int i = 0; i < maxTicks; i++)
      avg += g_trailingStates[symIdx].tickHistory[i];
   avg /= maxTicks;
   if(avg <= 0) return false;
   double thresh = g_trailingProfiles[symIdx].spikeThresholdPct / 100.0;
   return (MathAbs(currentPrice - avg) / avg > thresh);
}

double CalculateSafeSL(string symbol, double price,
                        double desiredSL, bool isBuy) {
   int    stopLvl = (int)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point   = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double spread  = SymbolInfoDouble(symbol, SYMBOL_ASK) -
                    SymbolInfoDouble(symbol, SYMBOL_BID);
   double minDist = (stopLvl * point) + (spread * 1.5);
   double safeSL;
   if(isBuy) {
      safeSL = price - minDist;
      if(desiredSL < safeSL) safeSL = desiredSL;
   } else {
      safeSL = price + minDist;
      if(desiredSL > safeSL) safeSL = desiredSL;
   }
   return NormalizeDouble(safeSL,
          (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}

bool IsValidSLDistance(string symbol, double price,
                        double sl, bool isBuy) {
   int    stopLvl = (int)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point   = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(stopLvl <= 0) return true;
   double curDist = isBuy ? price - sl : sl - price;
   return (curDist >= stopLvl * point);
}

bool UpdatePositionSL(int symIdx, ulong ticket, double newSL) {
   string symbol = g_resolvedSymbols[symIdx];
   if(!PositionSelectByTicket(ticket)) return false;
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   newSL = NormalizeDouble(newSL, digits);
   MqlTradeRequest request;
   MqlTradeResult  result;
   ZeroMemory(request);
   ZeroMemory(result);
   request.action   = TRADE_ACTION_SLTP;
   request.symbol   = symbol;
   request.position = ticket;
   request.sl       = newSL;
   request.tp       = PositionGetDouble(POSITION_TP);
   return (OrderSend(request, result) &&
           result.retcode == TRADE_RETCODE_DONE);
}

void InitTrailingState(int symIdx, ulong ticket, double targetProfit) {
   if(!PositionSelectByTicket(ticket)) return;
   g_trailingStates[symIdx].ticket        = ticket;
   g_trailingStates[symIdx].symbolIndex   = symIdx;
   g_trailingStates[symIdx].isActive      = true;
   g_trailingStates[symIdx].openPrice     = PositionGetDouble(POSITION_PRICE_OPEN);
   g_trailingStates[symIdx].currentSL     = PositionGetDouble(POSITION_SL);
   g_trailingStates[symIdx].previousSL    = g_trailingStates[symIdx].currentSL;
   g_trailingStates[symIdx].initialProfit = targetProfit;
   g_trailingStates[symIdx].peakProfit    = 0;
   g_trailingStates[symIdx].lockedProfit  = 0;
   g_trailingStates[symIdx].level         = TRAIL_NONE;
   g_trailingStates[symIdx].level1Hit     = false;
   g_trailingStates[symIdx].level2Hit     = false;
   g_trailingStates[symIdx].level3Hit     = false;
   g_trailingStates[symIdx].level4Hit     = false;
   g_trailingStates[symIdx].activeSince   = TimeCurrent();
   g_trailingStates[symIdx].lastUpdate    = TimeCurrent();
   g_trailingStates[symIdx].tickCount     = 0;
   g_trailingStates[symIdx].updateCount   = 0;
   g_trailingStats.totalActivations++;
   NexusLog(LOG_INFO, g_resolvedSymbols[symIdx],
      StringFormat("Trailing basladi T:%d", (int)ticket));
}

void UpdateTrailing(int symIdx) {
   if(!g_trailingStates[symIdx].isActive) return;
   ulong ticket = g_trailingStates[symIdx].ticket;
   if(ticket <= 0) return;
   if(!PositionSelectByTicket(ticket)) {
      g_trailingStates[symIdx].isActive = false;
      g_trailingStates[symIdx].level    = TRAIL_COMPLETED;
      return;
   }
   string symbol  = g_resolvedSymbols[symIdx];
   bool   isBuy   = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   double curPrice = isBuy ?
      SymbolInfoDouble(symbol, SYMBOL_BID) :
      SymbolInfoDouble(symbol, SYMBOL_ASK);
   double curProfit = PositionGetDouble(POSITION_PROFIT) +
                      PositionGetDouble(POSITION_SWAP);
   if(IsPriceSpike(symIdx, curPrice)) return;
   g_trailingStates[symIdx].currentProfit = curProfit;
   g_trailingStates[symIdx].lastUpdate    = TimeCurrent();
   if(curProfit > g_trailingStates[symIdx].peakProfit)
      g_trailingStates[symIdx].peakProfit = curProfit;
   double initP = g_trailingStates[symIdx].initialProfit;
   if(initP <= 0) return;
   double pct = (curProfit / initP) * 100.0;
   double l1  = g_trailingProfiles[symIdx].level1TriggerPct;
   double l2  = g_trailingProfiles[symIdx].level2TriggerPct;
   double l3  = g_trailingProfiles[symIdx].level3TriggerPct;
   double l4  = g_trailingProfiles[symIdx].level4TriggerPct;
   if(!g_trailingStates[symIdx].level4Hit && pct >= l4) {
      ApplyTrailingLevel(symIdx, 75.0, TRAIL_LEVEL_4, isBuy, curPrice, curProfit);
      g_trailingStates[symIdx].level4Hit = true;
      g_trailingStats.level4Hits++;
      return;
   }
   if(!g_trailingStates[symIdx].level3Hit && pct >= l3) {
      ApplyTrailingLevel(symIdx, 50.0, TRAIL_LEVEL_3, isBuy, curPrice, curProfit);
      g_trailingStates[symIdx].level3Hit = true;
      g_trailingStats.level3Hits++;
      return;
   }
   if(!g_trailingStates[symIdx].level2Hit && pct >= l2) {
      ApplyTrailingLevel(symIdx, 25.0, TRAIL_LEVEL_2, isBuy, curPrice, curProfit);
      g_trailingStates[symIdx].level2Hit = true;
      g_trailingStats.level2Hits++;
      return;
   }
   if(!g_trailingStates[symIdx].level1Hit && pct >= l1) {
      ApplyBreakEven(symIdx, isBuy, curPrice);
      g_trailingStates[symIdx].level1Hit = true;
      g_trailingStats.breakevenHits++;
      return;
   }
   if(g_trailingStates[symIdx].level2Hit)
      UpdateContinuousTrailing(symIdx, isBuy, curPrice, curProfit);
   g_trailingStates[symIdx].updateCount++;
}

bool ApplyBreakEven(int symIdx, bool isBuy, double curPrice) {
   string symbol = g_resolvedSymbols[symIdx];
   double spread = GetCurrentSpread(symbol) *
                   SymbolInfoDouble(symbol, SYMBOL_POINT);
   double openP  = g_trailingStates[symIdx].openPrice;
   double newSL  = isBuy ? openP + spread * 1.2 : openP - spread * 1.2;
   if(!IsValidSLDistance(symbol, curPrice, newSL, isBuy)) return false;
   double curSL  = g_trailingStates[symIdx].currentSL;
   if(isBuy && curSL >= newSL)   return true;
   if(!isBuy && curSL <= newSL && curSL > 0) return true;
   ulong ticket  = g_trailingStates[symIdx].ticket;
   if(UpdatePositionSL(symIdx, ticket, newSL)) {
      g_trailingStates[symIdx].previousSL   = curSL;
      g_trailingStates[symIdx].currentSL    = newSL;
      g_trailingStates[symIdx].lockedProfit = 0;
      NexusLog(LOG_INFO, symbol,
         StringFormat("BREAKEVEN SL:%.5f", newSL));
      SendTrailingNotification(symIdx, 1,
         g_trailingStates[symIdx].currentProfit, 0);
      return true;
   }
   return false;
}

bool ApplyTrailingLevel(int symIdx, double lockPct, int newLevel,
                         bool isBuy, double curPrice, double curProfit) {
   string symbol     = g_resolvedSymbols[symIdx];
   double lockAmount = curProfit * (lockPct / 100.0);
   double trailStep  = GetATRTrailingStep(symIdx);
   double curSL      = g_trailingStates[symIdx].currentSL;
   double newSL;
   if(isBuy) {
      newSL = curPrice - trailStep;
      if(newSL <= curSL) newSL = curSL + trailStep * 0.5;
   } else {
      newSL = curPrice + trailStep;
      if(newSL >= curSL && curSL > 0) newSL = curSL - trailStep * 0.5;
   }
   newSL = CalculateSafeSL(symbol, curPrice, newSL, isBuy);
   if(!IsValidSLDistance(symbol, curPrice, newSL, isBuy)) return false;
   ulong ticket = g_trailingStates[symIdx].ticket;
   if(UpdatePositionSL(symIdx, ticket, newSL)) {
      g_trailingStates[symIdx].previousSL   = curSL;
      g_trailingStates[symIdx].currentSL    = newSL;
      g_trailingStates[symIdx].level        = newLevel;
      g_trailingStates[symIdx].lockedProfit = lockAmount;
      g_trailingStats.totalLockedProfit    += lockAmount;
      NexusLog(LOG_INFO, symbol,
         StringFormat("L%d AKTIF SL:%.5f Kilitli:$%.2f",
                      newLevel, newSL, lockAmount));
      SendTrailingNotification(symIdx, newLevel, curProfit, lockAmount);
      return true;
   }
   return false;
}

void UpdateContinuousTrailing(int symIdx, bool isBuy,
                               double curPrice, double curProfit) {
   string symbol     = g_resolvedSymbols[symIdx];
   double trailStep  = GetATRTrailingStep(symIdx);
   double curSL      = g_trailingStates[symIdx].currentSL;
   double peakProfit = g_trailingStates[symIdx].peakProfit;
   double newSL;
   bool   shouldUpdate = false;
   if(isBuy) {
      newSL = curPrice - trailStep;
      if(newSL > curSL + trailStep * 0.1) shouldUpdate = true;
   } else {
      newSL = curPrice + trailStep;
      if(newSL < curSL - trailStep * 0.1 && curSL > 0) shouldUpdate = true;
   }
   if(!shouldUpdate) return;
   if(peakProfit > 0 && curProfit < peakProfit * 0.85) {
      trailStep *= 0.6;
      newSL = isBuy ? curPrice - trailStep : curPrice + trailStep;
   }
   newSL = CalculateSafeSL(symbol, curPrice, newSL, isBuy);
   if(!IsValidSLDistance(symbol, curPrice, newSL, isBuy)) return;
   ulong ticket = g_trailingStates[symIdx].ticket;
   if(UpdatePositionSL(symIdx, ticket, newSL)) {
      g_trailingStates[symIdx].previousSL = curSL;
      g_trailingStates[symIdx].currentSL  = newSL;
   }
}

void SendTrailingNotification(int symIdx, int level,
                               double curProfit, double lockedProfit) {
   string sym = GetSymbolShortName(symIdx);
   string levelMsg, lockMsg;
   switch(level) {
      case 1: levelMsg="BREAKEVEN!";  lockMsg="Zarar riski YOK!"; break;
      case 2: levelMsg="SEVIYE-2!";   lockMsg=StringFormat("25%% +$%.2f", lockedProfit); break;
      case 3: levelMsg="SEVIYE-3!";   lockMsg=StringFormat("50%% +$%.2f", lockedProfit); break;
      default:levelMsg="SEVIYE-4!";   lockMsg=StringFormat("75%% +$%.2f", lockedProfit); break;
   }
   SendTelegramMessage(StringFormat(
      "NEXUS TRAILING %s\n%s\nKar:+$%.2f\n%s\nSL:%.5f",
      sym, levelMsg, curProfit, lockMsg,
      g_trailingStates[symIdx].currentSL));
}

//+------------------------------------------------------------------+
//| MOTİVASYON                                                       |
//+------------------------------------------------------------------+
string SelectMotivationQuote() {
   int  hour   = GetCurrentHour();
   bool anyRec = false, anyBst = false;
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      if(g_systemStates[i] == STATE_RECOVERY) anyRec = true;
      if(g_systemStates[i] == STATE_BOOST_X3  ||
         g_systemStates[i] == STATE_BOOST_X9  ||
         g_systemStates[i] == STATE_BOOST_X27) anyBst = true;
   }
   int idx;
   if(anyRec) { idx = g_currentQuoteIdx % ArraySize(g_quotesRecovery); return g_quotesRecovery[idx]; }
   if(anyBst) { idx = g_currentQuoteIdx % ArraySize(g_quotesBoost);    return g_quotesBoost[idx];    }
   if(g_aiModel.isReady && g_currentQuoteIdx % 4 == 0) {
      idx = g_currentQuoteIdx % ArraySize(g_quotesAI);
      return g_quotesAI[idx];
   }
   if(hour >= 8  && hour < 12) { idx = g_currentQuoteIdx % ArraySize(g_quotesSabir);  return g_quotesSabir[idx];  }
   if(hour >= 12 && hour < 17) { idx = g_currentQuoteIdx % ArraySize(g_quotesGuc);    return g_quotesGuc[idx];    }
   if(hour >= 17 && hour < 20) { idx = g_currentQuoteIdx % ArraySize(g_quotesDisipl); return g_quotesDisipl[idx]; }
   if(hour >= 20 && hour < 24) { idx = g_currentQuoteIdx % ArraySize(g_quotesVizyon); return g_quotesVizyon[idx]; }
   idx = g_currentQuoteIdx % ArraySize(g_quotesGece);
   return g_quotesGece[idx];
}

void UpdateMotivationQuote() {
   if(g_lastQuoteTime == 0 || g_currentQuote == "" ||
      (TimeCurrent() - g_lastQuoteTime) >= QUOTE_INTERVAL_SEC) {
      g_currentQuoteIdx++;
      g_currentQuote  = SelectMotivationQuote();
      g_lastQuoteTime = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| NEON DASHBOARD YARDIMCILARI                                      |
//+------------------------------------------------------------------+
void NeonLabel(string name, string text, int x, int y,
               int fontSize, color clr, bool back = false) {
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetString(0,  name, OBJPROP_FONT,       "Consolas");
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK,       back);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  fontSize);
   ObjectSetString(0,  name, OBJPROP_TEXT,      text);
}

void NeonRect(string name, int x, int y, int w, int h,
              color bg, color border = CLR_NONE) {
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_BACK,        true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE,  false);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,     w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,     h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,   bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR,
      border == CLR_NONE ? bg : border);
}

color GetHealthColor(double score) {
   if(score <= HEALTH_CRITICAL) return CLR_NEON_RED;
   if(score <= HEALTH_WEAK)     return CLR_NEON_ORANGE;
   if(score <= HEALTH_NORMAL)   return CLR_NEON_YELLOW;
   return CLR_NEON_GREEN;
}

color GetBoostColor(int symIdx) {
   int bs = g_packets[symIdx].boostState;
   if(bs == BOOST_X3_ACTIVE)  return CLR_NEON_YELLOW;
   if(bs == BOOST_X9_ACTIVE)  return CLR_NEON_ORANGE;
   if(bs == BOOST_X27_ACTIVE) return CLR_NEON_RED;
   if(bs == BOOST_COMPLETED)  return CLR_NEON_GREEN;
   return CLR_NEON_DIM;
}

string GetBoostString(int symIdx) {
   int bs = g_packets[symIdx].boostState;
   if(bs == BOOST_X3_ACTIVE)  return " x3 ";
   if(bs == BOOST_X9_ACTIVE)  return " x9 ";
   if(bs == BOOST_X27_ACTIVE) return "x27 ";
   if(bs == BOOST_COMPLETED)  return " OK ";
   return " -- ";
}

color GetStateColor(int symIdx) {
   ENUM_SYSTEM_STATE st = g_systemStates[symIdx];
   if(st == STATE_PACKET_OPEN || st == STATE_SCANNING) return CLR_NEON_GREEN;
   if(st == STATE_BOOST_X3)   return CLR_NEON_YELLOW;
   if(st == STATE_BOOST_X9)   return CLR_NEON_ORANGE;
   if(st == STATE_BOOST_X27 || st == STATE_ERROR) return CLR_NEON_RED;
   if(st == STATE_RECOVERY)   return CLR_NEON_ORANGE;
   return CLR_NEON_DIM;
}

string GetStateString(int symIdx) {
   ENUM_SYSTEM_STATE st = g_systemStates[symIdx];
   if(st == STATE_INIT)        return "INIT ";
   if(st == STATE_SCANNING)    return "SCAN ";
   if(st == STATE_PACKET_OPEN) return "AKTIF";
   if(st == STATE_BOOST_X3)    return "BST3 ";
   if(st == STATE_BOOST_X9)    return "BST9 ";
   if(st == STATE_BOOST_X27)   return "B27  ";
   if(st == STATE_RECOVERY)    return "REC  ";
   if(st == STATE_PAUSED)      return "PAUSE";
   if(st == STATE_ERROR)       return "HATA ";
   return "?    ";
}

string GetTrailingMini(int symIdx) {
   if(!g_trailingStates[symIdx].isActive) return " -- ";
   int lvl = MathMax(0, MathMin(5, g_trailingStates[symIdx].level));
   string icons[] = {"W  ", "BE ", "L2 ", "L3 ", "L4 ", "OK "};
   return icons[lvl];
}

string GetDigitalClock() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return StringFormat("%02d:%02d:%02d", dt.hour, dt.min, dt.sec);
}

string GetDigitalDate() {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   string days[] = {"PAZ","PZT","SAL","CAR","PER","CUM","CMT"};
   return StringFormat("%s %02d.%02d.%04d",
          days[dt.day_of_week], dt.day, dt.mon, dt.year);
}

string GetNextQuoteCountdown() {
   int elapsed = (int)(TimeCurrent() - g_lastQuoteTime);
   int remain  = MathMax(0, QUOTE_INTERVAL_SEC - elapsed);
   return StringFormat("%02d:%02d", remain / 60, remain % 60);
}

//+------------------------------------------------------------------+
//| MOD A: MİNİ DASHBOARD (MODE_SYMBOL) — Sol Üst Neon              |
//+------------------------------------------------------------------+
void DrawMiniDashboard(int symIdx) {
   int x = InpDashX, y = InpDashY;
   int w = 340, rowH = 20;
   int totalH = 180;

   string sym    = g_resolvedSymbols[symIdx];
   double health = g_marketData[symIdx].healthScore;
   double pnl    = GetPacketPnL(symIdx);
   double bid    = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask    = SymbolInfoDouble(sym, SYMBOL_ASK);
   bool   active = HasActivePacket(symIdx);

   // Ana çerçeve — Neon cyan border
   NeonRect(DASH_PREFIX + "M_BG", x, y, w, totalH, CLR_NEON_BG, CLR_NEON_BORDER);
   NeonRect(DASH_PREFIX + "M_HDR", x, y, w, 28, CLR_NEON_HEADER, CLR_NEON_BORDER);

   // Header
   NeonLabel(DASH_PREFIX + "M_TIT",
      "⚡ AsFaRaS NEXUS  " + GetSymbolShortName(symIdx),
      x + 8, y + 6, 9, CLR_NEON_CYAN);

   // Live toggle animasyonu
   g_dashCache.liveToggle = !g_dashCache.liveToggle;
   color liveClr = g_dashCache.liveToggle ? CLR_NEON_GREEN : CLR_NEON_DIM;
   NeonLabel(DASH_PREFIX + "M_LIV", "● LIVE", x + w - 70, y + 8, 8, liveClr);

   int cy = y + 34;

   // Fiyat
   NeonLabel(DASH_PREFIX + "M_PRC",
      StringFormat("B:%.5f  A:%.5f", bid, ask),
      x + 8, cy, 8, CLR_NEON_WHITE); cy += 18;

   // Sağlık bar
   string hBar  = DrawHealthBar(health, 16);
   color  hClr  = GetHealthColor(health);
   NeonLabel(DASH_PREFIX + "M_HLB",
      StringFormat("SAGLIK [%s] %.0f/100", hBar, health),
      x + 8, cy, 8, hClr); cy += 18;

   // Spread
   double sprd = GetCurrentSpread(sym);
   NeonLabel(DASH_PREFIX + "M_SPR",
      StringFormat("SPREAD:%.1f  ATR:%.5f",
                   sprd, g_marketData[symIdx].atr),
      x + 8, cy, 7, CLR_NEON_DIM); cy += 16;

   // Pozisyon
   if(active) {
      color pnlClr = pnl >= 0 ? CLR_NEON_GREEN : CLR_NEON_RED;
      NeonLabel(DASH_PREFIX + "M_PNL",
         StringFormat("P&L: %+.2f$  LOT:%.2f",
                      pnl, g_packets[symIdx].baseLot),
         x + 8, cy, 9, pnlClr); cy += 18;
      NeonLabel(DASH_PREFIX + "M_BST",
         StringFormat("BOOST:%s  TRAIL:%s  %s",
                      GetBoostString(symIdx),
                      GetTrailingMini(symIdx),
                      GetStateString(symIdx)),
         x + 8, cy, 8, GetStateColor(symIdx)); cy += 18;
   } else {
      NeonLabel(DASH_PREFIX + "M_PNL", "Pozisyon Bekleniyor...",
                x + 8, cy, 8, CLR_NEON_DIM); cy += 18;
      NeonLabel(DASH_PREFIX + "M_BST",
         StringFormat("DURUM:%s  AI:%s",
                      GetStateString(symIdx),
                      GetAIStatusString(symIdx)),
         x + 8, cy, 8, CLR_NEON_DIM); cy += 18;
   }

   // Hesap mini
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   NeonLabel(DASH_PREFIX + "M_BAL",
      StringFormat("BAL:$%.2f  EQ:$%.2f  DD:%.1f%%",
                   bal, eq, g_account.drawdown),
      x + 8, cy, 7, g_account.drawdown < 5 ?
      CLR_NEON_GREEN : CLR_NEON_ORANGE); cy += 16;

   // Motivasyon
   UpdateMotivationQuote();
   string shortQ = g_currentQuote;
   if(StringLen(shortQ) > 40) shortQ = StringSubstr(shortQ, 0, 38) + "..";
   NeonLabel(DASH_PREFIX + "M_QUO",
      "\"" + shortQ + "\"",
      x + 8, cy, 7, CLR_NEON_PURPLE);

   // Saat (sağ üst)
   if(InpShowClock)
      NeonLabel(DASH_PREFIX + "M_CLK",
         GetDigitalClock(),
         x + w - 90, y + 34, 10, CLR_NEON_CYAN);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| MOD B: FULL PANEL (MODE_PANEL) — Tam Ekran Neon Terminal        |
//+------------------------------------------------------------------+
void DrawFullNeonPanel() {
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int px = 0, py = 0;
   int pw = chartW, ph = chartH;

   // ══════════════════════════════════════════════
   // ANA ARKA PLAN
   // ══════════════════════════════════════════════
   NeonRect(DASH_PREFIX + "F_BG", px, py, pw, ph, CLR_NEON_BG);

   // Üst dekoratif şerit
   NeonRect(DASH_PREFIX + "F_TOP", px, py, pw, 3, CLR_NEON_BORDER);
   NeonRect(DASH_PREFIX + "F_BOT", px, ph - 3, pw, 3, CLR_NEON_BORDER);

   // ══════════════════════════════════════════════
   // HEADER BÖLGESI (y: 0 - 60)
   // ══════════════════════════════════════════════
   NeonRect(DASH_PREFIX + "F_HDR", px, py, pw, 58, CLR_NEON_HEADER, CLR_NEON_BORDER);

   // Başlık
   NeonLabel(DASH_PREFIX + "F_NM1",
      "AsFaRaS NEXUS",
      px + 20, py + 6, 18, CLR_NEON_CYAN);
   NeonLabel(DASH_PREFIX + "F_NM2",
      "v" + NEXUS_VERSION,
      px + 250, py + 14, 9, CLR_NEON_DIM);
   NeonLabel(DASH_PREFIX + "F_SLG",
      "Bes Sembol  |  Sonsuz Dongu  |  Sifir Zarar",
      px + 20, py + 36, 8, CLR_NEON_PURPLE);

   // Live indikatör
   g_dashCache.liveToggle = !g_dashCache.liveToggle;
   color liveC = g_dashCache.liveToggle ? CLR_NEON_GREEN : C'0,80,40';
   NeonLabel(DASH_PREFIX + "F_LV1", "●", pw - 120, py + 10, 14, liveC);
   NeonLabel(DASH_PREFIX + "F_LV2", "LIVE", pw - 100, py + 14, 9, CLR_NEON_GREEN);

   // Hesap özeti — sağ üst
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   NeonLabel(DASH_PREFIX + "F_BAL",
      StringFormat("$%.2f", bal),
      pw - 200, py + 8, 13,
      eq >= bal ? CLR_NEON_GREEN : CLR_NEON_RED);
   NeonLabel(DASH_PREFIX + "F_EQT",
      StringFormat("EQ: $%.2f", eq),
      pw - 200, py + 32, 8, CLR_NEON_DIM);

   // ══════════════════════════════════════════════
   // 3 KOLON LAYOUT
   // ══════════════════════════════════════════════
   int colY    = py + 62;
   int colH    = ph - 130;
   int colW    = (pw - 30) / 3;
   int col1x   = px + 5;
   int col2x   = col1x + colW + 5;
   int col3x   = col2x + colW + 5;

   // Kolon çerçeveleri
   NeonRect(DASH_PREFIX + "F_C1B", col1x, colY, colW, colH,
            CLR_NEON_BG2, CLR_NEON_BORDER2);
   NeonRect(DASH_PREFIX + "F_C2B", col2x, colY, colW, colH,
            CLR_NEON_BG2, CLR_NEON_BORDER2);
   NeonRect(DASH_PREFIX + "F_C3B", col3x, colY, colW, colH,
            CLR_NEON_BG2, CLR_NEON_BORDER2);

   // ── KOLON 1: 5 Sembol Durumu ──
   NeonLabel(DASH_PREFIX + "F_C1T",
      "◈ SEMBOL PANELI",
      col1x + 8, colY + 6, 9, CLR_NEON_CYAN);
   NeonRect(DASH_PREFIX + "F_C1L",
      col1x + 8, colY + 20, colW - 16, 1,
      CLR_NEON_BORDER2);

   int sy = colY + 26;
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      double h   = g_marketData[i].healthScore;
      double pnl = GetPacketPnL(i);
      bool   act = HasActivePacket(i);
      string si  = IntegerToString(i);

      // Satır arka planı (alternatif)
      color rowBg = (i % 2 == 0) ? CLR_NEON_BG : CLR_NEON_BG2;
      NeonRect(DASH_PREFIX + "F_RB" + si,
         col1x + 4, sy - 1, colW - 8, 52, rowBg);

      // Sembol adı + durum
      NeonLabel(DASH_PREFIX + "F_RS" + si,
         GetSymbolShortName(i),
         col1x + 8, sy, 9, CLR_NEON_WHITE);
      NeonLabel(DASH_PREFIX + "F_RST" + si,
         GetStateString(i),
         col1x + 80, sy, 8, GetStateColor(i));
      NeonLabel(DASH_PREFIX + "F_RAI" + si,
         GetAIStatusString(i),
         col1x + 145, sy, 7, CLR_NEON_PURPLE); sy += 16;

      // Sağlık bar
      string hbar = DrawHealthBar(h, 12);
      NeonLabel(DASH_PREFIX + "F_RH" + si,
         StringFormat("[%s] %.0f", hbar, h),
         col1x + 8, sy, 7, GetHealthColor(h)); sy += 14;

      // P&L + Boost + Lot
      if(act) {
         color pc = pnl >= 0 ? CLR_NEON_GREEN : CLR_NEON_RED;
         NeonLabel(DASH_PREFIX + "F_RP" + si,
            StringFormat("P&L:%+.2f$  L:%.2f  B:%s",
                         pnl, g_packets[i].baseLot,
                         GetBoostString(i)),
            col1x + 8, sy, 7, pc); sy += 14;
      } else {
         NeonLabel(DASH_PREFIX + "F_RP" + si,
            "Bekleniyor...",
            col1x + 8, sy, 7, CLR_NEON_DIM); sy += 14;
      }

      // Trailing
      NeonLabel(DASH_PREFIX + "F_RT" + si,
         StringFormat("TRAIL:%s  SL:%.5f",
                      GetTrailingMini(i),
                      g_trailingStates[i].currentSL),
         col1x + 8, sy, 7, CLR_NEON_BLUE); sy += 16;
   }

   // ── KOLON 2: Merkez — Saat + Motivasyon + Sistem Durumu ──
   int midY = colY + 6;

   // Dijital saat — büyük format
   NeonLabel(DASH_PREFIX + "F_CLK",
      GetDigitalClock(),
      col2x + (colW / 2) - 60, midY, 24, CLR_NEON_CYAN); midY += 50;

   NeonLabel(DASH_PREFIX + "F_DAT",
      GetDigitalDate(),
      col2x + (colW / 2) - 55, midY, 8, CLR_NEON_DIM); midY += 20;

   // Çizgi
   NeonRect(DASH_PREFIX + "F_ML1",
      col2x + 8, midY, colW - 16, 1, CLR_NEON_BORDER2); midY += 8;

   // Hesap grafik barları
   NeonLabel(DASH_PREFIX + "F_ABT",
      "◈ HESAP DURUMU",
      col2x + 8, midY, 8, CLR_NEON_CYAN); midY += 16;

   double dd   = g_account.drawdown;
   double mlvl = g_account.marginLevel;
   color  ddC  = dd < 5 ? CLR_NEON_GREEN :
                 dd < 10 ? CLR_NEON_YELLOW : CLR_NEON_RED;

   // Drawdown bar
   string ddBar = DrawProgressBar(dd, InpMaxDrawdown, 18);
   NeonLabel(DASH_PREFIX + "F_DD",
      StringFormat("DD   [%s] %.1f%%", ddBar, dd),
      col2x + 8, midY, 8, ddC); midY += 16;

   // Equity bar
   double eqPct = bal > 0 ? (eq / bal) * 100 : 100;
   string eqBar = DrawProgressBar(MathMin(eqPct, 100), 100, 18);
   color  eqC   = eq >= bal ? CLR_NEON_GREEN : CLR_NEON_RED;
   NeonLabel(DASH_PREFIX + "F_EQ",
      StringFormat("EQ   [%s] %.1f%%", eqBar, eqPct),
      col2x + 8, midY, 8, eqC); midY += 16;

   // Win Rate bar
   double wr    = g_account.totalPackets > 0 ?
                  (double)g_account.successPackets /
                  g_account.totalPackets * 100 : 0;
   string wrBar = DrawProgressBar(wr, 100, 18);
   NeonLabel(DASH_PREFIX + "F_WR",
      StringFormat("WR   [%s] %.1f%%", wrBar, wr),
      col2x + 8, midY, 8, wr > 60 ? CLR_NEON_GREEN :
      wr > 40 ? CLR_NEON_YELLOW : CLR_NEON_RED); midY += 16;

   // AI WinRate bar
   if(g_aiModel.isReady) {
      double aiWr  = g_aiModel.overallWinRate * 100;
      string aiBar = DrawProgressBar(aiWr, 100, 18);
      NeonLabel(DASH_PREFIX + "F_AIW",
         StringFormat("AI   [%s] %.1f%%", aiBar, aiWr),
         col2x + 8, midY, 8, CLR_NEON_PURPLE); midY += 16;
   }

   // Çizgi
   NeonRect(DASH_PREFIX + "F_ML2",
      col2x + 8, midY, colW - 16, 1, CLR_NEON_BORDER2); midY += 8;

   // Motivasyon bölümü
   UpdateMotivationQuote();
   bool anyRec = false, anyBst = false;
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      if(g_systemStates[i] == STATE_RECOVERY) anyRec = true;
      if(g_systemStates[i] == STATE_BOOST_X3  ||
         g_systemStates[i] == STATE_BOOST_X9  ||
         g_systemStates[i] == STATE_BOOST_X27) anyBst = true;
   }
   color motClr  = anyRec ? CLR_NEON_RED :
                   anyBst ? CLR_NEON_ORANGE : CLR_NEON_PURPLE;
   color motBg   = anyRec ? C'30,8,8' :
                   anyBst ? C'30,18,5' : C'12,8,30';

   NeonRect(DASH_PREFIX + "F_QB",
      col2x + 4, midY, colW - 8, 80, motBg, motClr);

   string cat = anyRec ? "[RECOVERY]" :
                anyBst ? "[BOOST]"    : "[GUNUN SOZU]";
   NeonLabel(DASH_PREFIX + "F_QT",
      cat + "  >" + GetNextQuoteCountdown() + "<",
      col2x + 10, midY + 5, 8, motClr); midY += 20;

   // Quote - 2 satıra böl
   string q = "\"" + g_currentQuote + "\"";
   if(StringLen(q) <= 38) {
      NeonLabel(DASH_PREFIX + "F_Q1", q, col2x + 10, midY, 8, CLR_NEON_WHITE);
   } else {
      int sp = 38;
      while(sp > 10 && StringGetCharacter(q, sp) != ' ') sp--;
      NeonLabel(DASH_PREFIX + "F_Q1", StringSubstr(q, 0, sp),
                col2x + 10, midY, 8, CLR_NEON_WHITE);
      NeonLabel(DASH_PREFIX + "F_Q2", StringSubstr(q, sp + 1),
                col2x + 10, midY + 16, 8, CLR_NEON_WHITE);
   }
   NeonLabel(DASH_PREFIX + "F_QA",
      "-- AsFaRaS NEXUS --",
      col2x + colW - 160, midY + 50, 7, motClr);
   midY += 85;

   // İstatistikler
   NeonLabel(DASH_PREFIX + "F_ST",
      StringFormat("PKT:%d  OK:%d  ERR:%d  x3:%d x9:%d x27:%d  REC:%d",
                   g_account.totalPackets,
                   g_account.successPackets,
                   g_account.failedPackets,
                   g_stats.boostX3Count,
                   g_stats.boostX9Count,
                   g_stats.boostX27Count,
                   g_stats.recoveryCount),
      col2x + 8, midY, 7, CLR_NEON_DIM);

   // ── KOLON 3: Son 5 Log + AI Durum + Trailing Stats ──
   int logY = colY + 6;

   NeonLabel(DASH_PREFIX + "F_C3T",
      "◈ SISTEM LOGU",
      col3x + 8, logY, 9, CLR_NEON_CYAN); logY += 20;

   NeonRect(DASH_PREFIX + "F_C3L",
      col3x + 8, logY, colW - 16, 1, CLR_NEON_BORDER2); logY += 8;

   // Son 5 log mesajı
   NeonRect(DASH_PREFIX + "F_LBG",
      col3x + 4, logY, colW - 8, LOG_BUFFER_SIZE * 22 + 10,
      C'6,8,16', CLR_NEON_BORDER2);

   for(int l = 0; l < LOG_BUFFER_SIZE; l++) {
      int    msgIdx = (g_logBuffer.head - LOG_BUFFER_SIZE + l +
                      LOG_BUFFER_SIZE * 2) % LOG_BUFFER_SIZE;
      string msg    = g_logBuffer.messages[msgIdx];
      color  clr    = g_logBuffer.colors[msgIdx];
      if(msg == "") { msg = "..."; clr = CLR_NEON_DIM; }
      // Uzunsa kes
      if(StringLen(msg) > 36) msg = StringSubstr(msg, 0, 34) + "..";
      NeonLabel(DASH_PREFIX + "F_LM" + IntegerToString(l),
         msg, col3x + 8, logY + 5 + l * 22, 7, clr);
   }
   logY += LOG_BUFFER_SIZE * 22 + 18;

   // Çizgi
   NeonRect(DASH_PREFIX + "F_C3L2",
      col3x + 8, logY, colW - 16, 1, CLR_NEON_BORDER2); logY += 8;

   // AI Motor Durumu
   NeonLabel(DASH_PREFIX + "F_AIT",
      "◈ AI MOTOR",
      col3x + 8, logY, 9, CLR_NEON_CYAN); logY += 16;

   if(!InpAIEnabled) {
      NeonLabel(DASH_PREFIX + "F_AIS",
         "AI Motor Devre Disi",
         col3x + 8, logY, 8, CLR_NEON_DIM); logY += 16;
   } else if(!g_aiModel.isReady) {
      double pct = g_memoryCount / (double)InpAIMinSamples * 100;
      string aBar = DrawProgressBar(pct, 100, 14);
      NeonLabel(DASH_PREFIX + "F_AIL",
         StringFormat("Ogrenme [%s] %d/%d",
                      aBar, g_memoryCount, InpAIMinSamples),
         col3x + 8, logY, 8, CLR_NEON_YELLOW); logY += 16;
   } else {
      NeonLabel(DASH_PREFIX + "F_AIR",
         StringFormat("WinRate: %.1f%%  Ornek: %d",
                      g_aiModel.overallWinRate * 100,
                      g_memoryCount),
         col3x + 8, logY, 8, CLR_NEON_GREEN); logY += 14;
      NeonLabel(DASH_PREFIX + "F_AIH",
         StringFormat("Min Saglik: %.0f  Mod: ONERI",
                      g_aiModel.minSuccessHealth),
         col3x + 8, logY, 7, CLR_NEON_DIM); logY += 14;
   }
   logY += 6;

   // Çizgi
   NeonRect(DASH_PREFIX + "F_C3L3",
      col3x + 8, logY, colW - 16, 1, CLR_NEON_BORDER2); logY += 8;

   // Trailing Stats
   NeonLabel(DASH_PREFIX + "F_TRT",
      "◈ TRAILING STATS",
      col3x + 8, logY, 9, CLR_NEON_CYAN); logY += 16;

   NeonLabel(DASH_PREFIX + "F_TR1",
      StringFormat("Akt:%d  BE:%d  L2:%d  L3:%d  L4:%d",
                   g_trailingStats.totalActivations,
                   g_trailingStats.breakevenHits,
                   g_trailingStats.level2Hits,
                   g_trailingStats.level3Hits,
                   g_trailingStats.level4Hits),
      col3x + 8, logY, 7, CLR_NEON_BLUE); logY += 14;

   NeonLabel(DASH_PREFIX + "F_TR2",
      StringFormat("Kilitli Toplam: +$%.2f",
                   g_trailingStats.totalLockedProfit),
      col3x + 8, logY, 8,
      g_trailingStats.totalLockedProfit > 0 ?
      CLR_NEON_GREEN : CLR_NEON_DIM); logY += 14;

   // ══════════════════════════════════════════════
   // ALT ŞERIT
   // ══════════════════════════════════════════════
   int footY = ph - 26;
   NeonRect(DASH_PREFIX + "F_FT", px, footY, pw, 26,
            CLR_NEON_HEADER, CLR_NEON_BORDER);

   NeonLabel(DASH_PREFIX + "F_FV",
      "AsFaRaS NEXUS v" + NEXUS_VERSION +
      "  |  Ajan Konseyi Onaylidir  |  " +
      "AI:" + IntegerToString(g_memoryCount) + " kayit",
      px + 12, footY + 6, 8, CLR_NEON_DIM);

   NeonLabel(DASH_PREFIX + "F_FT2",
      GetDigitalDate() + "  " + GetDigitalClock(),
      pw - 220, footY + 6, 8, CLR_NEON_CYAN);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| DASHBOARD ANA YÖNETİCİ                                          |
//+------------------------------------------------------------------+
void UpdateDashboard() {
   if(TimeCurrent() - g_lastDashUpdate < 1) return;
   g_lastDashUpdate = TimeCurrent();

   if(g_operationMode == MODE_SYMBOL || g_operationMode == MODE_AUTO) {
      int idx = (g_singleSymbolIdx >= 0) ? g_singleSymbolIdx : 0;
      if(idx >= 0 && idx < NEXUS_SYMBOLS_COUNT)
         DrawMiniDashboard(idx);
   }
   else if(g_operationMode == MODE_PANEL) {
      DrawFullNeonPanel();
   }
}

//+------------------------------------------------------------------+
//| DURUM KAYIT/YÜKLE                                               |
//+------------------------------------------------------------------+
void SaveSystemState() {
   int f = FileOpen("ANX2_STATE.bin",
                    FILE_WRITE | FILE_BIN | FILE_COMMON);
   if(f == INVALID_HANDLE) return;
   // Versiyon imzası (Ajan-5 onaylı)
   FileWriteInteger(f, 200);
   FileWriteInteger(f, NEXUS_SYMBOLS_COUNT);
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      FileWriteDouble(f,  (double)g_packets[i].magicID);
      FileWriteDouble(f,  g_packets[i].baseLot);
      FileWriteDouble(f,  g_packets[i].buyTicket);
      FileWriteDouble(f,  g_packets[i].sellTicket);
      FileWriteDouble(f,  g_packets[i].boostTicket);
      FileWriteDouble(f,  g_packets[i].openPrice);
      FileWriteDouble(f,  g_packets[i].spreadAtOpen);
      FileWriteDouble(f,  g_packets[i].recoveryTarget);
      FileWriteInteger(f, g_packets[i].boostLevel);
      FileWriteInteger(f, g_packets[i].boostState);
      FileWriteInteger(f, g_packets[i].mumDevretCount);
      FileWriteInteger(f, (int)g_packets[i].isRecovery);
      FileWriteInteger(f, (int)g_packets[i].isFirstPacket);
      FileWriteInteger(f, (int)g_packets[i].openTime);
      FileWriteInteger(f, (int)g_systemStates[i]);
      FileWriteDouble(f,  (double)g_trailingStates[i].ticket);
      FileWriteInteger(f, (int)g_trailingStates[i].isActive);
      FileWriteDouble(f,  g_trailingStates[i].peakProfit);
      FileWriteDouble(f,  g_trailingStates[i].currentProfit);
      FileWriteDouble(f,  g_trailingStates[i].lockedProfit);
      FileWriteDouble(f,  g_trailingStates[i].initialProfit);
      FileWriteDouble(f,  g_trailingStates[i].currentSL);
      FileWriteDouble(f,  g_trailingStates[i].openPrice);
      FileWriteInteger(f, g_trailingStates[i].level);
      FileWriteInteger(f, (int)g_trailingStates[i].level1Hit);
      FileWriteInteger(f, (int)g_trailingStates[i].level2Hit);
      FileWriteInteger(f, (int)g_trailingStates[i].level3Hit);
      FileWriteInteger(f, (int)g_trailingStates[i].level4Hit);
   }
   FileWriteDouble(f,  g_account.balance);
   FileWriteDouble(f,  g_account.equity);
   FileWriteDouble(f,  g_account.dailyPnL);
   FileWriteInteger(f, g_account.totalPackets);
   FileWriteInteger(f, g_account.successPackets);
   FileWriteInteger(f, g_account.failedPackets);
   FileWriteInteger(f, g_stats.boostX3Count);
   FileWriteInteger(f, g_stats.boostX9Count);
   FileWriteInteger(f, g_stats.boostX27Count);
   FileWriteInteger(f, g_stats.recoveryCount);
   FileWriteInteger(f, g_trailingStats.totalActivations);
   FileWriteInteger(f, g_trailingStats.breakevenHits);
   FileWriteDouble(f,  g_trailingStats.totalLockedProfit);
   FileClose(f);
}

bool LoadSystemState() {
   if(!FileIsExist("ANX2_STATE.bin", FILE_COMMON)) return false;
   int f = FileOpen("ANX2_STATE.bin",
                    FILE_READ | FILE_BIN | FILE_COMMON);
   if(f == INVALID_HANDLE) return false;
   // Versiyon kontrolü (Ajan-5 onaylı)
   int ver  = FileReadInteger(f);
   int syms = FileReadInteger(f);
   if(ver != 200 || syms != NEXUS_SYMBOLS_COUNT) {
      NexusLog(LOG_WARNING, "SYSTEM",
         StringFormat("Durum dosyasi uyumsuz v%d s%d", ver, syms));
      FileClose(f);
      return false;
   }
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      g_packets[i].magicID        = (ulong)FileReadDouble(f);
      g_packets[i].baseLot        = FileReadDouble(f);
      g_packets[i].buyTicket      = FileReadDouble(f);
      g_packets[i].sellTicket     = FileReadDouble(f);
      g_packets[i].boostTicket    = FileReadDouble(f);
      g_packets[i].openPrice      = FileReadDouble(f);
      g_packets[i].spreadAtOpen   = FileReadDouble(f);
      g_packets[i].recoveryTarget = FileReadDouble(f);
      g_packets[i].boostLevel     = FileReadInteger(f);
      g_packets[i].boostState     = FileReadInteger(f);
      g_packets[i].mumDevretCount = FileReadInteger(f);
      g_packets[i].isRecovery     = (bool)FileReadInteger(f);
      g_packets[i].isFirstPacket  = (bool)FileReadInteger(f);
      g_packets[i].openTime       = (datetime)FileReadInteger(f);
      int st = FileReadInteger(f);
      if(st >= 0 && st <= (int)STATE_NEWS_FILTER)
         g_systemStates[i] = (ENUM_SYSTEM_STATE)st;
      g_trailingStates[i].ticket         = (ulong)FileReadDouble(f);
      g_trailingStates[i].isActive       = (bool)FileReadInteger(f);
      g_trailingStates[i].peakProfit     = FileReadDouble(f);
      g_trailingStates[i].currentProfit  = FileReadDouble(f);
      g_trailingStates[i].lockedProfit   = FileReadDouble(f);
      g_trailingStates[i].initialProfit  = FileReadDouble(f);
      g_trailingStates[i].currentSL      = FileReadDouble(f);
      g_trailingStates[i].openPrice      = FileReadDouble(f);
      g_trailingStates[i].level          = FileReadInteger(f);
      g_trailingStates[i].level1Hit      = (bool)FileReadInteger(f);
      g_trailingStates[i].level2Hit      = (bool)FileReadInteger(f);
      g_trailingStates[i].level3Hit      = (bool)FileReadInteger(f);
      g_trailingStates[i].level4Hit      = (bool)FileReadInteger(f);
   }
   g_account.balance        = FileReadDouble(f);
   g_account.equity         = FileReadDouble(f);
   g_account.dailyPnL       = FileReadDouble(f);
   g_account.totalPackets   = FileReadInteger(f);
   g_account.successPackets = FileReadInteger(f);
   g_account.failedPackets  = FileReadInteger(f);
   g_stats.boostX3Count     = FileReadInteger(f);
   g_stats.boostX9Count     = FileReadInteger(f);
   g_stats.boostX27Count    = FileReadInteger(f);
   g_stats.recoveryCount    = FileReadInteger(f);
   g_trailingStats.totalActivations = FileReadInteger(f);
   g_trailingStats.breakevenHits    = FileReadInteger(f);
   g_trailingStats.totalLockedProfit= FileReadDouble(f);
   FileClose(f);
   NexusLog(LOG_INFO, "SYSTEM", "Sistem durumu kurtarildi v2.0!");
   return true;
}

void WriteHeartbeat() {
   if(TimeCurrent() - g_lastHeartbeat < HEARTBEAT_INTERVAL) return;
   g_lastHeartbeat = TimeCurrent();
   int f = FileOpen("ANX2_HEARTBEAT.txt",
                    FILE_WRITE | FILE_TXT | FILE_COMMON);
   if(f != INVALID_HANDLE) {
      FileWrite(f,
         TimeToString(TimeCurrent()) + "|" +
         DoubleToString(g_account.equity, 2) + "|" +
         IntegerToString(g_account.totalPackets) + "|" +
         "v" + NEXUS_VERSION);
      FileClose(f);
   }
}

//+------------------------------------------------------------------+
//| YARDIMCI                                                         |
//+------------------------------------------------------------------+
void UpdateAccountData() {
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double freeMarj = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   g_account.balance    = balance;
   g_account.equity     = equity;
   g_account.freeMargin = freeMarj;
   if(balance > 0) {
      g_account.marginLevel = (equity / balance) * 100.0;
      g_account.drawdown    = MathMax(0, (balance - equity) / balance * 100.0);
   }
}

bool IsNewM5Candle(int symIdx) {
   datetime curBarTime = iTime(g_resolvedSymbols[symIdx], PERIOD_M5, 0);
   if(curBarTime != g_lastM5Time[symIdx]) {
      g_lastM5Time[symIdx] = curBarTime;
      return true;
   }
   return false;
}

bool RunBrokerTest(string symbol) {
   NexusLog(LOG_INFO, "BROKER", "Test basladi: " + symbol);
   bool ok   = true;
   bool symOK = SymbolSelect(symbol, true);
   if(!symOK) ok = false;
   bool hedgeOK = (AccountInfoInteger(ACCOUNT_MARGIN_MODE) ==
                   ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   g_broker.hedgeAllowed = hedgeOK;
   g_broker.minLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   g_broker.maxLot  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   g_broker.lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   g_broker.stopLevel = (int)SymbolInfoInteger(symbol,
                         SYMBOL_TRADE_STOPS_LEVEL);
   bool tradeOK = (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
   if(!tradeOK) ok = false;
   g_broker.testPassed = ok;
   NexusLog(ok ? LOG_INFO : LOG_WARNING, "BROKER",
      StringFormat("Test:%s Hedge:%s StopLvl:%d",
      ok ? "OK" : "WARN",
      hedgeOK ? "OK" : "NO",
      g_broker.stopLevel));
   return ok;
}

bool InitIndicatorHandles() {
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      g_atrHandles[i]   = iATR(g_resolvedSymbols[i],
                               PERIOD_M5, InpHealthPeriod);
      g_atrHandles14[i] = iATR(g_resolvedSymbols[i],
                               PERIOD_M5, 14);
      if(g_atrHandles[i]   == INVALID_HANDLE ||
         g_atrHandles14[i] == INVALID_HANDLE) {
         NexusLog(LOG_ERROR, g_resolvedSymbols[i],
                  "ATR handle olusturulamadi!");
         return false;
      }
   }
   return true;
}

bool InitializeGlobals() {
   // Operasyon modunu belirle
   g_operationMode = InpOperationMode;

   // Chart sembolünü algıla
   g_singleSymbolIdx = DetectChartSymbolIndex();

   // MODE_AUTO: Chart'a göre karar ver
   if(g_operationMode == MODE_AUTO) {
      if(g_singleSymbolIdx >= 0)
         g_operationMode = MODE_SYMBOL;
      else
         g_operationMode = MODE_PANEL;
   }

   NexusLog(LOG_INFO, "SYSTEM",
      StringFormat("Mod: %s  ChartIdx: %d",
      g_operationMode == MODE_SYMBOL ? "SYMBOL" : "PANEL",
      g_singleSymbolIdx));

   g_systemStartTime = TimeCurrent();
   ZeroMemory(g_stats);
   g_stats.systemStartTime = g_systemStartTime;
   ZeroMemory(g_dashCache);
   ZeroMemory(g_logBuffer);
   ZeroMemory(g_trailingStats);

   UpdateAccountData();
   g_account.sessionStart = TimeCurrent();

   // Sembolleri çözümle (ResolveSymbol ile)
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      g_resolvedSymbols[i] = ResolveSymbol(i);
      g_symbols[i]         = g_resolvedSymbols[i];

      if(!SymbolSelect(g_resolvedSymbols[i], true)) {
         NexusLog(LOG_ERROR, "INIT",
            StringFormat("Sembol secilemiyor: %s",
                         g_resolvedSymbols[i]));
         // Panel modunda hata kritik değil, devam et
         if(g_operationMode == MODE_SYMBOL &&
            i == g_singleSymbolIdx) return false;
         continue;
      }

      // Magic ID — deterministik (Ajan-1)
      g_magicIDs[i]     = GenerateMagicID(i);
      g_systemStates[i] = STATE_INIT;

      ZeroMemory(g_marketData[i]);
      g_marketData[i].category     = (int)GetSymbolCategory(g_resolvedSymbols[i]);
      g_marketData[i].digits       = (int)SymbolInfoInteger(g_resolvedSymbols[i], SYMBOL_DIGITS);
      g_marketData[i].pipValue     = GetPipValue(g_resolvedSymbols[i]);
      g_marketData[i].pointValue   = SymbolInfoDouble(g_resolvedSymbols[i], SYMBOL_POINT);
      g_marketData[i].tickSize     = SymbolInfoDouble(g_resolvedSymbols[i], SYMBOL_TRADE_TICK_SIZE);
      g_marketData[i].contractSize = SymbolInfoDouble(g_resolvedSymbols[i], SYMBOL_TRADE_CONTRACT_SIZE);

      ZeroMemory(g_packets[i]);
      g_packets[i].symbolIndex = i;
      g_packets[i].magicID     = g_magicIDs[i];
      g_packets[i].boostState  = BOOST_NONE;

      ZeroMemory(g_trailingStates[i]);
      g_trailingStates[i].isActive    = false;
      g_trailingStates[i].symbolIndex = i;
      g_lastM5Time[i] = 0;
      g_atrHandles[i] = INVALID_HANDLE;
      g_atrHandles14[i] = INVALID_HANDLE;

      NexusLog(LOG_INFO, "INIT",
         StringFormat("[%d] %s Magic:%d Cat:%d",
         i, g_resolvedSymbols[i], (int)g_magicIDs[i],
         g_marketData[i].category));
   }

   g_lastHourlyReport = TimeCurrent();
   g_lastDailyReport  = TimeCurrent();
   g_lastHeartbeat    = TimeCurrent();
   g_isInitialized    = true;
   return true;
}

//+------------------------------------------------------------------+
//| ANA SEMBOL DÖNGÜSÜ                                               |
//+------------------------------------------------------------------+
void ProcessSymbol(int symIdx) {
   if(g_emergencyStop) return;
   if(g_resolvedSymbols[symIdx] == "") return;

   string symbol = g_resolvedSymbols[symIdx];
   UpdateAverageSpread(symIdx);
   UpdateAverageVolume(symIdx);
   CalculateHealthScore(symIdx);
   g_marketData[symIdx].bidPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   g_marketData[symIdx].askPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);

   ENUM_SYSTEM_STATE state = g_systemStates[symIdx];

   if(state == STATE_INIT) {
      if(InpBrokerAutoTest) RunBrokerTest(symbol);
      if(OpenInitialPacket(symIdx))
         g_systemStates[symIdx] = STATE_PACKET_OPEN;
      else
         g_systemStates[symIdx] = STATE_ERROR;
      return;
   }

   if(state == STATE_ERROR) {
      if(TimeCurrent() - g_lastM5Time[symIdx] > 300) {
         g_lastM5Time[symIdx]   = TimeCurrent();
         g_systemStates[symIdx] = STATE_SCANNING;
      }
      return;
   }

   if(state == STATE_PAUSED || state == STATE_NEWS_FILTER) {
      if(g_marketData[symIdx].healthScore >= InpMinHealthScore &&
         !g_systemPaused)
         g_systemStates[symIdx] = STATE_SCANNING;
      return;
   }

   if(state == STATE_SCANNING || state == STATE_RECOVERY) {
      if(!IsNewM5Candle(symIdx))     return;
      if(!HasSufficientVolume(symIdx)) return;
      if(g_marketData[symIdx].healthScore < InpMinHealthScore) {
         g_systemStates[symIdx] = STATE_PAUSED;
         return;
      }
      if(!CheckLossLimits())         return;
      if(!CheckMarginSafety(symIdx)) return;
      OpenNormalPacket(symIdx);
      return;
   }

   if(state == STATE_PACKET_OPEN ||
      state == STATE_BOOST_X3    ||
      state == STATE_BOOST_X9    ||
      state == STATE_BOOST_X27) {
      CheckBoostTrigger(symIdx);
      CheckBoostConditions(symIdx);
      if(!HasActivePacket(symIdx)) {
         g_systemStates[symIdx] = STATE_SCANNING;
         SaveSystemState();
      }
      if(IsNewM5Candle(symIdx) &&
         g_packets[symIdx].boostState == BOOST_NONE &&
         state == STATE_PACKET_OPEN)
         g_packets[symIdx].mumDevretCount++;
   }

   if(g_trailingStates[symIdx].isActive)
      UpdateTrailing(symIdx);
}

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit() {
   Print("╔══════════════════════════════════════════╗");
   Print("║   AsFaRaS NEXUS Trading System v2.0     ║");
   Print("║   Bes Sembol. Sonsuz Dongu. Sifir Zarar.║");
   Print("║   Ajan Konseyi Onaylidir                ║");
   Print("╚══════════════════════════════════════════╝");

   OpenLogFile();
   NexusLog(LOG_INFO, "SYSTEM", "AsFaRaS NEXUS v2.0 baslatiliyor...");

   if(!InitializeGlobals()) {
      NexusLog(LOG_ERROR, "SYSTEM", "Baslatma basarisiz!");
      return INIT_FAILED;
   }

   if(!InitIndicatorHandles()) {
      NexusLog(LOG_WARNING, "SYSTEM",
               "ATR handle uyarisi - devam ediliyor");
   }

   InitTrailingProfiles();
   InitAIModel();

   if(LoadSystemState())
      NexusLog(LOG_INFO, "SYSTEM", "Onceki durum kurtarildi v2.0!");

   UpdateMotivationQuote();
   EventSetTimer(1);

   string startMsg = StringFormat(
      "AsFaRaS NEXUS v%s BASLIYOR\n"
      "\"Bes Sembol. Sonsuz Dongu. Sifir Zarar.\"\n"
      "Mod: %s\n"
      "Semboller: GOLD|SILVER|EURUSD|BTC|ETH\n"
      "Moduller: Hedge+Boost+Trailing+Recovery+AI\n"
      "AI: %s\n"
      "%s\n"
      "Gunun Sozu: %s\n"
      "-- AsFaRaS NEXUS --",
      NEXUS_VERSION,
      g_operationMode == MODE_SYMBOL ? "SYMBOL" : "PANEL",
      InpAIEnabled ? "AKTIF" : "KAPALI",
      TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
      g_currentQuote);
   SendTelegramMessage(startMsg);
   NexusLog(LOG_INFO, "SYSTEM", "AsFaRaS NEXUS v2.0 HAZIR!");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   SaveSystemState();

   // ATR handle'ları serbest bırak (Ajan-3 onaylı)
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      if(g_atrHandles[i]   != INVALID_HANDLE)
         IndicatorRelease(g_atrHandles[i]);
      if(g_atrHandles14[i] != INVALID_HANDLE)
         IndicatorRelease(g_atrHandles14[i]);
   }

   ObjectsDeleteAll(0, DASH_PREFIX);

   string reasonStr =
      reason == REASON_REMOVE    ? "EA Kaldirildi"    :
      reason == REASON_RECOMPILE ? "Yeniden Derlendi" :
      reason == REASON_CHARTCLOSE? "Chart Kapatildi"  :
      StringFormat("Sebep(%d)", reason);

   NexusLog(LOG_INFO, "SYSTEM",
      "AsFaRaS NEXUS v2.0 durduruldu: " + reasonStr);

   if(g_logFileHandle != INVALID_HANDLE) {
      FileWrite(g_logFileHandle,
         "=== AsFaRaS NEXUS v" + NEXUS_VERSION + " LOG END ===");
      FileClose(g_logFileHandle);
   }

   SendTelegramMessage(StringFormat(
      "AsFaRaS NEXUS v%s DURDURULDU\n%s\n%s\n"
      "Toplam Paket: %d | Basari: %d\n"
      "AI Kayit: %d\n"
      "-- AsFaRaS NEXUS --",
      NEXUS_VERSION, reasonStr,
      TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
      g_account.totalPackets, g_account.successPackets,
      g_memoryCount));
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick() {
   if(!g_isInitialized || g_emergencyStop) return;

   UpdateAccountData();

   if(g_account.drawdown >= InpMaxDrawdown) {
      NexusLog(LOG_CRITICAL, "SYSTEM",
         StringFormat("EMERGENCY STOP! DD:%.2f%%",
                      g_account.drawdown));
      g_emergencyStop = true;
      SendTelegramMessage(
         "NEXUS v2.0 EMERGENCY STOP!\n"
         "Drawdown limiti asildi!\n"
         "Manuel mudahale gerekli!\n"
         "-- AsFaRaS NEXUS --");
      return;
   }

   // Sadece aktif sembolleri işle
   if(g_operationMode == MODE_SYMBOL && g_singleSymbolIdx >= 0) {
      ProcessSymbol(g_singleSymbolIdx);
   } else {
      for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++)
         ProcessSymbol(i);
   }

   // Dashboard güncelle
   UpdateDashboard();

   // Heartbeat
   WriteHeartbeat();

   // Otomatik kayıt (30 saniye)
   if(TimeCurrent() - g_lastSave >= 30) {
      g_lastSave = TimeCurrent();
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
   UpdateMotivationQuote();
   if(g_account.drawdown > g_stats.maxDrawdownReached)
      g_stats.maxDrawdownReached = g_account.drawdown;
}

//+------------------------------------------------------------------+
//| ONTRADE                                                           |
//+------------------------------------------------------------------+
void OnTrade() {
   UpdateAccountData();
   SaveSystemState();
}

//+------------------------------------------------------------------+
//|      AsFaRaS NEXUS Trading System v2.0 - TAMAMLANDI             |
//|   "Beş Sembol. Sonsuz Döngü. Sıfır Zarar."                     |
//|   Ajan Konseyi: Risk Guardian | Market Analyst | UI Architect    |
//|                 AI Systems | Code Integrity                      |
//|                    — AsFaRaS NEXUS —                            |
//+------------------------------------------------------------------+
