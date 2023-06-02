// Put this into onScriptLoad

ClanDB <- ConnectSQL("Clan.db");
  QuerySQL(ClanDB, "CREATE TABLE IF NOT EXISTS Clans(ID INTEGER PRIMARY KEY AUTOINCREMENT, Owner VARCHAR(50), Name VARCHAR(25), Tag VARCHAR(6), Kills INT DEFAULT 0, Deaths INT DEFAULT 0, Money INT DEFAULT 0, TotalMembers INT DEFAULT 0, Ranks VARCHAR(255), skinID INT DEFAULT 0, teamID INT DEFAULT 0, defRank VARCHAR(20) DEFAULT Member, TagEnabled BOOLEAN DEFAULT true)");
  QuerySQL(ClanDB, "CREATE TABLE IF NOT EXISTS ClanMembers(Player VARCHAR(100), Clan VARCHAR(25), Owner BOOLEAN DEFAULT false, Kills INT DEFAULT 0, Deaths INT DEFAULT 0, Money INT DEFAULT 0, Rank VARCHAR(255))");

ClanStat <- array(GetMaxPlayers(), null); // Array to store player clan data.
Clan <- array(GetMaxPlayers(), null); // Array to store clan data.

dofile("scripts/ClanSys.nut"); // Include ClanSys.nut script.

LoadClanStats(); // Load clan data.


// Put this into onPlayerJoin

ClanStat[ player.ID ] = ClanInfo(); // Connect player ID with ClanInfo class.
LoadClan(player); // Load player's clan data if they are in a clan.

// Put this into onPlayerPart
if(ClanStat[player.ID].InClan) SaveClanInfo(player); // Save clan data when player quits.

// Put this into onPlayerDeath
if(ClanStat[player.ID].InClan) {
    ClanStat[player.ID].Deaths++; // Increase player's contribution deaths for clan.
    Clan[ClanStat[player.ID].ID].Deaths++; // Increase clan deaths.
}


// Put this into onPlayerKill
if(ClanStat[player.ID].InClan) {
    ClanStat[player.ID].Deaths++; // Increase player's contribution kills for clan.
    Clan[ClanStat[player.ID].ID].Deaths++; // Increase clan deaths.

    ClanStat[player.ID].Money+=500; // Increase player's contribution money for clan.
    Clan[ClanStat[player.ID].ID].Money+=500; // Increase clan's money.
}
// Put this into onPlayerChat

local clanID = ClanStat[player.ID].ID;
if(ClanStat[player.ID].InClan && Clan[clanID].TagEnabled) {
    Message("[#47A992][[#ffffff]" + Clan[clanID].Tag + "[#47A992]]~" + player.Name + "[#47A992]: [#ffffff]" + text); // Displays player's chat message with clan tag if available
}

// Put this onPlayerSpawn

if(ClanStat[player.ID].InClan) {
  local clanID = ClanStat[player.ID].ID;
  if(Clan[clanID].skinID != 0) player.Skin = Clan[clanID].skinID;
  if(Clan[clanID].teamID != 0) player.Team = Clan[clanID].teamID;
  }

// Put this onPlayerCommand
	onClanCommand(player, cmd, text)

/////// THAT's IT! \\\\\
// Place the ClanSys.nut file correctly, and enjoy my clan system! :)

//-> YOU DON'T HAVE TO COPY THIS FILE, AND CONNECT IT TO MAIN.NUT, JUST COPY THE STUFF INSIDE OF IT AND PASTE TO THEIR RESPECTIVE PLACES.
