import std.stdio;

import typetips;

void main() {
	auto b1 = some(true);
	auto b2 = no!bool;

	assert(b1.any);
	assert(!b2.any);
}
