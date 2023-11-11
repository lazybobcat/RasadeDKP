local addonName, addon = ...;
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "frFR", true);

if L then
    L["ADDON_NAME"] = addonName;
    L["ADDON_DESCRIPTION"] = "Addon de gestion des DKP";
    L["ADDON_VERSION_OUTDATED"] = "Une version plus récente de l'addon est disponible !";
    L["ADDON_VERSION"] = "Version :";
    L["ADDON_AUTHOR"] = "Auteur :";
    L["ADDON_MOTD"] = "Hey, merci d'utiliser "..addonName.."! Entre |cffffd700/rdkp|r pour ouvrir le menu et |cffffd700/loot <link de l'objet>|r pour ouvrir les paris sur un objet.";
    L["DATE_FORMAT"] = "%d/%m/%y";

    L["UI_MAINWINDOW_TITLE"] = "RasadeDKP";
    L["UI_MAINWINDOW_STATUS"] = "Work in progress...";
    L["UI_MAINWINDOW_AUCTIONS"] = "Ouvrir les enchères";
    L["UI_MAINWINDOW_EXPORT_CSV"] = "Export CSV";
    L["UI_WL_HEADER_CHARACTER"] = "|cffffd700Personnage|r";
    L["UI_WL_HEADER_PLAYER"] = "|cffffd700Joueur|r";
    L["UI_WL_HEADER_DKP"] = "|cffffd700DKP|r";
    L["UI_WL_HEADER_ACTIONS"] = "|cffffd700Actions|r";
    L["UI_WL_HEADER_ACTION_OK"] = "|cffffd700Ok|r";
    L["UI_WL_HEADER_ACTION_REMOVE"] = "|cffffd700Suppr.|r";
    L["UI_ROSTER_HEADER_PLAYER"] = "|cffffd700Joueur|r";
    L["UI_ROSTER_HEADER_CHARACTERS"] = "|cffffd700Personnages|r";
    L["UI_ROSTER_HEADER_DKP"] = "|cffffd700DKP|r";
    L["UI_PLAYER_DETAILS_NAME"] = "Nom du joueur";
    L["UI_PLAYER_DETAILS_DKP"] = "DKP du joueur";
    L["UI_PLAYER_DETAILS_CHARACTERS"] = "Personnages";
    L["UI_PLAYER_DETAILS_STATS"] = function(earned, spent) return "Statistiques : |cffC9221C"..spent.." dkp dépensés|r et |cff2BC85A"..earned.." dkp gagnés|r" end;
    L["UI_PLAYER_DETAILS_MOVEMENTS"] = "Mouvements";
    L["UI_PLAYER_DETAILS_MOVEMENT_credit"] = "|cff2BC85Acredit|r";
    L["UI_PLAYER_DETAILS_MOVEMENT_debit"] = "|cffC9221Cdebit|r";
    L["UI_PLAYER_DETAILS_ACTION_REMOVE"] = "Suppr.";
    L["UI_PLAYER_DETAILS_ACTION_DELETE"] = "Supprimer le joueur";
    L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_DATE"] = "|cffffd700Date|r";
    L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_TYPE"] = "|cffffd700Type|r";
    L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_DKP"] = "|cffffd700DKP|r";
    L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_REASON"] = "|cffffd700Raison|r";
    L["UI_PLAYER_DETAILS_MOVEMENT_HEADER_CHAR"] = "|cffffd700Personnage|r";
    L["UI_RAID_ADD_DKP"] = "Ajouter des DKP au raid";
    L["UI_RAID_ADD_DKP_WARNING"] = "|cffC9221CAttention : les joueurs en attente ne recevront pas de DKP|r";

    L["UI_AUCTIONSWINDOW_TITLE"] = "Enchères";
    L["UI_AUCTIONSWINDOW_ACTION_OK"] = "|cffffd700Attrib.|r";
    L["UI_AUCTIONSWINDOW_ACTION_CANCEL"] = "Annuler l'enchère";
    L["UI_AUCTIONSWINDOW_ACTION_RELOAD"] = "Sauvegarder les données";
    L["UI_AUCTIONSWINDOW_HEADER_TITLE"] = function (item) return item end;
    L["UI_AUCTIONSWINDOW_HEADER_TITLE_CANCELLED"] = function (item) return item.." (|cffC9221Cannulée|r)" end;
    L["UI_AUCTIONSWINDOW_HEADER_PLAYER"] = "|cffffd700Joueur|r";
    L["UI_AUCTIONSWINDOW_HEADER_BID"] = "|cffffd700Enchère|r";
    L["UI_AUCTIONSWINDOW_HEADER_DKP"] = "|cffffd700DKP dispo|r";
    L["UI_AUCTIONSWINDOW_WON"] = "|cff2BC85AEnchère emportée|r";
    
    L["UI_EXPORTWINDOW_TITLE"] = "Exporter les données";

    L["MOVEMENT_HARD_SET"] = "Solde défini via l'interface de l'addon";

    L["CSV_H_formattedDate"] = "Date";
    L["CSV_H_type"] = "Type";
    L["CSV_H_player"] = "Joueur";
    L["CSV_H_character"] = "Personnage";
    L["CSV_H_amount"] = "Montant";
    L["CSV_H_reason"] = "Raison";
    L["CSV_H_itemLink"] = "Lien de l'objet";
    --
    L["RL_MESSAGE_SEND_DKP"] = "Envoyez vos DKP en MP pour :";
    L["RL_MESSAGE_RAID_PARTICIPATION"] = function(dkp) return "Tous les joueurs ont reçu "..dkp.." pour leur participation au raid" end;
    L["RL_MESSAGE_AUCTION_ENDED"] = function(item, player) return "GG ! "..item.." a été attribué à "..player end;
    L["RL_MESSAGE_AUCTION_CANCELLED"] = function(item) return "L'enchère pour "..item.." a été annulée !" end;

    --
    L["DEFAULT_WAITING_LIST_MESSAGE"] = "Tu as été ajouté à la liste d'attente, en attente de confirmation";
    L["DEFAULT_WAITING_LIST_ACCEPTED_MESSAGE"] = "Tu as été ajouté aux raiders, tu as %dkp% dkp mon poulet";
    L["DEFAULT_DKP_MESSAGE"] = function(dkp) return "Tu as "..dkp.." dkp mon poulet" end;
    L["DEFAULT_PLAYER_UNKNOWN_MESSAGE"] = "T'es qui toi ? T'es pas enregistré, tu n'as pas de DKP, fais '!dkp' dans le chat et préviens moi pour que je t'ajoute";
    L["DEFAULT_DKP_UNKNOWN_MESSAGE"] = "L'IA super intelligente développée par Tzinntch n'a pas trouvé de montant de DKP dans ton message. Envoie juste le nombre stp.";
    L["DEFAULT_BID_PLACED_MESSAGE"] = function(dkp, item) return dkp.."dkp placés pour "..item end;
    L["DEFAULT_AUCTION_WON_MESSAGE"] = function(dkp, item) return "GG ! Tu as gagné "..item.." pour "..dkp.."dkp !" end;
    L["DEFAULT_DKP_RAID_GRANT_MESSAGE"] = "Participation au raid";
end
