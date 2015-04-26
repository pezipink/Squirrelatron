import TextureManager;
import InputHandler;
import Vector2D;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

class GameObject
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
			TextureManager.DrawFrame(_id,cast(int)_position.X,cast(int)_position.Y,_width,_height,_currentRow,_currentFrame,renderer,SDL_FLIP_NONE);
		}

		void Update()
		{
			_position += _velocity;
		};

		void Clean(){};
	protected:
		string _id;
		
		int _currentFrame;
		int _currentRow;

		int _width;
		int _height;

		Vector2D _position = new Vector2D(0,0);
		Vector2D _velocity = new Vector2D(0,0);
}

class Player : GameObject
{
	override void Update()
	{
		HandleInput();
		GameObject.Update();
	}

	void HandleInput()
	{
		if(MainInput.HorizontalMovement == Direction.Left)
		{
			_velocity.X = -10;
		}
		else if(MainInput.HorizontalMovement == Direction.Right)
		{
			_velocity.X = 10;
		}
		else 
		{
			_velocity.X = 0;
		}

		if(MainInput.VerticalMovement == Direction.Up)
		{
			_velocity.Y = -10;
		}
		else if(MainInput.VerticalMovement == Direction.Down)
		{
			_velocity.Y = 10;
		}
		else 
		{
			_velocity.Y = 0;
		}

	}
}