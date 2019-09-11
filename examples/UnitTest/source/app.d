import std.stdio;

import hunt.util.UnitTest;

import test.UnpooledTest;
import test.DuplicatedByteBufTest;


void main()
{
	testUnits!(DuplicatedByteBufTest);
	// testUnits!(UnpooledTest);
}
