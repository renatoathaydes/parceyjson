import com.athaydes.parcey {
    anyCharacter,
    ParseResult
}
"Run the module `test.com.athaydes.jsonparsey`."
shared void run() {
    value chars = [for (i in 1..100k) (i % 500).character];
    
    value parser = anyCharacter();
    
    value start = system.milliseconds;
    value results = [ for (c in chars)
        parser.parse(c.string)
    ];
    value time = system.milliseconds - start;
    print("Got ``results.size`` in ``time`` ms");
    
    assert(results.every((r) => r is ParseResult<Anything>));
}