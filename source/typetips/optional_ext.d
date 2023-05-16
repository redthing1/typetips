module typetips.optional_ext;

import std.exception : enforce, assertThrown;
public import optional;

bool any(T)(Optional!T thing) {
    return !thing.empty;
}

@("optional-any")
unittest {
    auto b1 = some(true);
    auto b2 = no!bool;

    assert(b1.any);
    assert(!b2.any);
}

T get(T)(Optional!T thing) {
    enforce(thing.any, "cannot get from empty optional");
    return thing.front;
}

@("optional-get")
unittest {
    auto b1 = some(true);
    auto b2 = no!bool;

    assert(b1.get);
    assertThrown(b2.get);
}
