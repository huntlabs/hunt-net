import std.stdio;

import hunt.util.UnitTest;

import test.CompositeByteBufTest;
import test.DuplicatedByteBufTest;
import test.HttpUriTest;
import test.HeapByteBufTest;
import test.UnpooledTest;


void main()
{
	testUnits!(CompositeByteBufTest);
	// testUnits!(DuplicatedByteBufTest);
	// testUnits!(HeapByteBufTest);
	// testUnits!(HttpUriTest);
	// testUnits!(UnpooledTest);

}
