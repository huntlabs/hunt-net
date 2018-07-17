module hunt.net.Result;

///
class Result(T)
{
    ///
    Throwable _thr;
    ///
    T         _value;
    ///
    bool      _failed;
    ///
    ///
    Throwable cause() { return _thr;}
    ///
    bool      failed() { return _failed; }
    ///
    T         result() { return _value;}
    ///
    bool      succeeded() { return !failed(); }
    ///failed
    this(Throwable thr)
    {
       _thr = thr;
       _failed = true;
    }
    ///succeded
    this(T value)
    {
        _value = value;
    }

}