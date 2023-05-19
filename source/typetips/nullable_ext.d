module typetips.nullable_ext;

public import std.typecons: Nullable;

pragma(inline, true) {
	Nullable!T no(T)() {
		return Nullable!T.init;
	}

	bool has(T)(Nullable!T value) {
		return !value.isNull;
	}

	Nullable!T some(T)(T value) {
		return Nullable!T(value);
	}
}

@("nullable-1") unittest {
    auto a1 = no!int;
    auto a2 = some(4);
    assert(!a1.has);
}
