/*
Vice City Multiplayer 0.4 Blank Server (by Seby) for 64bit Windows.
You can use it to script your own server. Here you can find all events developed.

VC:MP Official: www.vc-mp.org
Forum: forum.vc-mp.org
Wiki: wiki.vc-mp.org
*/

local   SRV_NAME = GetServerName(),
        SRV_PASS = GetPassword();

        
// Creating a connection between client and server scripts
// I'm using bytes for identification, because they are the most waste-less for the designated task
// This must be the same in both, client-side and server-side.
enum StreamType
{
    ServerName = 0x01
}

// =========================================== S E R V E R   E V E N T S ==============================================

/*
function onServerStart()
{
}

function onServerStop()
{
}
*/

function onScriptLoad()
{
	ClanDB <- ConnectSQL("Clan.db");
  QuerySQL(ClanDB, "CREATE TABLE IF NOT EXISTS Clans(ID INTEGER PRIMARY KEY AUTOINCREMENT, Owner VARCHAR(50), Name VARCHAR(25), Tag VARCHAR(6), Kills INT DEFAULT 0, Deaths INT DEFAULT 0, Money INT DEFAULT 0, TotalMembers INT DEFAULT 0, Ranks VARCHAR(255), skinID INT DEFAULT 0, teamID INT DEFAULT 0, defRank VARCHAR(20) DEFAULT Member, TagEnabled BOOLEAN DEFAULT true)");
  QuerySQL(ClanDB, "CREATE TABLE IF NOT EXISTS ClanMembers(Player VARCHAR(100), Clan VARCHAR(25), Owner BOOLEAN DEFAULT false, Kills INT DEFAULT 0, Deaths INT DEFAULT 0, Money INT DEFAULT 0, Rank VARCHAR(255))");


ClanStat <- array(GetMaxPlayers(), null); // Array to store player clan data.
Clan <- array(GetMaxPlayers(), null); // Array to store clan data.


dofile("scripts/ClanSys.nut"); // Include ClanSys.nut script.

LoadClanStats(); // Load clan data.
print("Gitto's Clan System Loaded")
}

function onScriptUnload()
{
}

// =========================================== P L A Y E R   E V E N T S ==============================================

function onPlayerJoin( player )
{
	
ClanStat[ player.ID ] = ClanInfo(); // Connect player ID with ClanInfo class.
LoadClan(player); // Load player's clan data if they are in a clan.
}

function onPlayerPart( player, reason )
{
	if(ClanStat[player.ID].InClan) SaveClanInfo(player); // Save clan data when player quits.
}

function onPlayerRequestClass( player, classID, team, skin )
{
	return 1;
}

function onPlayerRequestSpawn( player )
{
	return 1;
}

function onPlayerSpawn( player )
{
}

function onPlayerDeath( player, reason )
{
	if(ClanStat[player.ID].InClan) {
    ClanStat[player.ID].Deaths++; // Increase player's contribution deaths for clan.
    Clan[ClanStat[player.ID].ID].Deaths++; // Increase clan deaths.
	}
}

function onPlayerKill( player, killer, reason, bodypart )
{
	if(ClanStat[player.ID].InClan) {
    ClanStat[player.ID].Deaths++; // Increase player's contribution kills for clan.
    Clan[ClanStat[player.ID].ID].Deaths++; // Increase clan deaths.

    ClanStat[player.ID].Money+=500; // Increase player's contribution money for clan.
    Clan[ClanStat[player.ID].ID].Money+=500; // Increase clan's money.
}
}

function onPlayerTeamKill( player, killer, reason, bodypart )
{
}

function onPlayerChat( player, text )
{

	local clanID = ClanStat[player.ID].ID;
if(ClanStat[player.ID].InClan && Clan[clanID].TagEnabled) {
    Message("[#47A992][[#ffffff]" + Clan[clanID].Tag + "[#47A992]]~" + player.Name + "[#47A992]: [#ffffff]" + text); // Displays player's chat message with clan tag if available
} else {
	print( player.Name + ": " + text )
	 return 1;
}
}

function onPlayerCommand( player, cmd, text )
{
	onClanCommand(player, cmd, text)

	if(cmd == "heal")
	{
		local hp = player.Health;
		if(hp == 100) Message("[#FF3636]Error - [#8181FF]Use this command when you have less than 100% hp !");
		else {
			player.Health = 100.0;
			MessagePlayer( "[#FFFF81]---> You have been healed !", player );
		}
	}
	
	else if(cmd == "goto") {
		if(!text) MessagePlayer( "Error - Correct syntax - /goto <Name/ID>' !",player );
		else {
			local plr = FindPlayer(text);
			if(!plr) MessagePlayer( "Error - Unknown player !",player);
			else {
				player.Pos = plr.Pos;
				MessagePlayer( "[ /" + cmd + " ] " + player.Name + " was sent to " + plr.Name, player );
			}
		}
		
	}
	else if(cmd == "bring") {
		if(!text) MessagePlayer( "Error - Correct syntax - /bring <Name/ID>' !",player );
		else {
			local plr = FindPlayer(text);
			if(!plr) MessagePlayer( "Error - Unknown player !",player);
			else {
				plr.Pos = player.Pos;
				MessagePlayer( "[ /" + cmd + " ] " + plr.Name + " was sent to " + player.Name, player );
			}
		}
	}
    
	/*
	else if(cmd == "exec") 
	{
		if( !text ) MessagePlayer( "Error - Syntax: /exec <Squirrel code>", player);
		else
		{
			try
			{
				local script = compilestring( text );
				script();
			}
			catch(e) MessagePlayer( "Error: " + e, player);
		}
	}
    */
    
	return 1;
}

function onPlayerPM( player, playerTo, message )
{
	return 1;
}

function onPlayerBeginTyping( player )
{
}

function onPlayerEndTyping( player )
{
}

/*
function onLoginAttempt( player )
{
	return 1;
}
*/

function onNameChangeable( player )
{
}

function onPlayerSpectate( player, target )
{
}

function onPlayerCrashDump( player, crash )
{
}

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ )
{
}

function onPlayerHealthChange( player, lastHP, newHP )
{
}

function onPlayerArmourChange( player, lastArmour, newArmour )
{
}

function onPlayerWeaponChange( player, oldWep, newWep )
{
}

function onPlayerAwayChange( player, status )
{
}

function onPlayerNameChange( player, oldName, newName )
{
}

function onPlayerActionChange( player, oldAction, newAction )
{
}

function onPlayerStateChange( player, oldState, newState )
{
}

function onPlayerOnFireChange( player, IsOnFireNow )
{
}

function onPlayerCrouchChange( player, IsCrouchingNow )
{
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
}

function onPlayerUpdate( player, update )
{
}

function onClientScriptData( player )
{
    // receiving client data
    local stream = Stream.ReadByte();
    switch ( stream )
    {
        case StreamType.ServerName:
        {
            Message( "Server received client's request, so it's sending back the server name." );
            // server received the request of client-side, so it sends back the server name
            SendDataToClient( player, StreamType.ServerName, SRV_NAME );
        }
        break;
    }
}

// ========================================== V E H I C L E   E V E N T S =============================================

function onPlayerEnteringVehicle( player, vehicle, door )
{
	return 1;
}

function onPlayerEnterVehicle( player, vehicle, door )
{
}

function onPlayerExitVehicle( player, vehicle )
{
}

function onVehicleExplode( vehicle )
{
}

function onVehicleRespawn( vehicle )
{
}

function onVehicleHealthChange( vehicle, oldHP, newHP )
{
}

function onVehicleMove( vehicle, lastX, lastY, lastZ, newX, newY, newZ )
{
}

// =========================================== P I C K U P   E V E N T S ==============================================

function onPickupClaimPicked( player, pickup )
{
	return 1;
}

function onPickupPickedUp( player, pickup )
{
}

function onPickupRespawn( pickup )
{
}

// ========================================== O B J E C T   E V E N T S ==============================================

function onObjectShot( object, player, weapon )
{
}

function onObjectBump( object, player )
{
}

// ====================================== C H E C K P O I N T   E V E N T S ==========================================

function onCheckpointEntered( player, checkpoint )
{
}

function onCheckpointExited( player, checkpoint )
{
}

// =========================================== B I N D   E V E N T S =================================================

function onKeyDown( player, key )
{
}

function onKeyUp( player, key )
{
}

// ================================== E N D   OF   O F F I C I A L   E V E N T S ======================================


function SendDataToClient( player, ... )
{
    if( vargv[0] )
    {
        local     byte = vargv[0],
                len = vargv.len();
                
        if( 1 > len ) devprint( "ToClent <" + byte + "> No params specified." );
        else
        {
            Stream.StartWrite();
            Stream.WriteByte( byte );

            for( local i = 1; i < len; i++ )
            {
                switch( typeof( vargv[i] ) )
                {
                    case "integer": Stream.WriteInt( vargv[i] ); break;
                    case "string": Stream.WriteString( vargv[i] ); break;
                    case "float": Stream.WriteFloat( vargv[i] ); break;
                }
            }
            
            if( player == null ) Stream.SendStream( null );
            else if( typeof( player ) == "instance" ) Stream.SendStream( player );
            else devprint( "ToClient <" + byte + "> Player is not online." );
        }
    }
    else devprint( "ToClient: Even the byte wasn't specified..." );
}

function GetTok(string, separator, n, ...)
{
local m = vargv.len() > 0 ? vargv[0] : n,
tokenized = split(string, separator),
text = "";
if (n > tokenized.len() || n < 1) return null;
for (; n <= m; n++)
{
text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
}
return text;
}
function NumTok(string, separator)
{
	local tokenized = split(string, separator);
	return tokenized.len();
}
function Random( min, max ) // incase you don't have the random(a,b) function
{
	if ( min < max )
	return rand() % (max - min + 1) + min.tointeger();
	else if ( min > max )
	return rand() % (min - max + 1) + max.tointeger();
	else if ( min == max )
	return min.tointeger();
}

