import TextureManager;
import InputHandler;
import Vector2D;
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

		@property double PositionAngle() { return _positionAngle; }
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
	override void Update()
	{
		HandleInput();
		GameObject.Update();

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
			
		}
		else if(Direction.BaseUp.testDirection)
		{	
			_velocity.X = _velocity.X + cos(_positionAngle*(PI/180))*0.05;
			_velocity.Y = _velocity.Y + sin(_positionAngle*(PI/180))*0.05;
		}
		else if(Direction.BaseDown.testDirection)
		{
			_velocity.X = _velocity.X - cos(_positionAngle*(PI/180))*0.05;
			_velocity.Y = _velocity.Y - sin(_positionAngle*(PI/180))*0.05;
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