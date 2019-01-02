//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/* Double-include prevention */
#if defined _rp_stock_included_
  #endinput
#endif
#define _rp_stock_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

#if defined HL2DM
//Definitions:
#define	EFL_NO_PHYSCANNON_INTERACTION	(1<<30) // Physcannon can't pick these up or punt them
#endif

//Variable:
float GameTime[MAXPLAYERS + 1] = {0.0,...};
float lastKilled[MAXPLAYERS + 1] = {0.0,...};
float LastPressedE[MAXPLAYERS + 1] = {0.0,...};
float LastPressedSH[MAXPLAYERS + 1] = {0.0,...};
bool Wearables[MAXPLAYERS + 1] = {false,...};
bool CommandOverride[MAXPLAYERS + 1] = {false,...};
int MenuTarget[MAXPLAYERS + 1] = {-1,...};
int TargetPlayer[MAXPLAYERS + 1] = {-1,...};

int ClientFrom;
int WaterCache;
int LaserCache;
int SpriteCache;
int ExplodeCache1;
int ExplodeCache2;
int SmokeCache1;
int SmokeCache2;
int GlowBlueCache;
int CollisionOffset;
int BloodCache;
int BloodDropCache;

UserMsg FadeID;
UserMsg ShakeID;

#if defined HL2DM
char JudgementWaver[256] = "city8/city8-jw.wav";
//char CityInspection[256] = "city8/city8-inspection.wav";
char CityAlarm[256] = "ambient/alarms/citadel_alert_loop2.wav";
#endif

enum FX
{
	FxNone = 0,
	FxPulseFast,
	FxPulseSlowWide,
	FxPulseFastWide,
	FxFadeSlow,
	FxFadeFast,
	FxSolidSlow,
	FxSolidFast,
	FxStrobeSlow,
	FxStrobeFast,
	FxStrobeFaster,
	FxFlickerSlow,
	FxFlickerFast,
	FxNoDissipation,
	FxDistort,               // Distort/scale/translate flicker
	FxHologram,              // kRenderFxDistort + distance fade
	FxExplode,               // Scale up really big!
	FxGlowShell,             // Glowing Shell
	FxClampMinScale,         // Keep this sprite from getting very small (SPRITES only!)
	FxEnvRain,               // for environmental rendermode, make rain
	FxEnvSnow,               //  "        "            "    , make snow
	FxSpotlight,     
	FxRagdoll,
	FxPulseFastWider,
};

enum Render
{
	Normal = 0, 		// src
	TransColor, 		// c*a+dest*(1-a)
	TransTexture,		// src*a+dest*(1-a)
	Glow,				// src*a+dest -- No Z buffer checks -- Fixed size in screen space
	TransAlpha,			// src*srca+dest*(1-srca)
	TransAdd,			// src*a+dest
	Environmental,		// not drawn, used for environmental effects
	TransAddFrameBlend,	// use a fractional frame value to blend between animation frames
	TransAlphaAdd,		// src + dest*(1-a)
	WorldGlow,			// Same as kRenderGlow but not fixed size in screen space
	None,				// Don't render.
};

public void initStock()
{
#if defined HL2DM
	//Chat Hooks: used to block team chat message
	HookUserMessage(GetUserMessageId("SayText2"), UserMessageHook, true);

	HookUserMessage(GetUserMessageId("SayText"), UserMessageHook, true);

	HookUserMessage(GetUserMessageId("TextMsg"), UserMessageHook, true);
#endif
	//Command Listener:
	AddCommandListener(CommandPlayerModel, "cl_playermodel");

	AddCommandListener(DisableCommand, "cl_spec_mode");

	AddCommandListener(DisableCommand, "spectate");

	AddCommandListener(DisableCommand, "jointeam");

	AddCommandListener(DisableCommand, "cl_class");

	AddCommandListener(DisableCommand, "cl_team");

	AddCommandListener(DisableCommand, "explode");

	AddCommandListener(HandleKill, "kill");

	AddCommandListener(HandleCommand, "attack");

	AddCommandListener(HandleCommand, "speed");

	AddCommandListener(HandleCommand, "use");

	RegConsoleCmd("sm_hidewearables", Command_HideWearables);

	RegConsoleCmd("sm_viewwearables", Command_ShowWearables);

	RegConsoleCmd("sm_runtime", Command_RunTime);

	RegConsoleCmd("runtime", Command_RunTime);

	RegConsoleCmd("sm_admins", Command_ViewOnlineAdmins);

	RegConsoleCmd("sm_getmapents", Command_GetMapEnts);

	RegAdminCmd("sm_createcanister", Command_CreateCanister, ADMFLAG_ROOT);

	RegAdminCmd("sm_testparticle", Command_TestParticle, ADMFLAG_ROOT);

	//User Messages:
	FadeID = GetUserMessageId("Fade");

	ShakeID = GetUserMessageId("Shake");
}

public void initStockCache()
{

	//Precache Material:
	LaserCache = PrecacheModel("materials/sprites/laserbeam.vmt", true);

	SpriteCache = PrecacheModel("materials/sprites/halo01.vmt", true);

	ExplodeCache1 = PrecacheModel("sprites/sprite_fire01.vmt", true);

	ExplodeCache2 = PrecacheModel("materials/sprites/sprite_fire01.vmt");

	SmokeCache1 = PrecacheModel("materials/effects/fire_cloud1.vmt",true);

	SmokeCache2 = PrecacheModel("materials/effects/fire_cloud2.vmt",true);

	GlowBlueCache = PrecacheModel("materials/sprites/blueglow2.vmt", true);

	WaterCache = PrecacheModel("materials/sprites/blueglow2.vmt", true);

	BloodCache = PrecacheModel("materials/blood_zombie_split_spray.vmt", true);

	BloodDropCache = PrecacheModel("materials/blood_impact_red_01_droplets.vmt", true);

	//Find Offsets:
	CollisionOffset = FindSendPropInfo("CBasePlayer", "m_CollisionGroup");
}

public void OnRootAdminConnect(int Client)
{

	//Define:
	int Flags = GetUserFlagBits(Client);

	//Has Root:
	if(Flags == ADMFLAG_ROOT)
	{

		//Declare:
		int Effect = CreateEnvStarField(Client, "null", 2.0);

		//Timer:
		CreateTimer(5.0, RemoveStarFieldAdminConnect, Effect);
	}	
}

public Action RemoveStarFieldAdminConnect(Handle Timer, any Ent)
{

	//Connected:
	if(IsValidEdict(Ent))
	{

		//Request:
		RequestFrame(OnNextFrameKill, Ent);
	}
}

public void OverflowMessage(int Client, const char[] Contents)
{

	//Is In Time:
	if(GameTime[Client] <= (GetGameTime() - 5))
	{

		//Print:
		CPrintToChat(Client, Contents);

		//Initialize:
		GameTime[Client] = GetGameTime();
	}
}

public bool IsAdmin(int Client)
{

	//Declare:
	AdminId adminId = GetUserAdmin(Client);

	//Is Valid Admin:
	if(adminId == INVALID_ADMIN_ID)
	{

		//Return:
		return false;
	}

	//Return:
	return view_as<bool>(GetAdminFlag(adminId, Admin_Generic));
}

public bool IsRootAdmin(int Client)
{

	//Declare:
	AdminId adminId = GetUserAdmin(Client);

	//Is Valid Admin:
	if(GetAdminFlag(adminId, Admin_Root))
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public void SetEntityClassName(int Entity, const char[] ClassName)
{

	//Set Prop ClassName
	SetEntPropString(Entity, Prop_Data, "m_iClassname", ClassName);
}

public bool IsInDistance(int Ent1, int Ent2)
{

	//Declare:
	float ClientOrigin[3];
	float EntOrigin[3];

	//Initialize:
	GetEntPropVector(Ent1, Prop_Send, "m_vecOrigin", ClientOrigin);

	GetEntPropVector(Ent2, Prop_Send, "m_vecOrigin", EntOrigin);

	//Declare:
	float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

	//In Distance:
	if(Dist <= 150.0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public void PrintEscapeText(int Client, const char[] text, any:...)
{

	//Declare:
	char message[1024];

	//Format:
	VFormat(message, sizeof(message), text, 3);

	//Handle:
	Handle kv = CreateKeyValues("Message", "Title", message);

	//Set Color:
	KvSetColor(kv, "color", 50, 250, 50, 255);

	//Set Number:
	KvSetNum(kv, "level", 1);

	//Set Float:
	KvSetFloat(kv, "time", 1.5);

	//Show Menu:
	CreateDialog(Client, kv, DialogType_Text);

	//Close:
	CloseHandle(kv);
}

//Covert To String:
public int SteamIdToInt(int Client)
{

	//Check:
	if(!IsClientConnected(Client)) return -1;

	//Declare:
	char SteamId[32];

	//Initulize:
	GetClientAuthId(Client, AuthId_Steam3, SteamId, 32);

	//Declare:
	char subinfo[3][16];

	//Explode:
	ExplodeString(SteamId, ":", subinfo, sizeof(subinfo), sizeof(subinfo[]));

	//Initulize:
	int Intiger = StringToInt(subinfo[2], 10);

	if(StrEqual(subinfo[1], "1"))
	{

		//Initulize:
		Intiger *= -1;
	}

	//Return:
	return view_as<int>(Intiger);
}

//Return Money:
char IntToMoney(int Intiger)
{

	//Declare:
	int slen;
	int Pointer;
	bool negative;
	char IntStr[32];
	char Result[128];

	//Initulize:
	negative = Intiger < 0;

	//Is Valid:
	if(negative)
	{

		//Initulize:
		Intiger *= -1;
	}

	//Convert:
	IntToString(Intiger, IntStr, sizeof(IntStr));

	//Initulize:
	slen = strlen(IntStr);
	Intiger = slen % 3;

	//Is Valid:
	if(Intiger == 0)
	{

		//Initulize:
		Intiger = 3;
	}

	//Format:
	Format(Result, Intiger + 1, "%s", IntStr);

	//Initulize:
	slen -= Intiger;
	Pointer = Intiger + 1;

	//Loop:
	for(int i = Intiger; i <= slen ; i += 3)
	{

		//Initulize:
		Pointer += 4;

		//Format:
		Format(Result, Pointer, "%s,%s",Result, IntStr[i]);
	}

	//Is Valid:
	if(negative)
	{

		//Initulize:
		Format(Result, sizeof(Result), "â‚¬-%s", Result);
	}

	//Override:
	else
	{

		//Initulize:
		Format(Result, sizeof(Result), "â‚¬%s", Result);
	}

	//Return:
	return view_as<char>(Result);
}

//Bipass Cheats:
public void CheatCommand(int Client, char command[255], char arguments[255])
{

	//Define:
	int admindata = GetUserFlagBits(Client);

	//Set Client Flag Bits:
	SetUserFlagBits(Client, ADMFLAG_ROOT);

	//Define:
	int flags = GetCommandFlags(command);

	//Set Client Flags:
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);

	//Command:
	ClientCommand(Client, "\"%s\" \"%s\"", command, arguments);

	//Set Client Flags:
	SetCommandFlags(command, flags);

	//Set Client Flag Bits:
	SetUserFlagBits(Client, admindata);
}

public Action DisableCommand(int Client, const char[] Command, int Args)
{

	//Is Override:
	if(CommandOverride[Client] == true)
	{

		//Return:
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}

public Action CommandPlayerModel(int Client, const char[] Command, int Args)
{

	//Is Admin:
	if(IsAdmin(Client))
	{

		//Declare:
		char Model[128];

		//Initialize:
		GetCmdArg(1, Model, sizeof(Model));

		//Set:
		SetModel(Client, Model);

		//Return:
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}

#if defined HL2DM
public Action UserMessageHook(UserMsg MsgId, Handle hBitBuffer, const iPlayers[], int iNumPlayers, bool bReliable, bool bInit)
{

	//Get Info:
	BfReadByte(hBitBuffer);

	BfReadByte(hBitBuffer);

	//Declare:
	char strMessage[1024];

	//Read UserMessage
	BfReadString(hBitBuffer, strMessage, sizeof(strMessage));

	//Check:
	if(StrContains(strMessage, "before trying to switch", false) != -1)
	{

		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}
#endif
public Action HandleKill(int Client, const char[] Command, int Argc)
{

	//Check:
	if(IsInView(Client))
	{
		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use this command!");

		//Return:
		return Plugin_Handled;
	}

	//Is In Time::
	if(lastKilled[Client] < (GetGameTime() - 60))
	{	

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you will die in 10 seconds!");

		//Timer:
		CreateTimer(10.0, KillPlayer, Client);

		//Initulize:
		lastKilled[Client] = GetGameTime();
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use this command too often!");
	}

	//Return:
	return Plugin_Handled;
}

//Spawn Timer:
public Action KillPlayer(Handle Timer, any Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Slay Client:
		ForcePlayerSuicide(Client);
	}
}

public Action HandleCommand(int Client, const char[] Command, int Argc)
{

	//Is Valid:
	if(!IsCuffed(Client))
	{

		//Return::
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}

public int CheckMapEntityCount()
{

	//Declare:
	int Amount = 0;

	//Loop:
	for(int i = 0; i <= 2047; i++)
	{

		//Is Valid:
		if(IsValidEdict(i) || IsValidEntity(i))
		{

			//Initialize:
			Amount++;
		}
	}

	//Return:
	return view_as<int>(Amount);
}

public bool TraceEntityFilterPlayer(int Entity, int ContentsMask)
{

	//Return:
	return Entity != ClientFrom;
}

public bool TraceEntityFilterEntity(int Entity, int ContentsMask, any Data)
{

	//Return:
	return Entity > 0 && Entity != ClientFrom && Data != Entity;
}

public bool TraceEntityFilterWall(int Entity, int ContentsMask)
{

	//Return:
	return !Entity;
}

public bool TraceEntityFilterPlayerAndVehicle(int Entity, int ContentsMask, any Data)
{

	//Return:
	return Entity != Data && Entity != ClientFrom;
}

public bool TraceRayPlayerOnly(int Entity, int contentsMask, any data)
{

	//Check:
	if (Entity == data)
	{

		//Return:
		return true;
	}

	//Override:
	else
	{

		//Return:
		return false;
	}
}

public bool LookingAtWall(int Client)
{

	//Declare:
	float Origin[3];
	float Angles[3];
	float EndPos[3];

	//Initialize:
	GetClientEyePosition(Client, Origin);

	GetClientEyeAngles(Client, Angles);

	//Declare:
	float dist1 = 0.0;
	float dist2 = 0.0;

	ClientFrom = Client;

	//Handle:
	Handle Trace1 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterEntity, Client);

	//Is Tracer
	if(TR_DidHit(Trace1))
	{

		//Get Vector:
		TR_GetEndPosition(EndPos, Trace1);

		//Initialize:
		dist1 = GetVectorDistance(Origin, EndPos);
	}

	//Override:
	else
	{

		//Initialize:
		dist1 = -1.0;
	}

	//Close:
	CloseHandle(Trace1);

	//Handle:
	Handle Trace2 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterWall);
   	 	
	//Is Tracer
	if(TR_DidHit(Trace2))
	{

		//Get Vector:
		TR_GetEndPosition(EndPos, Trace2);

		//Initialize:
		dist2 = GetVectorDistance(Origin, EndPos);
	}

	//Override:
	else
	{

		//Initialize:
		dist2 = -1.0;
	}

	//Close:
	CloseHandle(Trace2);

	//Initialize:
	ClientFrom = -1;

	//Initialize:
	if(dist1 >= dist2)
	{

		//Return:
		return view_as<bool>(true);
	}

	//Return:
	return view_as<bool>(false);
}

public bool IsTargetInLineOfSight(int Subject, int Target)
{

	//Declare:
	float Position[3];
	float TargetPos[3];
	float EndPos[3];

	//Initulize:
	GetEntPropVector(Subject, Prop_Send, "m_vecOrigin", TargetPos);
	GetEntPropVector(Target, Prop_Send, "m_vecOrigin", Position);

	Position[2] + 20.0;
	TargetPos[2] + 20.0;

	ClientFrom = Subject;

	//Declare:
	float dist1 = 0.0;

	//Initulize:

	//Set Up Trace:
	Handle Trace = TR_TraceRayFilterEx(Position, TargetPos, MASK_SHOT, RayType_EndPoint, TraceEntityFilterEntity, Target);

	//Is Tracer
	if(TR_DidHit(Trace))
	{

		//Get Vector:
		TR_GetEndPosition(EndPos, Trace);

		//Initialize:
		dist1 = GetVectorDistance(TargetPos, EndPos);
	}

	//Override
	else
	{

		//Initialize:
		dist1 = -1.0;
	}

	//Close:
	CloseHandle(Trace);

	//Initialize:
	ClientFrom = -1;

	//Initialize:
	if(dist1 > 0)
	{

		//Return:
		return view_as<bool>(false);
	}

	//Return:
	return view_as<bool>(true);
}

public bool GetCollisionPoint(int Entity, float Pos[3])
{

	//Declare:
	float Origin[3];
	float Angles[3];

	//Initulize:
	GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", Origin);

	//Initulize:
	GetEntPropVector(Entity, Prop_Send, "m_angRotation", Angles);

	ClientFrom = Entity;

	//Handle:
	Handle trace = TR_TraceRayFilterEx(Origin, Angles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Get Ent:
		TR_GetEndPosition(Pos, trace);

		//Close:
		CloseHandle(trace);

		//Return:
		return view_as<bool>(true);
	}

	//Close:
	CloseHandle(trace);

	//Return:
	return view_as<bool>(false);
}

public bool GetClientCollisionPoint(int Client, float Pos[3])
{

	//Declare:
	float Origin[3];
	float Angles[3];

	//Initulize:
	GetClientEyePosition(Client, Origin);

	GetClientEyeAngles(Client, Angles);

	ClientFrom = Client;

	//Handle:
	Handle trace = TR_TraceRayFilterEx(Origin, Angles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Get Ent:
		TR_GetEndPosition(Pos, trace);

		//Close:
		CloseHandle(trace);

		//Return:
		return view_as<bool>(true);
	}

	//Close:
	CloseHandle(trace);

	//Return:
	return view_as<bool>(false);
}

public bool GetCollisionPointFromOrigin(int Entity, float vOrigin[3], float vAngles[3], float Pos[3])
{

	//Initulize:
	ClientFrom = Entity;

	//Handle:
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Get Ent:
		TR_GetEndPosition(Pos, trace);

		//Close:
		CloseHandle(trace);

		//Return:
		return view_as<bool>(true);
	}

	//Close:
	CloseHandle(trace);

	//Return:
	return view_as<bool>(false);
}

public int GetCollisionEntityFromOrigin(int Entity, float Origin[3], float Angles[3])
{

	//Initulize:
	ClientFrom = Entity;

	//Handle:
	Handle trace = TR_TraceRayFilterEx(Origin, Angles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	//Declare:
	int Result = -1;

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Initulize:
		Result = TR_GetEntityIndex(trace);
	}

	//Close:
	CloseHandle(trace);

	//Return:
	return view_as<int>(Result);
}

public int GetClientAimTargetInVehicle(int Client)
{

	//Declare:
	float vOrigin[3];
	float vAngles[3];

	//Initulize:
	GetClientEyePosition(Client, vOrigin);

	//Initulize:
	GetClientEyeAngles(Client, vAngles);

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Declare:
	int Entity = -1;

	//Initulize:
	ClientFrom = Client;

	//Handle:
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayerAndVehicle, InVehicle);

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Initulize:
		Entity = TR_GetEntityIndex(trace);
	}

	//Close:
	CloseHandle(trace);

	//Return:
	return view_as<int>(Entity);
}

public void GetAngleBetweenEntities(int Ent, int OtherEnt, float Angles[3])
{

	//Declare:
	float Origin[3];
	float OtherOrigin[3];
	float Buffer[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

	GetEntPropVector(OtherEnt, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Loop:
	for(int X = 0; X <= 2; X++)
	{

		//Initulize:
		Buffer[X] = FloatSub(Origin[X], OtherOrigin[X]);
	}

	//Normal:
	NormalizeVector(Buffer, Buffer);

	//Get Angles:
	GetVectorAngles(Buffer, Angles);
}


public void GetPullBetweenEntities(int Ent, int OtherEnt, float Scale, float Pull[3])
{

	//Declare:
	float Origin[3];
	float OtherOrigin[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

	GetEntPropVector(OtherEnt, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Caclulate:
	Pull[0] = (FloatMul(Scale, (FloatSub(Origin[0], OtherOrigin[0]))));

    	Pull[1] = (FloatMul(Scale, (FloatSub(Origin[1], OtherOrigin[1]))));

    	Pull[2] = -25.0;
}

public void GetPushBetweenEntities(int Ent, float Scale, float Push[3])
{

	//Declare:
	float EyeAngles[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", EyeAngles);

	//Caclulate:
	Push[0] = (FloatMul(Scale, Cosine(DegToRad(EyeAngles[1]))));

    	Push[1] = (FloatMul(Scale, Sine(DegToRad(EyeAngles[1]))));

    	Push[2] = (FloatMul((Scale / 10.0), Sine(DegToRad(EyeAngles[0]))));
}

public void GetPushBetweenEntitiesCustomAng(int Ent, float EyeAngles[3], float Scale, float Push[3])
{

	//Caclulate:
	Push[0] = (FloatMul(Scale, Cosine(DegToRad(EyeAngles[1]))));

    	Push[1] = (FloatMul(Scale, Sine(DegToRad(EyeAngles[1]))));

    	Push[2] = (FloatMul((Scale / 10.0), Sine(DegToRad(EyeAngles[0]))));
}

public void GetInFrontEntities(int Ent, float Scale, float AngleOffset[3], float NewPosition[3])
{

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};
	float Offset[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	Angles[0] += AngleOffset[0];
	Angles[1] += AngleOffset[1];
	Angles[2] += AngleOffset[2];

	//Caclulate:
	Offset[0] = (FloatMul(Scale, Cosine(DegToRad(Angles[1]))));

	Offset[1] = (FloatMul(Scale, Sine(DegToRad(Angles[1]))));

	Offset[2] = (FloatMul((Scale / 10), Sine(DegToRad(Angles[0]))));

	//Initulize:
	float Origin[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	//Add Vectors Safely
	AddVectors(Origin, Offset, NewPosition);
}

public float GetDistance(const float vec1[3], const float vec2[3])
{

	//Declare:
	float x = vec1[0] - vec2[0];
	float y = vec1[1] - vec2[1];
	float z = vec1[2] - vec2[2];

	//Return:
	return SquareRoot(x*x + y*y + z*z);
}

public void AddRotateEntity(int Ent, int XYZ, float Rotation)
{

	//Declare:
	float Angles[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Initulize:
	if(Angles[XYZ] + Rotation > 360.0)
	{

		//Initulize:
		Angles[1] = 0.0;
	}

	//Initulize:
	Angles[1] += Rotation;

	//Teleport:
	TeleportEntity(Ent, NULL_VECTOR, Angles, NULL_VECTOR);
}

public void SetRotateEntity(int Ent, int XYZ, float Rotation)
{

	//Declare:
	float Angles[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Initulize:
	Angles[1] = Rotation;

	//Teleport:
	TeleportEntity(Ent, NULL_VECTOR, Angles, NULL_VECTOR);
}

//SetEntityrendering(Client, view_as<FX>(FxGlowShell), 200, 200, 200, view_as<Render>(Glow), 255);
public void SetEntityrendering(int Entity, FX fx, int R, int G, int B, Render render, int Amount)
{

	//Initulize:
	SetEntProp(Entity, Prop_Send, "m_nRenderFX", view_as<FX>(fx), 1);
	SetEntProp(Entity, Prop_Send, "m_nRenderMode", view_as<Render>(render), 1);

	//Declare:
	int Offset = GetEntSendPropOffs(Entity, "m_clrRender");

	//Initulize:	
	SetEntData(Entity, Offset, R, 1, true);
	SetEntData(Entity, Offset + 1, G, 1, true);
	SetEntData(Entity, Offset + 2, B, 1, true);
	SetEntData(Entity, Offset + 3, Amount, 1, true);
}

public void LoadString(Handle Vault, char Key[32], char SaveKey[255], char DefaultValue[255], char Reference[255])
{

	//Skip:
	KvJumpToKey(Vault, Key, false);

	//Get KV:
	KvGetString(Vault, SaveKey, Reference, sizeof(Reference), DefaultValue);

	//Restart KV:
	KvRewind(Vault);
}

public void SaveString(Handle Vault, const char[] Key, const char[] SaveKey, const char[] Variable)
{

	//Skip:
	KvJumpToKey(Vault, Key, true);

	//Set KV:
	KvSetString(Vault, SaveKey, Variable);

	//Restart KV:
	KvRewind(Vault);
}

public int LoadInteger(Handle Vault, const char[] Key, const char[] SaveKey, int DefaultValue)
{

	//Skip:
	KvJumpToKey(Vault, Key, false);

	//Get KV:
	int Variable = KvGetNum(Vault, SaveKey, DefaultValue);

	//Restart KV:
	KvRewind(Vault);

	//Return:
	return view_as<int>(Variable);
}

public void PerformBlind(int Client, int Amount)
{

	//Declare
	int SendClient[2];

	SendClient[0] = Client;

	//Handle:
	Handle Message = StartMessageEx(FadeID, SendClient, 1);

	//Declare:
	int Color[4] = {0, 0, 0, 255};

	//Initulize:
	Color[3] = Amount;

	//Multi-Game:
	if (GetUserMessageType() == UM_Protobuf)
	{

		//Set:
		PbSetInt(Message, "duration", 9000);
		PbSetInt(Message, "hold_time", 9000);

		//Check:
		if(Amount == 0)
		{

			//Set:
			PbSetInt(Message, "flags", (0x0001 | 0x0010));
		}

		//Override:
		else
		{

			//Set:
			PbSetInt(Message, "flags", (0x0002 | 0x0008));
		}

		//Set:
		PbSetColor(Message, "clr", Color);
	}

	//Override:
	else
	{

		//Set:
		BfWriteShort(Message, 9000);

		BfWriteShort(Message, 9000);

		//Check:
		if(Amount == 0)
		{

			//Out and Stayout
			BfWriteShort(Message, (0x0001 | 0x0010));
		}

		//Override:
		else
		{

			//Out and Stayout
			BfWriteShort(Message, (0x0002 | 0x0008));
		}

			//Write Handle:
		BfWriteByte(Message, 0);

		BfWriteByte(Message, 0);

		BfWriteByte(Message, 0);

		//Alpha
		BfWriteByte(Message, Amount);
	}

	//Cloose:
	EndMessage();
}

public void PerformUnBlind(int Client)
{

	//Declare
	int SendClient[2];

	SendClient[0] = Client;

	//Handle:
	Handle Message = StartMessageEx(FadeID, SendClient, 1);

	//Declare:
	int Color[4] = {0, 0, 0, 0};

	//Multi-Game:
	if(GetUserMessageType() == UM_Protobuf)
	{

		//Set:
		PbSetInt(Message, "duration", 15);
		PbSetInt(Message, "hold_time", 0);

		//Set:
		PbSetInt(Message, "flags", (0x0001 | 0x0010));

		//Set:
		PbSetColor(Message, "clr", Color);
	}

	//Override:
	else
	{

		//Set:
		BfWriteShort(Message, 9000);

		BfWriteShort(Message, 9000);

		//Out and Stayout
		BfWriteShort(Message, (0x0001 | 0x0010));

		//Set:
		BfWriteByte(Message, Color[0]);

		BfWriteByte(Message, Color[1]);

		BfWriteByte(Message, Color[2]);

		BfWriteByte(Message, Color[3]);
	}

	//Cloose:
	EndMessage();
}

//shake effect
public Action ShakeClient(int Client, float Length, float Severity)
{

	//Conntected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		int SendClient[2];
		SendClient[0] = Client;

		//Handle:
		Handle Message = StartMessageEx(ShakeID, SendClient, 1);

		//Multi-Game:
		if(GetUserMessageType() == UM_Protobuf)
		{

			//Set:
			PbSetInt(Message, "command", 0);

			PbSetFloat(Message, "local_amplitude", Severity);

			PbSetFloat(Message, "frequency", 10.0);

			PbSetFloat(Message, "duration", Length);
		}

		//Override:
		else
		{

			//Set:
			BfWriteByte(Message, 0);

			BfWriteFloat(Message, Severity);

			BfWriteFloat(Message, 10.0);

			BfWriteFloat(Message, Length);
		}

		//Close:
		EndMessage();
	}
}

public float GetBlastDamage(float Dist)
{

	//Declare:
	float Damage = 0.0;

	//Get Damage:
	if(Dist >= 0.0 <= 25.0) Damage = 250.0;
	if(Dist >= 26.0 <= 50.0) Damage = 200.0;
	if(Dist >= 51.0 <= 75.0) Damage = 175.0;
	if(Dist >= 76.0 <= 100.0) Damage = 122.0;
	if(Dist >= 101.0 <= 150.0) Damage = 71.0;
	if(Dist >= 151.0 <= 200.0) Damage = 45.0;
	if(Dist >= 201.0 <= 250.0) Damage = 10.0;

	//Return:
	return view_as<float>(Damage);
}
#if defined HL2DM
public int IsPlayerPoisened(int Client)
{

	//Return:
	return view_as<int>(GetEntProp(Client, Prop_Data, "m_bPoisoned"));
}
#endif

//Show Player Hud
public void ResetClientOverlay(int Client)
{

	//Command:
	CheatCommand(Client, "r_screenoverlay", "0");
}

public int GetCollisionOffset()
{

	//Return:
	return view_as<int>(CollisionOffset);
}

public void HideHud(int Client, int Type)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Send, "m_iHideHUD", Type);
}

public void SetEntityArmor(int Client, int Armor)
{

	//Initialize:
	SetEntProp(Client, Prop_Data, "m_ArmorValue", Armor, 4);
}

public int GetClientScore(int Client)
{

	//Return:
	return view_as<int>(GetEntProp(Client, Prop_Data, "m_iFrags"));
}

public void SetClientScore(int Client, int Score)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Data, "m_iFrags", Score);
}

public void SetClientDeath(int Client, int Death)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Data, "m_iDeaths", Death); 
}

public int GetEntHealth(int Ent)
{

	//Return:
	return view_as<int>(GetEntProp(Ent, Prop_Data, "m_iHealth"));
}

public void SetEntHealth(int Ent, int Health)
{

	//Return:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);
}

public int GetEntMaxHealth(int Ent)
{

	//Return:
	return view_as<int>(GetEntProp(Ent, Prop_Data, "m_iMaxHealth"));
}

public void SetEntMaxHealth(int Ent, int Health)
{

	//Return:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);
}

public void SetEntitySpeed(int Client, float fSpeed)
{

	//Set Prop Data:
	SetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue", fSpeed);	
}

public int GetClientTeamEx(int Client)
{

	//Get Client Team:
	int m_iTeamNum = FindSendPropInfo("CBasePlayer", "m_iTeamNum");

	//Return:
	return view_as<int>(m_iTeamNum);
}

public void ChangeClientTeamEx(int Client, int Team)
{

	//Get Client Team:
	int m_iTeamNum = FindSendPropInfo("CBasePlayer", "m_iTeamNum");

	//Set Prop Data:
	SetEntData(Client, m_iTeamNum, Team);
}

public int GetClientMoveCollide(int Client)
{

	//Get Client Team:
	int MoveCollide = FindSendPropInfo("CBaseEntity", "movecollide");

	//Return:
	return view_as<int>(GetEntData(Client, MoveCollide));
}

public void SetClientMoveCollide(int Client, int Collide)
{

	//Get Client Team:
	int MoveCollide = FindSendPropInfo("CBaseEntity", "movecollide");

	//Set Ent Data:
	SetEntData(Client, MoveCollide, Collide);
}

public int GetClientMoveType(int Client)
{

	//Get Client Team:
	int movetype = FindSendPropInfo("CBaseEntity", "movetype");

	//Return:
	return view_as<int>(GetEntData(Client, movetype));
}

public void SetClientMoveType(int Client, int Type)
{

	//Get Client Team:
	int movetype = FindSendPropInfo("CBaseEntity", "movetype");

	//Set Ent Data:
	SetEntData(Client, movetype, Type);
}

public void GetEntityvecVelocity(int Entity, float vecVelocity[3])
{

	//Get Ent Data:
	GetEntPropVector(Entity, Prop_Data, "m_vecVelocity", vecVelocity);
}

char ServerMap()
{

	//Declare:
	char Map[64];

	//Initialize:
	GetCurrentMap(Map, sizeof(Map));

	//Return
	return Map;
}

public float GetLastPressedE(int Client)
{

	//Return:
	return view_as<float>(LastPressedE[Client]);
}

public void SetLastPressedE(int Client, float Time)
{

	//Initulize:
	LastPressedE[Client] = Time;
}

public float GetLastPressedSH(int Client)
{

	//Return:
	return view_as<float>(LastPressedE[Client]);
}

public void SetLastPressedSH(int Client, float Time)
{

	//Initulize:
	LastPressedSH[Client] = Time;
}

public void SetMaxSpeed(int Client, float Speed)

{



	//Declare:

	int SpeedOffset = FindSendPropInfo(GetCPlayer(), "m_flMaxspeed");



	//Set Speed:

	if(SpeedOffset > 0) SetEntData(Client, SpeedOffset, Speed, 4, true);

}

public int GetClientActiveDevices(int Client)
{

	//Return:
	return view_as<int>(GetEntProp(Client, Prop_Send, "m_bitsActiveDevices"));
}

public void RemoveClientActiveDevices(int Client, int ActiveDevice)
{

	//Initulize:
	SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", GetClientActiveDevices(Client) & ~ActiveDevice);
}

public void SetClientActiveDevices(int Client, int ActiveDevice)
{

	//Initulize:
	SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", ActiveDevice);
}

public void AddClientActiveDevices(int Client, int ActiveDevice)
{

	//Initulize:
	SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", (GetClientActiveDevices(Client) | ActiveDevice));
}

//Cache Natives:
public int Laser()
{

	//Return:
	return view_as<int>(LaserCache);
}

public int Sprite()
{

	//Return:
	return view_as<int>(SpriteCache);
}
public int Explode()
{

	//Return:
	return view_as<int>(ExplodeCache1);
}

public int ExplodeNew()
{

	//Return:
	return view_as<int>(ExplodeCache2);
}

public int Smoke()
{

	//Return:
	return view_as<int>(SmokeCache1);
}

public int SmokeNew()
{

	//Return:
	return view_as<int>(SmokeCache2);
}

public int GlowBlue()
{

	//Return:
	return view_as<int>(GlowBlueCache);
}

public int Water()
{

	//Return:
	return view_as<int>(WaterCache);
}

public int BloodEffect()
{

	//Return:
	return view_as<int>(BloodCache);
}

public int BloodDropEffect()
{

	//Return:
	return view_as<int>(BloodDropCache);
}

public int GetObserverMode(int Client)
{

	//Return:
	return view_as<int>(GetEntProp(Client, Prop_Send, "m_iObserverMode"));
}

public int GetObserverTarget(int Client)
{

	//Return:
	return view_as<int>(GetEntProp(Client, Prop_Send, "m_hObserverTarget"));
}

public Action Command_HideWearables(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Wearables[Client])
	{

		//Initulize:
		Wearables[Client] = false;

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled Your Wearables!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled your Wearables!");
	}


	//Return:
	return Plugin_Handled;
}

public Action Command_ShowWearables(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!Wearables[Client])
	{

		//Initulize:
		Wearables[Client] = true;

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled Your Wearables!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled your Wearables!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_RunTime(int Client, int Args)
{

	//Time Calculator:
	int Result = GetTime() - GetRunTime();
	int Days = Result / 86400;
	Result %= 86400;
	int Hours = Result / 3600;
	Result %= 3600;
	int Minutes = Result / 60;
	Result %= 60;
	int Seconds = Result;

	//Has Days:
	if(Days >= 1)
	{

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i days, %i hours and %i minutes.", Days, Hours, Minutes);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i days, %i hours and %i minutes.", Days, Hours, Minutes);
		}
	}

	//Has Hours:
	else if(Hours >= 1)
	{

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i hours and %i minutes and %i seconds.", Hours, Minutes, Seconds);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i hours and %i minutes and %i seconds.", Hours, Minutes, Seconds);
		}
	}

	//Has Minutes:
	else if(Minutes >= 1)
	{

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i minutes and %i seconds.", Minutes, Seconds);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i minutes and %i seconds.", Minutes, Seconds);
		}
	}

	//Override:
	else
	{

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i seconds.", Seconds);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i seconds.", Seconds);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_ViewOnlineAdmins(int Client, int Args)
{

	//Declare:
	bool Result = false;

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Admin Check:
			if(IsAdmin(i))
			{

				//Initulize:
				Result = true;
			}
		}
	}

	//Admins Online:
	if(Result == true)
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Define:
				int Flags = GetUserFlagBits(i);

				//Has Root:
				if(Flags == ADMFLAG_ROOT)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - %N is a Root Admin.", i);
				}

				//Has Advanced Admin:
				else if(Flags == ADMFLAG_BAN)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - %N is a Advanced Admin.", i);
				}

				//Has Basic Admin:
				else if(Flags == ADMFLAG_SLAY)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - %N is a Basic Admin.", i);
				}
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There are no Online admins currently in the server.");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_GetMapEnts(int Client, int Args)
{

	//Server Check:
	if(Client != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There are currently %i entities on the map", CheckMapEntityCount());

	}
	//Override:
	else
	{

		//Print:
		PrintToServer("|RP| - There are currently %i entities on the map", CheckMapEntityCount());
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateCanister(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Origin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Origin);

	CreateEnvheadcrabcanister(Origin);

	//Return:
	return Plugin_Handled;
}

public Action Command_TestParticle(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Particle[128];

	//Initialize:
	GetCmdArg(1, Particle, sizeof(Particle));

	//Declare:
	float ClientOrigin[3];
	float Origin[3];
	float EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	CreateInfoParticleSystemOther(Client, "null", Particle, 2.0, EyeAngles, EyeAngles);

	//Return:
	return Plugin_Handled;
}

public bool GetViewWearables(int Client)
{

	//Return:
	return view_as<bool>(Wearables[Client]);
}

public void SetViewWearables(int Client, bool Result)
{

	//Initulize:
	Wearables[Client] = Result;
}

public void ShakeGlobal(float Amount)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Shake:
			ShakeClient(i, Amount, 1.3);
		}
	}
}

public bool intTobool(int i)
{

	if(i == 1) return view_as<bool>(true);
	else return view_as<bool>(false);
}

public int boolToint(bool i)
{

	if(i) return view_as<int>(1);
	else return view_as<int>(0);
}

public int GetMenuTarget(int Client)
{

	//Return:
	return view_as<int>(MenuTarget[Client]);
}

public void SetMenuTarget(int Client, int Result)
{

	//Initulize:
	MenuTarget[Client] = Result;
}

public int GetTargetPlayer(int Client)
{

	//Return:
	return view_as<int>(TargetPlayer[Client]);
}

public void SetTargetPlayer(int Client, int Player)
{

	//Initulize:
	TargetPlayer[Client] = Player;
}

public int GetPlayerIdFromString(char Text[32])
{

	//Declare
	int Player = -1;

	//Clear Buffers:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Check:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Declare:
			char PlayerName[32];

			//Initialize:
			GetClientName(i, PlayerName, sizeof(PlayerName));

			//Check:
			if(StrContains(PlayerName, Text, false) != -1)
			{

				//Initialize:
				Player = i;

				//Stop:
				break;
			}
		}
	}

	//Return:
	return view_as<int>(Player);
}

public void ShowHudTextEx(int Client, int Channel, float Position[2], int Color[4], float holdtime, int Effect, float fxTime, float fadeIn, float FadeOutTime, const char[] Text)
{

	//Setup Hud:
	SetHudTextParams(Position[0], Position[1], holdtime, Color[0], Color[1], Color[2], Color[3], Effect, fxTime, fadeIn, FadeOutTime);

	//Show Hud Text:
        ShowHudText(Client, Channel, Text); 
}

public void CSGOShowHudTextEx(int Client, int Channel, float Position[2], int Color1[4], int Color2[4], float holdtime, int Effect, float fxTime, float fadeIn, float FadeOutTime, const char[] Text)
{

	//Setup Hud:
	SetHudTextParamsEx(Position[0], Position[1], holdtime, Color1, Color2, Effect, fxTime, fadeIn, FadeOutTime);

	//Show Hud Text:
        ShowHudText(Client, Channel, Text); 
}

public void RemoveObserverView(int Client)
{

	ShowVGUIPanel(Client, "specmenu", INVALID_HANDLE, false);
	ShowVGUIPanel(Client, "specgui", INVALID_HANDLE, false);
	ShowVGUIPanel(Client, "overview", INVALID_HANDLE, false);
}

public void RemoveWebPanel(int Client)
{

	ShowVGUIPanel(Client, "info", INVALID_HANDLE, false);
}

public void SetEntityAnimation(int Entity, char[] Animation)
{

	//Set:
	SetVariantString(Animation);

	//Accept:
	AcceptEntityInput(Entity, "SetAnimation");
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param format		Message
 * @return			No bool.
 */
public void CPrintKeyHintTextAll(const char[] format, any ...)
{

	//Declare:
	char buffer[254];

	//Loop:
	for(int i = 1; i <= MaxClients; i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{

			//Set Language:
			SetGlobalTransTarget(i);

			//Format:
			VFormat(buffer, sizeof(buffer), format, 2);

			//Print:
			CPrintKeyHintText(i, buffer);
		}
	}
}
/**
 * Sends a Dialog Menu to a client
 *
 * @param client		Client index.
 * @param format		Message
 * @return			No bool.
 */
public bool CPrintKeyHintText(int Client, const char[] format, any ...)
{

	//Handle:
	Handle userMessage = StartMessageOne("KeyHintText", Client);

	//Is Valid:
	if(userMessage == INVALID_HANDLE)
	{

		//Return:
		return view_as<bool>(false);
	}

	//Declare:
	char buffer[254];

	//Set Language:
	SetGlobalTransTarget(Client);

	//Format:
	VFormat(buffer, sizeof(buffer), format, 3);

	//Write Byte:
	BfWriteByte(userMessage, 1);

	//Write String:
	BfWriteString(userMessage, buffer); 

	//Send Message:
	EndMessage();

	//Return:
	return view_as<bool>(true);
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param client		Client index.
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CPrintDialogText(int Client, int Level, float Time, int r, int g, int b, int a, char[] Text, any:...)
{

	//Declare:
	char message[100];

	//Format:
	VFormat(message, sizeof(message), Text, 3);

	// message in the top of the screen
	Handle msgValues = CreateKeyValues("msg");

	//Text:
	KvSetString(msgValues, "title", Text);

	//Set Color:
	KvSetColor(msgValues, "color", r, g, b, a);

	//Level Type:
	KvSetNum(msgValues, "level", Level);

	//Time:
	KvSetFloat(msgValues, "time", Time);

	//Send Menu:
	CreateDialog(Client, msgValues, DialogType_Msg);

	//Close:
	CloseHandle(msgValues);
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CPrintDialogTextAll(int Level, float Time, int r, int g, int b, int a, char[] Text, any:...)
{

	//Declare:
	char buffer[254];

	//Loop:
	for(int i = 1; i <= MaxClients; i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{

			//Set Language:
			SetGlobalTransTarget(i);

			//Format:
			VFormat(buffer, sizeof(buffer), Text, 2);

			//Print:
			CPrintDialogText(i, Level, Time, r, g, b, a, buffer)
		}
	}
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CreateMenuTextBox(int Client, int Level, int Time, int R, int G, int B, int A, char[] Buffer, any:...)
{

	//Declare:
	char message[1028];

	//Format:
	VFormat(message,sizeof(message), Buffer, 9);

	//Handle:
	Handle kv = CreateKeyValues("message", "title", message);

	//Set Colour:
	KvSetColor(kv, "color", R, G, B, A);

	//Set Number
	KvSetNum(kv, "level", Level);

	//Set Number
	KvSetNum(kv, "time", Time);

	//Create Menu:
	CreateDialog(Client, kv, DialogType_Menu);

	//Create Menu:
	//CreateDialog(Client, kv, DialogType_Entry);

	//Create Menu:
	//CreateDialog(Client, kv, DialogType_Text);

	//Close:
	CloseHandle(kv);
}
/**
 * Sends a Dialog Menu to a client
 *
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CreateMenuTextBoxAll(int Level, int Time, int R, int G, int B, int A, char[] Buffer, any:...)
{

	//Declare:
	char buffer[1028];

	//Loop:
	for(int i = 1; i <= MaxClients; i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{

			//Set Language:
			SetGlobalTransTarget(i);

			//Format:
			VFormat(buffer, sizeof(buffer), Text, 2);

			//Print:
			CreateMenuTextBox(i, Level, Time, r, g, b, a, buffer)
		}
	}
}

public int IsClientPressingJump(int &Buttons)
{

	//Multi Button Check:
	if((Buttons & IN_JUMP)) return 1;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED)) return 2;

	if((Buttons & IN_JUMP) && (Buttons & IN_USE)) return 3;

	if((Buttons & IN_JUMP) && (Buttons & IN_ATTACK)) return 4;

	if((Buttons & IN_JUMP) && (Buttons & IN_ATTACK2)) return 5;

	if((Buttons & IN_JUMP) && (Buttons & IN_FORWARD)) return 6;

	if((Buttons & IN_JUMP) && (Buttons & IN_BACK)) return 7;

	if((Buttons & IN_JUMP) && (Buttons & IN_RIGHT)) return 8;

	if((Buttons & IN_JUMP) && (Buttons & IN_LEFT)) return 9;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED)) return 10;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_FORWARD)) return 11;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_BACK)) return 12;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_RIGHT)) return 13;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_LEFT)) return 14;

	if((Buttons & IN_JUMP) && (Buttons & IN_FORWARD) && (Buttons & IN_RIGHT)) return 15;

	if((Buttons & IN_JUMP) && (Buttons & IN_FORWARD) && (Buttons & IN_LEFT)) return 16;

	//Return:
	return -1;
}

stock bool IsClientInAir(int client, int flags)
{

	//Return:
	return !(flags & FL_ONGROUND);
}
stock bool IsClientNotMoving(int buttons)
{

	//Return:
	return !IsMoveButtonsPressed(buttons);
}

stock bool IsMoveButtonsPressed(int buttons)
{

	//Return:
	return buttons & IN_FORWARD || buttons & IN_BACK || buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT;
}
/* 
 * Precaches the given particle system. 
 * It's best to call this OnMapStart(). 
 * Code based on Rochellecrab's, thanks. 
 *  
 * @param particleSystem    Name of the particle system to precache. 
 * @return                    Returns the particle system index, INVALID_STRING_INDEX on error. 
 */ 
stock int PrecacheParticleSystem(const char[] particleSystem) 
{ 
	int particleEffectNames = INVALID_STRING_TABLE; 

	if(particleEffectNames == INVALID_STRING_TABLE)
	{ 
		if((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE)
		{ 
			return INVALID_STRING_INDEX; 
		} 
	} 

	int index = FindStringIndex2(particleEffectNames, particleSystem); 
	if(index == INVALID_STRING_INDEX)
	{ 
		int numStrings = GetStringTableNumStrings(particleEffectNames); 
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames))
		{ 
			return INVALID_STRING_INDEX; 
		} 
         
		AddToStringTable(particleEffectNames, particleSystem); 
		index = numStrings; 
	} 

	return index; 
} 

/* 
 * Rewrite of FindStringIndex, because in my tests 
 * FindStringIndex failed to work correctly. 
 * Searches for the index of a given string in a string table.  
 *  
 * @param tableidx        A string table index. 
 * @param str            String to find. 
 * @return                String index if found, INVALID_STRING_INDEX otherwise. 
 */ 
stock int FindStringIndex2(int tableidx, const char[] str) 
{ 
	char buf[1024]; 

	int numStrings = GetStringTableNumStrings(tableidx); 
	for(int i=0; i < numStrings; i++)
	{ 
		ReadStringTable(tableidx, i, buf, sizeof(buf)); 

		if(StrEqual(buf, str))
		{ 
			return i; 
		} 
	} 
     
	return INVALID_STRING_INDEX; 
}
public RenderMode IntToRenderMode(int Result)
{

	//Switch:
	switch(Result)
	{

		case 1:
		{

			//Return:
			return RENDER_NORMAL;
		}

		case 2:
		{

			//Return:
			return RENDER_TRANSCOLOR;
		}

		case 3:
		{

			//Return:
			return RENDER_TRANSTEXTURE;
		}

		case 4:
		{

			//Return:
			return RENDER_GLOW;
		}

		case 5:
		{

			//Return:
			return RENDER_TRANSALPHA;
		}

		case 6:
		{

			//Return:
			return RENDER_TRANSADD;
		}

		case 7:
		{

			//Return:
			return RENDER_ENVIRONMENTAL;
		}

		case 8:
		{

			//Return:
			return RENDER_TRANSADDFRAMEBLEND;
		}

		case 9:
		{

			//Return:
			return RENDER_TRANSALPHAADD;
		}

		case 10:
		{

			//Return:
			return RENDER_WORLDGLOW;
		}

		case 11:
		{

			//Return:
			return RENDER_NONE;
		}
	}

	//Return:
	return RENDER_NONE;
}

public RenderFx IntToRenderModeFx(int Result)
{

	//Switch:
	switch(Result)
	{

		case 1:
		{

			//Return:
			return RENDERFX_NONE;
		}

		case 2:
		{

			//Return:
			return RENDERFX_PULSE_SLOW;
		}

		case 3:
		{

			//Return:
			return RENDERFX_PULSE_FAST;
		}

		case 4:
		{

			//Return:
			return RENDERFX_PULSE_SLOW_WIDE;
		}

		case 5:
		{

			//Return:
			return RENDERFX_PULSE_FAST_WIDE;
		}

		case 6:
		{

			//Return:
			return RENDERFX_FADE_SLOW;
		}

		case 7:
		{

			//Return:
			return RENDERFX_FADE_FAST;
		}

		case 8:
		{

			//Return:
			return RENDERFX_SOLID_SLOW;
		}

		case 9:
		{

			//Return:
			return RENDERFX_SOLID_FAST;
		}

		case 10:
		{

			//Return:
			return RENDERFX_STROBE_SLOW;
		}

		case 11:
		{

			//Return:
			return RENDERFX_STROBE_FAST;
		}

		case 12:
		{

			//Return:
			return RENDERFX_STROBE_FASTER;
		}

		case 13:
		{

			//Return:
			return RENDERFX_FLICKER_SLOW;
		}

		case 14:
		{

			//Return:
			return RENDERFX_FLICKER_FAST;
		}

		case 15:
		{

			//Return:
			return RENDERFX_NO_DISSIPATION;
		}

		case 16:
		{

			//Return:
			return RENDERFX_DISTORT;
		}

		case 17:
		{

			//Return:
			return RENDERFX_HOLOGRAM;
		}

		case 18:
		{

			//Return:
			return RENDERFX_EXPLODE;
		}

		case 19:
		{

			//Return:
			return RENDERFX_GLOWSHELL;
		}

		case 20:
		{

			//Return:
			return RENDERFX_CLAMP_MIN_SCALE;
		}

		case 21:
		{

			//Return:
			return RENDERFX_ENV_RAIN;
		}

		case 22:
		{
			//Return:
			return RENDERFX_ENV_SNOW;
		}

		case 23:
		{

			//Return:
			return RENDERFX_SPOTLIGHT;
		}

		case 24:
		{

			//Return:
			return RENDERFX_RAGDOLL;
		}

		case 25:
		{

			//Return:
			return RENDERFX_PULSE_FAST_WIDER;
		}

		case 26:
		{

			//Return:
			return RENDERFX_MAX;
		}
	}

	//Return:
	return RENDERFX_MAX;
}
public void SetClientHours(int Client)
{

	//Time Calculator:
	int Result = GetOnlineTime(Client);
	int Days = Result / 360;
	Result %= 360;
	int Hours = Result / 60;
	if(Days > 0) Hours += (Days*24);
	if(Hours > 1999) Hours = 1999;
	
	//Set Score:
	SetClientScore(Client, Hours);
}
