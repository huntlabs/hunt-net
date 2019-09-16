import std.stdio;

import hunt.util.UnitTest;

import test.DuplicatedByteBufTest;
import test.HttpUriTest;
import test.UnpooledTest;


void main()
{
	// testUnits!(DuplicatedByteBufTest);
	testUnits!(HttpUriTest);
	// testUnits!(UnpooledTest);
}
