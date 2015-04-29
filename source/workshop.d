// workshop, cos no one likes a factory
class Workshop(T, alias creator)
{
	// not sure how effecient this is
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
}

unittest {
	class Test{
		int x;
		string y;
		this(int x,string y){Test.x=x;Test.y=y;}
	}
	string s = "test";
	auto w = new Workshop!(Test,()=>new Test(1,s))(10);
	auto x = w.Get();
	assert(x.y=="test");
	assert(w.pool.length==9);
	auto y = w.Get(5);
	assert(w.pool.length==4);
	assert(y.length == 5);
	auto z = w.Get(6);
	assert(w.pool.length==0);
	assert(z.length == 6);
	w.Put(z);
	assert(z.length == 6);
	assert(w.pool.length==6);
	w.Put(x);
	w.Put(y);
	assert(w.pool.length==12);
	
}