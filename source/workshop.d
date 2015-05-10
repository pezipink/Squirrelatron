import std.algorithm;

class ObjectPool(T, alias initializer, int initialSize) {

	T[] items;

	this(){
		items.size = initialSize;
	}

}


// workshop, cos no one likes a factory
class ElfWorkshop(T, alias creator) 
	if(new T() !is null ) 
{
	// dynamic array will do for now, this design needs changing so the 
	// workshop keeps track of all objects and which ones are dead / alive
	// using a free list w/union based linked list to conserve memory
	private T[] pool;
	this(int initialPool)
	{
		for(int i =0; i < initialPool; i++)
			pool ~= creator();	
	}

public:

	T Get() {
		if(pool.length > 0 ){
			auto x = pool[0];
			pool = pool[1..$];
			return x;
		}
		return creator();
	}
	
	T[] Get(int n) 
	{
		if(pool.length >= n ){
			auto x = pool[0..n];
			pool = pool[n..$];
			return x;
		}
		else{
			auto x = pool;
			while(x.length < n)
				x ~= creator();
			pool = [];
			return x;
		}
	}	

	void Put(T item) {
		pool ~= item;
	}

	void Put(T[] item) {
		pool ~= item;
	}

	T[] Recycle(T[] candidates, bool delegate(T) pred) {
		auto remainder = candidates.partition!(pred);
		if(remainder.length == candidates.length)
			return candidates;
		pool ~= candidates[0..candidates.length-remainder.length];
		return remainder;
	}
}

//unittest {
//	class Test{
//		int x;
//		string y;
//		this(int x,string y){Test.x=x;Test.y=y;}
//	}
//	string s = "test";
//	auto w = new ElfWorkshop!(Test,()=>new Test(1,s))(10);
//	auto x = w.Get();
//	assert(x.y=="test");
//	assert(w.pool.length==9);
//	auto y = w.Get(5);
//	assert(w.pool.length==4);
//	assert(y.length == 5);
//	auto z = w.Get(6);
//	assert(w.pool.length==0);
//	assert(z.length == 6);
//	w.Put(z);
//	assert(z.length == 6);
//	assert(w.pool.length==6);
//	w.Put(x);
//	w.Put(y);
//	assert(w.pool.length==12);
//}

//unittest {
//	auto w = new ElfWorkshop!(int,()=>10)(10);
//	auto x = w.Get(5);
//	assert(x.length==5);
//	x[0] = 1;
//	x[4] = 1;
//	auto r = w.Recycle(x,x=>x<10);
//	assert(r.length==3);
//	assert(w.Recycle([],x=>true)==[]);
//}	