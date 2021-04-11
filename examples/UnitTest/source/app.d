import std.stdio;

import hunt.util.UnitTest;

import test.CompositeByteBufTest;
import test.DuplicatedByteBufTest;
import test.URLEncodedTest;
import test.HttpUriTest;
import test.HeapByteBufTest;
import test.ObjectPoolTest;
import test.UnpooledTest;


void main()
{
	// testUnits!(CompositeByteBufTest);
	// testUnits!(DuplicatedByteBufTest);
	// testUnits!(HeapByteBufTest);
	// testUnits!(HttpUriTest);
	// testUnits!(URLEncodedTest);
	testUnits!(ObjectPoolTest);
	// testUnits!(UnpooledTest);

}
