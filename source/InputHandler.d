import derelict.sdl2.sdl;
import std.stdio;
import std.algorithm;
import std.typecons;

enum Direction : int
{
	None = 0,
	BaseUp 		= 0b0000_0001,
	BaseDown 	= 0b0000_0010,
	BaseVert	= 0b0000_0011,
	BaseLeft 	= 0b0000_0100,
	BaseRight 	= 0b0000_1000,
	BaseHoriz	= 0b0000_1100,
	BaseAll		= 0b0000_11,
	TurretUp 	= 0b0001_0000,
	TurretDown  = 0b0010_0000,
	TurretVert	= 0b0011_0000,
	TurretLeft 	= 0b0100_0000,
	TurretRight = 0b1000_0000,
	TurretHoriz = 0b1100_0000,
	TurretAll	= 0b1111_0000,
	All 		= 0b1111_1111 	
}
int mousex = 0;
int mousey = 0;

private int directions = 0;

bool testDirection(int dir){
	return (dir & directions) == dir;
}

unittest {
	directions = Direction.TurretUp | Direction.TurretLeft | Direction.TurretRight;
	assert(testDirection(Direction.TurretUp));
	assert(testDirection(Direction.TurretLeft));
	assert(testDirection(Direction.TurretUp | Direction.TurretLeft));
	assert(testDirection(Direction.TurretRight));
	assert(testDirection(Direction.TurretLeft | Direction.TurretDown) == false);
}

private SDL_Joystick* joystick;
private immutable int deadZone = 10000;

Uint8* _keyState;

public bool gameRunning = false;
void InitializeJoysticks(){
	if(SDL_NumJoysticks() > 0 ) {
		joystick = SDL_JoystickOpen(0);
		SDL_JoystickEventState(SDL_ENABLE);
	}
}
	
bool IsKeyDown(SDL_Scancode code){
	return _keyState[code] == 1;
}

private template KeyInput(Tuple!(string,string)[] inputs) {
	static if (inputs.length > 0) 
		const string KeyInput = 
			"if(IsKeyDown("~inputs[0][0]~"))
				directions |= "~inputs[0][1]~";
			 else
		 		directions &= (directions ^ " ~ inputs[0][1]~");
		 	" ~ KeyInput!(inputs[1..$]);
	
	else const string KeyInput = "";
}

private void UpdateKeys(){
	mixin(KeyInput!([tuple("SDL_SCANCODE_RIGHT", "Direction.BaseRight"),
		tuple("SDL_SCANCODE_LEFT", "Direction.BaseLeft"),
		tuple("SDL_SCANCODE_UP", "Direction.BaseUp"),
		tuple("SDL_SCANCODE_DOWN", "Direction.BaseDown"),
		tuple("SDL_SCANCODE_D", "Direction.TurretRight"),
		tuple("SDL_SCANCODE_A", "Direction.TurretLeft"),
		tuple("SDL_SCANCODE_W", "Direction.TurretUp"),
		tuple("SDL_SCANCODE_S", "Direction.TurretDown")]));
	if(IsKeyDown(SDL_SCANCODE_ESCAPE)) {
		gameRunning=false;
	}
}
private template JoyInput(string target, string greater, string less ) {
	const char[] JoyInput =
		"if( event.jaxis.value > deadZone)
		{
			"~target~"="~greater~";
		}
		else if( event.jaxis.value < -deadZone)
		{
			"~target~"="~less~";
		}
		else
		{
			"~target~" = Direction.None;
		}";
}

void Update() {
	_keyState = SDL_GetKeyboardState(null);
	UpdateKeys();
	SDL_Event event;
	while (SDL_PollEvent(&event))
	{
	  switch(event.type)
	  {
	    case SDL_QUIT:
	    gameRunning=false;
	    break;

    	case SDL_JOYAXISMOTION:
		//if(event.jaxis.axis == 0) { // left stick horiz 
		//	mixin(JoyInput!("MainInput.HorizontalMovement","Direction.BaseRight","Direction.BaseLeft"));
		//}
		//else if(event.jaxis.axis == 1) { // left stick vert
		//	mixin(JoyInput!("MainInput.VerticalMovement","Direction.BaseDown","Direction.BaseUp"));
		//}

		//if(event.jaxis.axis == 2) {// Right stick horiz
		//	mixin(JoyInput!("MainInput.HorizontalBullets","Direction.BaseRight","Direction.BaseLeft"));
		//}
		//else if(event.jaxis.axis == 3){ // Right stick vert
		//	mixin(JoyInput!("MainInput.VerticalBullets","Direction.BaseDown","Direction.BaseUp"));
		//}

		break;

		case SDL_MOUSEMOTION:
			mousex = event.motion.x;
			mousey = event.motion.y;
			std.stdio.writeln(mousex, " ", mousey);
		break;
	    default:
	    break;
	  }
	}
};

void Clean() {
	//foreach(j; _joysticks) {
	//	SDL_JoystickClose(j);
	//}
	if( joystick != null)
		SDL_JoystickClose(joystick);
};
