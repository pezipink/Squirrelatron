import TextureManager;
import InputHandler;
import Vector2D;
import BulletManager;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.math;
import Interfaces;
T MAX(T)(T x, T y) { return x > y ? x : y; }
T MIN(T)(T x, T y) { return x < y ? x : y; }
T WRAPP(T)(T x, T max) { return x > max ? x-max : x; }
T WRAPN(T)(T x, T min, T max) { return x < min ? max-abs(x-min) : x; }

unittest {
	assert(MAX(1,10) == 10);
	assert(WRAPP(365,360) == 5);
	assert(WRAPN(-5,0,360) == 355);
	assert(WRAPN(10,15,360) == 355);
}

class GameObject : IGameEntity
{
	public:
		void Load(int x,int y, int width, int height, immutable string id) {
			_position.X = x;
			_position.Y = y;
			_width=width;
			_height=height;
			_id=id;
			_currentFrame=0;
			_currentRow=0;
		}
		
		void Draw(SDL_Renderer* renderer) {
			TextureManager.DrawFrame(_id,cast(int)_position.X,cast(int)_position.Y,_width,_height,_positionAngle,_currentRow,_currentFrame,renderer,SDL_FLIP_NONE);
			SDL_SetRenderDrawColor(renderer,255,0,255,0);
			//SDL_RenderDrawLine(
			//	renderer,
			//	cast(int)_position.X,
			//	cast(int)_position.Y,
			//	cast(int)(_position.X + _velocity.X)*2,
			//	cast(int)(_position.Y + _velocity.Y)*2);
			SDL_RenderDrawLine(
				renderer,
				cast(int)_position.X,
				cast(int)_position.Y,
				cast(int)(_position.X  + cos(_turretAngle*(PI/180))*10),
				cast(int)(_position.Y  + sin(_turretAngle*(PI/180))*10));

			SDL_SetRenderDrawColor(renderer,0,0,0,0);
		}

		void Update()
		{
			_position += _velocity;
		};

		void Clean(){};
		void SetPosition(Vector2D pos){_position=pos;}
		void SetVelocity(Vector2D vel){_velocity=vel;}

		@property double PositionAngle() { return _positionAngle; }
		@property Vector2D Position() { return _position; }
	protected:
		string _id;
		
		int _currentFrame;
		int _currentRow;

		int _width;
		int _height;

		Vector2D _position = new Vector2D(0,0);
		Vector2D _velocity = new Vector2D(0,0);

		double _positionAngle = 0.0;
		double _turretAngle = 0.0;

}

class Player : GameObject
{
	BulletManager _bullets = new BulletManager();
	int _lastFired;
	this()
	{
		_lastFired=SDL_GetTicks();
	}
	override void Draw(SDL_Renderer* renderer){
		GameObject.Draw(renderer);
		_bullets.Draw(renderer);
	}

	override void Update()
	{
		if(SDL_GetTicks() - _lastFired > 200){
			auto x = cos(_turretAngle*(PI/180)) ;
			auto y = sin(_turretAngle*(PI/180)) ;
			if( x < 0 ) x-=1; else x+=1;
			if( y < 0 ) y-=1; else y+=1;
			auto v = new Vector2D(x,y);
			_bullets.AddBullet(true,_position.dup,v);
			_lastFired=SDL_GetTicks();
		}
		HandleInput();
		GameObject.Update();
		_bullets.Update();
		//bounds checking
		if( _position.X < 0  )
		{
			_position.X = 0;
			_velocity.X = (-_velocity.X)*0.8;
		}
		else if(_position.X + _width > 640 )
		{
			_position.X = 640 - _width;
			_velocity.X = (-_velocity.X)*0.8;	
		}

		if( _position.Y < 0 )
		{
			_position.Y = 0;
			_velocity.Y = -(_velocity.Y)*0.8;
		}
		else if( _position.Y + _height  > 480  )
		{
			_position.Y = 480 - _height;
			_velocity.Y = -(_velocity.Y)*0.8;
		}
	}

	void HandleInput()
	{
		//mixin("mixin(\"int x;\");");
		//_positionAngle = WRAPP(_positionAngle+10,360);
		if( (Direction.BaseLeft | Direction.BaseRight).testDirection)
		{
			
		}
		else if(Direction.BaseLeft.testDirection)
		{
			_positionAngle = WRAPN(_positionAngle-5,0,360);
		}
		else if(Direction.BaseRight.testDirection)
		{
			_positionAngle = WRAPP(_positionAngle+5,360);
		}		

		if( (Direction.BaseUp | Direction.BaseDown).testDirection)
		{
			_currentFrame = 0; 
		}
		else if(Direction.BaseUp.testDirection)
		{	
			_velocity.X = _velocity.X + cos(_positionAngle*(PI/180))*0.3;
			_velocity.Y = _velocity.Y + sin(_positionAngle*(PI/180))*0.3;
			_currentFrame = ((SDL_GetTicks() / 100) % 3);
		}
		else if(Direction.BaseDown.testDirection)
		{
			_velocity.X = _velocity.X - cos(_positionAngle*(PI/180))*0.3;
			_velocity.Y = _velocity.Y - sin(_positionAngle*(PI/180))*0.3;
			_currentFrame = ((SDL_GetTicks() / 100) % 3);
		}


		if( (Direction.TurretLeft | Direction.TurretRight).testDirection )
		{
			
		}
		else if(Direction.TurretLeft.testDirection)
		{			
			_turretAngle = WRAPN(_turretAngle-5,0,360);
		}
		else if(Direction.TurretRight.testDirection)
		{
			_turretAngle = WRAPP(_turretAngle+5,360);
		}

	}
}
