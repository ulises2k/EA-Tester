//+------------------------------------------------------------------+
//| Test adequacy of FXT file.
//| Documentation on the format can be found in terminal Help
//| (Client terminal - Auto Trading - Strategy Testing - History Files)
//+------------------------------------------------------------------+


#import "kernel32.dll"
   int CreateFileA(string Filename, int AccessMode, int ShareMode, int PassAsZero, int CreationMode, int FlagsAndAttributes, int AlsoPassAsZero);
   int CreateFileW(string Filename, int AccessMode, int ShareMode, int PassAsZero, int CreationMode, int FlagsAndAttributes, int AlsoPassAsZero);
   int ReadFile(int FileHandle, int BufferPtr, int BufferLength, int & BytesRead[], int PassAsZero);
   int WriteFile(int FileHandle, int BufferPtr, int BufferLength, int & BytesWritten[], int PassAsZero);
   int SetFilePointer(int FileHandle, int Distance, int PassAsZero, int FromPosition);
   int GetFileSize(int FileHandle, int PassAsZero);
   int CloseHandle(int FileHandle);

   bool DeleteFileA(string Filename);

   // See notes above for the explanation of the following...

   // Used for converting the address of a string into an integer.
   int MulDiv(string X, int N1, int N2);

   // Used for temporary conversion of an array into a block of memory, which
   // can then be passed as an integer to ReadFile.
   int LocalAlloc(int Flags, int Bytes);
   int RtlMoveMemory(int DestPtr, double & Array[], int Length);
   int LocalFree(int lMem);

   // Used for converting the address of an array to an integer.
   int GlobalLock(double & Array[]);
   bool GlobalUnlock(int hMem);
#import

#define GENERIC_READ          0x80000000
#define GENERIC_WRITE         0x40000000
#define FILE_SHARE_DELETE     0x00000004
#define CREATE_NEW            1
#define CREATE_ALWAYS         2
#define OPEN_EXISTING         3
#define OPEN_ALWAYS           4

#define OF_READ               0
#define OF_WRITE              1
#define OF_READWRITE          2
#define OF_SHARE_COMPAT       3
#define OF_SHARE_DENY_NONE    4
#define OF_SHARE_DENY_READ    5
#define OF_SHARE_DENY_WRITE   6
#define OF_SHARE_EXCLUSIVE    7


//---- Imports.
#property show_inputs

//---- Header version.
#define FXT_VERSION 405
//---- Profit calculation mode.
#define PROFIT_CALC_FOREX 0 // Default.
#define PROFIT_CALC_CFD 1
#define PROFIT_CALC_FUTURES 2
//---- Type of swap.
#define SWAP_BY_POINTS 0 // Default.
#define SWAP_BY_BASECURRENCY 1
#define SWAP_BY_INTEREST 2
#define SWAP_BY_MARGINCURRENCY 3
//---- Free margin calculation mode.
#define MARGIN_DONT_USE 0
#define MARGIN_USE_ALL 1 // Default.
#define MARGIN_USE_PROFIT 2
#define MARGIN_USE_LOSS 3
//---- Margin calculation mode.
#define MARGIN_CALC_FOREX 0 // Default.
#define MARGIN_CALC_CFD 1
#define MARGIN_CALC_FUTURES 2
#define MARGIN_CALC_CFDINDEX 3
//---- Basic commission type.
#define COMM_TYPE_MONEY 0
#define COMM_TYPE_PIPS 1
#define COMM_TYPE_PERCENT 2
//---- Commission per lot or per deal.
#define COMMISSION_PER_LOT 0
#define COMMISSION_PER_DEAL 1

//---- FXT file header
struct TestHistoryHeader
{
    int               version;            // Header version: 405
    char              copyright[64];      // Copyright/description.
    char              description[128];   // Account server name.
    // 196
    char              symbol[12];         // Symbol pair.
    int               period;             // Period of data aggregation in minutes (timeframe).
    int               model;              // Model type: 0 - every tick, 1 - control points, 2 - bar open.
    int               bars;               // Bars - number of modeled bars in history.
    int               fromdate;           // Modelling start date - date of the first tick.
    int               todate;             // Modelling end date - date of the last tick.
    int               totalTicks;         // Total ticks. Add 4 bytes to align to the next double?
    double            modelquality;       // Modeling quality (max. 99.9).
    // 240
    //---- Market symbol properties.
    char              currency[12];       // Base currency (12 bytes). Same as: StringLeft(symbol, 3)
    int               spread;             // Spread in points. Same as: MarketInfo(MODE_SPREAD)
    int               digits;             // Digits (default: 5). Same as: MarketInfo(MODE_DIGITS)
    int               padding1;           // Padding space - add 4 bytes to align to the next double.
    double            point;              // Point size (e.g. 0.0000'1). Same as: MarketInfo(MODE_POINT)
    int               lot_min;            // Minimal lot size in centi lots (hundredths). Same as: MarketInfo(MODE_MINLOT)*100
    int               lot_max;            // Maximal lot size in centi lots (hundredths). Same as: MarketInfo(MODE_MAXLOT) *100
    int               lot_step;           // Lot step in centi lots (hundredths). Same as: MarketInfo(MODE_LOTSTEP)*100
    int               stops_level;        // Stops level value (orders stop distance in points). Same as: MarketInfo(MODE_STOPLEVEL)
    int               gtc_pendings;       // GTC (Good till cancel) - instruction to close pending orders at end of day (default: False).
    int               padding2;           // Padding space - add 4 bytes to align to the next double.
    // 296
    //---- Profit calculation parameters.
    double            contract_size;      // Contract size (e.g. 100000). Same as: MarketInfo(MODE_LOTSIZE)
    double            tick_value;         // Tick value in quote currency (empty). Same as: MarketInfo(MODE_TICKVALUE)
    double            tick_size;          // Size of one tick (empty). Same as: MarketInfo(MODE_TICKSIZE)
    int               profit_mode;        // Profit calculation mode { PROFIT_CALC_FOREX=0, PROFIT_CALC_CFD=1, PROFIT_CALC_FUTURES=2 }. Same as: MarketInfo(MODE_PROFITCALCMODE)
    // 324
    //---- Swap calculation.
    int               swap_enable;        // Enable swaps (default: True).
    int               swap_type;          // Type of swap { SWAP_BY_POINTS=0, SWAP_BY_BASECURRENCY=1, SWAP_BY_INTEREST=2, SWAP_BY_MARGINCURRENCY=3 }. Same as: MarketInfo(MODE_SWAPTYPE)
    int               padding3;           // Padding space - add 4 bytes to align to the next double.
    double            swap_long;          // Swap of the buy order - long overnight swap value. Same as: MarketInfo(MODE_SWAPLONG)
    double            swap_short;         // Swap of the sell order - short overnight swap value. Same as: MarketInfo(MODE_SWAPSHORT)
    int               swap_rollover3days; // Day of week to charge 3 days swap rollover. Default: WEDNESDAY (3). Same as: MarketInfo(SYMBOL_SWAP_ROLLOVER3DAYS)
    // 356
    //---- Margin calculation.
    int               leverage;           // Account leverage (default: 100). Same as: AccountLeverage()
    int               free_margin_mode;   // Free margin calculation mode { MARGIN_DONT_USE=0, MARGIN_USE_ALL=1, MARGIN_USE_PROFIT=2, MARGIN_USE_LOSS=3 }. Same as: AccountFreeMarginMode()
    int               margin_mode;        // Margin calculation mode { MARGIN_CALC_FOREX=0, MARGIN_CALC_CFD=1, MARGIN_CALC_FUTURES=2, MARGIN_CALC_CFDINDEX=3 }. Same as: MarketInfo(MODE_MARGINCALCMODE)
    int               margin_stopout;     // Margin Stop Out level (default: 30). Same as: AccountStopoutLevel()

    int               margin_stopout_mode;// Check mode for Stop Out level { MARGIN_TYPE_PERCENT=0, MARGIN_TYPE_CURRENCY=1 }. Same as: AccountStopoutMode()
    double            margin_initial;     // Initial margin requirement (in units). Same as: MarketInfo(MODE_MARGININIT)
    double            margin_maintenance; // Maintenance margin requirement (in units). Same as: MarketInfo(MODE_MARGINMAINTENANCE)
    double            margin_hedged;      // Hedged margin requirement for positions (in units). Same as: MarketInfo(MODE_MARGINHEDGED)
    double            margin_divider;     // Margin divider used for leverage calculation.
    char              margin_currency[12];// Margin currency. Same as: AccountCurrency().
    int               padding4;           // Padding space - add 4 bytes to align to the next double.
    // 424
    //---- Commission calculation.
    double            comm_base;          // Basic commission rate.
    int               comm_type;          // Basic commission type          { COMM_TYPE_MONEY=0, COMM_TYPE_PIPS=1, COMM_TYPE_PERCENT=2 }.
    int               comm_lots;          // Commission per lot or per deal { COMMISSION_PER_LOT=0, COMMISSION_PER_DEAL=1 }
    // 440
    //---- For internal use.
    int               from_bar;           // Index of the first bar at which modeling started (0 for the first bar).
    int               to_bar;             // Index of the last bar at which modeling started (0 for the last bar).
    int               start_period_m1;    // Bar index where modeling started using M1 bars (0 for the first bar).
    int               start_period_m5;    // Bar index where modeling started using M5 bars (0 for the first bar).
    int               start_period_m15;   // Bar index where modeling started using M15 bars (0 for the first bar).
    int               start_period_m30;   // Bar index where modeling started using M30 bars (0 for the first bar).
    int               start_period_h1;    // Bar index where modeling started using H1 bars (0 for the first bar).
    int               start_period_h4;    // Bar index where modeling started using H4 bars (0 for the first bar).
    int               set_from;           // Begin date from tester settings (must be zero).
    int               set_to;             // End date from tester settings (must be zero).
    // 480
    //----
    int               freeze_level;       // Order freeze level in points. Same as: MarketInfo(MODE_FREEZELEVEL)
    int               generating_errors;  // Number of errors during model generation which needs to be fixed before testing.
    // 488
    //----
    int               reserved[60];       // Reserved - space for future use.
};

struct TestHistory
{
    datetime          otm;                // Bar datetime.
    double            open;               // OHLCV values.
    double            high;
    double            low;
    double            close;
    long              volume;
    int               ctm;                // The current time within a bar.
    int               flag;               // Flag to launch an expert (0 - bar will be modified, but the expert will not be launched).
};


datetime ExtLastBarTime;
string path;
int ExtBars, fileHandle;

//+------------------------------------------------------------------+
//| Read and check FXT header.
//+------------------------------------------------------------------+
bool ReadAndCheckHeader(int handle, int period, int& bars) {
  int    ivalue;
  double dvalue;
  string svalue;
  //----
  GetLastError();

  // FileFlush(handle);

  if (!FileSeek(handle, 0, SEEK_SET)) { // or: SetFilePointer?
    PrintFormat("Failed to seek on file handle (%d), Error code = %d", handle, GetLastError());
    return (FALSE);
  }
  //----
  int FILE_FXT_VERSION = FileReadInteger(handle, LONG_VALUE);
  if (FILE_FXT_VERSION != FXT_VERSION) {
    PrintFormat("Error: FXT Version (%i != %i) FILE FXT Version.", FXT_VERSION, FILE_FXT_VERSION);
    return(false);
  }
  FileSeek(handle, 64, SEEK_CUR);
  if (FileReadString(handle, 12) != Symbol()) { Print("Error: Wrong Symbol."); return(false); }
  if (FileReadInteger(handle, LONG_VALUE) != period) { Print("Error: Wrong period."); return(false); }
  //---- Every tick model.
  if (FileReadInteger(handle, LONG_VALUE) != 0) { Print("Error: Wrong tick model."); return(false); }
  //---- Bars.
  ivalue = FileReadInteger(handle, LONG_VALUE);
  if (ivalue <= 0) { Print("Error: Wrong numbers of bars."); return(false); }
  bars = ivalue;
  //---- Model quality.
  FileSeek(handle, 12, SEEK_CUR);
  dvalue = FileReadDouble(handle, DOUBLE_VALUE);
  if (dvalue < 0.0 || dvalue > 100.0) { Print("Error: Wrong number model quality."); return(false); }
  //---- Currency.
  svalue = FileReadString(handle, 12);
  if (svalue != StringSubstr(Symbol(), 0, 3)) { Print("Error: Wrong currency."); return(false); }
  //---- Spread digits and point.
  if (FileReadInteger(handle, LONG_VALUE) < 0) { Print("Error: Wrong spread."); return(false); }
  if (FileReadInteger(handle, LONG_VALUE) != Digits) { Print("Error: Wrong spread."); return(false); }
  FileSeek(handle, 4, SEEK_CUR);
  if (FileReadDouble(handle, DOUBLE_VALUE) != Point) { Print("Error: Wrong spread."); return(false); }
  //---- Lot min.
  if (FileReadInteger(handle, LONG_VALUE) < 0) { Print("Error: Wrong lot min."); return(false); }
  //---- Lot max.
  if (FileReadInteger(handle, LONG_VALUE) < 0) { Print("Error: Wrong lot max."); return(false); }
  //---- Lot step.
  if (FileReadInteger(handle, LONG_VALUE) <0 ) { Print("Error: Wrong lot step."); return(false); }
  //---- Stops level.
  if (FileReadInteger(handle, LONG_VALUE) < 0) { Print("Error: Wrong stops level."); return(false); }
  //---- Contract size.
  FileSeek(handle, 8, SEEK_CUR);
  if (FileReadDouble(handle, DOUBLE_VALUE) < 0.0) { Print("Error: Wrong contract size."); return(false); }
  //---- Profit mode.
  FileSeek(handle, 16, SEEK_CUR);
  ivalue = FileReadInteger(handle, LONG_VALUE);
  if (ivalue < 0 || ivalue > PROFIT_CALC_FUTURES) { Print("Error: Wrong profit mode."); return(false); }
  //---- Triple rollovers.
  FileSeek(handle, 28, SEEK_CUR);
  ivalue = FileReadInteger(handle, LONG_VALUE);
  if (ivalue < 0 || ivalue > 6) { Print("Error: Wrong triple rollovers."); return(false); }
  //---- Leverage.
  ivalue = FileReadInteger(handle, LONG_VALUE);
  if (ivalue <= 0 || ivalue > 500) { Print("Error: Wrong leverage."); return(false); }
  //---- Unexpected end of file.
  if (GetLastError() == 4099) { Print("Error: Unexpected end of file."); return(false); }
  //---- Check for stored bars.
  if (FileSize(handle) < (ulong) (600 + bars * 52)) { Print("Wrong stored bars."); return(false); }
  //----
  return (true);
}

//+------------------------------------------------------------------+
//| Read and check FXT header.
//+------------------------------------------------------------------+
/*
void ReadSpread(int handle) {
    int buffer[2];
    int adjustCursor1 = _llseek(handle, 0xfc, 0); // 16
    int ret_read1 = _lread(handle, buffer, 8);
    Print("spread = ", buffer[0]);
    Print("digits = ", buffer[1]);
}*/

void CheckWrittenBars() {
   int bars_count=0;
//----
   ExtLastBarTime=0;
   FileSeek(fileHandle, 600, SEEK_SET);
//----
   while(!IsStopped()) {
      datetime open_time=FileReadInteger(fileHandle, LONG_VALUE);
      if(FileIsEnding(fileHandle)) break;
      //---- check for bar changing
      if(ExtLastBarTime!=open_time)
        {
         ExtLastBarTime=open_time;
         bars_count++;
        }
      //---- set position to next bar
      FileSeek(fileHandle, 48, SEEK_CUR);
     }
//----
   if(ExtBars != bars_count)
     {
      Print("Wrong bars count ",ExtBars," in the FXT-header. Should be ",bars_count);
      ExtBars=bars_count;
     }
//----
  }

int OnInit () {

  if (IsDllsAllowed() == FALSE) {
    Print("DLL call is not allowed. Experts cannot run.");
    return(INIT_FAILED);
  }

  ExtBars = 0;
  ExtLastBarTime = 0;
  path = TerminalPath() + "\\tester\\history\\" + Symbol() + Period() + "_0.fxt";

  int ShareMode = 0;
  ShareMode += FILE_SHARE_READ;

  Print("File Path = ", path);
  fileHandle = CreateFileW(path, GENERIC_READ, ShareMode, 0, OPEN_EXISTING, 0, 0);

  if (fileHandle == -1) {
    Print("Invalid file handle");
    return(INIT_FAILED);
  }

  if (ReadAndCheckHeader(fileHandle, Period(), ExtBars)) {
    CloseHandle(fileHandle);
    //_lclose(fileHandle);
    Print("Success: FXT header is correct!");
    return(INIT_SUCCEEDED);
  }
  else {
    CloseHandle(fileHandle);
    //_lclose(fileHandle);
    //ExpertRemove();
    Print("Error: Invalid FXT format.");
    return(INIT_FAILED);
  }

}
