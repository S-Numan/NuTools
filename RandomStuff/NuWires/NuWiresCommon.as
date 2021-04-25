#include "NumanLib.as";

class WireSystem
{
    WireSystem()
    {
        vars_init = true;
        signal_blobs = array<CBlob@>();
        signals = Nu::IntKeyDictionary();
    }
    bool vars_init = false;


    array<CBlob@> signal_blobs;//Blobs that send signals to the wire system

    Nu::IntKeyDictionary signals;//Each key refers to a signal. Try hashing if you want a key to be a string.

    void TallySignals()
    {
        if(!vars_init) { Nu::Error("Init you haven't initialized the WireSystem class"); return; }
        //signals = array<s32>(65535, 0);

        //signals =
    }

}