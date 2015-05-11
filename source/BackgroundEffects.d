import derelict.sdl2.sdl;
import std.random;
import std.math;
import std.random;
import std.typecons;
import Vector2D;
import GameObjects;
import Interfaces;
import InputHandler;

class Tunnel {

	static immutable int texWidth = 512;
	static immutable int texHeight = 512;
	static immutable int screenWidth = 640;
	static immutable int screenHeight = 480;

	SDL_Color[texHeight][texWidth] texture;
	int[2*screenHeight][2*screenWidth] distanceTable;
	int[2*screenHeight][2*screenWidth] angleTable;

	RawPlasma _plasma;
//	SDL_Surface* _texSurf;
	void texset(int x, int y, const SDL_Color color)
	{
		
		//std.stdio.writeln(x, " ", y);
		texture[x][y] = color;
		
	}

	void delegate (int x, int y, const SDL_Color color) _pset ;
	this(void delegate (int x, int y, const SDL_Color color) pset)	{
		_pset=pset;
		 import derelict.sdl2.image;
		for(int x = 0; x < texWidth; x++)
		for(int y = 0; y < texHeight; y++)
		{
			auto c = cast(ubyte)(x ^ y);
			texture[x][y] = SDL_Color(c/4,c/8,0,0);
		}
		//_plasma = new RawPlasma( &texset );		
		for(int x = 0; x < screenWidth  * 2; x++)
	    for(int y = 0; y < screenHeight * 2; y++)
	    {
	        int angle, distance;
	        float ratio = 32.0;
	        distance = cast(int)(ratio * texHeight / sqrt(cast(real)((x - screenWidth) * (x - screenWidth)) + cast(real)((y - screenHeight) * (y - screenHeight)))) % texHeight;
	        angle = cast(uint)(0.5 * texWidth * atan2(cast(real)(y - screenHeight),cast(real)(x - screenWidth) ) / 3.1416);
	        distanceTable[x][y] = distance;
	        angleTable[x][y] = angle;
	    }
	}

	void Draw(){
		//_plasma.Draw();
        //i.SetInvaderIndex(uniform(0,max_invaders));
		//_plasma.Update();
		auto animation = SDL_GetTicks() / 1000.0;
        int shiftX = cast(int)(texWidth * 1.0 * animation);
        int shiftY = cast(int)(texHeight * 0.25 * animation);        
        int shiftLookX = screenWidth / 2 + cast(int)(screenWidth / 2 * sin(animation));
        int shiftLookY = screenHeight / 2 + cast(int)(screenHeight / 2 * sin(animation * 2.0));
        for(int x = 0; x < screenWidth; x++)
        for(int y = 0; y < screenHeight; y++)
        {
            //get the texel from the texture by using the tables, shifted with the animation values
            auto  color = texture[cast(uint)(distanceTable[x+shiftLookX][y+shiftLookY] + shiftX)  % texWidth][cast(uint)(angleTable[x+shiftLookX][y+shiftLookY] + shiftY) % texHeight];
            _pset(x,y,color);
            
        }
	}
}

class RawPlasma {
	double f1_v = 8.0;
	double f2_v = 8.0;
	double f2_w = 1.0;
	double f3_v = 8.0;
	int[480][640] _colourMap;
	SDL_Color[256] _colourIndex;
	uint t = 1;
	void delegate (int x, int y, const SDL_Color color) _pset ;
	this(void delegate (int x, int y, const SDL_Color color) pset)	{
		_pset = pset;
		for(int i=0;i<256;i++) {
			 _colourIndex[i].r =  cast(ubyte)abs(sin(PI * i / 32)*200);
			 _colourIndex[i].g  = cast(ubyte)abs(sin(PI * i / 64)*200);
			 _colourIndex[i].b  = cast(ubyte)abs(sin(PI * i / 128)*200);
			//std.stdio.writeln(_colourIndex[i].r,_colourIndex[i].g,_colourIndex[i].b);
		}

	}

	int F1(int x, int y) {
		return cast(int)(128.0 + (128.0 * sin(x / f1_v)));
	}

	int F2(int x, int y) {
		return cast(int)(128.0 + (128.0 * sin( (x + (y * f2_w)) / f2_v)));
	}

	int F3(int x, int y) {

		//return cast(int)(128.0 + (128.0 * sin(sqrt((x - 640.0 / 2.0) * (x - 640.0 / 2.0) + (y - 480.0 / 2.0) * (y - 480.0 / 2.0)) / 8.0)));

		auto xa = cast(float)(x - mousex) * (x - mousex);
		auto ya = cast(float)(y - mousey) * (y - mousey);

		return cast(int)(128.0 + (128.0 * sin(sqrt((xa + ya))/f3_v)));
	}

	void Draw(){
		auto shift = cast(int) (SDL_GetTicks() / 10.0);
		for(int x = 0; x < 640; x++)
    	for(int y = 0; y < 480; y++)
    	{
    	    //auto color = F1(x,y);
    	    //auto color = F2(x,y);
    	    //auto color = F3(x,y);
    	    auto color =  cast(ubyte)(F1(x,y) + F2(x,y) + F3(x,y) / 3);
    	    auto index = ((color + shift) % 256); 
    	    //auto index = (color ) ; 
    	    _pset(x, y, _colourIndex[index]);
    	}
    	
	}

	void Update(){
		if( Direction.TurretRight.testDirection){
			f1_v+=0.2;
		}
		else if( Direction.TurretLeft.testDirection){
			f1_v-=0.2;
		}

if( Direction.TurretUp.testDirection){
			f3_v+=0.2;
		}
		else if( Direction.TurretDown.testDirection){
			f3_v-=0.2;
		}

		if( Direction.BaseRight.testDirection){
			f2_v+=0.2;
		}
		else if( Direction.BaseLeft.testDirection){
			f2_v-=0.2;
		}

		if( Direction.BaseUp.testDirection){
			f2_w+=0.2;
		}
		else if( Direction.BaseDown.testDirection){
			f2_w-=0.2;
		}
	}
}

class Plasma : IGameEntity{

	private {
		static immutable int _cellSize = 1;
		static immutable int _pwidth = 640 / _cellSize;  // 80
		static immutable int _pheight = 480 / _cellSize; // 40
		int[_pheight][_pwidth] _colourMap;	double  _t = 1.0;
		int _lastFrame;
		rgb[256] _colourIndex;
		double _plasmaX = _pwidth/2;
		double _plasmaY =_pheight/2;

		struct rgb {
			double r,g,b;
		}
		enum renderType {
			Partial = 0,
			Filled = 1
		}
		//green(i) = cos(π * i / 128)
//blue(i) = sin(π * i / 128)
//red(i) = cos(π * i / 128)
	}

	this()
	{
		_lastFrame = SDL_GetTicks();
		for(int i=0;i<256;i++) {
			 _colourIndex[i].r = abs(sin(PI * i / 32)*200)/2;
			 _colourIndex[i].g  = abs(sin(PI * i / 64)*200)/2;
			 _colourIndex[i].b  = abs(sin(PI * i / 128)*200)/2;
			//std.stdio.writeln(_colourIndex[i].r,_colourIndex[i].g,_colourIndex[i].b);
		}

		//_colourMap[59][79] = 255;
	}

	void Update() 
	{
		//f(x, y, t) = sin(distance(x, y, (128 * sin(-t) + 128), (128 * cos(-t) + 128)) / 40.74) - which gives the effect of the second pattern rotating around the center of the canvas.

		//if(testDirection(Direction.BaseRight)){
		//	_plasmaX=MAX(_plasmaX-0.5, 0.1);
		//}

		//if(testDirection(Direction.BaseLeft)){
		//	_plasmaX=MIN(_plasmaX+0.5, 600.0);
		//}
		if((SDL_GetTicks() - _lastFrame > 100)){
			 _t+=0.1;
//			 std.stdio.writeln(_t);
			 //if(_t==100.0) {_t=0.1; std.stdio.writeln("!");}
			_lastFrame =SDL_GetTicks();
		}

		double f1(int x ) { return sin( x / 40.74 + _t ) * 256; }
		double f2(int x, int y) {
			float xt = _plasmaX * sin(-_t) + _plasmaX;
			float yt = _plasmaY * cos(-_t) + _plasmaY;
			float x2 = (xt-x)*(xt-x);
			float y2 = (yt-y)*(yt-y);
			float k = sqrt(cast(float)(x2 + y2 )); 
			return sin(k / 40.74 ) * 256;
			//f(x, y) = sin(distance(x, y, 128, 256) / 40.74)
		}
		for(int x = 0; x < _pwidth; x++) {
			auto v = f1(x);
			for(int y = 0; y < _pheight; y++) {
				auto v2 = f2(x,y);
				//_colourMap[x][y] = cast(int)v;
				//_colourMap[x][y] = cast(int)(v2);
				_colourMap[x][y] = MAX( cast(int)(v+v2)/2, 0);
			}
		}
	}
	
	void Draw(SDL_Renderer* renderer) {
		SDL_Rect rect;
		rect.w = _cellSize;
		rect.h = _cellSize;
		for(int x = 0; x < _pwidth; x++) {
			rect.x = x * _cellSize;
			for(int y = 0; y < _pheight; y++) { 
				rect.y = y * _cellSize;
				//std.stdio.writeln(_colourMap[x][y] );
				ubyte r = cast(ubyte)_colourIndex[_colourMap[x][y]].r;
				ubyte g = cast(ubyte)_colourIndex[_colourMap[x][y]].g;
				ubyte b = cast(ubyte)_colourIndex[_colourMap[x][y]].b;
				SDL_SetRenderDrawColor(renderer,r,g ,b,0);				
				if( (r == 0 && g == 0 && b == 0) ){
					SDL_RenderDrawRect(renderer,&rect);	
				}else{
				SDL_RenderFillRect(renderer,&rect);
				}//;
			}
		}

	}

}

//red(i) = sin(π * i / 32)
//green(i) = sin(π * i / 64)
//blue(i) = sin(π * i / 128)
//red(i) = 0
//green(i) = cos(π * i / 128)
//blue(i) = sin(π * i / 128)
//red(i) = cos(π * i / 128)
//green(i) = sin(π * i / 128)
//blue(i) = 0

class PlasmaFractal : IGameEntity
{
	private float[128][128] _heightmap;
	private float _max;
	private int[256] red;
	private int[256] green;
	private int[256] blue;
	this(int n) 
	{
		_max=n;
		for(int y=0;y<128;++y)		
			for(int x=0;x<128;++x)		
			{
			_heightmap[x][y]=128;	
			}
		DiamondSquare(0,0,127,127,255,8);
		//std.stdio.writeln(_heightmap);
		palette();

	}

	void palette () {
    for(int i=0;i<256;i++)
    {
        final switch(cast(int)(i/64))
        {
            case 0:
                red[i]=(i%64)*3+64;
                green[i]=0;
                blue[i]=0;
                break;
            case 1:
                red[i]=0;
                green[i]=(i%64)*3+64;
                blue[i]=0;
                break;
            case 2:
                red[i]=0;
                green[i]=0;
                blue[i]=(i%64)*3+64;
                break;
            case 3:
                red[i]=(i%64)*3+64;
                green[i]=(i%64)*3+64;
                blue[i]=0;
                break;
        }
    }
 

	}

	void DiamondSquare(int x1, int y1, int x2, int y2, float range, int level) {
	    if (level < 1) return;

	    // diamonds
	    for (int i = x1 + level; i < x2; i += level)
	        for (int j = y1 + level; j < y2; j += level) {
	            float a = _heightmap[i - level][j - level];
	            float b = _heightmap[i][j - level];
	            float c = _heightmap[i - level][j];
	            float d = _heightmap[i][j];
	            float e = _heightmap[i - level / 2][j - level / 2] = (a + b + c + d) / 4 + uniform(0.0,1.0) * range;
	        }

	    // squares
	    for (int i = x1 + 2 * level; i < x2; i += level)
	        for (int j = y1 + 2 * level; j < y2; j += level) {
	            float a = _heightmap[i - level][j - level];
	            float b = _heightmap[i][j - level];
	            float c = _heightmap[i - level][j];
	            float d = _heightmap[i][j];
	            float e = _heightmap[i - level / 2][j - level / 2];

	            float f = _heightmap[i - level][j - level / 2] = (a + c + e + _heightmap[i - 3 * level / 2][j - level / 2]) / 4 + uniform(0.0,1.0) * range;
	            float g = _heightmap[i - level / 2][j - level] = (a + b + e + _heightmap[i - level / 2][j - 3 * level / 2]) / 4 + uniform(0.0,1.0) * range;
	        }

	    DiamondSquare(x1, y1, x2, y2, range / 2, level / 2);
	}
	void Update(){
		  // rotate the colors (the palette)
    
	}
	void Draw(SDL_Renderer* renderer){
		for(int y=0;y<128;++y)		
			for(int x=0;x<128;++x)		
			{	
				ubyte level = cast(ubyte)_heightmap[x][y];
				SDL_SetRenderDrawColor(renderer,cast(ubyte)red[level],cast(ubyte)green[level],cast(ubyte)blue[level],0);				
				SDL_RenderDrawPoint(renderer, x,y);
			}

		SDL_SetRenderDrawColor(renderer,0,0,0,0);
	}
}

unittest {
	auto p = new PlasmaFractal(1);
	//std.stdio.writeln(p._heightmap);
	assert(true);
}

class ParallaxStarField : IGameEntity {
struct star {
	Vector2D pos;
	Vector2D vel;
	SDL_Color colour;
}

private:
	int depth;
	int maxSpeed;
	int minSpeed;
	int rows;
	int startY;
	int starsPerLayer;
	star[] stars;

public:
	this(int depth, int maxSpeed, int minSpeed, int rows, int startY, int starsPerLayer ) {
		this.depth=depth;
		this.maxSpeed=maxSpeed;
		this.minSpeed=minSpeed;
		this.rows=rows;
		this.startY=startY;
		this.starsPerLayer=starsPerLayer;

		for(int d = 0; d<depth; d++){
			for(int s = 0; s<starsPerLayer; s++){
				stars ~= star(new Vector2D(uniform(0,640),uniform(startY,startY+rows)),new Vector2D(-uniform(1.0,10.0),0.0),SDL_Color(255,255,255,0));
			}				
		}
	}


	void Draw(SDL_Renderer* renderer) {
		foreach(s;stars){
			SDL_SetRenderDrawColor(renderer,s.colour.r,s.colour.b,s.colour.g,0);
			SDL_RenderDrawPoint(renderer, cast(int)s.pos.X, cast(int)s.pos.Y);
		
		}
	}
	void Update(){
		foreach(s;stars){
			s.pos += s.vel;
			if(s.pos.X < 0) s.pos.X = 640;
		}
	}
}
class CircularStarField : IGameEntity
{
	struct star {
		Vector2D position;
		Vector2D velocity;
		ubyte shade;
	}

	private Player* _player;
	private star[50] _stars;
	private double _lastAngle;	
	this(Player* player)
	{
		_player = player;
		for(int i = 0; i < 50; i++) {
			_stars[i] = star();
			_stars[i].position = new Vector2D(320,240);
			_stars[i].velocity = new Vector2D(uniform(-5.0,5.0),uniform(-5.0,5.0));
			_stars[i].shade = cast(ubyte)uniform(50,200);
		}
	}


	void Draw(SDL_Renderer* renderer){
		foreach(star;_stars){
			SDL_SetRenderDrawColor(renderer,star.shade,star.shade,star.shade,0);
			SDL_RenderDrawPoint(renderer, cast(int)star.position.X, cast(int)star.position.Y);
		}
		SDL_SetRenderDrawColor(renderer,0,0,0,0);
	};

	void Update(){
		
		double newAngle = 0.0;
		//if( _player.PositionAngle != _lastAngle)
		//{
		//	newAngle = _player.PositionAngle;
		//	_lastAngle = _player.PositionAngle;
		//}		
		foreach(star;_stars){
			star.position += star.velocity;
			if( newAngle > 0.0 ){
				star.position.X = star.position.X  + cos(10*(PI/180))*2;
				star.position.Y = star.position.Y  + sin(10*(PI/180))*2;
			}
			if( star.position.X < 0 || star.position.X > 640 || star.position.Y < 0 || star.position.Y > 480 ){
					star.position.X = 320; 
					star.position.Y = 240;				
			}
		}
	};

}

