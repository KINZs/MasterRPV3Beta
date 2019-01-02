//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_scanner_included_
  #endinput
#endif
#define _rp_scanner_included_

//int ScannerEnt = -1;

public void OnMapStart_Scanner()
{

	//Timer:
	CreateTimer(30.0, SpawnScanner);
}

public Action SpawnScanner(Handle Timer)
{

	//Declare:
	float Position[3];

	//Initulize:
	GetRandomSpawnPosition(0, Position);
}