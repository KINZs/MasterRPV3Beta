#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define CLASSNAME "prop_combine_ball"

int LightSprite = -1;
int GlowSprite = -1;

//Plugin Info:
public Plugin myinfo =
{
	name = "AR2 Ball Effect Extension for CustomGuns",
	author = "Master(D)",
	description = "CustomGuns Extension",
	url = "",
	version = "00.00.01",
};

public void OnPluginStart()
{
}

public void OnMapStart()
{
	LightSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	GlowSprite = PrecacheModel("materials/sprites/blueglow2.vmt", true);
}

//Think:
public void OnGameFrame()
{

	//Loop:
	for(int Entity = GetMaxClients() + 1; Entity < 2047; Entity++)
	{

		if(IsValidEdict(Entity))
		{

			char cls[32];
			GetEntityClassname(Entity, cls, sizeof(cls));

			if(StrEqual(cls, CLASSNAME))
			{
				//Declare:
				float Origin[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_vecOrigin", Origin);

				//Declare:
				float Angels[3];

				//Initulize:
				GetEntPropVector(Entity, Prop_Data, "m_angRotation", Angels);

				//Temp Ent:
				TE_SetupEnergySplash(Origin, Angels, true);

				//Show To Client:
				TE_SendToAll();
			}
		}
	}
}

public OnEntityCreated(int Entity)
{
	char cls[32];
	GetEntityClassname(Entity, cls, sizeof(cls));

	if(StrEqual(cls, CLASSNAME))
	{
		int Color[4] = {20, 20, 255, 255};
		
		TE_SetupBeamFollow(Entity, LightSprite, GlowSprite, 0.6, 5.0, 0.5, 165, Color);

		//Show To All Clients:
		TE_SendToAll();

		Color = {220, 220, 255, 155};
		
		TE_SetupBeamFollow(Entity, LightSprite, GlowSprite, 0.4, 5.0, 0.5, 165, Color);

		//Show To All Clients:
		TE_SendToAll();
		
		//Ent Unhooking:
		//SDKHook(Entity, SDKHook_Spawn, OnCombineBallCreated);
	}
}
public OnEntityDestroyed(int Entity)
{
	//Check:
	if(IsValidEdict(Entity))
	{
		char cls[32];
		GetEntityClassname(Entity, cls, sizeof(cls));

		if(StrEqual(cls, CLASSNAME))
		{
		}
	}
}

public Action OnCombineBallCreated(int Entity)
{