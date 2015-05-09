import derelict.sdl2.sdl;
import std.random;
import std.math;
import std.random;
import std.typecons;
import Vector2D;
import GameObjects;
import Interfaces;
import InputHandler;

class Plasma : IGameEntity{

	private {
		static immutable int _cellSize = 8;
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




//import java.applet.Applet;
//import java.awt.*;

//public class Plasma extends Applet
//{

//	Image Buffer;	//A buffer used to store the image
//	Graphics Context;	//Used to draw to the buffer.
	
//	//Randomly displaces color value for midpoint depending on size
//	//of grid piece.
//	float Displace(float num)
//	{
//		float max = num / (float)(getSize().width + getSize().height) * 3;
//		return ((float)Math.random() - 0.5f) * max;
//	}

//	//Returns a color based on a color value, c.
//	Color ComputeColor(float c)
//	{		
//		float Red = 0;
//		float Green = 0;
//		float Blue = 0;
		
//		if (c < 0.5f)
//		{
//			Red = c * 2;
//		}
//		else
//		{
//			Red = (1.0f - c) * 2;
//		}
		
//		if (c >= 0.3f && c < 0.8f)
//		{
//			Green = (c - 0.3f) * 2;
//		}
//		else if (c < 0.3f)
//		{
//			Green = (0.3f - c) * 2;
//		}
//		else
//		{
//			Green = (1.3f - c) * 2;
//		}
		
//		if (c >= 0.5f)
//		{
//			Blue = (c - 0.5f) * 2;
//		}
//		else
//		{
//			Blue = (0.5f - c) * 2;
//		}
		
//		return new Color(Red, Green, Blue);
//	}
	
//	//This is something of a "helper function" to create an initial grid
//	//before the recursive function is called.	
//	void drawPlasma(Graphics g, int width, int height)
//	{
//		float c1, c2, c3, c4;
		
//		//Assign the four corners of the intial grid random color values
//		//These will end up being the colors of the four corners of the applet.		
//		c1 = (float)Math.random();
//		c2 = (float)Math.random();
//		c3 = (float)Math.random();
//		c4 = (float)Math.random();
				
//		DivideGrid(g, 0, 0, width , height , c1, c2, c3, c4);
//	}
	
//	//This is the recursive function that implements the random midpoint
//	//displacement algorithm.  It will call itself until the grid pieces
//	//become smaller than one pixel.	
//	void DivideGrid(Graphics g, float x, float y, float width, float height, float c1, float c2, float c3, float c4)
//	{
//		float Edge1, Edge2, Edge3, Edge4, Middle;
//		float newWidth = width / 2;
//		float newHeight = height / 2;

//		if (width > 2 || height > 2)
//		{	
//			Middle = (c1 + c2 + c3 + c4) / 4 + Displace(newWidth + newHeight);	//Randomly displace the midpoint!
//			Edge1 = (c1 + c2) / 2;	//Calculate the edges by averaging the two corners of each edge.
//			Edge2 = (c2 + c3) / 2;
//			Edge3 = (c3 + c4) / 2;
//			Edge4 = (c4 + c1) / 2;
			
//			//Make sure that the midpoint doesn't accidentally "randomly displaced" past the boundaries!
//			if (Middle < 0)
//			{
//				Middle = 0;
//			}
//			else if (Middle > 1.0f)
//			{
//				Middle = 1.0f;
//			}
			
//			//Do the operation over again for each of the four new grids.			
//			DivideGrid(g, x, y, newWidth, newHeight, c1, Edge1, Middle, Edge4);
//			DivideGrid(g, x + newWidth, y, newWidth, newHeight, Edge1, c2, Edge2, Middle);
//			DivideGrid(g, x + newWidth, y + newHeight, newWidth, newHeight, Middle, Edge2, c3, Edge3);
//			DivideGrid(g, x, y + newHeight, newWidth, newHeight, Edge4, Middle, Edge3, c4);
//		}
//		else	//This is the "base case," where each grid piece is less than the size of a pixel.
//		{
//			//The four corners of the grid piece will be averaged and drawn as a single pixel.
//			float c = (c1 + c2 + c3 + c4) / 4;
			
//			g.setColor(ComputeColor(c));
//			g.drawRect((int)x, (int)y, 1, 1);	//Java doesn't have a function to draw a single pixel, so
//								//a 1 by 1 rectangle is used.
//		}
//	}

//	//Draw a new plasma fractal whenever the applet is clicked.
//	public boolean mouseUp(Event evt, int x, int y)
//	{
//		drawPlasma(Context, getSize().width, getSize().height);
//		repaint();	//Force the applet to draw the new plasma fractal.
		
//		return false;
//	}
	
//	//Whenever something temporarily obscures the applet, it must be redrawn manually.
//	//Since the fractal is stored in an offscreen buffer, this function only needs to
//	//draw the buffer to the screen again.
//	public void paint(Graphics g)
//	{
//		g.drawImage(Buffer, 0, 0, this);
//	}
	
//	public String getAppletInfo()
//	{
//		return "Plasma Fractal.  Written January, 2002 by Justin Seyster.";
//	}
	
//	public void init()
//	{
//		Buffer = createImage(getSize().width, getSize().height);	//Set up the graphics buffer and context.
//		Context = Buffer.getGraphics();
//		drawPlasma(Context, getSize().width, getSize().height);	//Draw the first plasma fractal.
//	}
//};