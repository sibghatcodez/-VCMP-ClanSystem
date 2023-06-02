class ClanInfo
{
 ID = 0;
 Owner = false;
 Clan = "None";
    
 Kills = 0;
 Deaths = 0;
 Money = 0;

 Invited = false;
 InClan = false;
 Requester = "";

 Rank = "Member";
}

class Clans
{
    ID = 0;
    Owner = "None";
    Name = "None";
    Tag = "None";
    Kills = 0;
    Deaths = 0;
    Money = 0;
    TotalMembers = 0;
    Ranks = "";

    //Extra
    skinID = 0;
    teamID = 0;
    defRank = "Member";
    TagEnabled = true;
}


function onClanCommand( player, cmd, text )
{
    switch(cmd) {


case "clancmds":
  MessagePlayer("[#47A992]Clan Commands: [#ffffff]/createclan, /accept, /clanchat (cc), /leaveclan, /clans, /clan, /clanmembers, /ranks, /request", player);
  if (ClanStat[player.ID].Rank == "Owner") {
    MessagePlayer("[#47A992]Clan Owner Commands: [#ffffff]/invite, /kick, /giveclancash, /setdefrank, /addrank, /delrank, /setrank, /transferownership, /setting, /acceptrequest, /delclan", player);
  }
  break;

       
case "createclan":
  if (ClanStat[player.ID].InClan) {
    MessagePlayer("[#ffffff]Error 69: [#DB005B]Freak! You are already in a clan", player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [clanName] [clanTag]", player);
  }
  else {
    local clan = GetTok(text, " ", 1);
    local clanTag = GetTok(text, " ", 2);
    local Rank = "Member";
    local q = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE Name='" + clan + "'");
    
    if (q && GetSQLColumnData(q, 2) == clan) {
      MessagePlayer("[#ffffff]Error 69: [#DB005B]Clan name not available, try another.", player);
    }
    else if (!clan || !clanTag) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [clanName] [clanTag]", player);
    }
    else if (clan.len() > 25) {
      MessagePlayer("[#ffffff]Error 69: [#DB005B]Clan name is too long.", player);
    }
    else if (clanTag.len() > 6) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Clan tag is too long.", player);
    }
    else {
        local q = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE Tag='" + clanTag + "'");
        if (q && GetSQLColumnData(q, 3) == clanTag) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Clan tag not available, try another.", player);
          }
    else {
        QuerySQL(ClanDB, "INSERT INTO Clans(Owner, Name, Tag, Kills, Deaths, Money, TotalMembers, Ranks) VALUES('" + escapeSQLString(player.Name.tolower()) + "', '" + clan + "', '" + clanTag + "', '" + 0 + "', '" + 0 + "', '" + 0 + "', '" + 1 + "', '" + Rank + "')");
      
        QuerySQL(ClanDB, "INSERT INTO ClanMembers(Player, Clan, Owner, Kills, Deaths, Money, Rank) VALUES('" + escapeSQLString(player.Name.tolower()) + "', '" + clan + "', '" + true + "', '" + 0 + "', '" + 0 + "', '" + 0 + "', '" + "Owner" + "')");

       Message("[#47A992]-> [#ffffff]"+player.Name + "[#47A992] has created clan [#ffffff]" + clan + "[#47A992] [ [#ffffff]" + clanTag + " [#47A992]]");
      MessagePlayer("[#47A992]-> You can grow your clan by inviting players using [#ffffff]/invite", player);
      local rowID;
      local q2 = QuerySQL(ClanDB, "SELECT last_insert_rowid()");
      
      if (q2) {
        rowID = GetSQLColumnData(q2, 0);
      }

      ClanStat[player.ID].InClan = true;
      ClanStat[player.ID].Owner = true;
      ClanStat[player.ID].Clan = clan;
      ClanStat[player.ID].ID = rowID;
      ClanStat[player.ID].Rank = "Owner";

      local id = rowID;
      Clan[id] = Clans();
      Clan[id].ID = rowID;
      Clan[id].Owner = player.Name.tolower();
      Clan[id].Name = clan;
      Clan[id].Tag = clanTag;
      Clan[id].Kills = 0;
      Clan[id].Deaths = 0;
      Clan[id].Money = 0;
      Clan[id].TotalMembers = 1;
      Clan[id].Ranks = "Member";
      }
    }
    }
  break;






case "accept":
  if (ClanStat[player.ID].InClan) {
    MessagePlayer("[#ffffff]Error 69: [#DB005B]Freak! You are already in a clan", player);
  }
  else if (!ClanStat[player.ID].Invited) {
    MessagePlayer("[#ffffff]Error 69: [#DB005B]Prick, you aren't invited by anyone.", player);
  }
  else {
    local inviter = ClanStat[player.ID].Requester;
    local plr = FindPlayer(inviter);
    
    if (plr) {
      ClanStat[player.ID].InClan = true;
      ClanStat[player.ID].Owner = false;
      ClanStat[player.ID].Clan = ClanStat[plr.ID].Clan;
      ClanStat[player.ID].ID = ClanStat[plr.ID].ID;
      ClanStat[player.ID].Rank = Clan[ClanStat[player.ID].ID].defRank;
      ClanStat[player.ID].Requester = "";
      local clanID = ClanStat[plr.ID].ID;
      MessagePlayer("[#47A992]-> You joined Clan: [[#ffffff] " + ClanStat[plr.ID].Clan+" [#47A992]] as [[#ffffff] " + Clan[clanID].defRank+" [#47A992]]", player);
      QuerySQL(ClanDB, "INSERT INTO ClanMembers(Player, Clan, Owner, Kills, Deaths, Money, Rank) VALUES('" + escapeSQLString(player.Name.tolower()) + "', '" + ClanStat[plr.ID].Clan + "', '" + false + "', '" + 0 + "', '" + 0 + "', '" + 0 + "', '" + "Member" + "')");
      Clan[ClanStat[plr.ID].ID].TotalMembers++;
    } else {
      MessagePlayer("[#ffffff]Error 69: [#DB005B]Inviter disconnected, request expired.", player);
    }
  }
  break;




case "cc":
case "clanchat":
  if (!ClanStat[player.ID].InClan) {
    MessagePlayer(ErrorMSG(), player);
  } else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [text]", player);
  } else {
    for (local i = 0; i <= GetMaxPlayers(); i++) {
      local targetPlayer = FindPlayer(i);
      if (targetPlayer && ClanStat[player.ID].Clan == ClanStat[targetPlayer.ID].Clan) {
        MessagePlayer("[#47A992]-> [#ffffff]"+player.Name + "[[#47A992]"+ClanStat[player.ID].Clan+"[#ffffff]]: [#47A992]" + text, targetPlayer);
      }
    }
  }
  break;





        case "leaveclan":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank == "Owner") {
      MessagePlayer("[#47A992]-> Your clan: [[#ffffff] " + ClanStat[player.ID].Clan+" [#47A992]] has been deleted.", player);
      QuerySQL(ClanDB, "DELETE FROM Clans WHERE Name='" + ClanStat[player.ID].Clan + "'");
      QuerySQL(ClanDB, "DELETE FROM ClanMembers WHERE Clan='" + ClanStat[player.ID].Clan + "'");
      ClanStat[player.ID].Owner = false;
      ClanStat[player.ID].Clan = "None";
      ClanStat[player.ID].Kills = 0;
      ClanStat[player.ID].Deaths = 0;
      ClanStat[player.ID].Money = 0;
      ClanStat[player.ID].InClan = false;
      ClanStat[player.ID].Rank = "None";
    }
  else {
    local q = QuerySQL(ClanDB, "SELECT * FROM ClanMembers WHERE Player='" + player.Name.tolower() + "'");
    if (q) {
      MessagePlayer("[#47A992]-> You left Clan: [[#ffffff] " + ClanStat[player.ID].Clan+" [#47A992]]", player);
      local clanID = ClanStat[player.ID].ID;
      Clan[clanID].TotalMembers-=1;
      ClanStat[player.ID].Owner = false;
      ClanStat[player.ID].Clan = "None";
      ClanStat[player.ID].Kills = 0;
      ClanStat[player.ID].Deaths = 0;
      ClanStat[player.ID].Money = 0;
      ClanStat[player.ID].InClan = false;
      ClanStat[player.ID].Rank = "None";
      QuerySQL(ClanDB, "DELETE FROM ClanMembers WHERE Player='" + player.Name.tolower() + "'");
    }
  }
  break;


case "clans":
  local q = QuerySQL(ClanDB, "SELECT * FROM Clans");
  local clans = "";
  local total_Clans = 0;
  if (q) {
    do {
      local clan = GetSQLColumnData(q, 2);
      clans += GetSQLColumnData(q, 2) + ",";
      total_Clans++;
    } while (GetSQLNextRow(q))
    local totalClans = split(clans, ",").len();
    MessagePlayer("[#47A992]-> Total Clans: ([#ffffff]" + total_Clans + "[#47A992])", player);
    local clayn = split(clans, ",");
    for (local i = 0; i < clayn.len(); i++) {
      MessagePlayer("[#47A992]-> [#ffffff]" + clayn[i], player);
    }
  } else {
    MessagePlayer("[#ffffff]Error 69: [#DB005B]There are no clans registered.", player);
  }
  break;

  case "clansx":
    local clanID = ClanStat[player.ID].ID;
    local totalRanks = split(Clan[clanID].Ranks, ",").len();
    MessagePlayer("[#47A992]Total Ranks: ([#ffffff]" + totalRanks + "[#47A992])", player);
    local ranks = split(Clan[clanID].Ranks, ",");
    for (local i = 0; i < ranks.len(); i++) {
      MessagePlayer("[#47A992]-> [#ffffff]" + ranks[i], player);
    }

  break;



case "clan":
  local clanID = ClanStat[player.ID].ID;
  local q = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE ID='"+clanID+"'");

  if (!text) {
    if (!ClanStat[player.ID].InClan) {
      MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [clanName]", player);
    } else if (!text){
      MessagePlayer("[#47A992]-> [#ffffff]"+Clan[clanID].Name+"[#47A992]'s Owner: [#ffffff]"+Clan[clanID].Owner+" [#47A992]Kills: [#ffffff]"+Clan[clanID].Kills+" [#47A992]Deaths: [#ffffff]"+Clan[clanID].Deaths+" [#47A992]Money: [#ffffff]$[#47A992]"+Clan[clanID].Money,
        player
      );
      MessagePlayer(
        "[#47A992]-> My Contribution: for [#ffffff]"+ClanStat[player.ID].Clan+" [#47A992]Kills: [#ffffff]"+ClanStat[player.ID].Kills+" [#47A992]Deaths: [#ffffff]"+ClanStat[player.ID].Deaths+" [#47A992]Money: [#ffffff]$[#47A992]"+ClanStat[player.ID].Money,
        player);

      MessagePlayer("[#47A992]-> Your Rank: [[#ffffff] "+ClanStat[player.ID].Rank+" [#47A992]]",player);
    }
  } else {
    q = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE Name='"+text+"'");

    if (IsNum(text)) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Clan name should be a string", player);
    } else if (!q) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] "+text+" clan doesn't exist.", player);
    } else {
      MessagePlayer("[#47A992]-> [#ffffff]"+text+"[#47A992]'s Owner: [#ffffff]"+GetSQLColumnData(q,1)+" [#47A992]Kills: [#ffffff]"+GetSQLColumnData(q,4)+" [#47A992]Deaths: [#ffffff]"+GetSQLColumnData(q,5)+" [#47A992]Money: [#ffffff]$[#47A992]"+GetSQLColumnData(q,6),player);
    }
  }
  break;



case "clanmembers":
        local q = QuerySQL(ClanDB, "SELECT * FROM ClanMembers WHERE Clan='"+ClanStat[player.ID].Clan+"'");
        local members = "",
        rank = "",
        total_Members = 0;
        if (q) {
          do {
            rank = GetSQLColumnData(q, 6);
            members += GetSQLColumnData(q, 0) + "[[#47A992]"+rank+"[#ffffff]] | ";
            total_Members++;
          } while (GetSQLNextRow(q))
          
          MessagePlayer("[#47A992]-> Total Members: ([#ffffff]"+total_Members+"[#47A992])", player);
          MessagePlayer("[#47A992]-> [#ffffff]"+members, player);

        } else {
          MessagePlayer("[#ffffff]Error 69: [#DB005B]No clans found.", player);
        }
        
        break;




case "ranks":
  if (!ClanStat[player.ID].InClan) {
    MessagePlayer(ErrorMSG(), player);
  }
  else {
    local clanID = ClanStat[player.ID].ID;
    local totalRanks = split(Clan[clanID].Ranks, ",").len();
    MessagePlayer("[#47A992]Total Ranks: ([#ffffff]" + totalRanks + "[#47A992])", player);
    local ranks = split(Clan[clanID].Ranks, ",");
    for (local i = 0; i < ranks.len(); i++) {
      MessagePlayer("[#47A992]-> [#ffffff]" + ranks[i], player);
    }
  }
  break;

 case "request":
        if(ClanStat[player.ID].InClan) MessagePlayer("[#ffffff]Error 69: [#DB005B]Dudee! You are already in a clan.",player);
        else if (!text) MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [target player]", player);
        else {
          local plr = FindPlayer(text);
          if(!plr) MessagePlayer("Target player is offline",player);
          else if (!ClanStat[plr.ID].InClan) MessagePlayer("Error 69: Target player is not in any clan",player);
          else if(ClanStat[plr.ID].Rank != "Owner") MessagePlayer("Error 69: Target player is not the owner.",player);
          else {
            MessagePlayer("[#47A992]-> "+ClanStat[plr.ID].Clan+"[#ffffff]'s Join request sent to [#ffffff]"+plr.Name+"",player);
            MessagePlayer("[#47A992]-> "+player.Name+" [#ffffff]wants to join your clan [#47A992]"+ClanStat[plr.ID].Clan+"",plr);
            MessagePlayer("[#47A992]-> Type [#ffffff]/acceptrequest [#47A992]to accept [#ffffff]"+plr.Name+"[#47A992]'s joining request.",plr);

            ClanStat[plr.ID].Requester = player.Name;
          }
        }
        break;

      
///////////////////// CLAN OWNER COMMANDS \\\\\\\\\\\\\\\\\\\\\\\\

case "invite":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [target player]", player);
  }
  else {
    local targetPlayer = FindPlayer(text);
    
    if (!targetPlayer) {
      MessagePlayer("[#ffffff]Error 69: [#DB005B]Target player is offline", player);
    }
    else if (ClanStat[targetPlayer.ID].InClan) {
      MessagePlayer("[#ffffff]Error 69: [#DB005B]Target player is already in a clan", player);
    }
    else {
      MessagePlayer("[#79E0EE]-> Invitation to join [[#ffffff] " + ClanStat[player.ID].Clan + " [#79E0EE]] has been sent to [#ffffff]" + targetPlayer.Name, player);
      MessagePlayer("[#79E0EE]-> You have received an invitation to join [ [#ffffff]" + ClanStat[player.ID].Clan + " [#79E0EE]] from [#ffffff]" + player.Name, targetPlayer);
      MessagePlayer("[#79E0EE]-> Type [#ffffff]/accept to join [#79E0EE]" + ClanStat[player.ID].Clan, targetPlayer);

      ClanStat[targetPlayer.ID].Invited = true;
      ClanStat[targetPlayer.ID].Requester = player.Name;
    }
  }
  break;


  case "kick":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [target player] [reason]", player);
  }
  else {
    local targetPlayerName = GetTok(text, " ", 1);
    local reason = GetTok(text, " ", 2);
    
    if (!targetPlayerName) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is offline", player);
    }
    else {
      local targetPlayer = FindPlayer(targetPlayerName);
      
      if (!targetPlayer) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is offline", player);
      }
      else if (ClanStat[player.ID].Clan != ClanStat[targetPlayer.ID].Clan) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player should be in the same clan as you.", player);
      }
      else if (player.ID == targetPlayer.ID) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] You cannot kick yourself B)", player);
      }
      else {
        if (reason == null) {
          reason = "[#79E0EE]Noobies aren't allowed in our clan. GTFO!";
        }
        
        MessagePlayer("[#79E0EE]-> You kicked out [#ffffff]" + targetPlayer.Name + " [#79E0EE]from [ [#ffffff]" + ClanStat[player.ID].Clan + " [#79E0EE]] for reason: [#ffffff]" + reason, player);
        MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name + " [#79E0EE]has kicked you out from [ [#ffffff]" + ClanStat[player.ID].Clan + " [#79E0EE]] for reason: [#ffffff]" + reason, targetPlayer);
        
        local clanID = ClanStat[targetPlayer.ID].ID;
        Clan[clanID].TotalMembers--;
        ClanStat[targetPlayer.ID].ID = 0;
        ClanStat[targetPlayer.ID].Owner = false;
        ClanStat[targetPlayer.ID].Clan = "None";
        ClanStat[targetPlayer.ID].Kills = 0;
        ClanStat[targetPlayer.ID].Deaths = 0;
        ClanStat[targetPlayer.ID].Money = 0;
        ClanStat[targetPlayer.ID].InClan = false;
        ClanStat[targetPlayer.ID].Rank = "None";
        
        QuerySQL(ClanDB, "DELETE FROM ClanMembers WHERE Player='" + targetPlayer.Name.tolower() + "'");
      }
    }
  }
  break;




case "giveclancash":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [target player] [cash]", player);
  }
  else {
    local targetPlayerName = GetTok(text, " ", 1);
    local cash = GetTok(text, " ", 2);
    
    if (!targetPlayerName) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is offline.", player);
    }
    else if (!cash || !IsNum(cash)) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Money should be an integer.", player);
    }
    else {
      local targetPlayer = FindPlayer(targetPlayerName);
      
      if (!targetPlayer) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is offline.", player);
      }
      else if (!ClanStat[targetPlayer.ID].InClan) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is not in any clan.", player);
      }
      else if (ClanStat[player.ID].Clan != ClanStat[targetPlayer.ID].Clan) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player should be in the same clan as you.", player);
      }
      else if (Clan[ClanStat[player.ID].ID].Money < cash.tointeger()) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Your clan doesn't have that much money.", player);
      }
      else {
        targetPlayer.Cash += cash.tointeger();
        Clan[ClanStat[player.ID].ID].Money -= cash.tointeger();
        MessagePlayer("[#79E0EE]-> You sent $[#ffffff]" + cash + "[#79E0EE] to [#ffffff]" + targetPlayer.Name + " [#79E0EE]from the clan bank.", player);
        MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name + " [#79E0EE]sent you $[#ffffff]" + cash + " [#79E0EE]from the clan bank.", targetPlayer);
      }
    }
  }
  break;



case "setdefrank":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [rank]", player);
  }
  else {
    local rank = GetTok(text, " ", 1);
    local clanID = ClanStat[player.ID].ID;
    local existingRanks = Clan[clanID].Ranks;
    local ranks = split(existingRanks, ",");
    local rankExists = false;

    for (local i = 0; i < ranks.len(); i++) {
      if (ranks[i] == rank) {
        rankExists = true;
        break;
      }
    }

    if (!rankExists) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] The specified rank does not exist, /ranks", player);
    }
    else {
      Clan[clanID].defRank = rank;
      MessagePlayer("[#79E0EE]-> You changed the default clan rank to [#ffffff]" + Clan[clanID].defRank, player);
    }
  }
  break;



case "addrank":
  if (!ClanStat[player.ID].InClan) {
    MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [rankName]", player);
  }
  else if (IsNum(text)) {
    MessagePlayer("[#ffffff]Error 69:[#DB005B] rankName should be a string.", player);
  }
  else {
    local rank = GetTok(text, " ", 1);
    local clanID = ClanStat[player.ID].ID;
    local existingRanks = Clan[clanID].Ranks;
    local ranks = split(existingRanks, ",");
    local rankExists = false;

    for (local i = 0; i < ranks.len(); i++) {
      if (ranks[i] == rank) {
        rankExists = true;
        break;
      }
    }

    if (rankExists) {
      MessagePlayer("[#ffffff]Error 69: [#DB005B]The specified rank already exists", player);
    }
    else {
      Clan[clanID].Ranks += ","+rank;
      MessagePlayer("[#79E0EE]-> New clan rank added: [#ffffff][ [#79E0EE]" + rank +" [#ffffff]]", player);
      SaveClanInfo(player);
    }
  }
  break;



case "delrank":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [rankName]", player);
  }
  else if (IsNum(text)) {
    MessagePlayer("[#ffffff]Error 69:[#DB005B] rankName should be a string.", player);
  }
  else {
    local rank = GetTok(text, " ", 1);
    local clanID = ClanStat[player.ID].ID;
    local existingRanks = Clan[clanID].Ranks;
    local ranks = split(existingRanks, ",");
    local rankExists = false;

    for (local i = 0; i < ranks.len(); i++) {
      if (ranks[i] == rank) {
        rankExists = true;
        break;
      }
    }

    if (!rankExists) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] The specified rank does not exist", player);
    }
    else {
      local newRanks = "";
      for (local i = 0; i < ranks.len(); i++) {
        if (ranks[i] != rank) {
          newRanks += ranks[i] + ",";
        }
      }
      Clan[clanID].Ranks = newRanks;

      QuerySQL(ClanDB, "UPDATE Clans SET Ranks='" + Clan[clanID].Ranks + "' WHERE Name='" + Clan[clanID].Name + "'");
      QuerySQL(ClanDB, "UPDATE ClanMembers SET Rank='" + "Member" + "' WHERE Rank='" + rank + "'");

      for (local i = 0; i <= GetMaxPlayers(); i++) {
        local plr = FindPlayer(i);
        if (plr && ClanStat[plr.ID].InClan && ClanStat[plr.ID].Clan == ClanStat[player.ID].Clan) {
          if (ClanStat[plr.ID].Rank == rank) {
            ClanStat[plr.ID].Rank = "Member";
          }
        }
      }
      
      MessagePlayer("[#79E0EE]-> [[#ffffff] "+rank + " [#79E0EE]] rank has been deleted.", player);
    }
  }
  break;





case "setrank":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [target player] [rank]", player);
  }
  else {
    local targetPlayerName = GetTok(text, " ", 1);
    local rank = GetTok(text, " ", 2);
    
    if (!targetPlayerName) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is not specified", player);
    }
    else if (!rank) {
      MessagePlayer("[#ffffff]Error 69:[#DB005B] Rank is not specified", player);
    }
    else {
      local targetPlayer = FindPlayer(targetPlayerName);
      
      if (!targetPlayer) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is offline", player);
      }
      else if (ClanStat[player.ID].Clan != ClanStat[targetPlayer.ID].Clan) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player should be in the same clan as you", player);
      }
      else if (player.ID == targetPlayer.ID) {
        MessagePlayer("[#ffffff]Error 69:[#DB005B] You cannot change your own rank", player);
      }
      else {
        local clanID = ClanStat[player.ID].ID;
        local existingRanks = Clan[clanID].Ranks;
        local ranks = split(existingRanks, ",");
        local rankExists = false;
        
        for (local i = 0; i < ranks.len(); i++) {
          if (ranks[i] == rank) {
            rankExists = true;
            break;
          }
        }
        
        if (!rankExists) {
          MessagePlayer("[#ffffff]Error 69:[#DB005B] The specified rank does not exist", player);
        }
        else {
          ClanStat[targetPlayer.ID].Rank = rank;
          MessagePlayer("[#79E0EE]-> You changed the rank of [#ffffff]" + targetPlayer.Name + " [#79E0EE]to [[#fffff] " + ClanStat[targetPlayer.ID].Rank+"[#79E0EE] ]", player);
          MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name + "[#79E0EE] has changed your rank to [[#ffffff]" + ClanStat[targetPlayer.ID].Rank +" [#79E0EE]]", targetPlayer);
        }
      }
    }
  }
  break;






case "transferownership":
          if(!ClanStat[player.ID].InClan) MessagePlayer(ErrorMSG(), player);
          else if(ClanStat[player.ID].Rank != "Owner") MessagePlayer(ClanOwnerError(), player);
          else if (!text) MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [target player]", player);
          else {
            local plr = FindPlayer(text);
            if(!plr) MessagePlayer("[#ffffff]Error 69:[#DB005B] Target player is offline",player);
            else if (!ClanStat[ plr.ID ].InClan) MessagePlayer("[#ffffff]Error 69:[#DB005B] Requested player should be in same clan as you.",player);
            else if (ClanStat[ player.ID ].Clan != ClanStat[ plr.ID ].Clan) MessagePlayer("[#ffffff]Error 69:[#DB005B] Requested player should be in same clan as you.",player);
            else {
          local query_1 = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE Name='"+ClanStat[ player.ID ].Clan+"'");
          local query_2 = QuerySQL(ClanDB, "SELECT * FROM ClanMembers WHERE Player='"+player.Name.tolower()+"'");
          if(query_1 && query_2 && ClanStat[player.ID].Owner) {
            QuerySQL( ClanDB, "UPDATE Clans SET Owner='"+plr.Name.tolower()+"' WHERE Name = '"+ClanStat[player.ID].Clan +"'");
            QuerySQL( ClanDB, "UPDATE ClanMembers SET Owner='"+false+"' WHERE Clan = '"+ClanStat[player.ID].Clan +"'");
            MessagePlayer("[#79E0EE]-> [#ffffff]"+ClanStat[player.ID].Clan+"[#79E0EE]'s Ownership transferred to [#ffffff]"+plr.Name+"",player);
            ClanStat[ player.ID ].Owner = false;
            ClanStat[ player.ID ].Rank = "Member";
            ClanStat[ plr.ID ].Owner = true;
            ClanStat[ plr.ID ].Rank = "Owner";
            }
          }
        }
        break;




case "setting":
  if (!ClanStat[player.ID].InClan) {
        MessagePlayer(ErrorMSG(), player);
  }
  else if (ClanStat[player.ID].Rank != "Owner") {
    MessagePlayer(ClanOwnerError(), player);
  }
  else if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [skin/team/tag]", player);
  }
  else {
    local category = GetTok(text, " ", 1);
    local val = GetTok(text, " ", 2);

    if (!category) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [skin/team/tag]", player);
    }
    else if (category == "skin") {
      if (val == null) {
        MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " skin [skinID]", player);
      }
      else if (!IsNum(val)) {
        MessagePlayer("[#ffffff]Error 69: [#DB005B] SkinID should be an integer.", player);
      }
      else {
        ClanSetting(player.Name, "skin", val.tointeger());
      }
    }
    else if (category == "team") {
      if (val == null) {
        MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " team [teamID]", player);
      }
      else if (!IsNum(val)) {
        MessagePlayer("[#ffffff]Error 69: [#DB005B] TeamID should be an integer.", player);
      }
      else {
        ClanSetting(player.Name, "team", val.tointeger());
      }
    }
    else if (category == "tag") {
      local clanID = ClanStat[player.ID].ID;
      if (Clan[clanID].TagEnabled) {
        ClanSetting(player.Name, "tag", false);
      }
      else {
        ClanSetting(player.Name, "tag", true);
      }
    }
    else {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [skin/team/tag]", player);
    }
  }
  break;


case "acceptrequest":
        if(!ClanStat[player.ID].InClan) MessagePlayer(ErrorMSG(), player);
        else if (ClanStat[player.ID].Rank != "Owner") MessagePlayer(ClanOwnerError(), player);
        else if (ClanStat[player.ID].Requester == "") MessagePlayer("[#ffffff]Error 69:[#DB005B] Bruh no one wants to join your clan.",player);
        else {
          local plr = FindPlayer(ClanStat[player.ID].Requester);
          if (plr) {
              ClanStat[plr.ID].InClan = true;
              ClanStat[plr.ID].Owner = false;
              ClanStat[plr.ID].Clan = ClanStat[player.ID].Clan;
              ClanStat[plr.ID].ID = ClanStat[player.ID].ID;
              ClanStat[plr.ID].Rank = Clan[ClanStat[player.ID].ID].defRank;
              MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name+" [#79E0EE]accepted your request, you are now in clan: [[#ffffff] "+ClanStat[player.ID].Clan+" [#79E0EE]]",plr);
              MessagePlayer("[#79E0EE]-> You accepted [#ffffff]"+plr.Name+"[#79E0EE]'s joining request of [[#ffffff] "+ClanStat[player.ID].Clan+" [#79E0EE]]",player);
              QuerySQL(ClanDB, "INSERT INTO ClanMembers(Player,Clan,Owner,Kills,Deaths,Money,Rank) VALUES('" + escapeSQLString(plr.Name.tolower()) + "', '" + ClanStat[plr.ID].Clan + "', '" + false + "', '" + 0 + "', '" + 0 + "', '" + 0 + "', '" + "Member" + "')");
              Clan[ClanStat[player.ID].ID].TotalMembers++;
          } else MessagePlayer("[#ffffff]Error 69:[#DB005B] Requester disconnected, request expired.",player);
        }
        break;



/////////////// CLAN CMDS FOR ADMIN \\\\\\\\\\\\\\\\\

case "delclan":
case "deleteclan":
  local q = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE Name='" + text + "'");
  if (!text) {
    MessagePlayer("[#ffffff]Error 69: [#98EECC]Usage: /" + cmd + " [clanName]", player);
  }
  else if (IsNum(text)) {
    MessagePlayer("[#ffffff]Error 69:[#DB005B] Clan name should be a string", player);
  }
  else if (!q) {
    MessagePlayer("[#ffffff]Error 69:[#DB005B] " + text + " clan doesn't exist.", player);
  }
  else {
    QuerySQL(ClanDB, "DELETE FROM Clans WHERE Name='" + text + "'");
    QuerySQL(ClanDB, "DELETE FROM ClanMembers WHERE Clan='" + text + "'");
    MessagePlayer("[#47A992]-> [#ffffff]"+text + " [#47A992]clan has been deleted.", player);
  }
  break;

        default:
        MessagePlayer("[#47A992]Error 69: Command doesn't exist, try [#ffffff]/clancmds.",player);
        }

}



////////////////////// FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\
function ClanOwnerError()
 {
  local rand = Random(1, 10)
  switch (rand) {
    case 1:
      return "[#ffffff]Error 69:[#DB005B] Sorry, but you are not the owner of the clan.";
      break;
    case 2:
      return "[#ffffff]Error 69:[#DB005B] Oops! Only the clan owner can perform this action.";
      break;
    case 3:
      return "[#ffffff]Error 69:[#DB005B] Uh-oh! You don't have the necessary permissions as a clan member.";
      break;
    case 4:
      return "[#ffffff]Error 69:[#DB005B] Whoops! This action is restricted to clan owners only.";
      break;
    case 5:
      return "[#ffffff]Error 69:[#DB005B] Hold on! You need to be the owner of the clan to proceed.";
      break;
    case 6:
      return "[#ffffff]Error 69:[#DB005B] Apologies, but only the clan owner can perform this action.";
      break;
    case 7:
      return "[#ffffff]Error 69:[#DB005B] Sorry, this action is limited to clan owners.";
      break;
    case 8:
      return "[#ffffff]Error 69:[#DB005B] Attention! Only the clan owner has the authority for this action.";
      break;
    case 9:
      return "[#ffffff]Error 69:[#DB005B] Halt! You must be the owner of the clan to proceed.";
      break;
    case 10:
      return "[#ffffff]Error 69:[#DB005B] Alert! You are not the clan owner, so this action is not available.";
      break;
    default:
      return "[#DB005B]Unknown error occurred."
  }
}
  
function ErrorMSG()
{
  local rand = Random(1, 10)
  switch (rand) {
    case 1:
      return "[#ffffff]Error 69:[#DB005B] Sorry, you're not currently a member of any clan.";
      break;
    case 2:
      return "[#ffffff]Error 69:[#DB005B] Oops! It seems you're not part of any clan yet.";
      break;
    case 3:
      return "[#ffffff]Error 69:[#DB005B] Uh-oh! You must join a clan before performing this action.";
      break;
    case 4:
      return "[#ffffff]Error 69:[#DB005B] Whoops! You need to be in a clan to proceed.";
      break;
    case 5:
      return "[#ffffff]Error 69:[#DB005B] Hold on! You can't do that without being in a clan.";
      break;
    case 6:
      return "[#ffffff]Error 69:[#DB005B] Apologies, but you must join a clan first.";
      break;
    case 7:
      return "[#ffffff]Error 69:[#DB005B] Sorry, this action requires clan membership.";
      break;
    case 8:
      return "[#ffffff]Error 69:[#DB005B] Attention! You need to be part of a clan to continue.";
      break;
    case 9:
      return "[#ffffff]Error 69:[#DB005B] Halt! Please join a clan before proceeding.";
      break;
    case 10:
      return "[#ffffff]Error 69:[#DB005B] Alert! You must be a clan member to perform this action.";
      break;
    default:
      return "[#DB005B]Unknown error occurred."
  }
}


function LoadClanStats()
{
  local q = QuerySQL(ClanDB, "SELECT * FROM Clans");
  if(q) {
  local id = 0;
      do {
        id = GetSQLColumnData(q,0)
        Clan[id] = Clans();
        Clan[id].ID = GetSQLColumnData(q, 0);
        Clan[id].Owner = GetSQLColumnData(q, 1);
        Clan[id].Name = GetSQLColumnData(q, 2);
        Clan[id].Tag = GetSQLColumnData(q, 3);
        Clan[id].Kills = GetSQLColumnData(q, 4);
        Clan[id].Deaths = GetSQLColumnData(q, 5);
        Clan[id].Money = GetSQLColumnData(q, 6);
        Clan[id].TotalMembers = GetSQLColumnData(q, 7);
        Clan[id].Ranks = GetSQLColumnData(q, 8);
        Clan[id].skinID = GetSQLColumnData(q, 9);
        Clan[id].teamID = GetSQLColumnData(q, 10);
        Clan[id].defRank = GetSQLColumnData(q, 11);
        Clan[id].TagEnabled = GetSQLColumnData(q, 12);
      } while (GetSQLNextRow(q))
  }
}




function LoadClan(player)
{
  local q = QuerySQL(ClanDB, "SELECT * FROM ClanMembers WHERE Player='"+player.Name.tolower()+"'");
  if(q) {
    ClanStat[ player.ID ].Owner = GetSQLColumnData(q, 2);
    ClanStat[ player.ID ].Clan = GetSQLColumnData(q, 1);
        
    ClanStat[ player.ID ].Kills = GetSQLColumnData(q, 3);
    ClanStat[ player.ID ].Deaths = GetSQLColumnData(q, 4);
    ClanStat[ player.ID ].Money = GetSQLColumnData(q, 5);

    ClanStat[ player.ID ].InClan = true;
    ClanStat[ player.ID ].Rank = GetSQLColumnData(q, 6);
    MessagePlayer("[#47A992]-> Clan: [[#ffffff] "+ClanStat[player.ID].Clan+" [#47A992]] - Rank: [[#ffffff] "+ClanStat[player.ID].Rank+"[#47A992] ]",player);
  }

  local q_2 = QuerySQL(ClanDB, "SELECT * FROM Clans WHERE Name='"+ClanStat[ player.ID ].Clan+"'");
    if (q_2) {
    ClanStat[player.ID].ID = GetSQLColumnData(q_2, 0);
    local clanID = ClanStat[player.ID].ID;
    Clan[clanID] = Clans();
    Clan[clanID].ID = GetSQLColumnData(q_2, 0);
    Clan[clanID].Owner = GetSQLColumnData(q_2, 1);
    Clan[clanID].Name = GetSQLColumnData(q_2, 2);
    Clan[clanID].Tag = GetSQLColumnData(q_2, 3);
    Clan[clanID].Kills = GetSQLColumnData(q_2, 4);
    Clan[clanID].Deaths = GetSQLColumnData(q_2, 5);
    Clan[clanID].Money = GetSQLColumnData(q_2, 6);
    Clan[clanID].TotalMembers = GetSQLColumnData(q_2, 7);
    Clan[clanID].Ranks = GetSQLColumnData(q_2, 8);
    Clan[clanID].skinID = GetSQLColumnData(q_2, 9);
    Clan[clanID].teamID = GetSQLColumnData(q_2, 10);
    Clan[clanID].defRank = GetSQLColumnData(q_2, 11);
    Clan[clanID].TagEnabled = GetSQLColumnData(q_2, 12);
  }
}

function SaveClanInfo(player)
{
	QuerySQL( ClanDB, "UPDATE ClanMembers SET Clan='"+ClanStat[ player.ID ].Clan+"', Owner='"+ClanStat[ player.ID ].Owner+"', Kills='"+ClanStat[ player.ID ].Kills+"', Deaths='"+ClanStat[ player.ID ].Deaths+"', Money='"+ClanStat[ player.ID ].Money+"', Rank='"+ClanStat[ player.ID ].Rank+"' WHERE Player LIKE '" + player.Name.tolower() + "'" );
        
        local clanID = ClanStat[ player.ID ].ID;
      	QuerySQL( ClanDB, "UPDATE Clans SET Kills='"+Clan[clanID].Kills+"', Deaths='"+ Clan[clanID].Deaths+"', Money='"+Clan[clanID].Money+"', Ranks= '"+Clan[clanID].Ranks+"', TotalMembers='"+Clan[clanID].TotalMembers+"', skinID='"+Clan[clanID].skinID+"', teamID='"+Clan[clanID].teamID+"', defRank='"+Clan[clanID].defRank+"', teamID='"+Clan[clanID].teamID+"', TagEnabled='"+Clan[clanID].TagEnabled+"' WHERE ID='" + clanID + "'" );
}



function ClanSetting(player, category, value) 
{
          local player = FindPlayer(player);
          switch(category) {
            case "skin":
            local clanID = ClanStat[player.ID].ID;
            Clan[clanID].skinID = value;
             for(local i = 0; i <= GetMaxPlayers(); i++) {
              local plr = FindPlayer(i);
              if(plr && ClanStat[player.ID].Clan == ClanStat[plr.ID].Clan) {
                MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name+"[#79E0EE] has changed the default skin of clan to: ([#ffffff]"+value+"[#79E0EE])",plr);
                plr.Skin = value.tointeger();
              }
            }
            break;
            case "team":
            local clanID = ClanStat[player.ID].ID;
            Clan[clanID].teamID = value;
             for(local i = 0; i <= GetMaxPlayers(); i++) {
              local plr = FindPlayer(i);
              if(plr && ClanStat[player.ID].Clan == ClanStat[plr.ID].Clan) {
                MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name+"[#79E0EE] has changed the default team id of clan to: ([#ffffff]"+value+"[#79E0EE])",plr);
                plr.Team = value.tointeger();
              }
            }

            case "tag":
            local clanID = ClanStat[player.ID].ID;
            Clan[clanID].TagEnabled = value;
             for(local i = 0; i <= GetMaxPlayers(); i++) {
              local plr = FindPlayer(i);
              if(plr && ClanStat[player.ID].Clan == ClanStat[plr.ID].Clan) {
                if ( Clan[clanID].TagEnabled) MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name+"[#79E0EE] has enabled clan tags.",plr);
                else MessagePlayer("[#79E0EE]-> [#ffffff]"+player.Name+"[#79E0EE] has disabled clan tags.",plr);
              }
            }
            break;
          }
        }