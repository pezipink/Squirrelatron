import derelict.sdl2.sdl;
import std.random;
import std.math;
import Vector2D;
import GameObjects;
import Interfaces;

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
		if( _player.PositionAngle != _lastAngle)
		{
			newAngle = _player.PositionAngle;
			_lastAngle = _player.PositionAngle;
		}		
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