//+------------------------------------------------------------------+
//|                AsFaRaS NEXUS Trading System v1.5                 |
//|         "Beş Sembol. Sonsuz Döngü. Sıfır Zarar."                |
//|                    — AsFaRaS NEXUS —                             |
//+------------------------------------------------------------------+
#property copyright   "AsFaRaS NEXUS v1.5"
#property link        "https://github.com/erdist27/AsFaRaS-NEXUS"
#property version     "1.50"
#property strict

//+------------------------------------------------------------------+
//| SABİTLER                                                         |
//+------------------------------------------------------------------+
#define NEXUS_VERSION          "1.5.0"
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
#define DASH_PREFIX            "NX_"

// NEON RENK PALETİ
#define C_BG_BASE              C'10,12,18'
#define C_BG_PANEL             C'18,22,32'
#define C_BG_CARD              C'22,28,40'
#define C_BG_TERMINAL          C'6,8,14'
#define C_NEON_CYAN            C'0,230,255'
#define C_NEON_PURPLE          C'160,32,240'
#define C_NEON_GREEN           C'39,255,20'
#define C_NEON_RED             C'255,45,45'
#define C_NEON_GOLD            C'255,200,0'
#define C_NEON_BLUE            C'30,144,255'
#define C_NEON_PINK            C'255,20,147'
#define C_TEXT_MAIN            C'210,220,230'
#define C_TEXT_MUTED           C'90,100,120'
#define C_SEPARATOR            C'30,36,50'

//+------------------------------------------------------------------+
//| ENUMLAR                                                          |
//+------------------------------------------------------------------+
enum ENUM_DASH_MODE {
   DASH_MINI,  // [MİNİ MOD] Sol Üst Köşe - Grafik İzlemek İçin
   DASH_FULL   // [ULTRA PANEL] Tam Ekran Neon Arayüz
};

enum ENUM_SYSTEM_STATE {
   STATE_INIT, STATE_SCANNING, STATE_PACKET_OPEN,
   STATE_BOOST_X3, STATE_BOOST_X9, STATE_BOOST_X27,
   STATE_RECOVERY, STATE_PAUSED, STATE_ERROR
};

enum ENUM_BOOST_STATE {
   BOOST_NONE, BOOST_X3_ACTIVE, BOOST_X9_ACTIVE,
   BOOST_X27_ACTIVE, BOOST_COMPLETED, BOOST_FAILED
};

enum ENUM_SYMBOL_CATEGORY {
   CATEGORY_FOREX, CATEGORY_METALS, CATEGORY_CRYPTO
};

enum ENUM_LOG_LEVEL {
   LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR, LOG_CRITICAL
};

enum ENUM_TRAILING_LEVEL {
   TRAIL_NONE, TRAIL_LEVEL_1, TRAIL_LEVEL_2,
   TRAIL_LEVEL_3, TRAIL_LEVEL_4, TRAIL_COMPLETED
};

//+------------------------------------------------------------------+
//| INPUT PARAMETRELERİ                                               |
//+------------------------------------------------------------------+
input group "=== GÖRÜNÜM MODU ==="
input ENUM_DASH_MODE InpDashMode = DASH_FULL;

input group "=== RİSK YÖNETİMİ ==="
input double  InpRiskPercent      = 0.5;
input double  InpMaxDrawdown      = 20.0;
input double  InpDailyLossLimit   = 2.0;
input double  InpMinLot           = 0.01;
input double  InpMaxLot           = 5.0;

input group "=== BOOST & SAĞLIK ==="
input double  InpBoostThreshPct   = 1.0;
input double  InpBoostX9StopPct   = 10.0;
input double  InpBoostX27StopPct  = 20.0;
input double  InpBoostX27ClosePct = 30.0;
input int     InpHealthPeriod     = 20;
input double  InpMinHealthScore   = 30.0;

input group "=== TELEGRAM ==="
input string  InpTelegramToken    = "";
input string  InpTelegramChatID   = "";
input bool    InpTelegramActive   = true;
input int     InpHourlyReport     = 1;
input bool    InpDailyReport      = true;

input group "=== SİSTEM ==="
input bool    InpDebugMode        = true;
input int     InpMagicOffset      = 0;

//+------------------------------------------------------------------+
//| STRUCT TANIMLARI                                                  |
//+------------------------------------------------------------------+
struct PacketState {
   ulong  magicID;
   int    symbolIndex;
   double baseLot;
   int    boostLevel;
   double buyTicket;
   double sellTicket;
   double boostTicket;
   double openPrice;
   double spreadAtOpen;
   datetime openTime;
   bool   isRecovery;
   double recoveryTarget;
   int    boostState;
   bool   isFirstPacket;
   int    mumDevretCount;
};

struct MarketData {
   double spread;
   double avgSpread;
   double healthScore;
   double pipValue;
   double pointValue;
   int    digits;
   int    category;
   double avgVolume;
   double currentVolume;
   double atr;
};

struct AccountData {
   double balance;
   double equity;
   double freeMargin;
   double drawdown;
   double dailyPnL;
   int    totalPackets;
   int    successPackets;
   int    failedPackets;
   datetime sessionStart;
};

struct StatisticsData {
   int    boostX3Count;
   int    boostX9Count;
   int    boostX27Count;
   int    recoveryCount;
   double maxDrawdownReached;
   datetime systemStartTime;
};

struct TrailingProfile {
   double level1TriggerPct;
   double level2TriggerPct;
   double level3TriggerPct;
   double level4TriggerPct;
   double atrMultLondon;
   double atrMultNY;
   double atrMultAsia;
   double atrMultNight;
   double minDistancePip;
   double maxDistancePip;
   int    spikeFilterTicks;
   double spikeThresholdPct;
};

struct TrailingState {
   ulong  ticket;
   int    symbolIndex;
   bool   isActive;
   double peakProfit;
   double currentProfit;
   double lockedProfit;
   double initialProfit;
   double currentSL;
   double openPrice;
   int    level;
   bool   level1Hit;
   bool   level2Hit;
   bool   level3Hit;
   bool   level4Hit;
   double tickHistory[5];
   int    tickCount;
   datetime activeSince;
   datetime lastUpdate;
   int    updateCount;
};

struct TrailingStats {
   int    totalActivations;
   int    breakevenHits;
   int    level2Hits;
   int    level3Hits;
   int    level4Hits;
   double totalLockedProfit;
};

struct BrokerCapabilities {
   bool   hedgeAllowed;
   double minLot;
   double maxLot;
   int    stopLevel;
   bool   testPassed;
};

//+------------------------------------------------------------------+
//| GLOBAL DEĞİŞKENLER                                               |
//+------------------------------------------------------------------+
string            g_symbols[NEXUS_SYMBOLS_COUNT];
MarketData        g_marketData[NEXUS_SYMBOLS_COUNT];
PacketState       g_packets[NEXUS_SYMBOLS_COUNT];
TrailingProfile   g_trailingProfiles[NEXUS_SYMBOLS_COUNT];
TrailingState     g_trailingStates[NEXUS_SYMBOLS_COUNT];
TrailingStats     g_trailingStats;
AccountData       g_account;
StatisticsData    g_stats;
BrokerCapabilities g_broker;
ENUM_SYSTEM_STATE g_systemStates[NEXUS_SYMBOLS_COUNT];
ulong             g_magicIDs[NEXUS_SYMBOLS_COUNT];
datetime          g_lastM5Time[NEXUS_SYMBOLS_COUNT];

bool     g_isInitialized  = false;
bool     g_emergencyStop  = false;
bool     g_systemPaused   = false;
datetime g_lastDashUpdate = 0;
datetime g_lastHourlyReport = 0;
datetime g_lastDailyReport  = 0;
int      g_logFileHandle  = INVALID_HANDLE;

// Motivasyon Sistemi
string g_currentQuote    = "";
datetime g_lastQuoteTime = 0;
int    g_quoteIdx        = 0;

// Terminal Log Buffer (Son 5 Log)
string g_terminalLogs[5];
int    g_terminalCount = 0;

// Motivasyon Havuzları
string g_quotesSabir[]    = {
   "Sabir, basarinin sessiz ama en guclu motorudur.",
   "Dogru ani beklemek, aceleci kaybetmekten iyidir.",
   "Piyasa test eder. Sabir kazanir.",
   "En iyi islemler zorla degil bekleyerek gelir.",
   "Firsat kapiya vurmaz sen ona hazir olursun."
};
string g_quotesGuc[]      = {
   "Sistem calisir. Sen sisteme guven.",
   "Her pip disiplinin bir oduludur.",
   "Guclu sistem guclu sonuc uretir.",
   "Simdi odaklan kalanini sistem halleder.",
   "Algoritma yorulmaz. Sen de yorulma."
};
string g_quotesDisipl[]   = {
   "Kural bozulmaz. Sistem bozulmaz.",
   "Disiplin en karli yatirimdir.",
   "Duygular satar sistem kazanir.",
   "Plan ne diyorsa o olur sapma yok.",
   "Sistem konustu karar verildi."
};
string g_quotesVizyon[]   = {
   "Bugun ekilenler yarin bicilenlerdir.",
   "Buyuk resmi gormeyen kucuk kayipte bogulur.",
   "Kucuk karlar buyuk hayallerin tuglalaridir.",
   "Zaman en iyi ortaginizdir.",
   "Vizyon olmadan sistem calisir ama nereye?"
};
string g_quotesGece[]     = {
   "Sistem uyumaz. Sen uyu o calisir.",
   "Her sabah sifirdan baslamak bir avantajdir.",
   "Dinlenmek de bir stratejidir.",
   "Algoritma gece de dusunur.",
   "Sabah geldiginde sistem hazir olacak."
};
string g_quotesRecovery[] = {
   "Firtina ne kadar surerse surSun gunes hep dogar.",
   "Dusmek utanc degil kalkmamak utanctir.",
   "Her zarar bir sonraki kazancin ogretmenidir.",
   "Sistem bir kez dustu bin kez kalkar.",
   "Kriz sistemi daha guclu yapar."
};
string g_quotesBoost[]    = {
   "Firsat yakalandi. Sistem devrede!",
   "Boost aktif. Guven tam.",
   "Bu an icin tasarlandik.",
   "Sistem gucunu gosteriyor!",
   "Hazirlik bu anin icindi."
};

//+------------------------------------------------------------------+
//| LOG VE TERMİNAL SİSTEMİ                                          |
//+------------------------------------------------------------------+
void AddTerminalLog(string msg) {
   for(int i=4; i>0; i--) g_terminalLogs[i] = g_terminalLogs[i-1];
   g_terminalLogs[0] = TimeToString(TimeCurrent(), TIME_SECONDS) + " " + msg;
   g_terminalCount++;
}

void NexusLog(ENUM_LOG_LEVEL level, string symbol, string message) {
   if(!InpDebugMode && level == LOG_DEBUG) return;
   string prefix;
   switch(level) {
      case LOG_DEBUG:    prefix = "[DBG]"; break;
      case LOG_INFO:     prefix = "[INF]"; break;
      case LOG_WARNING:  prefix = "[WRN]"; break;
      case LOG_ERROR:    prefix = "[ERR]"; break;
      case LOG_CRITICAL: prefix = "[!!!]"; break;
      default:           prefix = "[???]"; break;
   }
   string line = StringFormat("%s [%s] %s", prefix, symbol, message);
   Print(line);
   AddTerminalLog(line);
   if(level == LOG_CRITICAL) {
      string msg = StringFormat("NEXUS KRITIK\n%s\n%s", symbol, message);
      SendTelegramMessage(msg);
   }
}

//+------------------------------------------------------------------+
//| TELEGRAM                                                          |
//+------------------------------------------------------------------+
void SendTelegramMessage(string message) {
   if(!InpTelegramActive || InpTelegramToken == "" || InpTelegramChatID == "") return;
   string url  = "https://api.telegram.org/bot" + InpTelegramToken + "/sendMessage";
   string body = "chat_id=" + InpTelegramChatID + "&text=" + message + "&parse_mode=HTML";
   char post[], result[];
   string headers;
   StringToCharArray(body, post, 0, StringLen(body), CP_UTF8);
   WebRequest("POST", url, "Content-Type: application/x-www-form-urlencoded\r\n",
              5000, post, result, headers);
}

void SendTelegramAlert(int symIdx, string title, bool critical) {
   double pnl = GetPacketPnL(symIdx);
   string msg = StringFormat(
      "%s AsFaRaS NEXUS\nSembol: %s\n%s\nP&L: %+.2f$\nBakiye: $%.2f\n%s",
      critical ? "[KRITIK]" : "[UYARI]",
      g_symbols[symIdx], title, pnl,
      AccountInfoDouble(ACCOUNT_BALANCE),
      TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   SendTelegramMessage(msg);
}

void SendHourlyReport() {
   datetime now = TimeCurrent();
   if((int)(now - g_lastHourlyReport) < InpHourlyReport * 3600) return;
   g_lastHourlyReport = now;
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   string msg = StringFormat(
      "AsFaRaS NEXUS SAATLIK RAPOR\n%s\nBakiye: $%.2f\nEquity: $%.2f\n"
      "x3/x9/x27: %d/%d/%d\nBasari: %d/%d\nRecovery: %d\n%s\n-- AsFaRaS NEXUS --",
      TimeToString(now, TIME_DATE|TIME_MINUTES),
      bal, eq,
      g_stats.boostX3Count, g_stats.boostX9Count, g_stats.boostX27Count,
      g_account.successPackets, g_account.totalPackets,
      g_stats.recoveryCount, g_currentQuote);
   SendTelegramMessage(msg);
}

void SendDailyReport() {
   if(!InpDailyReport) return;
   MqlDateTime n, l;
   TimeToStruct(TimeCurrent(), n); TimeToStruct(g_lastDailyReport, l);
   if(n.day == l.day && n.mon == l.mon) return;
   g_lastDailyReport = TimeCurrent();
   string msg = StringFormat(
      "AsFaRaS NEXUS GUNLUK RAPOR\n%s\nGunluk P&L: %+.2f$\nBakiye: $%.2f\n"
      "Max DD: %.2f%%\nBasari: %.1f%%\nRecovery: %d\n%s\n-- AsFaRaS NEXUS --",
      TimeToString(TimeCurrent(), TIME_DATE),
      g_account.dailyPnL, AccountInfoDouble(ACCOUNT_BALANCE),
      g_stats.maxDrawdownReached,
      g_account.totalPackets > 0 ?
        (double)g_account.successPackets / g_account.totalPackets * 100 : 0,
      g_stats.recoveryCount, g_currentQuote);
   SendTelegramMessage(msg);
}

//+------------------------------------------------------------------+
//| MOTİVASYON SİSTEMİ                                               |
//+------------------------------------------------------------------+
string SelectQuote() {
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   int hour = dt.hour;
   bool rec = false, bst = false;
   for(int i = 0; i < NEXUS_SYMBOLS_COUNT; i++) {
      if(g_systemStates[i] == STATE_RECOVERY) rec = true;
      if(g_systemStates[i] == STATE_BOOST_X3 ||
         g_systemStates[i] == STATE_BOOST_X9 ||
         g_systemStates[i] == STATE_BOOST_X27) bst = true;
   }
   int idx;
   if(rec)             { idx = g_quoteIdx % ArraySize(g_quotesRecovery); return g_quotesRecovery[idx]; }
   if(bst)             { idx = g_quoteIdx % ArraySize(g_quotesBoost);    return g_quotesBoost[idx];    }
   if(hour >= 8  && hour < 12) { idx = g_quoteIdx % ArraySize(g_quotesSabir);  return g_quotesSabir[idx];  }
   if(hour >= 12 && hour < 17) { idx = g_quoteIdx % ArraySize(g_quotesGuc);    return g_quotesGuc[idx];    }
   if(hour >= 17 && hour < 20) { idx = g_quoteIdx % ArraySize(g_quotesDisipl); return g_quotesDisipl[idx]; }
   if(hour >= 20 && hour < 24) { idx = g_quoteIdx % ArraySize(g_quotesVizyon); return g_quotesVizyon[idx]; }
   idx = g_quoteIdx % ArraySize(g_quotesGece);
   return g_quotesGece[idx];
}

void UpdateQuote() {
   MqlDateTime n, l;
   TimeToStruct(TimeCurrent(), n); TimeToStruct(g_lastQuoteTime, l);
   if(g_lastQuoteTime == 0 || n.hour != l.hour || g_currentQuote == "") {
      g_quoteIdx++;
      g_currentQuote  = SelectQuote();
      g_lastQuoteTime = TimeCurrent();
   }
}

string QuoteCountdown() {
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   return StringFormat("%02d:%02d", 59 - dt.min, 59 - dt.sec);
}

//+------------------------------------------------------------------+
//| OTOMATİK SEMBOL TESPİTİ (YZ TARAYICI)                            |
//+------------------------------------------------------------------+
bool AutoDetectSymbols() {
   NexusLog(LOG_INFO, "CORE", "YZ Broker Tarayici Aktif...");
   string kw[5][3] = {
      {"XAU","GOLD",""},
      {"XAG","SILVER",""},
      {"EURUSD","",""},
      {"BTC","BITCOIN",""},
      {"ETH","ETHEREUM",""}
   };
   int total = SymbolsTotal(false);
   bool ok   = true;
   for(int s = 0; s < 5; s++) {
      g_symbols[s] = "";
      for(int i = 0; i < total; i++) {
         string n = SymbolName(i, false);
         string u = n; StringToUpper(u);
         bool match = (StringFind(u, kw[s][0]) >= 0) ||
                      (kw[s][1] != "" && StringFind(u, kw[s][1]) >= 0);
         if(s == 2 && StringFind(u, "EURUSD") < 0) continue;
         if(match) {
            g_symbols[s] = n;
            SymbolSelect(n, true);
            NexusLog(LOG_INFO, "DETECT", kw[s][0] + " -> " + n);
            break;
         }
      }
      if(g_symbols[s] == "") {
         NexusLog(LOG_ERROR, "DETECT", "Bulunamadi: " + kw[s][0]);
         ok = false;
      }
   }
   return ok;
}

//+------------------------------------------------------------------+
//| PİYASA SAĞLIK SİSTEMİ                                            |
//+------------------------------------------------------------------+
double GetCurrentSpread(string symbol) {
   double pt = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(pt <= 0) return 0;
   return (SymbolInfoDouble(symbol, SYMBOL_ASK) -
           SymbolInfoDouble(symbol, SYMBOL_BID)) / pt;
}

double GetPipValue(string symbol) {
   double tv = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double pt = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int    dg = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double ps = (dg == 3 || dg == 5) ? pt * 10 : pt;
   return (ts <= 0) ? 0 : (tv / ts) * ps;
}

ENUM_SYMBOL_CATEGORY GetCategory(string symbol) {
   string u = symbol; StringToUpper(u);
   if(StringFind(u,"XAU")>=0||StringFind(u,"XAG")>=0||
      StringFind(u,"GOLD")>=0||StringFind(u,"SILVER")>=0) return CATEGORY_METALS;
   if(StringFind(u,"BTC")>=0||StringFind(u,"ETH")>=0||
      StringFind(u,"BITCOIN")>=0||StringFind(u,"ETHEREUM")>=0) return CATEGORY_CRYPTO;
   return CATEGORY_FOREX;
}

double GetSessionMult(int symIdx) {
   MqlDateTime dt; TimeToStruct(TimeGMT(), dt);
   int h = dt.hour, d = dt.day_of_week;
   int cat = g_marketData[symIdx].category;
   if(cat == CATEGORY_CRYPTO) {
      if(d==0||d==6){if(h<6)return 0.5;return 0.75;}
      if(h<6)return 0.7; if(h>=14&&h<22)return 1.0; return 0.85;
   }
   if(d==0||d==6)return 0.2; if(h<6)return 0.4;
   if(h>=6&&h<8)return 0.6; if(h>=8&&h<17)return 1.0;
   if(h>=17&&h<20)return 0.9; return 0.7;
}

void CalculateHealthScore(int symIdx) {
   string sym = g_symbols[symIdx];
   double cur = GetCurrentSpread(sym);
   double avg = g_marketData[symIdx].avgSpread;
   if(avg <= 0) avg = cur;
   if(cur > 0) g_marketData[symIdx].avgSpread = 0.1*cur + 0.9*avg;
   g_marketData[symIdx].spread = cur;

   double spScore = 0;
   if(cur > 0 && avg > 0) {
      double r = MathMax(0.1, MathMin(2.0, avg/cur));
      spScore = MathMax(0, MathMin(25.0, (r/2.0)*25.0));
   }
   long vol = iVolume(sym, PERIOD_M5, 0);
   double avgVol = g_marketData[symIdx].avgVolume;
   if(avgVol <= 0) avgVol = (double)vol;
   g_marketData[symIdx].avgVolume = 0.1*(double)vol + 0.9*avgVol;
   double vr = (avgVol > 0) ? MathMax(0.1, MathMin(3.0, (double)vol/avgVol)) : 1.0;
   double volScore = (vr>=0.5&&vr<=1.5)?25.0:(vr<0.5?vr*50.0:MathMax(10.0,25.0-(vr-1.5)*10.0));

   int atrH = iATR(sym, PERIOD_M5, InpHealthPeriod);
   double atrScore = 12.5;
   if(atrH != INVALID_HANDLE) {
      double ab[]; ArraySetAsSeries(ab, true);
      if(CopyBuffer(atrH, 0, 0, 2, ab) >= 2) {
         double pt = SymbolInfoDouble(sym, SYMBOL_POINT);
         g_marketData[symIdx].atr = ab[0];
         int cat = g_marketData[symIdx].category;
         double iMin = (cat==CATEGORY_CRYPTO)?pt*100:(cat==CATEGORY_METALS)?pt*50:pt*5;
         double iMax = (cat==CATEGORY_CRYPTO)?pt*500:(cat==CATEGORY_METALS)?pt*200:pt*20;
         if(ab[0]>=iMin&&ab[0]<=iMax) atrScore=25.0;
         else if(ab[0]<iMin) atrScore=(ab[0]/iMin)*25.0;
         else atrScore=MathMax(5.0,25.0-((ab[0]-iMax)/iMax)*15.0);
      }
      IndicatorRelease(atrH);
   }

   double total = (spScore + MathMax(0,MathMin(25,volScore)) +
                  MathMax(0,MathMin(25,atrScore)) + 12.5) *
                  GetSessionMult(symIdx);
   g_marketData[symIdx].healthScore = MathMax(0, MathMin(100.0, total));
}

//+------------------------------------------------------------------+
//| PAKET YÖNETİMİ                                                   |
//+------------------------------------------------------------------+
ulong GenerateMagicID(int idx) {
   return NEXUS_MAGIC_BASE + (ulong)(idx*10000) +
          (ulong)(TimeCurrent()%9999) + (ulong)InpMagicOffset;
}

double NormalizeLot(string sym, double lot) {
   double mn = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double st = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   if(st <= 0) st = 0.01;
   lot = MathMax(lot, MathMax(mn, InpMinLot));
   lot = MathMin(lot, MathMin(mx, InpMaxLot));
   return NormalizeDouble(MathRound(lot/st)*st, 2);
}

double CalculateBaseLot(string sym, bool recovery = false) {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double pv  = GetPipValue(sym);
   if(pv <= 0) return InpMinLot;
   double rp = InpRiskPercent / 100.0;
   double mp = 30.0;
   ENUM_SYMBOL_CATEGORY cat = GetCategory(sym);
   if(cat == CATEGORY_CRYPTO)      { mp = 50.0; rp *= 0.7; }
   else if(cat == CATEGORY_METALS)   mp = 35.0;
   double lot = (bal * rp) / (mp * pv * 27.0);
   if(recovery) lot *= (1.0 + RECOVERY_LOT_BONUS);
   return NormalizeLot(sym, lot);
}

bool HasActivePacket(int symIdx) {
   for(int i = PositionsTotal()-1; i >= 0; i--) {
      ulong tkt = PositionGetTicket(i);
      if(!PositionSelectByTicket(tkt)) continue;
      if(PositionGetString(POSITION_SYMBOL) == g_symbols[symIdx] &&
         PositionGetInteger(POSITION_MAGIC) == (long)g_magicIDs[symIdx]) return true;
   }
   return false;
}

double GetPacketPnL(int symIdx) {
   double total = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--) {
      ulong tkt = PositionGetTicket(i);
      if(!PositionSelectByTicket(tkt)) continue;
      if(PositionGetString(POSITION_SYMBOL) == g_symbols[symIdx] &&
         PositionGetInteger(POSITION_MAGIC) == (long)g_magicIDs[symIdx])
         total += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return total;
}

ulong OpenOrder(string sym, ENUM_ORDER_TYPE type, double lot,
                string comment, ulong magic) {
   MqlTradeRequest req; MqlTradeResult res;
   ZeroMemory(req); ZeroMemory(res);
   req.action    = TRADE_ACTION_DEAL;
   req.symbol    = sym;
   req.volume    = lot;
   req.type      = type;
   req.price     = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(sym,SYMBOL_ASK) :
                                             SymbolInfoDouble(sym,SYMBOL_BID);
   req.deviation = 10;
   req.magic     = magic;
   req.comment   = comment;
   req.type_filling = ORDER_FILLING_IOC;
   for(int r = 0; r < MAX_RETRY_COUNT; r++) {
      if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE) {
         NexusLog(LOG_INFO, sym, StringFormat("Acildi %s %.2f",
                  type==ORDER_TYPE_BUY?"BUY":"SELL", lot));
         return res.deal;
      }
      Sleep(300);
      req.price = (type==ORDER_TYPE_BUY) ? SymbolInfoDouble(sym,SYMBOL_ASK) :
                                            SymbolInfoDouble(sym,SYMBOL_BID);
   }
   NexusLog(LOG_ERROR, sym, StringFormat("Acilamadi! %d", res.retcode));
   return 0;
}

bool CloseOrder(string sym, ulong ticket, string reason) {
   if(!PositionSelectByTicket(ticket)) return false;
   MqlTradeRequest req; MqlTradeResult res;
   ZeroMemory(req); ZeroMemory(res);
   ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   req.action    = TRADE_ACTION_DEAL;
   req.symbol    = sym;
   req.volume    = PositionGetDouble(POSITION_VOLUME);
   req.type      = (pt==POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   req.price     = (pt==POSITION_TYPE_BUY) ? SymbolInfoDouble(sym,SYMBOL_BID) :
                                              SymbolInfoDouble(sym,SYMBOL_ASK);
   req.position  = ticket;
   req.deviation = 10;
   req.comment   = "ANX:" + reason;
   req.type_filling = ORDER_FILLING_IOC;
   for(int r = 0; r < MAX_RETRY_COUNT; r++) {
      if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE) return true;
      Sleep(300);
   }
   return false;
}

bool CloseAll(int symIdx, string reason) {
   string sym = g_symbols[symIdx];
   ulong  mag = g_magicIDs[symIdx];
   bool   ok  = true;
   for(int i = PositionsTotal()-1; i >= 0; i--) {
      ulong tkt = PositionGetTicket(i);
      if(!PositionSelectByTicket(tkt)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=sym) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=(long)mag) continue;
      if(!CloseOrder(sym, tkt, reason)) ok = false;
   }
   if(ok) {
      g_packets[symIdx].boostState  = BOOST_NONE;
      g_packets[symIdx].buyTicket   = 0;
      g_packets[symIdx].sellTicket  = 0;
      g_packets[symIdx].boostTicket = 0;
      g_systemStates[symIdx] = STATE_SCANNING;
   }
   return ok;
}

bool CheckLimits() {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(bal <= 0) return false;
   double dd = (bal-eq)/bal*100.0;
   if(dd >= InpMaxDrawdown) { g_emergencyStop = true; return false; }
   if(g_account.dailyPnL < -(bal*(InpDailyLossLimit/100.0))) return false;
   return true;
}

bool CheckMargin(int symIdx) {
   double fm = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double bl = AccountInfoDouble(ACCOUNT_BALANCE);
   return (bl <= 0) ? false : (fm >= bl * 0.20);
}

bool OpenInitialPacket(int symIdx) {
   string sym = g_symbols[symIdx];
   if(HasActivePacket(symIdx)) return false;
   ulong buyT  = OpenOrder(sym, ORDER_TYPE_BUY,  0.01, "ANX_INIT_B", g_magicIDs[symIdx]);
   ulong sellT = OpenOrder(sym, ORDER_TYPE_SELL, 0.01, "ANX_INIT_S", g_magicIDs[symIdx]);
   if(buyT > 0 && sellT > 0) {
      g_packets[symIdx].buyTicket    = (double)buyT;
      g_packets[symIdx].sellTicket   = (double)sellT;
      g_packets[symIdx].baseLot      = 0.01;
      g_packets[symIdx].openTime     = TimeCurrent();
      g_packets[symIdx].isFirstPacket= true;
      g_packets[symIdx].boostState   = BOOST_NONE;
      g_systemStates[symIdx] = STATE_PACKET_OPEN;
      g_account.totalPackets++;
      NexusLog(LOG_INFO, sym, "Ilk paket 0.01 lot acildi");
      return true;
   }
   return false;
}

bool OpenNormalPacket(int symIdx) {
   string sym = g_symbols[symIdx];
   if(HasActivePacket(symIdx)) return false;
   if(g_marketData[symIdx].healthScore < InpMinHealthScore) return false;
   if(!CheckLimits() || !CheckMargin(symIdx)) return false;
   bool rec = (g_systemStates[symIdx] == STATE_RECOVERY);
   double lot = CalculateBaseLot(sym, rec);
   ulong buyT  = OpenOrder(sym, ORDER_TYPE_BUY,  lot,
                           rec?"ANX_REC_B":"ANX_B", g_magicIDs[symIdx]);
   ulong sellT = OpenOrder(sym, ORDER_TYPE_SELL, lot,
                           rec?"ANX_REC_S":"ANX_S", g_magicIDs[symIdx]);
   if(buyT > 0 && sellT > 0) {
      g_packets[symIdx].buyTicket    = (double)buyT;
      g_packets[symIdx].sellTicket   = (double)sellT;
      g_packets[symIdx].baseLot      = lot;
      g_packets[symIdx].openTime     = TimeCurrent();
      g_packets[symIdx].isFirstPacket= false;
      g_packets[symIdx].boostState   = BOOST_NONE;
      g_systemStates[symIdx] = STATE_PACKET_OPEN;
      g_account.totalPackets++;
      return true;
   }
   return false;
}

bool UpdatePositionSL(int symIdx, ulong ticket, double sl) {
   if(!PositionSelectByTicket(ticket)) return false;
   MqlTradeRequest req; MqlTradeResult res;
   ZeroMemory(req); ZeroMemory(res);
   req.action   = TRADE_ACTION_SLTP;
   req.symbol   = g_symbols[symIdx];
   req.position = ticket;
   req.sl       = NormalizeDouble(sl, g_marketData[symIdx].digits);
   req.tp       = PositionGetDouble(POSITION_TP);
   return (OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE);
}

//+------------------------------------------------------------------+
//| BOOST SİSTEMİ                                                    |
//+------------------------------------------------------------------+
bool OpenBoost(int symIdx, int multiplier) {
   string sym  = g_symbols[symIdx];
   ulong  mag  = g_magicIDs[symIdx];
   double lot  = NormalizeLot(sym, g_packets[symIdx].baseLot * multiplier);
   ulong  prev = (ulong)g_packets[symIdx].boostTicket;
   ENUM_ORDER_TYPE bt = ORDER_TYPE_BUY;
   if(prev > 0 && PositionSelectByTicket(prev)) {
      ENUM_POSITION_TYPE pt=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      bt = (pt==POSITION_TYPE_BUY)?ORDER_TYPE_SELL:ORDER_TYPE_BUY;
      CloseOrder(sym, prev, "BOOST_CLOSE");
   } else {
      ulong buyT  = (ulong)g_packets[symIdx].buyTicket;
      ulong sellT = (ulong)g_packets[symIdx].sellTicket;
      double bPnL = 0, sPnL = 0;
      if(PositionSelectByTicket(buyT))  bPnL = PositionGetDouble(POSITION_PROFIT);
      if(PositionSelectByTicket(sellT)) sPnL = PositionGetDouble(POSITION_PROFIT);
      bt = (bPnL < sPnL) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   }
   string tag = "ANX_BST_X" + IntegerToString(multiplier);
   ulong bTkt = OpenOrder(sym, bt, lot, tag, mag);
   if(bTkt > 0) {
      g_packets[symIdx].boostTicket = (double)bTkt;
      g_packets[symIdx].boostLevel  = multiplier;
      if(multiplier ==  3) { g_packets[symIdx].boostState=BOOST_X3_ACTIVE;  g_systemStates[symIdx]=STATE_BOOST_X3;  g_stats.boostX3Count++;  }
      if(multiplier ==  9) { g_packets[symIdx].boostState=BOOST_X9_ACTIVE;  g_systemStates[symIdx]=STATE_BOOST_X9;  g_stats.boostX9Count++;  }
      if(multiplier == 27) { g_packets[symIdx].boostState=BOOST_X27_ACTIVE; g_systemStates[symIdx]=STATE_BOOST_X27; g_stats.boostX27Count++; }
      NexusLog(LOG_WARNING, sym, StringFormat("BOOST x%d AKTIF Lot:%.2f", multiplier, lot));
      SendTelegramAlert(symIdx, StringFormat("BOOST x%d AKTIF!", multiplier), multiplier==27);
      return true;
   }
   return false;
}

double CalcBoostThreshold(int symIdx) {
   double sp  = g_marketData[symIdx].spread;
   double hs  = g_marketData[symIdx].healthScore;
   double thr = sp * InpBoostThreshPct * (0.5 + hs/100.0);
   int cat = g_marketData[symIdx].category;
   if(cat == CATEGORY_CRYPTO)      thr *= 2.0;
   else if(cat == CATEGORY_METALS) thr *= 1.3;
   return MathMax(thr, sp * 0.5);
}

void CheckBoostTrigger(int symIdx) {
   if(g_packets[symIdx].boostState != BOOST_NONE) return;
   if(g_systemStates[symIdx] != STATE_PACKET_OPEN) return;
   ulong bT = (ulong)g_packets[symIdx].buyTicket;
   ulong sT = (ulong)g_packets[symIdx].sellTicket;
   double bO = 0, sO = 0;
   if(PositionSelectByTicket(bT)) bO = PositionGetDouble(POSITION_PRICE_OPEN);
   if(PositionSelectByTicket(sT)) sO = PositionGetDouble(POSITION_PRICE_OPEN);
   if(bO <= 0 || sO <= 0) return;
   if(MathAbs(bO - sO) >= CalcBoostThreshold(symIdx)) OpenBoost(symIdx, 3);
}

void CheckBoostConditions(int symIdx) {
   int bs = g_packets[symIdx].boostState;
   if(bs==BOOST_NONE||bs==BOOST_COMPLETED||bs==BOOST_FAILED) return;
   string sym   = g_symbols[symIdx];
   double sp    = g_marketData[symIdx].spread;
   double pt    = g_marketData[symIdx].pointValue;
   double bl    = g_packets[symIdx].baseLot;
   ulong  bstTkt= (ulong)g_packets[symIdx].boostTicket;
   ulong  buyTkt= (ulong)g_packets[symIdx].buyTicket;
   ulong  selTkt= (ulong)g_packets[symIdx].sellTicket;
   double bstPnL= 0, bPnL = 0, sPnL = 0;
   ENUM_POSITION_TYPE bstType = POSITION_TYPE_BUY;
   if(PositionSelectByTicket(bstTkt)) {
      bstPnL  = PositionGetDouble(POSITION_PROFIT);
      bstType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   }
   if(PositionSelectByTicket(buyTkt)) bPnL = PositionGetDouble(POSITION_PROFIT);
   if(PositionSelectByTicket(selTkt)) sPnL = PositionGetDouble(POSITION_PROFIT);
   double mainPnL = bPnL + sPnL;
   double pipSz   = (g_marketData[symIdx].digits==3||g_marketData[symIdx].digits==5)?pt*10:pt;
   double curP    = SymbolInfoDouble(sym, bstType==POSITION_TYPE_BUY?SYMBOL_BID:SYMBOL_ASK);
   double target  = sp * pipSz * bl * (1.0 + PROFIT_TARGET_PCT);

   if(bs == BOOST_X3_ACTIVE) {
      if(mainPnL+bstPnL >= target) {
         CloseOrder(sym,buyTkt,"OK_B"); CloseOrder(sym,selTkt,"OK_S");
         double sl = bstType==POSITION_TYPE_BUY?curP-(pipSz*TRAILING_STOP_PCT*100):curP+(pipSz*TRAILING_STOP_PCT*100);
         UpdatePositionSL(symIdx,bstTkt,sl);
         g_packets[symIdx].boostState = BOOST_COMPLETED;
         g_systemStates[symIdx] = STATE_SCANNING;
         g_account.successPackets++;
         InitTrailingState(symIdx, bstTkt, target);
         return;
      }
      if(bstPnL <= -(sp*pipSz*InpBoostX9StopPct/100.0)) OpenBoost(symIdx, 9);
   }
   else if(bs == BOOST_X9_ACTIVE) {
      if(mainPnL+bstPnL >= target) {
         CloseOrder(sym,buyTkt,"x9_OK"); CloseOrder(sym,selTkt,"x9_OK");
         g_packets[symIdx].boostState = BOOST_COMPLETED;
         g_systemStates[symIdx] = STATE_SCANNING;
         g_account.successPackets++;
         return;
      }
      if(bstPnL <= -(sp*pipSz*InpBoostX27StopPct/100.0)) OpenBoost(symIdx, 27);
   }
   else if(bs == BOOST_X27_ACTIVE) {
      if(mainPnL+bstPnL >= 0) { CloseAll(symIdx,"x27_OK"); g_account.successPackets++; return; }
      if(bstPnL <= -(sp*pipSz*InpBoostX27ClosePct/100.0)) {
         CloseAll(symIdx,"x27_FAIL");
         g_account.failedPackets++;
         g_stats.recoveryCount++;
         g_systemStates[symIdx] = STATE_RECOVERY;
         g_packets[symIdx].isRecovery = true;
         g_packets[symIdx].recoveryTarget = MathAbs(GetPacketPnL(symIdx))*1.1;
         SendTelegramAlert(symIdx, "ZARAR! Recovery Aktif!", true);
      }
   }
}

//+------------------------------------------------------------------+
//| TRAİLİNG STOP SİSTEMİ                                            |
//+------------------------------------------------------------------+
void InitTrailingProfiles() {
   double lv1=25.0, lv2=50.0, lv3=75.0, lv4=100.0;
   for(int s=0; s<NEXUS_SYMBOLS_COUNT; s++) {
      g_trailingProfiles[s].level1TriggerPct = lv1;
      g_trailingProfiles[s].level2TriggerPct = lv2;
      g_trailingProfiles[s].level3TriggerPct = lv3;
      g_trailingProfiles[s].level4TriggerPct = lv4;
      g_trailingProfiles[s].spikeFilterTicks  = (s==SYM_BITCOIN||s==SYM_ETHEREUM)?5:3;
      g_trailingProfiles[s].spikeThresholdPct = (s==SYM_BITCOIN)?0.50:(s==SYM_ETHEREUM)?0.60:0.20;
   }
   g_trailingProfiles[SYM_GOLD].atrMultLondon=0.30; g_trailingProfiles[SYM_GOLD].atrMultNY=0.45; g_trailingProfiles[SYM_GOLD].atrMultAsia=0.70; g_trailingProfiles[SYM_GOLD].atrMultNight=0.90; g_trailingProfiles[SYM_GOLD].minDistancePip=5.0; g_trailingProfiles[SYM_GOLD].maxDistancePip=50.0;
   g_trailingProfiles[SYM_SILVER].atrMultLondon=0.35; g_trailingProfiles[SYM_SILVER].atrMultNY=0.50; g_trailingProfiles[SYM_SILVER].atrMultAsia=0.75; g_trailingProfiles[SYM_SILVER].atrMultNight=1.00; g_trailingProfiles[SYM_SILVER].minDistancePip=8.0; g_trailingProfiles[SYM_SILVER].maxDistancePip=80.0;
   g_trailingProfiles[SYM_EURUSD].atrMultLondon=0.25; g_trailingProfiles[SYM_EURUSD].atrMultNY=0.35; g_trailingProfiles[SYM_EURUSD].atrMultAsia=0.65; g_trailingProfiles[SYM_EURUSD].atrMultNight=0.85; g_trailingProfiles[SYM_EURUSD].minDistancePip=3.0; g_trailingProfiles[SYM_EURUSD].maxDistancePip=25.0;
   g_trailingProfiles[SYM_BITCOIN].atrMultLondon=0.50; g_trailingProfiles[SYM_BITCOIN].atrMultNY=0.60; g_trailingProfiles[SYM_BITCOIN].atrMultAsia=0.80; g_trailingProfiles[SYM_BITCOIN].atrMultNight=1.00; g_trailingProfiles[SYM_BITCOIN].minDistancePip=50.0; g_trailingProfiles[SYM_BITCOIN].maxDistancePip=500.0;
   g_trailingProfiles[SYM_ETHEREUM].atrMultLondon=0.55; g_trailingProfiles[SYM_ETHEREUM].atrMultNY=0.65; g_trailingProfiles[SYM_ETHEREUM].atrMultAsia=0.85; g_trailingProfiles[SYM_ETHEREUM].atrMultNight=1.10; g_trailingProfiles[SYM_ETHEREUM].minDistancePip=30.0; g_trailingProfiles[SYM_ETHEREUM].maxDistancePip=400.0;
}

double GetATRStep(int symIdx) {
   string sym = g_symbols[symIdx];
   double minP = g_trailingProfiles[symIdx].minDistancePip;
   double maxP = g_trailingProfiles[symIdx].maxDistancePip;
   int atrH = iATR(sym, PERIOD_M5, 14);
   double atrV = 0;
   if(atrH != INVALID_HANDLE) {
      double ab[]; ArraySetAsSeries(ab, true);
      if(CopyBuffer(atrH,0,0,3,ab)>=3) atrV=(ab[0]+ab[1]+ab[2])/3.0;
      IndicatorRelease(atrH);
   }
   double pt  = SymbolInfoDouble(sym, SYMBOL_POINT);
   double pip = (g_marketData[symIdx].digits==3||g_marketData[symIdx].digits==5)?pt*10:pt;
   if(atrV<=0||pip<=0) return minP*pip;
   MqlDateTime dt; TimeToStruct(TimeGMT(),dt);
   int h=dt.hour, d=dt.day_of_week;
   int cat=g_marketData[symIdx].category;
   double mult;
   if(cat==CATEGORY_CRYPTO) {
      if(d==0||d==6)mult=g_trailingProfiles[symIdx].atrMultNight;
      else if(h<6)  mult=g_trailingProfiles[symIdx].atrMultNight;
      else if(h>=14&&h<22)mult=g_trailingProfiles[symIdx].atrMultLondon;
      else          mult=g_trailingProfiles[symIdx].atrMultAsia;
   } else {
      if(h<6)       mult=g_trailingProfiles[symIdx].atrMultNight;
      else if(h<8)  mult=g_trailingProfiles[symIdx].atrMultAsia;
      else if(h<17) mult=g_trailingProfiles[symIdx].atrMultLondon;
      else if(h<20) mult=g_trailingProfiles[symIdx].atrMultNY;
      else          mult=g_trailingProfiles[symIdx].atrMultNight;
   }
   double step = atrV * mult / pip;
   return MathMax(minP, MathMin(maxP, step)) * pip;
}

void InitTrailingState(int symIdx, ulong ticket, double targetProfit) {
   if(!PositionSelectByTicket(ticket)) return;
   g_trailingStates[symIdx].ticket        = ticket;
   g_trailingStates[symIdx].symbolIndex   = symIdx;
   g_trailingStates[symIdx].isActive      = true;
   g_trailingStates[symIdx].openPrice     = PositionGetDouble(POSITION_PRICE_OPEN);
   g_trailingStates[symIdx].currentSL     = PositionGetDouble(POSITION_SL);
   g_trailingStates[symIdx].initialProfit = targetProfit;
   g_trailingStates[symIdx].peakProfit    = 0;
   g_trailingStates[symIdx].lockedProfit  = 0;
   g_trailingStates[symIdx].level         = TRAIL_NONE;
   g_trailingStates[symIdx].level1Hit     = false;
   g_trailingStates[symIdx].level2Hit     = false;
   g_trailingStates[symIdx].level3Hit     = false;
   g_trailingStates[symIdx].level4Hit     = false;
   g_trailingStates[symIdx].activeSince   = TimeCurrent();
   g_trailingStates[symIdx].tickCount     = 0;
   g_trailingStats.totalActivations++;
   NexusLog(LOG_INFO, g_symbols[symIdx], "Trailing baslatildi T:" + IntegerToString((int)ticket));
}

void UpdateTrailing(int symIdx) {
   if(!g_trailingStates[symIdx].isActive) return;
   ulong tkt = g_trailingStates[symIdx].ticket;
   if(tkt <= 0) return;
   if(!PositionSelectByTicket(tkt)) { g_trailingStates[symIdx].isActive=false; return; }
   string sym  = g_symbols[symIdx];
   bool   isBuy= (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
   double curP = isBuy?SymbolInfoDouble(sym,SYMBOL_BID):SymbolInfoDouble(sym,SYMBOL_ASK);
   double curPnL = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   g_trailingStates[symIdx].currentProfit = curPnL;
   if(curPnL > g_trailingStates[symIdx].peakProfit) g_trailingStates[symIdx].peakProfit = curPnL;
   double initP = g_trailingStates[symIdx].initialProfit;
   if(initP <= 0) return;
   double pct = (curPnL/initP)*100.0;
   double step = GetATRStep(symIdx);
   double curSL= g_trailingStates[symIdx].currentSL;

   auto tryApply = [&](double lockPct, int newLevel, bool& hit) {
      if(hit) return;
      double lkAmt  = curPnL*(lockPct/100.0);
      double newSL   = isBuy?curP-step:curP+step;
      if(isBuy&&newSL<=curSL) newSL=curSL+step*0.5;
      if(!isBuy&&newSL>=curSL&&curSL>0) newSL=curSL-step*0.5;
      int dig = g_marketData[symIdx].digits;
      newSL = NormalizeDouble(newSL, dig);
      if(UpdatePositionSL(symIdx, tkt, newSL)) {
         g_trailingStates[symIdx].currentSL    = newSL;
         g_trailingStates[symIdx].level        = newLevel;
         g_trailingStates[symIdx].lockedProfit = lkAmt;
         g_trailingStats.totalLockedProfit    += lkAmt;
         hit = true;
         NexusLog(LOG_INFO,sym,StringFormat("TRAIL L%d SL:%.5f Kilitli:$%.2f",newLevel,newSL,lkAmt));
      }
   };

   if(!g_trailingStates[symIdx].level4Hit && pct>=g_trailingProfiles[symIdx].level4TriggerPct) tryApply(75.0,TRAIL_LEVEL_4,g_trailingStates[symIdx].level4Hit);
   if(!g_trailingStates[symIdx].level3Hit && pct>=g_trailingProfiles[symIdx].level3TriggerPct) tryApply(50.0,TRAIL_LEVEL_3,g_trailingStates[symIdx].level3Hit);
   if(!g_trailingStates[symIdx].level2Hit && pct>=g_trailingProfiles[symIdx].level2TriggerPct) tryApply(25.0,TRAIL_LEVEL_2,g_trailingStates[symIdx].level2Hit);
   if(!g_trailingStates[symIdx].level1Hit && pct>=g_trailingProfiles[symIdx].level1TriggerPct) {
      double spread = GetCurrentSpread(sym)*SymbolInfoDouble(sym,SYMBOL_POINT);
      double beP    = isBuy?g_trailingStates[symIdx].openPrice+spread*1.2:g_trailingStates[symIdx].openPrice-spread*1.2;
      beP = NormalizeDouble(beP, g_marketData[symIdx].digits);
      if((isBuy&&curSL<beP)||(!isBuy&&(curSL>beP||curSL==0)))
         if(UpdatePositionSL(symIdx,tkt,beP)) {
            g_trailingStates[symIdx].currentSL  = beP;
            g_trailingStates[symIdx].level      = TRAIL_LEVEL_1;
            g_trailingStates[symIdx].level1Hit  = true;
            g_trailingStats.breakevenHits++;
            NexusLog(LOG_INFO,sym,"BREAKEVEN! SL:"+DoubleToString(beP,g_marketData[symIdx].digits));
         }
   }
   if(g_trailingStates[symIdx].level2Hit) {
      double newSL = isBuy?curP-step:curP+step;
      newSL = NormalizeDouble(newSL, g_marketData[symIdx].digits);
      if((isBuy&&newSL>curSL+step*0.1)||(!isBuy&&newSL<curSL-step*0.1&&curSL>0))
         if(UpdatePositionSL(symIdx,tkt,newSL)) g_trailingStates[symIdx].currentSL=newSL;
   }
   g_trailingStates[symIdx].updateCount++;
}

//+------------------------------------------------------------------+
//| CRASH RECOVERY                                                   |
//+------------------------------------------------------------------+
void SaveState() {
   int h = FileOpen("ANX_STATE.bin", FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(h == INVALID_HANDLE) return;
   for(int i=0; i<NEXUS_SYMBOLS_COUNT; i++) {
      FileWriteDouble(h,(double)g_packets[i].magicID);
      FileWriteDouble(h,g_packets[i].baseLot);
      FileWriteDouble(h,g_packets[i].buyTicket);
      FileWriteDouble(h,g_packets[i].sellTicket);
      FileWriteDouble(h,g_packets[i].boostTicket);
      FileWriteDouble(h,g_packets[i].recoveryTarget);
      FileWriteInteger(h,g_packets[i].boostState);
      FileWriteInteger(h,(int)g_packets[i].isRecovery);
      FileWriteInteger(h,(int)g_systemStates[i]);
      FileWriteDouble(h,(double)g_trailingStates[i].ticket);
      FileWriteInteger(h,(int)g_trailingStates[i].isActive);
      FileWriteDouble(h,g_trailingStates[i].currentSL);
      FileWriteDouble(h,g_trailingStates[i].initialProfit);
      FileWriteInteger(h,g_trailingStates[i].level);
      FileWriteInteger(h,(int)g_trailingStates[i].level1Hit);
      FileWriteInteger(h,(int)g_trailingStates[i].level2Hit);
      FileWriteInteger(h,(int)g_trailingStates[i].level3Hit);
      FileWriteInteger(h,(int)g_trailingStates[i].level4Hit);
   }
   FileWriteInteger(h,g_account.totalPackets);
   FileWriteInteger(h,g_account.successPackets);
   FileWriteInteger(h,g_account.failedPackets);
   FileWriteInteger(h,g_stats.boostX3Count);
   FileWriteInteger(h,g_stats.boostX9Count);
   FileWriteInteger(h,g_stats.boostX27Count);
   FileWriteInteger(h,g_stats.recoveryCount);
   FileClose(h);
}

void LoadState() {
   if(!FileIsExist("ANX_STATE.bin", FILE_COMMON)) return;
   int h = FileOpen("ANX_STATE.bin", FILE_READ|FILE_BIN|FILE_COMMON);
   if(h == INVALID_HANDLE) return;
   for(int i=0; i<NEXUS_SYMBOLS_COUNT; i++) {
      g_packets[i].magicID       = (ulong)FileReadDouble(h);
      g_packets[i].baseLot       = FileReadDouble(h);
      g_packets[i].buyTicket     = FileReadDouble(h);
      g_packets[i].sellTicket    = FileReadDouble(h);
      g_packets[i].boostTicket   = FileReadDouble(h);
      g_packets[i].recoveryTarget= FileReadDouble(h);
      g_packets[i].boostState    = FileReadInteger(h);
      g_packets[i].isRecovery    = (bool)FileReadInteger(h);
      int st = FileReadInteger(h);
      if(st>=0&&st<=(int)STATE_ERROR) g_systemStates[i]=(ENUM_SYSTEM_STATE)st;
      g_trailingStates[i].ticket      = (ulong)FileReadDouble(h);
      g_trailingStates[i].isActive    = (bool)FileReadInteger(h);
      g_trailingStates[i].currentSL   = FileReadDouble(h);
      g_trailingStates[i].initialProfit=FileReadDouble(h);
      g_trailingStates[i].level       = FileReadInteger(h);
      g_trailingStates[i].level1Hit   = (bool)FileReadInteger(h);
      g_trailingStates[i].level2Hit   = (bool)FileReadInteger(h);
      g_trailingStates[i].level3Hit   = (bool)FileReadInteger(h);
      g_trailingStates[i].level4Hit   = (bool)FileReadInteger(h);
   }
   g_account.totalPackets   = FileReadInteger(h);
   g_account.successPackets = FileReadInteger(h);
   g_account.failedPackets  = FileReadInteger(h);
   g_stats.boostX3Count     = FileReadInteger(h);
   g_stats.boostX9Count     = FileReadInteger(h);
   g_stats.boostX27Count    = FileReadInteger(h);
   g_stats.recoveryCount    = FileReadInteger(h);
   FileClose(h);
   NexusLog(LOG_INFO, "SYS", "Sistem durumu kurtarildi!");
}

//+------------------------------------------------------------------+
//| ULTRA NEON PANEL ÇİZİM MOTORU                                    |
//+------------------------------------------------------------------+
void DrawLabel(string name, string text, int x, int y, int sz, color clr,
               string font="Trebuchet MS", ENUM_ANCHOR_POINT anc=ANCHOR_LEFT_UPPER) {
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,sz);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anc);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
}

void DrawRect(string name, int x, int y, int w, int h, color bg, color border) {
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
}

string NeonBar(double val, double mx, int len, string fillCh="■", string emptyCh="-") {
   int fill=(int)MathRound((MathMax(0,MathMin(val,mx))/mx)*len);
   string b=""; for(int i=0;i<len;i++) b+=(i<fill)?fillCh:emptyCh;
   return b;
}

string GetSymShort(int s) {
   string n = g_symbols[s]; StringReplace(n,"#",""); StringReplace(n,"m","");
   if(StringFind(n,"XAU")>=0||StringFind(n,"GOLD")>=0) return "GOLD";
   if(StringFind(n,"XAG")>=0||StringFind(n,"SILVER")>=0) return "SILVER";
   if(StringFind(n,"BTC")>=0) return "BITCOIN";
   if(StringFind(n,"ETH")>=0) return "ETHEREUM";
   if(StringFind(n,"EURUSD")>=0) return "EURUSD";
   return StringSubstr(n,0,8);
}

color GetHealthColor(double h) {
   if(h>65) return C_NEON_GREEN; if(h>40) return C_NEON_GOLD; return C_NEON_RED;
}

string GetStateStr(int symIdx) {
   switch(g_systemStates[symIdx]) {
      case STATE_INIT:       return "INIT";
      case STATE_SCANNING:   return "SCAN";
      case STATE_PACKET_OPEN:return "AKTIF";
      case STATE_BOOST_X3:   return "BOOST-3";
      case STATE_BOOST_X9:   return "BOOST-9";
      case STATE_BOOST_X27:  return "BOOST-27";
      case STATE_RECOVERY:   return "RECOVERY";
      case STATE_PAUSED:     return "PAUSE";
      case STATE_ERROR:      return "ERROR";
   }
   return "?";
}

color GetStateColor(int symIdx) {
   switch(g_systemStates[symIdx]) {
      case STATE_PACKET_OPEN: return C_NEON_CYAN;
      case STATE_BOOST_X3:    return C_NEON_GOLD;
      case STATE_BOOST_X9:    return C_NEON_PINK;
      case STATE_BOOST_X27:   return C_NEON_RED;
      case STATE_RECOVERY:    return C_NEON_PURPLE;
      case STATE_SCANNING:    return C_NEON_BLUE;
   }
   return C_TEXT_MUTED;
}

string GetBoostStr(int symIdx) {
   int bs = g_packets[symIdx].boostState;
   if(bs==BOOST_X3_ACTIVE)  return "x3";
   if(bs==BOOST_X9_ACTIVE)  return "x9";
   if(bs==BOOST_X27_ACTIVE) return "x27";
   if(bs==BOOST_COMPLETED)  return "DONE";
   return "IDLE";
}

string GetTrailStr(int symIdx) {
   if(!g_trailingStates[symIdx].isActive) return "OFF";
   int lv = g_trailingStates[symIdx].level;
   if(lv==TRAIL_LEVEL_1) return "BE";
   if(lv==TRAIL_LEVEL_2) return "L2-25%";
   if(lv==TRAIL_LEVEL_3) return "L3-50%";
   if(lv==TRAIL_LEVEL_4) return "L4-75%";
   return "WAIT";
}

void DrawUltraPanel() {
   int W = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int H = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   string s;

   // === ZEMIN ===
   DrawRect(DASH_PREFIX+"BG", 0, 0, W, H, C_BG_BASE, C_BG_BASE);

   // === HEADER (Üst Şerit) ===
   DrawRect(DASH_PREFIX+"HDR", 0, 0, W, 70, C_BG_PANEL, C_NEON_CYAN);
   // Logo ve Başlık
   DrawLabel(DASH_PREFIX+"H_LOGO", "◈", 18, 12, 28, C_NEON_PURPLE, "Arial Black");
   DrawLabel(DASH_PREFIX+"H_TITLE","AsFaRaS NEXUS", 58, 12, 22, C_NEON_CYAN, "Arial Black");
   DrawLabel(DASH_PREFIX+"H_SLOGAN","TRADING SYSTEM  |  BEŞ SEMBOL · SONSUZ DÖNGÜ · SIFIR ZARAR", 58, 45, 8, C_TEXT_MUTED, "Consolas");
   // Sağ Bilgi
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double dd  = g_account.drawdown;
   DrawLabel(DASH_PREFIX+"H_VER",  "v" + NEXUS_VERSION, W-20, 8,  10, C_NEON_PURPLE, "Consolas", ANCHOR_RIGHT_UPPER);
   DrawLabel(DASH_PREFIX+"H_TIME", "⏱ " + TimeToString(TimeCurrent(), TIME_SECONDS), W-20, 28, 11, C_TEXT_MAIN, "Consolas", ANCHOR_RIGHT_UPPER);
   DrawLabel(DASH_PREFIX+"H_STAT", "[● LIVE]", W-20, 50, 10, C_NEON_GREEN, "Consolas", ANCHOR_RIGHT_UPPER);
   // Hesap Özeti (Ortada)
   DrawLabel(DASH_PREFIX+"H_BAL",  StringFormat("BAL: $%.2f", bal),  W/2-200, 15, 11, C_TEXT_MAIN, "Consolas");
   DrawLabel(DASH_PREFIX+"H_EQ",   StringFormat("EQ:  $%.2f", eq),   W/2-200, 35, 11, eq>=bal?C_NEON_GREEN:C_NEON_RED, "Consolas");
   DrawLabel(DASH_PREFIX+"H_DD",   StringFormat("DD:  %.2f%%", dd),  W/2-200, 55, 11, dd<5?C_NEON_GREEN:dd<10?C_NEON_GOLD:C_NEON_RED, "Consolas");

   // === 5 SEMBOL SUTUNLARI (Orta Alan) ===
   int colAreaH = H - 70 - 140; // Üst header + alt footer
   int colW     = (W - 20) / 5;
   for(int i=0; i<5; i++) {
      int cX  = 10 + i*colW;
      int cY  = 75;
      int cH  = colAreaH;
      int cIW = colW - 8;
      string si = IntegerToString(i);

      // Kart Arkaplanı
      DrawRect(DASH_PREFIX+"COL"+si, cX, cY, cIW, cH, C_BG_CARD, GetStateColor(i));

      // Sembol Adı
      DrawLabel(DASH_PREFIX+"CN"+si, GetSymShort(i), cX+cIW/2, cY+12, 15, C_TEXT_MAIN, "Arial Black", ANCHOR_TOP);

      // Ayraç
      DrawRect(DASH_PREFIX+"CSP"+si, cX+8, cY+38, cIW-16, 1, GetStateColor(i), GetStateColor(i));

      int yy = cY + 48;

      // Sağlık Skoru
      double hs = g_marketData[i].healthScore;
      DrawLabel(DASH_PREFIX+"CH1"+si, "HEALTH", cX+12, yy, 8, C_TEXT_MUTED, "Consolas"); yy+=14;
      DrawLabel(DASH_PREFIX+"CH2"+si, NeonBar(hs,100,14,"■","-"), cX+12, yy, 10, GetHealthColor(hs), "Consolas"); yy+=14;
      DrawLabel(DASH_PREFIX+"CH3"+si, StringFormat("%.0f / 100", hs), cX+12, yy, 10, GetHealthColor(hs), "Consolas"); yy+=24;

      // Paket P&L
      DrawLabel(DASH_PREFIX+"CP1"+si, "PACKET P&L", cX+12, yy, 8, C_TEXT_MUTED, "Consolas"); yy+=14;
      if(HasActivePacket(i)) {
         double pnl = GetPacketPnL(i);
         DrawLabel(DASH_PREFIX+"CP2"+si, StringFormat("%+.2f USD", pnl), cX+12, yy, 14,
                   pnl>=0?C_NEON_GREEN:C_NEON_RED, "Arial Black"); yy+=22;
         DrawLabel(DASH_PREFIX+"CP3"+si, StringFormat("VOL: %.2f", g_packets[i].baseLot), cX+12, yy, 9, C_TEXT_MAIN, "Consolas"); yy+=22;
      } else {
         DrawLabel(DASH_PREFIX+"CP4"+si, "SCANNING...", cX+12, yy, 11, C_NEON_BLUE, "Consolas"); yy+=44;
      }

      // Durum
      DrawLabel(DASH_PREFIX+"CST1"+si, "STATUS", cX+12, yy, 8, C_TEXT_MUTED, "Consolas"); yy+=14;
      DrawLabel(DASH_PREFIX+"CST2"+si, GetStateStr(i), cX+12, yy, 11, GetStateColor(i), "Consolas"); yy+=22;

      // Boost
      DrawLabel(DASH_PREFIX+"CBL"+si, "BOOST", cX+12, yy, 8, C_TEXT_MUTED, "Consolas"); yy+=14;
      string bstr = GetBoostStr(i);
      color  bclr = (bstr=="x27")?C_NEON_RED:(bstr=="x9")?C_NEON_PINK:(bstr=="x3")?C_NEON_GOLD:(bstr=="DONE")?C_NEON_GREEN:C_TEXT_MUTED;
      DrawLabel(DASH_PREFIX+"CBS"+si, bstr, cX+12, yy, 11, bclr, "Consolas"); yy+=22;

      // Trailing
      DrawLabel(DASH_PREFIX+"CTL"+si, "TRAIL", cX+12, yy, 8, C_TEXT_MUTED, "Consolas"); yy+=14;
      string tstr = GetTrailStr(i);
      color  tclr = (tstr=="OFF"||tstr=="WAIT")?C_TEXT_MUTED:C_NEON_GREEN;
      DrawLabel(DASH_PREFIX+"CTS"+si, tstr, cX+12, yy, 11, tclr, "Consolas");

      // Spread (Alt)
      DrawLabel(DASH_PREFIX+"CSR"+si,
                StringFormat("SPR: %.1f", g_marketData[i].spread),
                cX+12, cY+cH-20, 8, C_TEXT_MUTED, "Consolas");
   }

   // === ALT ALAN: Motivasyon + Terminal ===
   int bY  = H - 130;
   int bH  = 120;
   int hw  = W/2 - 15;

   // --- SOL ALT: MOTİVASYON KARTI ---
   DrawRect(DASH_PREFIX+"MOTBG", 10, bY, hw, bH, C_BG_PANEL, C_NEON_GOLD);
   DrawLabel(DASH_PREFIX+"MT0", "◆ GÜNÜN MOTİVASYONU", 28, bY+12, 9, C_NEON_GOLD, "Consolas");
   DrawRect(DASH_PREFIX+"MSEP", 10, bY+30, hw, 1, C_NEON_GOLD, C_NEON_GOLD);
   // Sözü 2 satıra böl
   string q = g_currentQuote;
   if(StringLen(q) <= 50) {
      DrawLabel(DASH_PREFIX+"MT1", "\" " + q + " \"", 24, bY+42, 11, C_TEXT_MAIN, "Trebuchet MS");
   } else {
      int sp = 48; while(sp>15 && StringGetCharacter(q,sp)!=' ') sp--;
      DrawLabel(DASH_PREFIX+"MT1", "\" " + StringSubstr(q,0,sp), 24, bY+40, 11, C_TEXT_MAIN, "Trebuchet MS");
      DrawLabel(DASH_PREFIX+"MT2", "  " + StringSubstr(q,sp+1) + " \"", 24, bY+58, 11, C_TEXT_MAIN, "Trebuchet MS");
   }
   DrawLabel(DASH_PREFIX+"MT3", "— AsFaRaS NEXUS —", hw-10, bY+bH-18, 9, C_NEON_GOLD, "Consolas", ANCHOR_RIGHT_UPPER);
   DrawLabel(DASH_PREFIX+"MT4", "Sonraki: " + QuoteCountdown(), 28, bY+bH-18, 8, C_TEXT_MUTED, "Consolas");

   // --- SAĞ ALT: SİSTEM TERMİNALİ ---
   int tX = W/2 + 5;
   DrawRect(DASH_PREFIX+"TMBG", tX, bY, hw, bH, C_BG_TERMINAL, C_NEON_CYAN);
   DrawLabel(DASH_PREFIX+"TH",  "[ SYSTEM TERMINAL ]", tX+15, bY+10, 9, C_NEON_CYAN, "Consolas");
   DrawRect(DASH_PREFIX+"TSEP", tX, bY+28, hw, 1, C_NEON_CYAN, C_NEON_CYAN);

   // Son 5 Logu Renklendir
   for(int l=0; l<5; l++) {
      if(g_terminalLogs[l] == "") continue;
      color lClr = C_NEON_GREEN; // Varsayılan INFO
      if(StringFind(g_terminalLogs[l],"ERR")>=0 || StringFind(g_terminalLogs[l],"!!!")>=0) lClr=C_NEON_RED;
      else if(StringFind(g_terminalLogs[l],"WRN")>=0) lClr=C_NEON_GOLD;
      else if(StringFind(g_terminalLogs[l],"SYS")>=0) lClr=C_NEON_CYAN;
      DrawLabel(DASH_PREFIX+"TL"+IntegerToString(l), g_terminalLogs[l],
                tX+12, bY+35+(l*17), 8, lClr, "Consolas");
   }
}

//+------------------------------------------------------------------+
//| MİNİ PANEL                                                       |
//+------------------------------------------------------------------+
void DrawMiniPanel() {
   int x=20, y=20, w=380, rH=26, hH=52;
   int h = hH + (5*rH) + 10;
   DrawRect(DASH_PREFIX+"MBG", x, y, w, h, C_BG_PANEL, C_NEON_CYAN);
   DrawRect(DASH_PREFIX+"MHDR",x, y, w, hH, C_BG_BASE, C_NEON_CYAN);
   DrawLabel(DASH_PREFIX+"MH1","◈ AsFaRaS NEXUS", x+12, y+8,  13, C_NEON_CYAN, "Arial Black");
   DrawLabel(DASH_PREFIX+"MH2","MINI DASHBOARD", x+12, y+32, 8, C_TEXT_MUTED, "Consolas");
   DrawLabel(DASH_PREFIX+"MHS","[●]", x+w-20, y+18, 12, C_NEON_GREEN, "Consolas", ANCHOR_RIGHT_UPPER);
   int cY = y+hH;
   for(int i=0; i<5; i++) {
      string si=IntegerToString(i);
      DrawRect(DASH_PREFIX+"MR"+si, x+5, cY, w-10, rH-2, i%2==0?C_BG_CARD:C_BG_BASE, C_BG_BASE);
      DrawLabel(DASH_PREFIX+"MS"+si, GetSymShort(i), x+14, cY+4, 10, C_TEXT_MAIN, "Consolas");
      double hs=g_marketData[i].healthScore;
      DrawLabel(DASH_PREFIX+"MH"+si, StringFormat("%.0f",hs), x+130, cY+4, 10, GetHealthColor(hs), "Consolas");
      DrawLabel(DASH_PREFIX+"MST"+si,GetStateStr(i), x+200, cY+4, 9, GetStateColor(i), "Consolas");
      double pnl=GetPacketPnL(i);
      DrawLabel(DASH_PREFIX+"MP"+si, HasActivePacket(i)?StringFormat("%+.2f$",pnl):"--",
                x+w-14, cY+4, 11, pnl>=0?C_NEON_GREEN:C_NEON_RED, "Consolas", ANCHOR_RIGHT_UPPER);
      cY+=rH;
   }
}

//+------------------------------------------------------------------+
//| SİSTEM DÖNGÜSÜ                                                   |
//+------------------------------------------------------------------+
bool IsNewM5(int symIdx) {
   datetime t = iTime(g_symbols[symIdx], PERIOD_M5, 0);
   if(t != g_lastM5Time[symIdx]) { g_lastM5Time[symIdx]=t; return true; }
   return false;
}

void UpdateAccount() {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   g_account.balance    = bal;
   g_account.equity     = eq;
   g_account.freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   g_account.drawdown   = (bal>0)?MathMax(0,(bal-eq)/bal*100.0):0;
   if(g_account.drawdown > g_stats.maxDrawdownReached) g_stats.maxDrawdownReached=g_account.drawdown;
}

void ProcessSymbol(int symIdx) {
   if(g_emergencyStop) return;
   string sym = g_symbols[symIdx];
   CalculateHealthScore(symIdx);

   ENUM_SYSTEM_STATE st = g_systemStates[symIdx];

   if(st == STATE_INIT) {
      if(OpenInitialPacket(symIdx)) g_systemStates[symIdx]=STATE_PACKET_OPEN;
      else g_systemStates[symIdx]=STATE_ERROR;
      return;
   }
   if(st == STATE_ERROR) {
      static datetime lr[]; if(ArraySize(lr)<5) ArrayResize(lr,5);
      if(TimeCurrent()-lr[symIdx]>300){lr[symIdx]=TimeCurrent();g_systemStates[symIdx]=STATE_SCANNING;}
      return;
   }
   if(st==STATE_PAUSED) {
      if(g_marketData[symIdx].healthScore>=InpMinHealthScore&&!g_systemPaused)
         g_systemStates[symIdx]=STATE_SCANNING;
      return;
   }
   if(st==STATE_SCANNING||st==STATE_RECOVERY) {
      if(!IsNewM5(symIdx)) return;
      MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
      if(dt.sec<VOLUME_CHECK_START||dt.sec>VOLUME_CHECK_END) return;
      if(g_marketData[symIdx].healthScore<InpMinHealthScore){g_systemStates[symIdx]=STATE_PAUSED;return;}
      if(!CheckLimits()||!CheckMargin(symIdx)) return;
      OpenNormalPacket(symIdx);
      return;
   }
   if(st==STATE_PACKET_OPEN||st==STATE_BOOST_X3||st==STATE_BOOST_X9||st==STATE_BOOST_X27) {
      CheckBoostTrigger(symIdx);
      CheckBoostConditions(symIdx);
      if(!HasActivePacket(symIdx)){g_systemStates[symIdx]=STATE_SCANNING;SaveState();}
      if(IsNewM5(symIdx)&&g_packets[symIdx].boostState==BOOST_NONE&&st==STATE_PACKET_OPEN)
         g_packets[symIdx].mumDevretCount++;
   }
   if(g_trailingStates[symIdx].isActive) UpdateTrailing(symIdx);
}

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit() {
   // Tüm logları temizle
   for(int i=0;i<5;i++) g_terminalLogs[i]="";

   NexusLog(LOG_INFO,"SYS","AsFaRaS NEXUS v"+NEXUS_VERSION+" Baslatiliyor...");

   if(!AutoDetectSymbols()) {
      Alert("KRITIK: Broker sembolleri bulunamadi!");
      return INIT_FAILED;
   }

   for(int i=0; i<NEXUS_SYMBOLS_COUNT; i++) {
      g_magicIDs[i] = GenerateMagicID(i);
      g_systemStates[i] = STATE_INIT;
      g_marketData[i].category = (int)GetCategory(g_symbols[i]);
      g_marketData[i].digits   = (int)SymbolInfoInteger(g_symbols[i],SYMBOL_DIGITS);
      g_marketData[i].pointValue = SymbolInfoDouble(g_symbols[i],SYMBOL_POINT);
      g_marketData[i].pipValue   = GetPipValue(g_symbols[i]);
      ZeroMemory(g_packets[i]);
      ZeroMemory(g_trailingStates[i]);
      g_packets[i].symbolIndex = i;
      g_packets[i].magicID     = g_magicIDs[i];
      g_packets[i].boostState  = BOOST_NONE;
      g_lastM5Time[i] = 0;
   }

   InitTrailingProfiles();
   ZeroMemory(g_trailingStats);
   ZeroMemory(g_stats);
   ZeroMemory(g_account);
   g_account.sessionStart = TimeCurrent();

   LoadState();
   UpdateQuote();

   // Chart Görünüm Ayarı
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   if(InpDashMode == DASH_FULL) {
      ChartSetInteger(0, CHART_SHOW_CANDLES, false);
      ChartSetInteger(0, CHART_SHOW_VOLUMES, false);
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, (long)C_BG_BASE);
   }

   g_isInitialized = true;
   g_lastHourlyReport = TimeCurrent();
   g_lastDailyReport  = TimeCurrent();
   EventSetTimer(1);

   NexusLog(LOG_INFO, "SYS", "Sistem basariyla aktive edildi!");
   SendTelegramMessage(
      "AsFaRaS NEXUS v" + NEXUS_VERSION + " BASLIYOR\n" +
      "\"Bes Sembol. Sonsuz Dongu. Sifir Zarar.\"\n" +
      TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   SaveState();
   ObjectsDeleteAll(0, DASH_PREFIX);
   ChartSetInteger(0, CHART_SHOW_CANDLES, true);
   ChartSetInteger(0, CHART_SHOW_VOLUMES, true);
   ChartRedraw(0);
   NexusLog(LOG_INFO, "SYS", "Sistem durduruldu.");
   SendTelegramMessage("AsFaRaS NEXUS DURDURULDU\n" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick() {
   if(!g_isInitialized || g_emergencyStop) return;

   UpdateAccount();

   if(g_account.drawdown >= InpMaxDrawdown) {
      NexusLog(LOG_CRITICAL,"SYS",StringFormat("EMERGENCY STOP! DD:%.2f%%",g_account.drawdown));
      g_emergencyStop = true;
      SendTelegramMessage("EMERGENCY STOP! Drawdown limiti asildi! Manuel kontrol gerekli!");
      return;
   }

   for(int i=0; i<NEXUS_SYMBOLS_COUNT; i++) ProcessSymbol(i);

   if(TimeCurrent() - g_lastDashUpdate >= 1) {
      g_lastDashUpdate = TimeCurrent();
      UpdateQuote();
      ObjectsDeleteAll(0, DASH_PREFIX);
      if(InpDashMode == DASH_FULL) DrawUltraPanel();
      else DrawMiniPanel();
      ChartRedraw(0);
   }

   static datetime lastSave = 0;
   if(TimeCurrent() - lastSave >= 30) { lastSave=TimeCurrent(); SaveState(); }
}

//+------------------------------------------------------------------+
//| ONTIMER                                                           |
//+------------------------------------------------------------------+
void OnTimer() {
   if(!g_isInitialized) return;
   SendHourlyReport();
   SendDailyReport();
}

//+------------------------------------------------------------------+
//| ONCHART EVENT (Pencere Boyut Değişimi)                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if(id == CHARTEVENT_CHART_CHANGE) {
      ObjectsDeleteAll(0, DASH_PREFIX);
      if(InpDashMode == DASH_FULL) DrawUltraPanel();
      else DrawMiniPanel();
      ChartRedraw(0);
   }
}

//+------------------------------------------------------------------+
//| ONTRADE                                                           |
//+------------------------------------------------------------------+
void OnTrade() {
   SaveState();
   UpdateAccount();
}
//+------------------------------------------------------------------+
//|          AsFaRaS NEXUS v1.5 - BEŞ SEMBOL. SONSUZ DÖNGÜ.         |
//|                      SIFIR ZARAR.                                 |
//|                   — AsFaRaS NEXUS —                              |
//+------------------------------------------------------------------+
