const double kHourH = 76.0;
const int kStart = 6;
const int kEnd = 24;
const int kTotal = kEnd - kStart;

String fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
