#!/bin/bash

# https://github.com/mrchrisster/MiSTer_SAM/
# Copyright (c) 2023 by mrchrisster and Mellified

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Description
# This cycles through arcade and console cores periodically
# Games are randomly pulled from their respective folders

# ======== Credits ========
# Original concept and implementation: mrchrisster
# Additional development and script layout: Mellified and Paradox
#
# Thanks for the contributions and support:
# pocomane, kaloun34, redsteakraw, RetroDriven, woelper, LamerDeluxe, InquisitiveCoder, Sigismond, theypsilon
# tty2oled improvements by venice

# TODO implement playcurrentgame for amiga


# ======== INI VARIABLES ========
# Change these in the INI file
function init_vars() {
	declare -g mrsampath="/media/fat/Scripts/.MiSTer_SAM"
	declare -g misterpath="/media/fat"
	declare -g mrsamtmp="/tmp/.SAM_tmp"
	# Save our PID and process
	declare -g sampid="${$}"
	declare -g samprocess
	samprocess="$(basename -- "${0}")"
	declare -g menuonly="Yes"
	declare -gi inmenu=0
	declare -gi sam_bgmmenu=0					  
	declare -gi shown=0
	declare -gi coreretries=3
	declare -gi romloadfails=0
	declare -g gamelistpath="${mrsampath}/SAM_Gamelists"
	declare -g gamelistpathtmp="/tmp/.SAM_List"
	declare -g gamelistpathtmp="/tmp/.SAM_List"
	declare -g tmpfile="/tmp/.SAM_List/tmpfile"
	declare -g tmpfile2="/tmp/.SAM_List/tmpfile2"
	declare -g tmpfilefilter="/tmp/.SAM_List/tmpfilefilter"
	declare -g corelisttmpfile="/tmp/.SAM_List/corelisttmp.tmp"
	declare -g corelistfile="/tmp/.SAM_List/corelist.tmp"
	declare -gi disablecoredel="0"	
	declare -gi gametimer=120
	declare -gl corelist="amiga,ao486,arcade,atari2600,atari5200,atari7800,atarilynx,c64,fds,gb,gbc,gba,genesis,gg,megacd,neogeo,nes,s32x,sms,snes,tgfx16,tgfx16cd,psx"
	declare -gl corelistall="${corelist}"
	declare -gl skipmessage="Yes"
	declare -gl norepeat="Yes"
	declare -gl disablebootrom="Yes"
	declare -gl amigaselect="All"
	declare -gl mute="No"
	declare -gl coreweight="No"
	declare -gl playcurrentgame="No"
	declare -gl kids_safe="No"
	declare -gl listenmouse="Yes"
	declare -gl listenkeyboard="Yes"
	declare -gl listenjoy="Yes"
	declare -g repository_url="https://github.com/mrchrisster/MiSTer_SAM"
	declare -g branch="main"
	declare -gi counter=0
	declare -gA corewc
	declare -gA corep
	declare -g userstartup="/media/fat/linux/user-startup.sh"
	declare -g userstartuptpl="/media/fat/linux/_user-startup.sh"
	declare -gl useneogeotitles="Yes"
	declare -gl arcadeorient
	declare -gl checkzipsondisk="Yes"
	declare -gi bootsleep="60"
	declare -g ntpserver="0.pool.ntp.org"
	declare -gi totalgamecount		
	# ======== DEBUG VARIABLES ========
	declare -gl samdebug="No"
	declare -gl samdebuglog="No"						
	# ======== BGM =======
	declare -gl bgm="No"
	declare -gl bgmplay="Yes"
	declare -gl bgmstop="Yes"
	declare -gi gvoladjust="0"
	
	# ======== TTY2OLED =======
	declare -g TTY_cmd_pipe="${mrsamtmp}/TTY_cmd_pipe"
	declare -gl ttyenable="No"
	declare -gi ttyupdate_pause=10
	declare -g tty_currentinfo_file=${mrsamtmp}/tty_currentinfo
	declare -g tty_sleepfile="/tmp/tty2oled_sleep"
	declare -gl ttyname_cleanup="no"
	declare -gA tty_currentinfo=(
		[core_pretty]=""
		[name]=""
		[core]=""
		[date]=0
		[counter]=0
		[name_scroll]=""
		[name_scroll_position]=0
		[name_scroll_direction]=1
		[update_pause]=${ttyupdate_pause}
	)
	
	# ======== SAMVIDEO =======
	declare -gl samvideo
	declare -gl samvideo_freq
	declare -gl samvideo_output="hdmi"
	declare -gl samvideo_source
	declare -g samvideo_crtmode="video_mode=640,16,64,80,240,1,3,14,12380"
	declare -g samvideo_displaywait="2"
	declare -g tmpvideo="/tmp/SAMvideo.mp4"
	declare -g ini_file="/media/fat/MiSTer.ini"
	declare -g ini_contents=$(cat "$ini_file")
	declare -g sv_loadcounter=0
	declare -g samvideo_path="/media/fat/video"
	declare -g sv_archive_hdmilist="https://ia902700.us.archive.org/3/items/640x480_videogame_commercials/640x480_videogame_commercials_files.xml"
	declare -g sv_archive_crtlist="https://ia902700.us.archive.org/3/items/640x240_videogame_commercials/640x240_videogame_commercials_files.xml"
	declare -g sv_youtube_hdmilist="/media/fat/Scripts/.MiSTer_SAM/sv_yt360_list.txt"
	declare -g sv_youtube_crtlist="/media/fat/Scripts/.MiSTer_SAM/sv_yt240_list.txt"


	# ======== CORE PATHS RBF ========
	declare -g amigapathrbf="_Computer"
	declare -g arcadepathrbf="_Arcade"
	declare -g ao486pathrbf="_Computer"
	declare -g atari2600pathrbf="_Console"
	declare -g atari5200pathrbf="_Console"
	declare -g atari7800pathrbf="_Console"
	declare -g atarilynxpathrbf="_Console"
	declare -g c64pathrbf="_Computer"
	declare -g fdspathrbf="_Console"
	declare -g gbpathrbf="_Console"
	declare -g gbcpathrbf="_Console"
	declare -g gbapathrbf="_Console"
	declare -g genesispathrbf="_Console"
	declare -g ggpathrbf="_Console"
	declare -g megacdpathrbf="_Console"
	declare -g neogeopathrbf="_Console"
	declare -g nespathrbf="_Console"
	declare -g s32xpathrbf="_Console"
	declare -g smspathrbf="_Console"
	declare -g snespathrbf="_Console"
	declare -g tgfx16pathrbf="_Console"
	declare -g tgfx16cdpathrbf="_Console"
	declare -g psxpathrbf="_Console"
	
	if [[ "${corelist[@]}" == *"amiga"* ]] || [[ "${corelist[@]}" == *"ao486"* ]] && [ -f "${mrsampath}"/samindex ]; then
		declare -g amigapath="$("${mrsampath}"/samindex -q -s amiga -d |awk -F':' '{print $2}')"
		declare -g amigacore="$(find /media/fat/_Computer/ -iname "*minimig*")"
		declare -g ao486path="$("${mrsampath}"/samindex -q -s ao486 -d |awk -F':' '{print $2}')/screensaver"
	fi

}

# ======== CORE CONFIG ========
function init_data() {
	# Core to long name mappings
	declare -gA CORE_PRETTY=(
		["amiga"]="Commodore Amiga"
		["arcade"]="MiSTer Arcade"
		["ao486"]="PC 486 DX-33"
		["atari2600"]="Atari 2600"
		["atari5200"]="Atari 5200"
		["atari7800"]="Atari 7800"
		["atarilynx"]="Atari Lynx"
		["c64"]="Commodore 64"
		["fds"]="Nintendo Disk System"
		["gb"]="Nintendo Game Boy"
		["gbc"]="Nintendo Game Boy Color"
		["gba"]="Nintendo Game Boy Advance"
		["genesis"]="Sega Genesis / Megadrive"
		["gg"]="Sega Game Gear"
		["megacd"]="Sega CD / Mega CD"
		["neogeo"]="SNK NeoGeo"
		["nes"]="Nintendo Entertainment System"
		["s32x"]="Sega 32x"
		["sms"]="Sega Master System"
		["snes"]="Super Nintendo"
		["tgfx16"]="NEC TurboGrafx-16 "
		["tgfx16cd"]="NEC TurboGrafx-16 CD"
		["psx"]="Sony Playstation"
	)

	# Core to file extension mappings
	declare -glA CORE_EXT=(
		["amiga"]="hdf" 			#This is just a placeholder
		["ao486"]="vhd"		#This is just a placeholder
		["arcade"]="mra"
		["atari2600"]="a26"     
		["atari5200"]="a52,car" 
		["atari7800"]="a78"     
		["atarilynx"]="lnx"		 
		["c64"]="crt,prg" 		# need to be tested "reu,tap,flt,rom,c1581"
		["fds"]="fds"
		["gb"]="gb"			 		
		["gbc"]="gbc"		 		
		["gba"]="gba"
		["genesis"]="md,gen" 		
		["gg"]="gg"
		["megacd"]="chd,cue"
		["neogeo"]="neo"
		["nes"]="nes"
		["s32x"]="32x"
		["sms"]="sms,sg"
		["snes"]="sfc,smc" 	 	# Should we include? "bin,bs"
		["tgfx16"]="pce,sgx"		
		["tgfx16cd"]="chd,cue"
		["psx"]="chd,cue,exe"
	)
	
	# Core to path mappings
	declare -gA PATHFILTER=(
		["amiga"]="${amigapathfilter}"
		["ao486"]="${ao486pathfilter}"
		["arcade"]="${arcadepathfilter}"
		["atari2600"]="${atari2600pathfilter}"
		["atari5200"]="${atari5200pathfilter}"
		["atari7800"]="${atari7800pathfilter}"
		["atarilynx"]="${atarilynxpathfilter}"				  
		["c64"]="${c64pathfilter}"
		["fds"]="${fdspathfilter}"
		["gb"]="${gbpathfilter}"
		["gbc"]="${gbcpathfilter}"
		["gba"]="${gbapathfilter}"
		["genesis"]="${genesispathfilter}"
		["gg"]="${ggpathfilter}"
		["megacd"]="${megacdpathfilter}"
		["neogeo"]="${neogeopathfilter}"
		["nes"]="${nespathfilter}"
		["s32x"]="${s32xpathfilter}"
		["sms"]="${smspathfilter}"
		["snes"]="${snespathfilter}"
		["tgfx16"]="${tgfx16pathfilter}"
		["tgfx16cd"]="${tgfx16cdpathfilter}"
		["psx"]="${psxpathfilter}"
	)
	
	declare -glA FIRSTRUN=(
		["amiga"]="0"	
		["ao486"]="0"
		["arcade"]="0"
		["atari2600"]="0"
		["atari5200"]="0"
		["atari7800"]="0"
		["atarilynx"]="0"
		["c64"]="0"
		["fds"]="0"
		["gb"]="0" 		
		["gbc"]="0" 		
		["gba"]="0"
		["genesis"]="0"
		["gg"]="0"
		["megacd"]="0"
		["neogeo"]="0"
		["nes"]="0"
		["s32x"]="0"
		["sms"]="0"
		["snes"]="0"	
		["tgfx16"]="0"
		["tgfx16cd"]="0"
		["psx"]="0"
	)


	# Core to path mappings for rbf files
	declare -gA CORE_PATH_RBF=(
		["amiga"]="${amigapathrbf}"
		["ao486"]="${ao486pathrbf}"
		["arcade"]="${arcadepathrbf}"
		["atari2600"]="${atari2600pathrbf}"
		["atari5200"]="${atari5200pathrbf}"
		["atari7800"]="${atari7800pathrbf}"
		["atarilynx"]="${atarilynxpathrbf}"					 
		["c64"]="${c64pathrbf}"
		["fds"]="${fdspathrbf}"
		["gb"]="${gbpathrbf}"
		["gbc"]="${gbcpathrbf}"
		["gba"]="${gbapathrbf}"
		["genesis"]="${genesispathrbf}"
		["gg"]="${ggpathrbf}"
		["megacd"]="${megacdpathrbf}"
		["neogeo"]="${neogeopathrbf}"
		["nes"]="${nespathrbf}"
		["s32x"]="${s32xpathrbf}"
		["sms"]="${smspathrbf}"
		["snes"]="${snespathrbf}"
		["tgfx16"]="${tgfx16pathrbf}"
		["tgfx16cd"]="${tgfx16cdpathrbf}"
		["psx"]="${psxpathrbf}"
	)

	# Can this core skip Bios/Safety warning messages
	declare -glA CORE_SKIP=(
		["amiga"]="No"
		["ao486"]="No"
		["arcade"]="No"
		["atari2600"]="No"
		["atari5200"]="No"
		["atari7800"]="No"
		["atarilynx"]="No"		
		["c64"]="No"
		["fds"]="Yes"
		["gb"]="No"
		["gbc"]="No"
		["gba"]="No"
		["genesis"]="No"
		["gg"]="No"
		["megacd"]="Yes"
		["neogeo"]="No"
		["nes"]="No"
		["s32x"]="No"
		["sms"]="No"
		["snes"]="No"
		["tgfx16"]="No"
		["tgfx16cd"]="Yes"
		["psx"]="No"
	)
	
	# Can this core use ZIPped ROMs
	declare -glA CORE_ZIPPED=(
		["amiga"]="No"
		["ao486"]="No"
		["arcade"]="No"
		["atari2600"]="Yes"
		["atari5200"]="Yes"
		["atari7800"]="Yes"
		["atarilynx"]="Yes"
		["c64"]="Yes"
		["fds"]="Yes"
		["gameboy"]="Yes"
		["gbc"]="Yes"
		["gba"]="Yes"
		["genesis"]="Yes"
		["gamegear"]="Yes"
		["megacd"]="No"
		["neogeo"]="Yes"
		["nes"]="Yes"
		["s32x"]="Yes"
		["sms"]="Yes"
		["snes"]="Yes"
		["tgfx16"]="Yes"
		["tgfx16cd"]="No"
		["psx"]="No"
	)

	# Core to input maps mapping
	declare -gA CORE_LAUNCH=(
		["amiga"]="Minimig"
		["ao486"]="ao486"
		["arcade"]="Arcade"
		["atari2600"]="ATARI7800"
		["atari5200"]="ATARI5200"
		["atari7800"]="ATARI7800"
		["atarilynx"]="AtariLynx"
		["c64"]="C64"
		["fds"]="NES"
		["gb"]="GAMEBOY"
		["gbc"]="GAMEBOY"
		["gba"]="GBA"
		["genesis"]="Genesis"
		["gg"]="SMS"
		["megacd"]="MegaCD"
		["neogeo"]="NEOGEO"
		["nes"]="NES"
		["s32x"]="S32X"
		["sms"]="SMS"
		["snes"]="SNES"
		["tgfx16"]="TGFX16"
		["tgfx16cd"]="TGFX16"
		["psx"]="PSX"
	)
	
	# TTY2OLED Core Pic mappings
	declare -gA TTY2OLED_PIC_NAME=(
		["amiga"]="Minimig"
		["ao486"]="ao486"
		["arcade"]="Arcade"
		["atari2600"]="ATARI2600"
		["atari5200"]="ATARI5200"
		["atari7800"]="ATARI7800"
		["atarilynx"]="AtariLynx"
		["c64"]="C64"
		["fds"]="fds"
		["gb"]="GAMEBOY"
		["gbc"]="GAMEBOY"
		["gba"]="GBA"
		["genesis"]="Genesis"
		["gg"]="gamegear"
		["megacd"]="MegaCD"
		["neogeo"]="NEOGEO"
		["nes"]="NES"
		["s32x"]="S32X"
		["sms"]="SMS"
		["snes"]="SNES"
		["tgfx16"]="TGFX16"
		["tgfx16cd"]="TGFX16"
		["psx"]="PSX"
	)

	# MGL core name settings
	declare -gA MGL_CORE=(
		["amiga"]="Minimig"
		["ao486"]="ao486"
		["arcade"]="Arcade"
		["atari2600"]="ATARI7800"
		["atari5200"]="ATARI5200"
		["atari7800"]="ATARI7800"
		["atarilynx"]="AtariLynx"		   
		["c64"]="C64"
		["fds"]="NES"
		["gb"]="GAMEBOY"
		["gbc"]="GAMEBOY"
		["gba"]="GBA"
		["genesis"]="Genesis"
		["gg"]="SMS"
		["megacd"]="MegaCD"
		["neogeo"]="NEOGEO"
		["nes"]="NES"
		["s32x"]="S32X"
		["sms"]="SMS"
		["snes"]="SNES"
		["tgfx16"]="TurboGrafx16"
		["tgfx16cd"]="TurboGrafx16"
		["psx"]="PSX"
	)

	# MGL delay settings
	declare -giA MGL_DELAY=(
		["amiga"]="1"
		["ao486"]="0"
		["arcade"]="2"
		["atari2600"]="1"
		["atari5200"]="1"
		["atari7800"]="1"
		["atarilynx"]="1"
		["c64"]="1"
		["fds"]="2"
		["gb"]="2"
		["gbc"]="2"
		["gba"]="2"
		["genesis"]="1"
		["gg"]="1"
		["megacd"]="1"
		["neogeo"]="1"
		["nes"]="2"
		["s32x"]="1"
		["sms"]="1"
		["snes"]="2"
		["tgfx16"]="1"
		["tgfx16cd"]="1"
		["psx"]="1"
	)

	# MGL index settings
	declare -giA MGL_INDEX=(
		["amiga"]="0"
		["ao486"]="2"
		["arcade"]="0"
		["atari2600"]="0"
		["atari5200"]="1"
		["atari7800"]="1"
		["atarilynx"]="1"   
		["c64"]="1"
		["fds"]="0"
		["gb"]="0"
		["gbc"]="0"
		["gba"]="0"
		["genesis"]="0"
		["gg"]="2"
		["megacd"]="0"
		["neogeo"]="1"
		["nes"]="0"
		["s32x"]="0"
		["sms"]="1"
		["snes"]="0"
		["tgfx16"]="1"
		["tgfx16cd"]="0"
		["psx"]="1"
	)

	# MGL type settings
	declare -glA MGL_TYPE=(
		["amiga"]="f"
		["ao486"]="s"
		["arcade"]="f"
		["atari2600"]="f"
		["atari5200"]="f"
		["atari7800"]="f"
		["atarilynx"]="f"
		["c64"]="f"
		["fds"]="f"
		["gb"]="f"
		["gbc"]="f"
		["gba"]="f"
		["genesis"]="f"
		["gg"]="f"
		["megacd"]="s"
		["neogeo"]="f"
		["nes"]="f"
		["s32x"]="f"
		["sms"]="f"
		["snes"]="f"
		["tgfx16"]="f"
		["tgfx16cd"]="s"
		["psx"]="s"
	)


	# NEOGEO to long name mappings English
	declare -gA NEOGEO_PRETTY_ENGLISH=(
		["3countb"]="3 Count Bout"
		["2020bb"]="2020 Super Baseball"
		["2020bba"]="2020 Super Baseball (set 2)"
		["2020bbh"]="2020 Super Baseball (set 3)"
		["abyssal"]="Abyssal Infants"
		["alpham2"]="Alpha Mission II"
		["alpham2p"]="Alpha Mission II (prototype)"
		["androdun"]="Andro Dunos"
		["aodk"]="Aggressors of Dark Kombat"
		["aof"]="Art of Fighting"
		["aof2"]="Art of Fighting 2"
		["aof2a"]="Art of Fighting 2 (NGH-056)"
		["aof3"]="Art of Fighting 3: The Path of the Warrior"
		["aof3k"]="Art of Fighting 3: The Path of the Warrior (Korean release)"
		["b2b"]="Bang Bang Busters"
		["badapple"]="Bad Apple Demo"
		["bakatono"]="Bakatonosama Mahjong Manyuuki"
		["bangbead"]="Bang Bead"
		["bjourney"]="Blue's Journey"
		["blazstar"]="Blazing Star"
		["breakers"]="Breakers"
		["breakrev"]="Breakers Revenge"
		["brningfh"]="Burning Fight (NGH-018, US)"
		["brningfp"]="Burning Fight (prototype, older)"
		["brnngfpa"]="Burning Fight (prototype, near final, ver 23.3, 910326)"
		["bstars"]="Baseball Stars Professional"
		["bstars2"]="Baseball Stars 2"
		["bstarsh"]="Baseball Stars Professional (NGH-002)"
		["burningf"]="Burning Fight"
		["burningfh"]="Burning Fight (NGH-018, US)"
		["burningfp"]="Burning Fight (prototype, older)"
		["burningfpa"]="Burning Fight (prototype, near final, ver 23.3, 910326)"
		["cabalng"]="Cabal"
		["columnsn"]="Columns"
		["cphd"]="Crouching Pony Hidden Dragon Demo"
		["crswd2bl"]="Crossed Swords 2 (CD conversion)"
		["crsword"]="Crossed Swords"
		["ct2k3sa"]="Crouching Tiger Hidden Dragon 2003 Super Plus (The King of Fighters 2001 bootleg)"
		["ctomaday"]="Captain Tomaday"
		["cyberlip"]="Cyber-Lip"
		["diggerma"]="Digger Man"
		["doubledr"]="Double Dragon"
		["eightman"]="Eight Man"
		["fatfursp"]="Fatal Fury Special"
		["fatfurspa"]="Fatal Fury Special (NGM-058 ~ NGH-058, set 2)"
		["fatfury1"]="Fatal Fury: King of Fighters"
		["fatfury2"]="Fatal Fury 2"
		["fatfury3"]="Fatal Fury 3: Road to the Final Victory"
		["fbfrenzy"]="Football Frenzy"
		["fghtfeva"]="Fight Fever (set 2)"
		["fightfev"]="Fight Fever"
		["fightfeva"]="Fight Fever (set 2)"
		["flipshot"]="Battle Flip Shot"
		["frogfest"]="Frog Feast"
		["froman2b"]="Idol Mahjong Final Romance 2 (CD conversion)"
		["fswords"]="Fighters Swords (Korean release of Samurai Shodown III)"
		["ftfurspa"]="Fatal Fury Special (NGM-058 ~ NGH-058, set 2)"
		["galaxyfg"]="Galaxy Fight: Universal Warriors"
		["ganryu"]="Ganryu"
		["garou"]="Garou: Mark of the Wolves"
		["garoubl"]="Garou: Mark of the Wolves (bootleg)"
		["garouh"]="Garou: Mark of the Wolves (earlier release)"
		["garoup"]="Garou: Mark of the Wolves (prototype)"
		["ghostlop"]="Ghostlop"
		["goalx3"]="Goal! Goal! Goal!"
		["gowcaizr"]="Voltage Fighter Gowcaizer"
		["gpilots"]="Ghost Pilots"
		["gpilotsh"]="Ghost Pilots (NGH-020, US)"
		["gururin"]="Gururin"
		["hyprnoid"]="Hypernoid"
		["irnclado"]="Ironclad (prototype, bootleg)"
		["ironclad"]="Ironclad"
		["ironclado"]="Ironclad (prototype, bootleg)"
		["irrmaze"]="The Irritating Maze"
		["janshin"]="Janshin Densetsu: Quest of Jongmaster"
		["joyjoy"]="Puzzled"
		["kabukikl"]="Far East of Eden: Kabuki Klash"
		["karnovr"]="Karnov's Revenge"
		["kf2k2mp"]="The King of Fighters 2002 Magic Plus (bootleg)"
		["kf2k2mp2"]="The King of Fighters 2002 Magic Plus II (bootleg)"
		["kf2k2pla"]="The King of Fighters 2002 Plus (bootleg set 2)"
		["kf2k2pls"]="The King of Fighters 2002 Plus (bootleg)"
		["kf2k5uni"]="The King of Fighters 10th Anniversary 2005 Unique (The King of Fighters 2002 bootleg)"
		["kf10thep"]="The King of Fighters 10th Anniversary Extra Plus (The King of Fighters 2002 bootleg)"
		["kizuna"]="Kizuna Encounter: Super Tag Battle"
		["kof2k4se"]="The King of Fighters Special Edition 2004 (The King of Fighters 2002 bootleg)"
		["kof94"]="The King of Fighters '94"
		["kof95"]="The King of Fighters '95"
		["kof95a"]="The King of Fighters '95 (NGM-084, alt board)"
		["kof95h"]="The King of Fighters '95 (NGH-084)"
		["kof96"]="The King of Fighters '96"
		["kof96h"]="The King of Fighters '96 (NGH-214)"
		["kof97"]="The King of Fighters '97"
		["kof97h"]="The King of Fighters '97 (NGH-2320)"
		["kof97k"]="The King of Fighters '97 (Korean release)"
		["kof97oro"]="The King of Fighters '97 Chongchu Jianghu Plus 2003 (bootleg)"
		["kof97pls"]="The King of Fighters '97 Plus (bootleg)"
		["kof98"]="The King of Fighters '98: The Slugfest"
		["kof98a"]="The King of Fighters '98: The Slugfest (NGM-2420, alt board)"
		["kof98h"]="The King of Fighters '98: The Slugfest (NGH-2420)"
		["kof98k"]="The King of Fighters '98: The Slugfest (Korean release)"
		["kof98ka"]="The King of Fighters '98: The Slugfest (Korean release, set 2)"
		["kof99"]="The King of Fighters '99: Millennium Battle"
		["kof99e"]="The King of Fighters '99: Millennium Battle (earlier release)"
		["kof99h"]="The King of Fighters '99: Millennium Battle (NGH-2510)"
		["kof99k"]="The King of Fighters '99: Millennium Battle (Korean release)"
		["kof99p"]="The King of Fighters '99: Millennium Battle (prototype)"
		["kof2000"]="The King of Fighters 2000"
		["kof2000n"]="The King of Fighters 2000"
		["kof2001"]="The King of Fighters 2001"
		["kof2001h"]="The King of Fighters 2001 (NGH-2621)"
		["kof2002"]="The King of Fighters 2002"
		["kof2002b"]="The King of Fighters 2002 (bootleg)"
		["kof2003"]="The King of Fighters 2003"
		["kof2003h"]="The King of Fighters 2003 (NGH-2710)"
		["kof2003ps2"]="The King of Fighters 2003 (PS2)"
		["kog"]="King of Gladiators (The King of Fighters '97 bootleg)"
		["kotm"]="King of the Monsters"
		["kotm2"]="King of the Monsters 2: The Next Thing"
		["kotm2p"]="King of the Monsters 2: The Next Thing (prototype)"
		["kotmh"]="King of the Monsters (set 2)"
		["lans2004"]="Lansquenet"
		["lastblad"]="The Last Blade"
		["lastbladh"]="The Last Blade (NGH-2340)"
		["lastbld2"]="The Last Blade 2"
		["lasthope"]="Last Hope"
		["lastsold"]="The Last Soldier"
		["lbowling"]="League Bowling"
		["legendos"]="Legend of Success Joe"
		["lresort"]="Last Resort"
		["lresortp"]="Last Resort (prototype)"
		["lstbladh"]="Last Blade (NGH-2340)"
		["magdrop2"]="Magical Drop II"
		["magdrop3"]="Magical Drop III"
		["maglord"]="Magician Lord"
		["maglordh"]="Magician Lord (NGH-005)"
		["mahretsu"]="Mahjong Kyo Retsuden"
		["marukodq"]="Chibi Marukochan Deluxe Quiz"
		["matrim"]="Power Instinct Matrimelee"
		["miexchng"]="Money Puzzle Exchanger"
		["minasan"]="Minasan no Okagesamadesu! Dai Sugoroku Taikai"
		["montest"]="Monitor Test ROM"
		["moshougi"]="Shougi no Tatsujin: Master of Syougi"
		["ms4plus"]="Metal Slug 4 Plus (bootleg)"
		["mslug"]="Metal Slug: Super Vehicle-001"
		["mslug2"]="Metal Slug 2: Super Vehicle-001/II"
		["mslug2t"]="Metal Slug 2 Turbo (hack)"
		["mslug3"]="Metal Slug 3"
		["mslug3b6"]="Metal Slug 6 (Metal Slug 3 bootleg)"
		["mslug3h"]="Metal Slug 3 (NGH-2560)"
		["mslug4"]="Metal Slug 4"
		["mslug4h"]="Metal Slug 4 (NGH-2630)"
		["mslug5"]="Metal Slug 5"
		["mslug5h"]="Metal Slug 5 (NGH-2680)"
		["mslug6"]="Metal Slug 6 (Metal Slug 3 bootleg)"
		["mslugx"]="Metal Slug X: Super Vehicle-001"
		["mutnat"]="Mutation Nation"
		["nam1975"]="NAM-1975"
		["nblktigr"]="Neo Black Tiger"
		["ncombat"]="Ninja Combat"
		["ncombath"]="Ninja Combat (NGH-009)"
		["ncommand"]="Ninja Commando"
		["neobombe"]="Neo Bomberman"
		["neocup98"]="Neo-Geo Cup 98: The Road to the Victory"
		["neodrift"]="Neo Drift Out: New Technology"
		["neofight"]="Neo Fight"
		["neomrdo"]="Neo Mr. Do!"
		["neothund"]="Neo Thunder"
		["neotris"]="NeoTRIS (free beta version)"
		["ninjamas"]="Ninja Master's"
		["nitd"]="Nightmare in the Dark"
		["nitdbl"]="Nightmare in the Dark (bootleg)"
		["nsmb"]="New Super Mario Bros."
		["overtop"]="OverTop"
		["panicbom"]="Panic Bomber"
		["pbbblenb"]="Puzzle Bobble (bootleg)"
		["pbobbl2n"]="Puzzle Bobble 2"
		["pbobblen"]="Puzzle Bobble"
		["pbobblenb"]="Puzzle Bobble (bootleg)"
		["pgoal"]="Pleasure Goal"
		["pnyaa"]="Pochi and Nyaa"
		["popbounc"]="Pop 'n Bounce"
		["preisle2"]="Prehistoric Isle 2"
		["pspikes2"]="Power Spikes II"
		["pulstar"]="Pulstar"
		["puzzldpr"]="Puzzle De Pon! R!"
		["puzzledp"]="Puzzle De Pon!"
		["quizdai2"]="Quiz Meitantei Neo & Geo: Quiz Daisousa Sen part 2"
		["quizdais"]="Quiz Daisousa Sen: The Last Count Down"
		["quizdask"]="Quiz Salibtamjeong: The Last Count Down (Korean localized Quiz Daisousa Sen)"
		["quizkof"]="Quiz King of Fighters"
		["quizkofk"]="Quiz King of Fighters (Korean release)"
		["ragnagrd"]="Ragnagard"
		["rbff1"]="Real Bout Fatal Fury"
		["rbff1a"]="Real Bout Fatal Fury (bug fix revision)"
		["rbff2"]="Real Bout Fatal Fury 2: The Newcomers"
		["rbff2h"]="Real Bout Fatal Fury 2: The Newcomers (NGH-2400)"
		["rbff2k"]="Real Bout Fatal Fury 2: The Newcomers (Korean release)"
		["rbffspck"]="Real Bout Fatal Fury Special (Korean release)"
		["rbffspec"]="Real Bout Fatal Fury Special"
		["rbffspeck"]="Real Bout Fatal Fury Special (Korean release)"
		["ridhero"]="Riding Hero"
		["ridheroh"]="Riding Hero (set 2)"
		["roboarma"]="Robo Army (NGM-032 ~ NGH-032)"
		["roboarmy"]="Robo Army"
		["roboarmya"]="Robo Army (NGM-032 ~ NGH-032)"
		["rotd"]="Rage of the Dragons"
		["rotdh"]="Rage of the Dragons (NGH-2640?)"
		["s1945p"]="Strikers 1945 Plus"
		["samsh5fe"]="Samurai Shodown V Special Final Edition"
		["samsh5pf"]="Samurai Shodown V Perfect"
		["samsh5sp"]="Samurai Shodown V Special"
		["samsh5sph"]="Samurai Shodown V Special (2nd release, less censored)"
		["samsh5spho"]="Samurai Shodown V Special (1st release, censored)"
		["samsho"]="Samurai Shodown"
		["samsho2"]="Samurai Shodown II"
		["samsho2k"]="Saulabi Spirits (Korean release of Samurai Shodown II)"
		["samsho2ka"]="Saulabi Spirits (Korean release of Samurai Shodown II, set 2)"
		["samsho3"]="Samurai Shodown III"
		["samsho3h"]="Samurai Shodown III (NGH-087)"
		["samsho4"]="Samurai Shodown IV: Amakusa's Revenge"
		["samsho4k"]="Pae Wang Jeon Seol: Legend of a Warrior"
		["samsho5"]="Samurai Shodown V"
		["samsho5b"]="Samurai Shodown V (bootleg)"
		["samsho5h"]="Samurai Shodown V (NGH-2700)"
		["samsho5x"]="Samurai Shodown V (XBOX version hack)"
		["samshoh"]="Samurai Shodown (NGH-045)"
		["savagere"]="Savage Reign"
		["sbp"]="Super Bubble Pop"
		["scbrawlh"]="Soccer Brawl (NGH-031)"
		["sdodgeb"]="Super Dodge Ball"
		["sengoku"]="Sengoku"
		["sengoku2"]="Sengoku 2"
		["sengoku3"]="Sengoku 3"
		["sengokuh"]="Sengoku (NGH-017, US)"
		["shcktroa"]="Shock Troopers (set 2)"
		["shocktr2"]="Shock Troopers: 2nd Squad"
		["shocktro"]="Shock Troopers"
		["shocktroa"]="Shock Troopers (set 2)"
		["smbng"]="New Super Mario Bros. Demo"
		["smsh5sph"]="Samurai Shodown V Special (2nd release, less censored)"
		["smsh5spo"]="Samurai Shodown V Special (1st release, censored)"
		["smsho2k2"]="Saulabi Spirits (Korean release of Samurai Shodown II, set 2)"
		["socbrawl"]="Soccer Brawl"
		["socbrawlh"]="Soccer Brawl (NGH-031)"
		["sonicwi2"]="Aero Fighters 2"
		["sonicwi3"]="Aero Fighters 3"
		["spinmast"]="Spinmaster"
		["ssideki"]="Super Sidekicks"
		["ssideki2"]="Super Sidekicks 2: The World Championship"
		["ssideki3"]="Super Sidekicks 3: The Next Glory"
		["ssideki4"]="The Ultimate 11: The SNK Football Championship"
		["stakwin"]="Stakes Winner"
		["stakwin2"]="Stakes Winner 2"
		["strhoop"]="Street Hoop / Street Slam"
		["superspy"]="The Super Spy"
		["svc"]="SNK vs. Capcom: SVC Chaos"
		["svccpru"]="SNK vs. Capcom Remix Ultra"
		["svcplus"]="SNK vs. Capcom Plus (bootleg)"
		["svcsplus"]="SNK vs. Capcom Super Plus (bootleg)"
		["teot"]="The Eye of Typhoon: Tsunami Edition"
		["tetrismn"]="Tetris"
		["tophuntr"]="Top Hunter: Roddy & Cathy"
		["tophuntrh"]="Top Hunter: Roddy & Cathy (NGH-046)"
		["totc"]="Treasure of the Caribbean"
		["tpgolf"]="Top Player's Golf"
		["tphuntrh"]="Top Hunter: Roddy & Cathy (NGH-046)"
		["trally"]="Thrash Rally"
		["turfmast"]="Neo Turf Masters"
		["twinspri"]="Twinkle Star Sprites"
		["tws96"]="Tecmo World Soccer '96"
		["twsoc96"]="Tecmo World Soccer '96"
		["viewpoin"]="Viewpoint"
		["wakuwak7"]="Waku Waku 7"
		["wh1"]="World Heroes"
		["wh1h"]="World Heroes (ALH-005)"
		["wh1ha"]="World Heroes (set 3)"
		["wh2"]="World Heroes 2"
		["wh2j"]="World Heroes 2 Jet"
		["whp"]="World Heroes Perfect"
		["wjammers"]="Windjammers"
		["wjammss"]="Windjammers Supersonic"
		["xenocrisis"]="Xeno Crisis"
		["zedblade"]="Zed Blade"
		["zintrckb"]="ZinTricK"
		["zintrkcd"]="ZinTricK (CD conversion)"
		["zupapa"]="Zupapa!"
	)
}

# ========= PARSE INI =========

# Read INI
function read_samini() {
	if [ ! -f "${misterpath}/Scripts/MiSTer_SAM.ini" ]; then
		echo "Error: MiSTer_SAM.ini not found. Attempting to update now..."
		get_samstuff MiSTer_SAM.ini /media/fat/Scripts
		if [ $? -ne 0 ]; then 
			echo "Error: Please try again or update MiSTer_SAM.ini manually."
			exit 1
		fi
	fi
	source "${misterpath}/Scripts/MiSTer_SAM.ini"
	
	# Remove trailing slash from paths
	grep "^[^#;]" < "${misterpath}/Scripts/MiSTer_SAM.ini" | grep "pathfilter=" | cut -f1 -d"=" | while IFS= read -r var; do
		declare -g "${var}"="${!var%/}"
	done
	
	#corelist=("$(echo "${corelist[@]}" | tr ',' ' ' | tr -s ' ')")
	IFS=',' read -ra corelist <<< "${corelist}"
	IFS=',' read -ra corelistall <<< "${corelistall}"
	
	#Roulette Mode
	if [ -f /tmp/.SAM_tmp/gameroulette.ini ]; then
		source /tmp/.SAM_tmp/gameroulette.ini
	fi
	
}


# ============== PARSE COMMANDS ===============

# FLOWCHART
# If core is supplied as first argument, we start SAM in single core mode - parse_cmd ${nextcore} start. In function next_core, corelist shuffle is ignored and nextcore always stays the same
# If no argument is passed to SAM, we shuffle the corelist in next_core

function parse_cmd() {
	if [ ${#} -gt 2 ]; then # We don't accept more than 2 parameters
		sam_help
	elif [ ${#} -eq 0 ]; then # No options - show the pre-menu
		sam_premenu
	else
		# If we're given a core name, we need to set it first
		for arg in "${@,,}"; do
			case ${arg} in
			arcade | ao486 | atari2600 | atari5200 | atari7800 | atarilynx | amiga | c64 | fds | gb | gbc | gba | genesis | gg | megacd | neogeo | nes | s32x | sms | snes | tgfx16 | tgfx16cd | psx)
				echo "${CORE_PRETTY[${arg}]} selected!"
				nextcore="${arg}"
				disablecoredel=1
				;;
			esac
		done

		# If the one command was a core then we need to call in again with "start" specified
		if [ "${nextcore}" ] && [ ${#} -eq 1 ]; then
			# Move cursor up a line to avoid duplicate message
			echo -n -e "\033[A"
			# Re-enter this function with start added
			parse_cmd "${nextcore}" start
			return
		fi

		while [ ${#} -gt 0 ]; do
			case "${1,,}" in
			default) # sam_update relaunches itself
				sam_update autoconfig
				break
				;;
			--sourceonly | --create-gamelists)
				break
				;;
			autoconfig | defaultb)
				tmux kill-session -t MCP &>/dev/null
				there_can_be_only_one
				sam_update
				mcp_start
				sam_enable
				break
				;;
			bootstart) # Start as from init
				env_check "${1}"
				# Sleep before startup so clock of Mister can synchronize if connected to the internet.
				# We assume most people don't have RTC add-on so sleep is default.
				# Only start MCP on boot
				boot_sleep
				mcp_start
				break
				;;
			start | restart) # Start as a detached tmux session for monitoring
				sam_start
				break
				;;
			start_real) # Start SAM immediately
				loop_core "${nextcore}"
				break
				;;
			skip | next) # Load next game - stops monitor
				echo " Skipping to next game..."
				tmux send-keys -t SAM C-c ENTER
				# break
				;;
			ignore) # Exclude current game
				ignoregame
				break
				;;
			stop) # Stop SAM immediately	
				kill_all_sams
				sam_exit 0
				break
				;;
			kill) # Stop and reset SAM completely
				[[ -d /tmp/.SAM_List ]] && rm -rf /tmp/.SAM* && rm -rf /tmp/SAM* && rm -rf /tmp/MiSTer_SAM*
				kill_all_sams
				sam_exit 0
				break
				;;
			update) # Update SAM
				sam_cleanup
				sam_update
				break
				;;
			enable) # Enable SAM autoplay mode
				env_check "${1}"
				sam_enable
				break
				;;
			disable) # Disable SAM autoplay
				sam_cleanup
				sam_disable
				break
				;;
			monitor) # Warn user of changes
				sam_monitor
				break
				;;
			playcurrent)
				sam_exit 2
				break
				;;
			startmonitor | sm)
				sam_start
				sam_monitor
				break
				;;
			amiga | ao486 | arcade | atari2600 | atari5200 | atari7800 | atarilynx | c64 | fds | gb | gbc | gba | genesis | gg | megacd | neogeo | nes | s32x | sms | snes | tgfx16 | tgfx16cd | psx)
				: # Placeholder since we parsed these above
				;;
			single)
				sam_singlemenu
				break
				;;
			utility)
				sam_utilitymenu
				break
				;;
			autoplay)
				sam_autoplaymenu
				break
				;;
			favorite)
				mglfavorite
				break
				;;
			reset)
				sam_resetmenu
				break
				;;
			config)
				sam_configmenu
				break
				;;
			back)
				sam_menu
				break
				;;
			menu)
				sam_menu
				break
				;;
			cancel) # Exit
				echo " It's pitch dark; You are likely to be eaten by a Grue."
				inmenu=0
				break
				;;
			deleteall)
				deleteall
				break
				;;
			exclude)
				samedit_excltags
				break
				;;
			settings)
				sam_settings
				break
				;;
			include)
				samedit_include
				break
				;;
			gamemode)
				sam_gamemodemenu
				break
				;;
			bgm)
				sam_bgmmenu
				break
				;;
			gamelists)
				sam_gamelistmenu
				break
				;;
			creategl)
				creategl
				break
				;;
			deletegl)
				deletegl
				break
				;;
			help)
				sam_help
				break
				;;
			*)
				echo " ERROR! ${1} is unknown."
				echo " Try $(basename -- "${0}") help"
				echo " Or check the Github readme."
				break
				;;
			esac
			shift
		done
	fi
}




# ======== SAM OPERATIONAL FUNCTIONS ========


function loop_core() { # loop_core (core)
	echo -e "Starting Super Attract Mode...\nLet Mortal Kombat begin!\n"
	# Reset game log for this session
	echo "" >/tmp/SAM_Games.log
	samdebug "corelist: ${corelist[*]}"

	while :; do

		while [ ${counter} -gt 0 ]; do
			trap 'counter=0' INT #Break out of loop for skip & next command
			
			#Only show game counter when samvideo is not active
			if [ "${samvideo}" == "yes" ] && [ "$nextcore" == "samvideo" ]; then
				if [ -f /tmp/sv_gametimer ]; then
					counter=$(cat /tmp/sv_gametimer)	
					rm /tmp/sv_gametimer 2>/dev/null
				fi
			else
				echo -ne " Next game in ${counter}...\033[0K\r"
			fi
			


			sleep 1
			((counter--))

			if [ -s /tmp/.SAM_Mouse_Activity ]; then
				if [ "${listenmouse}" == "yes" ]; then
					echo " Mouse activity detected!"
					play_or_exit
				else
					#echo " Mouse activity ignored!"
					truncate -s 0 /tmp/.SAM_Mouse_Activity
				fi
			fi

			if [ -s /tmp/.SAM_Keyboard_Activity ]; then
				if [ "${listenkeyboard}" == "yes" ]; then
					echo " Keyboard activity detected!"
					play_or_exit

				else
					echo " Keyboard activity ignored!"
					truncate -s 0 /tmp/.SAM_Keyboard_Activity
				fi
			fi

			if [ -s /tmp/.SAM_Joy_Activity ]; then
				if [ "${listenjoy}" == "yes" ] && [[ "$(cat /tmp/.SAM_Joy_Activity)" != "Start" ]]; then
					echo " Controller activity detected!"
					play_or_exit
				elif [ "${listenmouse}" == "no" ]; then		
					#echo " Controller activity ignored!"
					truncate -s 0 /tmp/.SAM_Joy_Activity
				else
					sam_exit 3
				fi
			fi

		done

		counter=${gametimer}
		next_core "${1}"

	done
	trap - INT
	sleep 1
}

# Pick a random core

function next_core() { # next_core (core)
	
	load_samvideo
	if [ $? -ne 0 ]; then nextcore="samvideo" && return; fi
	
	if [[ ! ${corelist[*]} ]]; then
		echo "ERROR: FATAL - List of cores is empty."
		echo "Using default corelist"
		declare -ga corelist=("${corelistall[@]}")
		samdebug "Corelist is now ${corelist[*]}"
	fi

	# Pick a core if no corename was supplied as argument (eg "MiSTer_SAM_on.sh psx")
	if [ -z "${1}" ]; then
		corelist_update	
		create_all_gamelists	
		pick_core

	fi

	#samdebug "corelist: ${corelist[*]}"
	#samdebug "corelisttmp: ${corelisttmp[*]}"
	samdebug "Selected core: ${nextcore}"
		
	check_list "${nextcore}"
	if [ $? -ne 0 ]; then next_core; return; fi
	
	# Check if new roms got added
	check_gamelistupdate ${nextcore} &
	
	pick_rom
	
	check_rom "${nextcore}"
	if [ $? -ne 0 ]; then return; fi
	
	delete_played_game
	
	load_core "${nextcore}" "${rompath}" "${romname%.*}"
}

function load_samvideo() {
	sv_loadcounter=$((sv_loadcounter + 1))
	#Load the actual rom (or play a video)
	if [ "${samvideo}" == "yes" ]; then		
		if [ "${samvideo_freq}" == "only" ]; then
			activity_reset
			samvideo_play &
			return 1
		elif [ "${samvideo_freq}" == "core" ]; then
		  	echo "samvideo load core counter is now $sv_loadcounter"
		  	if ((sv_loadcounter % ${#corelist[@]} == 0)); then
				activity_reset
				samvideo_play &
				sv_loadcounter=0
				return 1
		  	fi
		  	return 0

		elif [ "${samvideo_freq}" == "alternate" ]; then
			if ((sv_loadcounter % 2 == 1)); then
				activity_reset
				samvideo_play &
				return 1
		  	else
				return 0
			fi
		fi
		
	fi
}

# Don't repeat same core twice
function corelist_update() {
	
	# TODO avoid tmp file here
	if [ -s "${corelistfile}" ]; then
		unset corelist 
		mapfile -t corelist <${corelistfile}
		rm ${corelistfile}
	fi
	
	if [[ "${disablecoredel}" == "0" ]]; then
		delete_from_corelist "$nextcore" tmp
	fi
	
	
	if [ ${#corelisttmp[@]} -eq 0 ]; then 
		declare -ga corelisttmp=("${corelist[@]}") 
	fi

	if [[ ! "${corelisttmp[*]}" ]]; then
		corelisttmp=("${corelist[@]}")
	fi
}

# Create all gamelists in the background

function create_all_gamelists() {
	# Run this until corelist matches exisitng gamelists
	if [[ "$(for a in "${glclondisk[@]}"; do echo "$a"; done | sort -u)" != "$(for a in "${corelist[@]}"; do echo "$a"; done | sort -u)" ]]; then
		
		samdebug "Checking all game lists now."
		
		# Read all gamelists present
		readarray -t glondisk <<< "$(find "${gamelistpath}" -name "*_gamelist.txt" | awk -F'/' '{ print $NF }' | awk -F'_' '{print$1}')"
		samdebug "Game lists stored on SD: ${glondisk[*]}"
		
		if [[ "${glondisk[*]}" != *"arcade"* ]]; then	
			"${mrsampath}"/samindex -s arcade -o "${gamelistpath}"
		fi
		if [ $? -gt 1 ]; then
			echo "Couldn't find Arcade games. Please run update_all.sh first or add some Arcade games manually."
			sleep 5
			exit
		fi
		
		# Read all gamelists again in case arcade was missing
		if [[ ! "${glondisk[*]}" ]]; then
			unset glondisk
			readarray -t glondisk <<< "$(find "${gamelistpath}" -name "*_gamelist.txt" | awk -F'/' '{ print $NF }' | awk -F'_' '{print$1}')"
		fi
				
		# Check if more gamelists have been created
		unset glclondisk
		for g in "${glondisk[@]}"; do 
			for c in "${corelist[@]}"; do 
				if [[ "$c" == "$g" ]]; then 
					glclondisk+=("$c")
				fi
			done 
		done
		
		samdebug "Game lists that match corelist in ini: ${glclondisk[*]}"
				
		# Remove cores with no games in bg
		check_gamelists &
		
		corelisttmp=("${glclondisk[@]}")
		if [[ "${glclondisk[*]}" ]]; then
			samdebug "Setting corelisttmp to '${glclondisk[*]}'"
			corelisttmp=("${glclondisk[@]}")
		fi
	fi
}

function check_gamelistupdate() {
	if [ ! -f "${gamelistpathtmp}/comp/${1}_gamelist.txt" ] && [[ "${1}" != "amiga" ]]; then
		create_gamelist ${1} comp
		if [[ "$(wc -c "${gamelistpath}/${1}_gamelist.txt" | awk '{print $1}')" != "$(wc -c "${gamelistpathtmp}/comp/${1}_gamelist.txt" | awk '{print $1}')" ]]; then
			samdebug "Changes detected in ${1} folder. Updating gamelist now."
			cp "${gamelistpathtmp}/comp/${1}_gamelist.txt" "${gamelistpath}/${1}_gamelist.txt" 
		fi
	fi
	
}

#Pick next core
function pick_core(){

	nextcore=$(printf "%s\n" "${corelisttmp[@]}" | shuf --random-source=/dev/urandom | head -1)
	
	if [[ ! "${nextcore}" ]]; then
		samdebug "nextcore empty. Using arcade core for now"
		nextcore=arcade
	fi
			
	#Core Weight mode
	if [ "$coreweight" == "yes" ]; then
		#Check if all gamelists have been created
		if [[ "$(for a in "${glclondisk[@]}"; do echo "$a"; done | sort -u)" == "$(for a in "${corelist[@]}"; do echo "$a"; done | sort -u)" ]]; then
			#Check if every core's game library has been counted
			if [[ ! "${corewc[*]}" ]]; then
				readarray -t gltmpondisk <<< "$(find "${gamelistpathtmp}" -name "*_gamelist.txt" | awk -F'/' '{ print $NF }' | awk -F'_' '{print$1}')"
				unset gltmpclondisk
				for g in "${gltmpondisk[@]}"; do 
					for c in "${corelist[@]}"; do 
						if [[ "$c" == "$g" ]]; then 
							gltmpclondisk+=("$c")
						fi
					done 
				done
				readarray -t gltmpexistcl <<< "$(printf '%s\n'  "${corelist[@]}" "${gltmpondisk[@]}"  | sort | uniq -iu )"
				unset gltmpcreate
				#samdebug "gltmpexistcl is "${gltmpexistcl[@]}""
				for g in "${gltmpexistcl[@]}"; do 
					for c in "${corelist[@]}"; do 
						if [[ "$c" == "$g" ]]; then 
							gltmpcreate+=("$c")
						fi
					done 
				done
				echo -n "Please wait while creating gamelists..."
				#samdebug "gltmpcreate is "${gltmpcreatel[@]}""
				for g in "${gltmpcreate[@]}"; do
					check_list "${g}" >/dev/null
				done
				echo "Done."
				
				for c in "${corelist[@]}"; do 
					corewc[$c]="$(wc -l < "${gamelistpathtmp}/${c}_gamelist.txt")"
				done					 
				
				
				totalgamecount="$(printf "%s\n" "${corewc[@]}" | awk '{s+=$1} END {printf "%.0f\n", s}')"
				i=5
				# Sorting cores by games
				while IFS= read -r line; do 
					played_perc=$((${line#*=}*100/totalgamecount))
					if [ "$played_perc" -lt "5" ]; then 
						played_perc=$i
						if [ $i -gt 2 ]; then ((i--)); fi #minimum core display is 2% of the time
					fi
					corep[${line%%=*}]="$played_perc"
				done <<< "$(for k in "${!corewc[@]}"; do echo "$k"'='"${corewc["$k"]}";done | sort -k2 -t'=' -nr )"

				totalpcount=$(printf "%s\n" "${corep[@]}" | awk '{s+=$1} END {printf "%.0f\n", s}')
				disablecoredel=1
				{
				echo -e "\n\nGames per core:\n"
				echo "$(for k in "${!corewc[@]}"; do echo ["$k"] '=' "${corewc["$k"]}"; done | sort -rn -k3)"
				echo -e "\nTotal game count: $totalgamecount\n"
				} > /tmp/.SAM_tmp/totalgcount
				{
				echo -e "\n\nCore selection by app. percentage:\n"
				echo "$(for k in "${!corep[@]}"; do echo ["$k"] '=' "${corep["$k"]}""%"; done | sort -rn -k3)"
				} > /tmp/.SAM_tmp/totalpcount
				pr -Tm /tmp/.SAM_tmp/totalgcount /tmp/.SAM_tmp/totalpcount

				
				
			fi
			#Pick a random core based on how many games a library has
			game=0
			samdebug "totalpcount: $totalpcount"
			pickgame=$(shuf --random-source=/dev/urandom -i 1-"$totalpcount" -n 1)
			for c in "${!corep[@]}"; do 
				let game+=${corep["$c"]}
				if [[ "$game" -gt "$pickgame" ]]; 
					then nextcore=$c
					samdebug "Selected game number: $pickgame / $c"
					break 
				fi
			done
		fi
	fi
			
}

function load_special_core() {
	# If $nextcore is ao486, amiga or arcade 
	if [ "${nextcore}" == "arcade" ]; then
		# If this is an arcade core we go to special code
		load_core_arcade
		return 2
	fi
	if [ "${nextcore}" == "amiga" ]; then
		
		if [ -f "${amigapath}/MegaAGS.hdf" ]; then
			load_core_amiga
		else
			echo "ERROR - MegaAGS Pack not found in Amiga folder. Skipping to next core..."
			delete_from_corelist amiga
			next_core
		fi
		return 2
	fi
	if [ "${nextcore}" == "ao486" ]; then
		if [ "$(find "${ao486path}" -name "*.vhd" | wc -l )" == "0" ]; then
			echo "ERROR - No ao486 screensavers found..."
			delete_from_corelist ao486
			next_core
		else
			load_core_ao486
		fi
		return 2
	fi
}


# Romfinder
function create_gamelist() { # args ${nextcore} 

	if [ ! $(ps -ef | grep -qi '[s]amindex') ] && [ -z "${2}" ]; then
		samdebug "Creating gamelist for ${1}"
		${mrsampath}/samindex -q -s "${1}" -o "${gamelistpath}" 
		if [ $? -gt 1 ]; then
			delete_from_corelist "${1}"
			echo "Can't find games for ${CORE_PRETTY[${1}]}" 
			samdebug "create_gamelist function returned error code"
			return 1
		else	
			cp "${gamelistpath}/${1}_gamelist.txt" "${gamelistpathtmp}/${1}_gamelist.txt" 2>/dev/null
		fi
	elif [ -n "${2}" ]; then
		mkdir -p "${gamelistpathtmp}/comp"
		${mrsampath}/samindex -q -s "${1}" -o "${gamelistpathtmp}/comp"
	fi

}

function check_list() { # args ${nextcore} 
	
	if [ ! -f "${gamelistpath}/${1}_gamelist.txt" ]; then
		echo "Creating game list at ${gamelistpath}/${1}_gamelist.txt"
		create_gamelist "${1}"
		if [ $? -ne 0 ]; then 
			samdebug "check_list function returned error code"
			return 1
		else
			return
		fi
	fi
	
	#if [ "${FIRSTRUN[${1}]}" == "0" ] && [ "${CORE_ZIPPED[${1}]}" == "yes" ] && [ "$(fgrep -c -m 1 ".zip" ${gamelistpath}/${1}_gamelist.txt)" != "0" ]; then
	#	check_zips ${1} &
	#fi
	
	
	# Copy gamelist to tmp
	if [ ! -s "${gamelistpathtmp}/${1}_gamelist.txt" ]; then	
		cp "${gamelistpath}/${1}_gamelist.txt" "${gamelistpathtmp}/${1}_gamelist.txt" 2>/dev/null
		
		filter_list "${1}"
		if [ $? -ne 0 ]; then return 1; fi
	fi
	
}

function pick_rom() {	
	if [ -s ${gamelistpathtmp}/"${nextcore}"_gamelist.txt ]; then
		rompath="$(cat ${gamelistpathtmp}/"${nextcore}"_gamelist.txt | shuf --random-source=/dev/urandom --head-count=1)"
	else
		echo "Gamelist creation failed. Will try again on next core launch. Trying another rom..."	
		rompath="$(cat ${gamelistpath}/"${nextcore}"_gamelist.txt | shuf --random-source=/dev/urandom --head-count=1)"
	fi

}

function check_rom(){
	if [ -z "${rompath}" ]; then
		core_error_rom "${nextcore}" "${rompath}"
		return 1
	fi
	
	# Make sure file exists since we're reading from a static list
	if [[ "${rompath,,}" != *.zip* ]]; then
		if [ ! -f "${rompath}" ]; then
			echo "ERROR: File not found - ${rompath}"
			echo "Creating new game list now..."
			rm "${gamelistpath}/${1}_gamelist.txt"
			create_gamelist "${1}"
			return 1
		fi
	else
		zipfile="$(echo "$rompath" | awk -F".zip" '{print $1}' | sed -e 's/$/.zip/')"
		if [ ! -f "${zipfile}" ]; then
			echo "ERROR: File not found - ${zipfile}"
			echo "Creating new game list now..."
			rm "${gamelistpath}/${1}_gamelist.txt"
			create_gamelist "${1}"
			return 1
		fi
	fi
	
	romname=$(basename "${rompath}")

	# Make sure we have a valid extension as well
	extension="${rompath##*.}"
	extlist="${CORE_EXT[${nextcore}]//,/ }" 
				
	if [[ "$extlist" != *"$extension"* ]]; then
		create_gamelist "${nextcore}" &
		if [ ${romloadfails} -lt ${coreretries} ]; then
			declare -g romloadfails=$((romloadfails + 1))
			samdebug "Wrong extension found: '${extension^^}' for core: ${nextcore} rom: ${rompath}"
			samdebug "Picking new rom.."
			next_core "${nextcore}"
		else
			echo "ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
			echo "ERROR: Core ${nextcore} is blacklisted!"
			delete_from_corelist "${nextcore}"
			echo "List of cores is now: ${corelist[*]}"
			declare -g romloadfails=0
			# Load a different core
			next_core	
		fi
		return 1
	fi

}

function delete_played_game() {
	# Delete played game from list
	samdebug "Selected file: ${rompath}"
	if [ "${norepeat}" == "yes" ]; then
		awk -vLine="$rompath" '!index($0,Line)' "${gamelistpathtmp}/${nextcore}_gamelist.txt" >${tmpfile} && cp -f ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"
	fi
}

# Load selected core and rom
function load_core() { # load_core core /path/to/rom name_of_rom 
	# Load arcade, ao486 or amiga cores
	load_special_core
	if [ $? -ne 0 ]; then return; fi
	local core=${1}
	local rompath=${2}
	local romname=${3}
	local gamename
	local tty_corename
	if [ "${1}" == "neogeo" ] && [ ${useneogeotitles} == "yes" ]; then
		for e in "${!NEOGEO_PRETTY_ENGLISH[@]}"; do
			if [[ "$rompath" == *"$e"* ]]; then
				gamename="${NEOGEO_PRETTY_ENGLISH[$e]}"
			fi
		done
	fi

	if [ ! "${gamename}" ]; then
		gamename="${3}"
	fi
	
	mute "${CORE_LAUNCH[${1}]}"
	

	echo -n "Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${1}]}\e[0m: "
	echo -e "\e[1m${gamename}\e[0m"
	echo "$(date +%H:%M:%S) - ${1} - $([ "${samdebug}" == "yes" ] && echo ${rompath} || echo ${3})" "$(if [ "${1}" == "neogeo" ] && [ ${useneogeotitles} == "yes" ]; then echo "(${gamename})"; fi)" >>/tmp/SAM_Games.log
	echo "${3} (${1}) $(if [ "${1}" == "neogeo" ] && [ ${useneogeotitles} == "yes" ]; then echo "(${gamename})"; fi)" >/tmp/SAM_Game.txt
	tty_corename="${TTY2OLED_PIC_NAME[${1}]}"
	
	
	if [[ "${ttyname_cleanup}" == "yes" ]]; then
		gamename="$(echo "${gamename}" | awk -F "(" '{print $1}')"
	fi

	if [ "${ttyenable}" == "yes" ]; then
		tty_currentinfo=(
			[core_pretty]="${CORE_PRETTY[${nextcore}]}"
			[name]="${gamename}"
			[core]=${tty_corename}
			[date]=$EPOCHSECONDS
			[counter]=${gametimer}
			[name_scroll]="${gamename:0:21}"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
		)
	
		declare -p tty_currentinfo | sed 's/declare -A/declare -gA/' >"${tty_currentinfo_file}"
		tty_displayswitch=$(($gametimer / $ttycoresleep - 1))
		write_to_TTY_cmd_pipe "display_info" &		
		local elapsed=$((EPOCHSECONDS - tty_currentinfo[date]))
		SECONDS=${elapsed}
	fi


	# Create mgl file and launch game
	if [ -s /tmp/SAM_game.mgl ]; then
		mv /tmp/SAM_game.mgl /tmp/SAM_game.previous.mgl
	fi
	
	{
	  echo "<mistergamedescription>"
	  echo "<rbf>${CORE_PATH_RBF[${nextcore}]}/${MGL_CORE[${nextcore}]}</rbf>"
	  echo "<file delay=\"${MGL_DELAY[${nextcore}]}\" type=\"${MGL_TYPE[${nextcore}]}\" index=\"${MGL_INDEX[${nextcore}]}\" path=\"../../../../..${rompath}\"/>"
	} >/tmp/SAM_game.mgl


	echo "load_core /tmp/SAM_game.mgl" >/dev/MiSTer_cmd

	sleep 1
	activity_reset

	# Skip bios screen for FDS or MegaCD
	skipmessage &

}


# ARCADE MODE
function build_mralist() {

	${mrsampath}/samindex -s arcade -o "${gamelistpath}" 
	cp "${gamelistpath}/${1}_gamelist.txt" "${gamelistpathtmp}/${1}_gamelist.txt" 2>/dev/null

}

function load_core_arcade() {

	# Check if the MRA list is empty or doesn't exist - if so, make a new list

	if [ ! -s "${gamelistpath}/${nextcore}_gamelist.txt" ]; then
		samdebug "Rebuilding mra list."
		build_mralist 
	fi
	
	#Check blacklist and copy gamelist to tmp
	if [ ! -s "${gamelistpathtmp}/${nextcore}_gamelist.txt" ]; then
		cp "${gamelistpath}/${nextcore}_gamelist.txt" "${gamelistpathtmp}/${nextcore}_gamelist.txt" 2>/dev/null
		
		filter_list arcade
		
	fi
	
	sed -i '/^$/d' "${gamelistpathtmp}/${nextcore}_gamelist.txt"
	
	
	# Get a random game from the list
	mra="$(shuf --random-source=/dev/urandom --head-count=1 ${gamelistpathtmp}/${nextcore}_gamelist.txt)"
	
	# Check if Game exists
	if [ ! -f "${mra}" ]; then
		build_mralist 
		mra=$(shuf --random-source=/dev/urandom --head-count=1 ${gamelistpathtmp}/${nextcore}_gamelist.txt)
	fi
	
	
	#mraname="$(basename "${mra}" | sed -e 's/\.[^.]*$//')"	
	mraname="$(basename "${mra//.mra/}")"
	mrasetname=$(grep "<setname>" "${mra}" | sed -e 's/<setname>//' -e 's/<\/setname>//' | tr -cd '[:alnum:]')
	tty_corename="${mrasetname}"

	samdebug "Selected file: ${mra}"

	# Delete mra from list so it doesn't repeat
	if [ "${norepeat}" == "yes" ]; then
		awk -vLine="$mra" '!index($0,Line)' "${gamelistpathtmp}/${nextcore}_gamelist.txt" >${tmpfile} && cp -f ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"

	fi
		if [ "${ttyenable}" == "yes" ]; then
		tty_currentinfo=(
			[core_pretty]="${CORE_PRETTY[${nextcore}]}"
			[name]="${mraname}"
			[core]=${tty_corename}
			[date]=$EPOCHSECONDS
			[counter]=${gametimer}
			[name_scroll]="${mraname:0:21}"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
		)
		declare -p tty_currentinfo | sed 's/declare -A/declare -gA/' >"${tty_currentinfo_file}"
		write_to_TTY_cmd_pipe "display_info" &
		local elapsed=$((EPOCHSECONDS - tty_currentinfo[date]))
		SECONDS=${elapsed}
	fi



	echo -n "Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
	echo -e "\e[1m${mraname}\e[0m"
	echo "$(date +%H:%M:%S) - Arcade - ${mraname}" >>/tmp/SAM_Games.log
	echo "${mraname} (${nextcore})" >/tmp/SAM_Game.txt
	
	mute "${mrasetname}"
	
	# Tell MiSTer to load the next MRA
	echo "load_core ${mra}" >/dev/MiSTer_cmd
	
	sleep 1
	activity_reset
	

}

function create_amigalist () {

	if [ -f "${amigapath}/listings/games.txt" ]; then
		if [[ "${amigaselect}" == "demos" ]]; then
			cat "${amigapath}/listings/demos.txt" > ${gamelistpathtmp}/amiga_gamelist.txt
			sed -i -e 's/^/Demo: /' ${gamelistpathtmp}/amiga_gamelist.txt
		elif [[ "${amigaselect}" == "games" ]]; then
			cat "${amigapath}/listings/games.txt" > ${gamelistpathtmp}/amiga_gamelist.txt
		elif [[ "${amigaselect}" == "all" ]]; then
			cat "${amigapath}/listings/demos.txt" > ${gamelistpathtmp}/amiga_gamelist.txt
			sed -i -e 's/^/Demo: /' ${gamelistpathtmp}/amiga_gamelist.txt
			cat "${amigapath}/listings/games.txt" >> ${gamelistpathtmp}/amiga_gamelist.txt			
			
		else
			samdebug "Invalid option specified for amigaselect variable."
		fi
		total_games="$(wc -l < "${gamelistpathtmp}/amiga_gamelist.txt")"
		samdebug "${total_games} Games and/or Demos found."
	else
		echo "ERROR: Can't find Amiga games.txt or demos.txt file"
	fi

}


function load_core_amiga() {

	if [ ! -f "${gamelistpath}/${nextcore}_gamelist.txt" ]; then
		[ -f "${amigapath}/listings/demos.txt" ] && cat "${amigapath}/listings/demos.txt" > ${gamelistpath}/amiga_gamelist.txt
		sed -i -e 's/^/Demo: /' ${gamelistpath}/amiga_gamelist.txt
		[ -f "${amigapath}/listings/games.txt" ] && cat "${amigapath}/listings/games.txt" >> ${gamelistpath}/amiga_gamelist.txt
	fi

	if [ ! -s "${gamelistpathtmp}/${nextcore}_gamelist.txt" ]; then
		create_amigalist
		filter_list amiga
	fi
		
	mute Minimig

	if [ ! -f "${amigapath}/listings/games.txt" ]; then
		# This is for MegaAGS version June 2022 or older
		echo -n "Starting now on the "
		echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
		echo -e "\e[1mMegaAGS Amiga Game\e[0m"

		# Tell MiSTer to load the next MRA

		echo "load_core ${amigacore}" >/dev/MiSTer_cmd
		sleep 13
		"${mrsampath}/mbc" raw_seq {6c
		"${mrsampath}/mbc" raw_seq O
		activity_reset
	else
		# This is for MegaAGS version July 2022 or newer

		rompath="$(shuf --random-source=/dev/urandom --head-count=1 ${gamelistpathtmp}/"${nextcore}"_gamelist.txt)"
		agpretty="$(echo "${rompath}" | tr '_' ' ')"
		
		# Special case for demo
		if [[ "${rompath}" == *"Demo:"* ]]; then
			rompath=${rompath//Demo: /}
		fi

		# Delete played game from list
		samdebug "Selected file: ${rompath}"
		if [ "${norepeat}" == "yes" ]; then
			awk -vLine="$rompath" '!index($0,Line)' "${gamelistpathtmp}/${nextcore}_gamelist.txt" >${tmpfile} && cp -f ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"
		fi

		echo "${rompath}" > "${amigapath}"/shared/ags_boot
		tty_corename="Minimig"
		
		if [ "${ttyenable}" == "yes" ]; then
			tty_currentinfo=(
				[core_pretty]="${CORE_PRETTY[${nextcore}]}"
				[name]="${agpretty}"
				[core]=${tty_corename}
				[date]=$EPOCHSECONDS
				[counter]=${gametimer}
				[name_scroll]="${agpretty:0:21}"
				[name_scroll_position]=0
				[name_scroll_direction]=1
				[update_pause]=${ttyupdate_pause}
			)
			declare -p tty_currentinfo | sed 's/declare -A/declare -gA/' >"${tty_currentinfo_file}"
			write_to_TTY_cmd_pipe "display_info" &
			local elapsed=$((EPOCHSECONDS - tty_currentinfo[date]))
			SECONDS=${elapsed}
		fi
		


		echo -n "Starting now on the "
		echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
		echo -e "\e[1m${agpretty}\e[0m"
		echo "$(date +%H:%M:%S) - ${nextcore} - ${rompath}" >>/tmp/SAM_Games.log
		echo "${rompath} (${nextcore})" >/tmp/SAM_Game.txt
		echo "load_core ${amigacore}" >/dev/MiSTer_cmd
		activity_reset
	fi
}

function create_ao486list () {

	find "${ao486path}" -name "*.vhd" > "${gamelistpath}/${nextcore}_gamelist.txt"

}

function load_core_ao486() {

	if [ ! -s "${gamelistpathtmp}/${nextcore}_gamelist.txt" ]; then
		create_ao486list
		cp "${gamelistpath}/${nextcore}_gamelist.txt" "${gamelistpathtmp}/${nextcore}_gamelist.txt" &>/dev/null
		filter_list ao486
		if [ $? -eq 1 ]; then
			next_core
			return
		fi
	fi
		
	mute ao486
	rompath="$(shuf --random-source=/dev/urandom --head-count=1 ${gamelistpathtmp}/"${nextcore}"_gamelist.txt)"
	romname=$(basename "${rompath}")
	aopretty="$(echo "${romname%.*}" | tr '_' ' ')"		

	# Delete played game from list
	samdebug "Selected file: ${rompath}"
	if [ "${norepeat}" == "yes" ]; then
		awk -vLine="$rompath" '!index($0,Line)' "${gamelistpathtmp}/${nextcore}_gamelist.txt" >${tmpfile} && cp -f ${tmpfile} "${gamelistpathtmp}/${nextcore}_gamelist.txt"
	fi

	tty_corename="ao486"
	
	if [ "${ttyenable}" == "yes" ]; then
		tty_currentinfo=(
			[core_pretty]="${CORE_PRETTY[${nextcore}]}"
			[name]="${aopretty}"
			[core]=${tty_corename}
			[date]=$EPOCHSECONDS
			[counter]=${gametimer}
			[name_scroll]="${aopretty:0:21}"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
		)
		declare -p tty_currentinfo | sed 's/declare -A/declare -gA/' >"${tty_currentinfo_file}"
		write_to_TTY_cmd_pipe "display_info" &
		local elapsed=$((EPOCHSECONDS - tty_currentinfo[date]))
		SECONDS=${elapsed}
	fi
	


	echo -n "Starting now on the "
	echo -ne "\e[4m${CORE_PRETTY[${nextcore}]}\e[0m: "
	echo -e "\e[1m${aopretty}\e[0m"
	echo "$(date +%H:%M:%S) - ${nextcore} - ${romname}" >>/tmp/SAM_Games.log
	echo "${romname} (${nextcore})" >/tmp/SAM_Game.txt

	if [ "$(find "${ao486path}" -maxdepth 1 -iname "${romname%.*}.cue" | wc -l )" != "0" ]; then
	  extension=".cue"
	elif [ "$(find "${ao486path}" -maxdepth 1 -iname "${romname%.*}.iso" | wc -l )" != "0" ]; then
	  extension=".iso"
	else
	  extension=""
	fi

	{
	  echo "<mistergamedescription>" 
	  echo "<rbf>${CORE_PATH_RBF[${nextcore}]}/${MGL_CORE[${nextcore}]}</rbf>"
	  echo "<file delay=\"${MGL_DELAY[${nextcore}]}\" type=\"${MGL_TYPE[${nextcore}]}\" index=\"${MGL_INDEX[${nextcore}]}\" path=\"../../../../..${rompath}\"/>"
	  if [ -n "$extension" ]; then
		echo "<file delay=\"${MGL_DELAY[${nextcore}]}\" type=\"${MGL_TYPE[${nextcore}]}\" index=\"4\" path=\"../../../../..${rompath%.*}$extension\"/>"
	  fi
	  echo 
	  echo "<reset delay=0/>"
	} >/tmp/SAM_game.mgl
	
	echo "load_core /tmp/SAM_game.mgl" >/dev/MiSTer_cmd

	sleep 1
	activity_reset


}

# ========= SAM START AND STOP =========

function sam_start() {
	env_check
	# Terminate any other running SAM processes
	there_can_be_only_one
	mcp_start
	sam_prep
	disable_bootrom # Disable Bootrom until Reboot
	bgm_start
	tty_start
	echo "Starting SAM in the background."
	tmux new-session -x 180 -y 40 -n "-= SAM Monitor -- Detach with ctrl-b, then push d  =-" -s SAM -d "${misterpath}/Scripts/MiSTer_SAM_on.sh" start_real "${nextcore}"
}

function boot_sleep() { #Wait for rtc sync
	unset end
	end=$((SECONDS+60))
	while [ $SECONDS -lt $end ]; do
		if [[ "$(date +%Y)" -gt "2020" ]]; then 
			break
		else
			sleep 1
		fi 
	done
}

function there_can_be_only_one() { # there_can_be_only_one
	# If another attract process is running kill it
	# This can happen if the script is started multiple times
	
	echo "Stopping other running instances of ${samprocess}..."

	kill_1=$(ps -o pid,args | grep '[M]iSTer_SAM_init start' | awk '{print $1}' | head -1)
	kill_2=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh start_real' | awk '{print $1}')
	kill_3=$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh bootstart_real' | awk '{print $1}' | head -1)

	[[ -n ${kill_1} ]] && kill -9 "${kill_1}" >/dev/null
	for kill in ${kill_2}; do
		[[ -n ${kill_2} ]] && kill -9 "${kill}" >/dev/null
	done
	[[ -n ${kill_3} ]] && kill -9 "${kill_3}" >/dev/null

	sleep 1

}

function kill_all_sams() {
	# Kill all SAM processes except for currently running
	ps -ef | grep -i '[M]iSTer_SAM' | awk -v me=${sampid} '$1 != me {print $1}' | xargs kill &>/dev/null
}

function play_or_exit() {
	if [ "${playcurrentgame}" == "yes" ] && { [ ${mute} == "yes" ] || [ ${mute} == "global" ] || [ ${mute} == "core" ]; }; then
		sam_exit 3
	elif [ "${playcurrentgame}" == "yes" ] && [ ${mute} == "no" ]; then
		sam_exit 2
	else
		sam_exit 0
	fi
}

function sam_exit() { # args = ${1}(exit_code required) ${2} optional error message
	sam_cleanup
	if [ "${1}" -eq 0 ]; then # just exit
		echo "load_core /media/fat/menu.rbf" >/dev/MiSTer_cmd
		sleep 1
		echo "Thanks for playing!"
	elif [ "${1}" -eq 1 ]; then # Error
		echo "load_core /media/fat/menu.rbf" >/dev/MiSTer_cmd
		sleep 1
		echo "There was an error ${2}" # Pass error messages in ${2}
	elif [ "${1}" -eq 2 ]; then        # Play Current Game
		sleep 1
	elif [ "${1}" -eq 3 ]; then # Play Current Game, relaunch because of mute
		sleep 1
		if [ "${nextcore}" == "arcade" ]; then
			echo "load_core ${mra}" >/dev/MiSTer_cmd
		else
			echo "load_core /tmp/SAM_game.mgl" >/dev/MiSTer_cmd
		fi
	fi
	
	#	Exit SAM Modules
	bgm_stop
	tty_exit
	ps -ef | grep -i '[M]iSTer_SAM_on.sh' | xargs kill &>/dev/null

}


# ======== UTILITY FUNCTIONS ========

function mcp_start() {
	# MCP monitors when SAM should be launched. "menuonly" and "samtimeout" determine when MCP launches SAM
	if [ -z "$(pidof MiSTer_SAM_MCP)" ]; then
		tmux new-session -s MCP -d "${mrsampath}/MiSTer_SAM_MCP"
	fi
}

function activity_reset() {
		truncate -s 0 /tmp/.SAM_Joy_Activity
		truncate -s 0 /tmp/.SAM_Mouse_Activity
		truncate -s 0 /tmp/.SAM_Keyboard_Activity
}								 

function init_paths() {
	# Create folders if they don't exist
	mkdir -p "${mrsampath}/SAM_Gamelists"
	#[ -d "/tmp/.SAM_List" ] && rm -rf /tmp/.SAM_List
	mkdir -p /tmp/.SAM_List
	[ -e "${tmpfile}" ] && { rm "${tmpfile}"; }
	[ -e "${tmpfile2}" ] && { rm "${tmpfile2}"; }
	touch "${tmpfile}"
	touch "${tmpfile2}"
}

function sam_prep() {
	[ ! -d "/tmp/.SAM_tmp/SAM_config" ] && mkdir -p "/tmp/.SAM_tmp/SAM_config"
	[ ! -d "${mrsampath}/video" ] && mkdir -p "${mrsampath}/video"
	[[ -f /tmp/SAM_game.previous.mgl ]] && rm /tmp/SAM_game.previous.mgl
	[[ ! -d "${mrsampath}" ]] && mkdir -p "${mrsampath}"
	[[ ! -d "${mrsamtmp}" ]] && mkdir -p "${mrsamtmp}"
	mkdir -p /media/fat/Games/SAM &>/dev/null
	[ ! -d "/tmp/.SAM_tmp/Amiga_shared" ] && mkdir -p "/tmp/.SAM_tmp/Amiga_shared"
	if [ -d "${amigapath}/shared" ] && [ "$(mount | grep -ic "${amigapath}"/shared)" == "0" ]; then
		if [ "$(du -m "${amigapath}/shared" | cut -f1)" -lt 30 ]; then
			cp -r --force "${amigapath}"/shared/* /tmp/.SAM_tmp/Amiga_shared &>/dev/null
			mount --bind "/tmp/.SAM_tmp/Amiga_shared" "${amigapath}/shared"
		else
			echo "WARNING: ${amigapath}/shared folder is bigger than 30 MB. Items in shared folder won't be accessible while SAM is running."
			mount --bind "/tmp/.SAM_tmp/Amiga_shared" "${amigapath}/shared"
		fi
	fi
	if [ "${kids_safe}" == "yes" ]; then
		if [ ! -f "${mrsampath}"/SAM_Rated/amiga_rated.txt ]; then
			echo "No kids safe rating lists found."
			get_ratedlist
			if [ $? -ne 0 ]; then 
				echo "Kids Safe Filter failed downloading."
				return 1
			else
				echo "Kids Safe Filter active."
			fi
		else
			echo "Kids Safe Filter active."
		fi
		#Set corelist to only include cores with rated lists
		readarray -t glr <<< "$(find "${mrsampath}/SAM_Rated" -name "*_rated.txt" | awk -F'/' '{ print $NF }' | awk -F'_' '{print$1}')"
		unset clr
		for g in "${glr[@]}"; do 
			for c in "${corelist[@]}"; do 
				if [[ "$c" == "$g" ]]; then 
					clr+=("$c")
				fi
			done 
		done
		readarray -t nclr <<< "$(printf '%s\n'  "${clr[@]}" "${corelist[@]}"  | sort | uniq -iu )"		
		echo "Kids Safe lists missing for cores: ${nclr[@]}"
		printf "%s\n" "${clr[@]}" > "${corelistfile}"
	fi
	[ "${coreweight}" == "yes" ] && echo "Weighted core mode active."
	[ "${samdebuglog}" == "yes" ] && rm /tmp/samdebug.log 2>/dev/null
	if [ "${samvideo}" == "yes" ]; then
		misterini_mod
		if [ ! -f "${mrsampath}"/mplayer ]; then
			if [ -f "${mrsampath}"/mplayer.zip ]; then
				unzip -ojq "${mrsampath}"/mplayer.zip -d "${mrsampath}" # &>/dev/null
			else
				get_samvideo
			fi
		fi
	fi
	if [ ! -f "${mrsampath}"/ytdl ]; then
			curl_download "${mrsampath}"/ytdl "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux_armv7l"
	fi

}

function sam_cleanup() {
	# Clean up by umounting any mount binds
	[ -f "/media/fat/config/Volume.dat" ] && [ ${mute} == "global" ] && rm "/media/fat/config/Volume.dat"
	[ "$(mount | grep -ic "${amigapath}"/shared)" == "1" ] && umount "${amigapath}/shared"
	[ -d "${misterpath}/Bootrom" ] && [ "$(mount | grep -ic 'bootrom')" == "1" ] && umount "${misterpath}/Bootrom"
	[ -f "${misterpath}/Games/NES/boot1.rom" ] && [ "$(mount | grep -ic 'nes/boot1.rom')" == "1" ] && umount "${misterpath}/Games/NES/boot1.rom"
	[ -f "${misterpath}/Games/NES/boot2.rom" ] && [ "$(mount | grep -ic 'nes/boot2.rom')" == "1" ] && umount "${misterpath}/Games/NES/boot2.rom"
	[ -f "${misterpath}/Games/NES/boot3.rom" ] && [ "$(mount | grep -ic 'nes/boot3.rom')" == "1" ] && umount "${misterpath}/Games/NES/boot3.rom"
	[ ${mute} != "no" ] && [ "$(mount | grep -qic _volume.cfg)" != "0" ] && readarray -t volmount <<< "$(mount | grep -i _volume.cfg | awk '{print $3}')" && umount "${volmount[@]}" >/dev/null
	[ "${samvideo}" == "yes" ] && misterini_reset
	samdebug "Cleanup done."
}

function sam_monitor() {

	tmux attach-session -t SAM
}

function sam_enable() { # Enable autoplay
	echo -n " Enabling MiSTer SAM Autoplay..."

	# Awaken daemon
	# Check for and delete old fashioned scripts to prefer /media/fat/linux/user-startup.sh
	# (https://misterfpga.org/viewtopic.php?p=32159#p32159)

	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	# Add new startup way
	if [ ! -e "${userstartup}" ] && [ -e /etc/init.d/S99user ]; then
		if [ -e "${userstartuptpl}" ]; then
			echo "Copying ${userstartuptpl} to ${userstartup}"
			cp "${userstartuptpl}" "${userstartup}"
			sleep 1
		else
			echo "Building ${userstartup}"
		fi
	fi
	if [ "$(grep -ic "mister_sam" ${userstartup})" = "0" ]; then
		echo -e "Adding SAM to ${userstartup}\n"
		echo -e "\n# Startup MiSTer_SAM - Super Attract Mode" >>${userstartup}
		echo -e "[[ -e ${mrsampath}/MiSTer_SAM_init ]] && ${mrsampath}/MiSTer_SAM_init \$1 &" >>"${userstartup}"
	fi
	echo "SAM install complete."
	echo -e "\n\n\n"
	source "${misterpath}/Scripts/MiSTer_SAM.ini"
	echo -ne "\e[1m" SAM will start ${samtimeout} sec. after boot"\e[0m"
	if [ "${menuonly,,}" == "yes" ]; then
		echo -ne "\e[1m" in the main menu"\e[0m"
	else
		echo -ne "\e[1m" whenever controller is not in use"\e[0m"
	fi
	echo -e "\e[1m" and show each game for ${gametimer} sec."\e[0m"
	echo -ne "\e[1m" First run will take some time to compile game list... please wait."\e[0m"
	echo -e "\n\n\n"
	sleep 5

	"${misterpath}/Scripts/MiSTer_SAM_on.sh" start

	exit
}

function sam_disable() { # Disable autoplay

	echo -n " Disabling SAM autoplay..."
	# Clean out existing processes to ensure we can update

	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi

	there_can_be_only_one
	sed -i '/MiSTer_SAM/d' ${userstartup}
	sync
	echo " Done."
}


function env_check() {
	# Check if we've been installed
	if [ ! -f "${mrsampath}/partun" ] || [ ! -f "${mrsampath}/MiSTer_SAM_MCP" ]; then
		echo " SAM required files not found."
		echo " Installing now."
		sam_update autoconfig
		echo " Setup complete."
	fi
}

function deleteall() {
	# In case of issues, reset SAM

	there_can_be_only_one
	
	mkdir -p /media/fat/Scripts/.SAM_Backup
	find "/media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists" -name "*_excludelist.txt" -exec cp '{}' "/media/fat/Scripts/.SAM_Backup" \;
	cp /media/fat/Scripts/MiSTer_SAM.ini "/media/fat/Scripts/.SAM_Backup" 2>/dev/null
	
	if [ -d "${mrsampath}" ]; then
		echo "Deleting MiSTer_SAM folder"
		rm -rf "${mrsampath}"
	fi
	if [ -f "/media/fat/Scripts/MiSTer_SAM.ini" ]; then
		echo "Deleting MiSTer_SAM.ini"
		cp /media/fat/Scripts/MiSTer_SAM.ini /media/fat/Scripts/MiSTer_SAM.ini.bak
		rm /media/fat/Scripts/MiSTer_SAM.ini
	fi
	if [ -f "/media/fat/Scripts/MiSTer_SAM_off.sh" ]; then
		echo "Deleting MiSTer_SAM_off.sh"
		rm /media/fat/Scripts/MiSTer_SAM_off.sh
	fi
	
	if [ -d "/tmp/.SAM_List" ]; then
		echo "Deleting temporary files"
		rm -rf "/tmp/.SAM_List"
	fi
	
	if ls /media/fat/Config/inputs/*_input_1234_5678_v3.map 1>/dev/null 2>&1; then
		echo "Deleting Keyboard mapping files"
		rm /media/fat/Config/inputs/*_input_1234_5678_v3.map
	fi
	# Remount root as read-write if read-only so we can remove daemon
	mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
	[ "$RO_ROOT" == "true" ] && mount / -o remount,rw

	# Delete daemon
	echo "Deleting Auto boot Daemon..."
	if [ -f /etc/init.d/S93mistersam ] || [ -f /etc/init.d/_S93mistersam ]; then
		mount | grep "on / .*[(,]ro[,$]" -q && RO_ROOT="true"
		[ "$RO_ROOT" == "true" ] && mount / -o remount,rw
		sync
		rm /etc/init.d/S93mistersam &>/dev/null
		rm /etc/init.d/_S93mistersam &>/dev/null
		sync
		[ "$RO_ROOT" == "true" ] && mount / -o remount,ro
	fi
	echo "Done."

	sed -i '/MiSTer_SAM/d' ${userstartup}
	sed -i '/Super Attract/d' ${userstartup}

	printf "\nAll files deleted except for MiSTer_SAM_on.sh\n"
	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_resetmenu
	else
		printf "\nGamelist reset successful. Please start SAM now.\n"
		sleep 1
		parse_cmd stop
	fi
}


function deletegl() {
	# In case of issues, reset game lists

	there_can_be_only_one
	if [ -d "${mrsampath}/SAM_Gamelists" ]; then
		echo "Deleting MiSTer_SAM Gamelist folder"
		rm  "${mrsampath}"/SAM_Gamelists/*_gamelist.txt
	fi

	if [ -d /tmp/.SAM_List ]; then
		rm -rf /tmp/.SAM_List
	fi

	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_menu
	else
		echo -e "\nGamelist reset successful. Please start SAM now.\n"
		sleep 1
		parse_cmd stop
	fi
}

# Check if gamelists exist
function checkgl() {
	if ! compgen -G "${gamelistpath}/*_gamelist.txt" >/dev/null; then
		echo "Creating Game Lists"
		read_samini
		creategl
	fi
}

function creategl() {
	init_vars 
	read_samini 
	init_paths 
	init_data
	${mrsampath}/samindex -o "${gamelistpath}"
	
	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_menu
	else
		echo -e "\nGamelist creation successful. Please start SAM now.\n"
		sleep 1
		parse_cmd stop
	fi
}

function skipmessage() {
	if [ "${skipmessage}" == "yes" ] && [ "${CORE_SKIP[${nextcore}]}" == "yes" ]; then
		sleep 10
		samdebug "Button push sent to skip BIOS"
		"${mrsampath}/mbc" raw_seq :31
		sleep 1
		"${mrsampath}/mbc" raw_seq :31
		
	fi
}

function mglfavorite() {
	# Add current game to _Favorites folder

	if [ ! -d "${misterpath}/_Favorites" ]; then
		mkdir -p "${misterpath}/_Favorites"
	fi
	cp /tmp/SAM_game.mgl "${misterpath}/_Favorites/$(cat /tmp/SAM_Game.txt).mgl"

}

function ignoregame() {
	declare -l currentrbf="$(cat /tmp/SAM_Games.log | tail -n1 | awk -F- '{print $2}')"
	currentgame="$(cat /tmp/SAM_Games.log | tail -n1 | awk 'BEGIN{FS=OFS="\-"; }{for(i=3;i<NF;i++) printf "%s", $i OFS; print $NF }')"
	cr=`echo $currentrbf`
	cg=`echo $currentgame`
	if [ ! -f "${gamelistpath}/${cr}_excludelist.txt" ]; then
		touch "${gamelistpath}/${cr}_excludelist.txt"
	fi	
	echo ${cg} >> "${gamelistpath}/${cr}_excludelist.txt"
	echo "${currentgame:1} added to ${cr}_excludelist.txt"
	echo ""
	echo "Tip: If you want to add the game again, go to ${gamelistpath}/${cr}_excludelist.txt"
	echo ""
}
	

function delete_from_corelist() { # delete_from_corelist core tmp
	if [ -z "$2" ]; then
		for i in "${!corelist[@]}"; do
			if [[ ${corelist[i]} = "$1" ]]; then
				unset 'corelist[i]'
				samdebug "Deleted $1 from corelist"
			fi
		done
		samdebug "Corelist now ${corelist[@]}"
		printf "%s\n" "${corelist[@]}" > "${corelistfile}"
	else
		for i in "${!corelisttmp[@]}"; do
			if [[ ${corelisttmp[i]} = "$1" ]]; then
				unset 'corelisttmp[i]'
			fi
		done
		#printf "%s\n" ${corelisttmp[@]} > ${corelisttmpfile}
	fi
}


function reset_core_gl() { # args ${nextcore}
	echo " Deleting old game lists for ${1^^}..."
	rm "${gamelistpath}/${1}_gamelist.txt" &>/dev/null
	sync
}


function core_error_rom() { # core_error core /path/to/ROM
	if [ ${romloadfails} -lt ${coreretries} ]; then
		declare -g romloadfails=$((romloadfails + 1))
		echo " ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
		echo " Trying to find another rom..."
		next_core "${1}"
	else
		echo " ERROR: Failed ${romloadfails} times. No valid game found for core: ${1} rom: ${2}"
		echo " ERROR: Core ${1} is blacklisted!"
		delete_from_corelist "${1}"
		echo " List of cores is now: ${corelist[*]}"
		declare -g romloadfails=0
		# Load a different core
		next_core
	fi
}

function core_error_checklist() { # core_error core /path/to/ROM
		delete_from_corelist "${1}"
		echo " List of cores is now: ${corelist[*]}"
		declare -g romloadfails=0
		# Load a different core
		next_core

}


function disable_bootrom() {
	if [ "${disablebootrom}" == "Yes" ]; then
		# Make Bootrom folder inaccessible until restart
		mkdir -p /tmp/.SAM_List/Bootrom
		[ -d "${misterpath}/Bootrom" ] && [ "$(mount | grep -ic 'bootrom')" == "0" ] && mount --bind /tmp/.SAM_List/Bootrom "${misterpath}/Bootrom"
		# Disable Nes bootroms except for FDS Bios (boot0.rom)
		[ -f "${misterpath}/Games/NES/boot1.rom" ] && [ "$(mount | grep -ic 'nes/boot1.rom')" == "0" ] && touch /tmp/brfake && mount --bind /tmp/brfake "${misterpath}/Games/NES/boot1.rom"
		[ -f "${misterpath}/Games/NES/boot2.rom" ] && [ "$(mount | grep -ic 'nes/boot2.rom')" == "0" ] && touch /tmp/brfake && mount --bind /tmp/brfake "${misterpath}/Games/NES/boot2.rom"
		[ -f "${misterpath}/Games/NES/boot3.rom" ] && [ "$(mount | grep -ic 'nes/boot3.rom')" == "0" ] && touch /tmp/brfake && mount --bind /tmp/brfake "${misterpath}/Games/NES/boot3.rom"
	fi
}

function mute() {
	if [ "${mute}" == "global" ]; then
		if [ -f "/media/fat/config/Volume.dat" ]; then
	 		if [[ "$(xxd "/media/fat/config/Volume.dat" |awk '{print $2}')" != 10 ]]; then
				# Mute Global Volume
				echo "volume mute" > /dev/MiSTer_cmd
			fi
		else
			#echo -e "\0020\c" >/media/fat/config/Volume.dat
			echo "volume mute" > /dev/MiSTer_cmd
		fi
			
	elif [ "${mute}" == "core" ] || [ "${mute}" == "yes" ]; then
		# Create empty volume files. Only SD card write operation necessary for mute to work.
		[ ! -f "/media/fat/config/${1}_volume.cfg" ] && touch "/media/fat/config/${1}_volume.cfg"
		[ ! -f "/tmp/.SAM_tmp/SAM_config/${1}_volume.cfg" ] && touch "/tmp/.SAM_tmp/SAM_config/${1}_volume.cfg"		
		for i in {1..3}; do
		  if mount | grep -iq "/media/fat/config/${1}_volume.cfg"; then
			samdebug "${1}_volume.cfg already mounted"
			break
		  fi

		  mount --bind "/tmp/.SAM_tmp/SAM_config/${1}_volume.cfg" "/media/fat/config/${1}_volume.cfg"
		  
		  if [ $? -eq 0 ]; then
			samdebug "${1}_volume.cfg mounted successfully"
			break
		  else
			echo "ERROR: Failed to mute ${1} (attempt ${i})"
			if [ $i -eq 3 ]; then
			  echo "ERROR: All attempts to mute ${1} failed... Continuing."
			fi
			sleep 2
		  fi
		done
		[[ "$(mount | grep -ic "${1}"_volume.cfg)" != "0" ]] && echo -e "\0006\c" > "/tmp/.SAM_tmp/SAM_config/${1}_volume.cfg"
		# Only keep one volume.cfg file mounted
		if [ -n "${prevcore}" ] && [ "${prevcore}" != "${1}" ]; then
			umount /media/fat/config/"${prevcore}_volume.cfg"
			sync
		fi	
		prevcore=${1}

	fi
}

function check_zips() { # check_zips core
	# Check if zip still exists
	#samdebug "Checking zips in file..."
	unset zipsondisk
	unset zipsinfile
	unset files
	unset newfiles
	mapfile -t zipsinfile < <(fgrep ".zip" "${gamelistpath}/${1}_gamelist.txt" | awk -F".zip" '!seen[$1]++' | awk -F".zip" '{print $1}' | sed -e 's/$/.zip/')
	if [ ${#zipsinfile[@]} -gt 0 ]; then
		for zips in "${zipsinfile[@]}"; do
			if [ ! -f "${zips}" ]; then
				samdebug "Creating new game list because zip file[s] seems to have changed."
				create_gamelist "${1}"
				unset zipsinfile
				mapfile -t zipsinfile < <(fgrep ".zip" "${gamelistpath}/${1}_gamelist.txt" | awk -F".zip" '!seen[$1]++' | awk -F".zip" '{print $1}' | sed -e 's/$/.zip/')
				break
				return
			fi
		done
		#samdebug "Done."
		#samdebug -n "Checking zips on disk..."
		if [ "${checkzipsondisk}" == "yes" ]; then 
			# Check for new zips
			corepath="$("${mrsampath}"/samindex -q -s "${1}" -d |awk -F':' '{print $2}')"
			readarray -t files <<< "$(find "${corepath}" -maxdepth 2 -type f -name "*.zip")"
			extgrep=$(echo ".${CORE_EXT[${1}]}" | sed -e "s/,/\\\|/g"| sed 's/,/,./g')
			# Check which files have valid roms
			readarray -t newfiles <<< "$(printf '%s\n'  "${zipsinfile[@]}" "${files[@]}"  | sort | uniq -iu )"
			if [[ "${newfiles[*]}" ]]; then
				for f in "${newfiles[@]}"; do
					if [ -f "${f}" ]; then
						if "${mrsampath}"/partun -l "${f}" --ext "${extgrep}" | grep -q "${extgrep}"; then
							zipsondisk+=( "${f}" )
						fi
					else
						samdebug "Zip file ${f} not found"
					fi
				done
			fi
			if [[ "${zipsondisk[*]}" ]]; then
				result="$(printf '%s\n' "${zipsondisk[@]}")"
				if [[ "${result}" ]]; then
					samdebug "Found new zip file[s]: ${result##*/}"
					create_gamelist "${1}"
					return
				fi
			fi
		fi
	fi
	#samdebug "Done."
}
	
	
function check_gamelists() {

	unset glcreate
	readarray -t glexistcl <<< "$(printf '%s\n'  "${corelist[@]}" "${glondisk[@]}"  | sort | uniq -iu )"

	for g in "${glexistcl[@]}"; do 
		for c in "${corelist[@]}"; do 
			if [[ "$c" == "$g" ]]; then 
				glcreate+=("$c")
			fi
		done 
	done
	
	if [[ "${glcreate[*]}" == *"amiga"* ]]; then
		create_amigalist &
		glcreate=( "${glcreate[@]/amiga}" )
	fi


	if [[ "${glcreate[*]}" ]] && [[ ! "$(ps -ef | grep -i '[s]amindex')" ]]; then
		unset nogames
		for c in "${glcreate[@]}"; do
			samdebug "Creating "$c" gamelist"
			"${mrsampath}"/samindex -q -s "$c" -o "${gamelistpath}"
			if [ $? -gt 1 ]; then
				nogames+=("$c")
			fi
		done
		
		if [[ "${nogames[*]}" ]]; then
			for f in "${nogames[@],,}"; do
				samdebug "Deleting ${f}"
				delete_from_corelist "${f}"
				delete_from_corelist "${f}" tmp 
				#echo "Can't find games for ${CORE_PRETTY[${f}]}"		
			done
			#[ -s "${corelistfile}" ] && corelistupdate="$(cat ${corelistfile} | tr '\n' ' ' | tr ' ' ',')"
			#[ -n ${corelistupdate} ] && sed -i '/corelist=/c\corelist="'"$corelistupdate"'"' /media/fat/Scripts/MiSTer_SAM.ini
			echo "SAM now has the following cores disabled: $( echo "${nogames[@]}" ) "
			echo "No games were found for these cores."
		fi 
		
	fi

}

function filter_list() { # args ${nextcore} 	
		
	# Check path filter
	if [ -n "${PATHFILTER[${1}]}" ]; then 
		echo "Found path filter for ${1} core: ${PATHFILTER[${1}]}."
		fgrep "${PATHFILTER[${1}]}" "${gamelistpathtmp}/${1}_gamelist.txt"  > "${tmpfile}" && cp -f "${tmpfile}" "${gamelistpathtmp}/${1}_gamelist.txt"
	fi
	
	if [ -n "${arcadeorient}" ] && [[ "${1}" == "arcade" ]]; then
		cat "${gamelistpath}/${1}_gamelist.txt" | fgrep "Rotation/" | fgrep -i "${arcadeorient}" > $tmpfile
		if [ -s ${tmpfile} ]; then
			mv -f $tmpfile "${gamelistpathtmp}/${1}_gamelist.txt"	
		else
			echo "Arcade Orientation Filter Error."
		fi
	fi

	# Strip dupes			
	awk -F'/' '!seen[$NF]++' "${gamelistpathtmp}/${1}_gamelist.txt" > "${tmpfile}" && cp -f "${tmpfile}" "${gamelistpathtmp}/${1}_gamelist.txt"
	samdebug "$(wc -l < "${gamelistpathtmp}/${1}_gamelist.txt") Games in list after removing duplicates."

	#Check exclusion or kids safe white lists
	#First check for category exclusion
	if [ -f "${gamelistpath}/${1}_gamelist_exclude.txt" ]; then
		echo "Found category excludelist for core ${1}. Stripping out unwanted games now."
		# Process full file paths from gamelist_exclude
		awk 'FNR==NR{a[$0];next} !($0 in a)' "${gamelistpath}/${1}_gamelist_exclude.txt" "${gamelistpathtmp}/${1}_gamelist.txt" > "${tmpfilefilter}" 
		mv "${tmpfilefilter}" "${gamelistpathtmp}/${1}_gamelist.txt"
	fi
	if [ -f "${gamelistpath}/${1}_excludelist.txt" ]; then
		echo "Found excludelist for core ${1}. Stripping out unwanted games now."
		# Process file names without extensions from excludelist
		awk "BEGIN { while (getline < \"${gamelistpath}/${1}_excludelist.txt\") { a[\$0] = 1 } close(\"${gamelistpath}/${1}_excludelist.txt\"); } \
		{ gamelistfile = \$0; sub(/\\.[^.]*\$/, \"\", gamelistfile); sub(/^.*\\//, \"\", gamelistfile); if (!(gamelistfile in a)) print }" \
		"${gamelistpathtmp}/${1}_gamelist.txt" > "${tmpfilefilter}"
		mv "${tmpfilefilter}" "${gamelistpathtmp}/${1}_gamelist.txt"
	fi

	
	if [ "${kids_safe}" == "yes" ]; then
		samdebug "Kids Safe Mode - Filtering Roms..."
			if [ ${1} == amiga ]; then
				fgrep -f "${mrsampath}/SAM_Rated/amiga_rated.txt" <(fgrep -v "Demo:" "${gamelistpath}/amiga_gamelist.txt") | awk -F'(' '!seen[$1]++ {print $0}' > "${tmpfilefilter}"
			else
				fgrep -f "${mrsampath}/SAM_Rated/${1}_rated.txt" "${gamelistpathtmp}/${1}_gamelist.txt" | awk -F "/" '{split($NF,a," \\("); if (!seen[a[1]]++) print $0}' > "${tmpfilefilter}"
			fi
			if [ -s "${tmpfilefilter}" ]; then 
				samdebug "$(wc -l <"${tmpfilefilter}") games after kids safe filter applied."
				cp -f "${tmpfilefilter}" "${gamelistpathtmp}/${1}_gamelist.txt"
			else
				delete_from_corelist "${1}"
				delete_from_corelist "${1}" tmp
				echo "${1} kids safe filter produced no results and will be disabled."
				echo "List of cores is now: ${corelist[*]}"
				return 1
			fi
	fi
	
	#Check ini exclusion
	if [[ "${exclude[*]}" ]]; then 
		for e in "${exclude[@]}"; do
			fgrep -viw "$e" "${gamelistpathtmp}/${1}_gamelist.txt" > "${tmpfilefilter}" && cp -f "${tmpfilefilter}" "${gamelistpathtmp}/${1}_gamelist.txt"
		done

	fi
 
	#Check blacklist	
	if [ -f "${gamelistpath}/${1}_blacklist.txt" ]; then
		# Sometimes fails, can't use --line-buffered in busybox fgrep which would probably fix error. 
		echo -n "Disabling static screen games for ${1} core..."
		
		# Process file names without extensions from blacklist
		awk "BEGIN { while (getline < \"${gamelistpath}/${1}_blacklist.txt\") { a[\$0] = 1 } close(\"${gamelistpath}/${1}_blacklist.txt\"); } \
		{ gamelistfile = \$0; sub(/\\.[^.]*\$/, \"\", gamelistfile); sub(/^.*\\//, \"\", gamelistfile); if (!(gamelistfile in a)) print }" \
		"${gamelistpathtmp}/${1}_gamelist.txt" > "${tmpfilefilter}"
		if [ -s "${tmpfilefilter}" ]; then 
			cp -f "${tmpfilefilter}" "${gamelistpathtmp}/${1}_gamelist.txt"
		else
			samdebug "Blacklist filter failed" 
		fi
		echo " $(wc -l <"${gamelistpathtmp}/${1}_gamelist.txt") games will be shuffled."
	fi
}


function samdebug() {
    if [ "${samdebug}" == "yes" ]; then
        echo -e "\e[1m\e[31m${*-}\e[0m"
    fi

    if [ "${samdebuglog}" == "yes" ]; then
        echo -e "${*-}" >> /tmp/samdebug.log
    fi
}


function sam_help() { # sam_help
	echo " start - start immediately"
	echo " skip - skip to the next game"
	echo " stop - stop immediately"
	echo ""
	echo " update - self-update"
	echo " monitor - monitor SAM output"
	echo ""
	echo " enable - enable autoplay"
	echo " disable - disable autoplay"
	echo ""
	echo " menu - load to menu"
	echo ""
	echo " arcade, genesis, gba..."
	echo " games from one system only"
	exit 2
}

# ======== BACKGROUND MUSIC PLAYER FUNCTIONS ========

function bgm_start() {

	if [ "${bgm}" == "yes" ] && [ "${mute}" == "core" ]; then
		if [ ! "$(ps -o pid,args | grep '[b]gm' | head -1)" ]; then
			/media/fat/Scripts/bgm.sh
		else
			echo "BGM already running."
		fi
		sleep 2
		echo -n "set playincore yes" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
		#BGM playback tends to be louder than most cores. Let's adjust global volume down..
		if [ "${gvoladjust}" -ne 0 ] &&  [ "${bgmstop}" == "yes" ]; then
			if [[ "$(xxd "/media/fat/config/Volume.dat" |awk '{print $2}')" != 10 ]]; then
				declare -g currentvol=$(xxd "/media/fat/config/Volume.dat" |awk '{print $2}')
				unset newvol
				local newvol=$(($currentvol + $gvoladjust))
				samdebug "Changing global volume to $newvol"
				if [ $newvol -le 7 ]; then 
					#echo "volume ${newvol}" > /dev/MiSTer_cmd &
					echo -e "\00$newvol\c" >/media/fat/config/Volume.dat
				fi
			fi
		fi
		if [ "${bgmplay}" == "yes" ]; then
			echo -n "play" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
		fi
	fi

}

function bgm_stop() {

	if [ "${bgm}" == "yes" ]; then
		echo -n "Stopping Background Music Player... "
		echo -n "set playincore no" | socat - UNIX-CONNECT:/tmp/bgm.sock &>/dev/null
		if [ "${bgmstop}" == "yes" ]; then
			echo -n "stop" | socat - UNIX-CONNECT:/tmp/bgm.sock 2>/dev/null
			kill -9 "$(ps -o pid,args | grep '[b]gm.sh' | awk '{print $1}' | head -1)" 2>/dev/null
			rm /tmp/bgm.sock 2>/dev/null
			if [ "${gvoladjust}" -ne 0 ]; then
				#local oldvol=$((7 - $currentvol + $gvoladjust))
				#samdebug "Changing global volume back to $oldvol"
				#echo "volume ${oldvol}" > /dev/MiSTer_cmd &
				echo -e "\00$currentvol\c" >/media/fat/config/Volume.dat
			fi
		fi
		echo "Done."
	fi

}

# ======== tty2oled FUNCTIONS ========

function tty_start() {
	if [ "${ttyenable}" == "yes" ]; then 
		[ -f /tmp/.SAM_tmp/tty_currentinfo ] && rm /tmp/.SAM_tmp/tty_currentinfo 
		#[ -f /media/fat/tty2oled/S60tty2oled ] && /media/fat/tty2oled/S60tty2oled restart && sleep 3
		touch "${tty_sleepfile}"
		echo -n "Starting tty2oled... "
		tmux new -s OLED -d "/media/fat/Scripts/.MiSTer_SAM/MiSTer_SAM_tty2oled" &>/dev/null
		echo "Done."
	fi
}

function tty_exit() {
	if [ "${ttyenable}" == "yes" ]; then
		echo -n "Stopping tty2oled... "
		tmux kill-session -t OLED &>/dev/null
		rm "${tty_sleepfile}" &>/dev/null
		#/media/fat/tty2oled/S60tty2oled restart 
		#sleep 5

		echo "Done."
	fi
}

function write_to_TTY_cmd_pipe() {
	[[ -p ${TTY_cmd_pipe} ]] && echo "${@}" >${TTY_cmd_pipe}
}

# ======== SAM VIDEO PLAYER FUNCTIONS ========


function misterini_mod() {

	samdebug "samvideo_output: $samvideo_output"
	samdebug "samvideo_source: $samvideo_source"
	echo "For samvideo playback to work, we need to modify /media/fat/MiSTer.ini"
	echo "This will be reset when SAM quits. If it doesn't reset, please delete the last two lines from the ini manually."
	if [ -f "$ini_file" ]; then
		cp "$ini_file" "${ini_file}".sam
	else
		touch "$ini_file"
	fi
	if [ "$samvideo_output" == "hdmi" ]; then
		if [ "${samvideo_source}" == "youtube" ]; then
			ini_res=640x360
		else
			ini_res=640x480
		fi
		res_comma=$(echo "$ini_res" | tr 'x' ',')
		
		if [ "$(tail -n1 "$ini_file")" != "video_mode=${res_comma},60" ]; then
			#append menu info
			echo -e "\n[menu]" >> "$ini_file"
			echo -e "video_mode=${res_comma},60" >> "$ini_file"
			echo "[menu] entry created in $ini_file."
		fi
	#CRT mode	
	elif [ "$samvideo_output" == "crt" ]; then
		if [ "$samvideo_source" == "youtube" ]; then
			echo "Youtube and CRT: Setting CRT out to 320x240"
			samvideo_crtmode="${samvideo_crtmode320}"
		elif [ "$samvideo_source" == "archive" ]; then
			echo "Archive and CRT: Setting CRT out to 640x240"
			samvideo_crtmode="${samvideo_crtmode640}"
		fi
		if [ "$(tail -n1 "$ini_file")" != "${samvideo_crtmode}" ]; then
			#append menu info
			echo -e "\n[menu]" >> "$ini_file"
			echo -e "vga_scaler=1" >> "$ini_file"
			echo -e "${samvideo_crtmode}" >> "$ini_file"
			echo "[menu] entry created in $ini_file."

		fi
	fi
}

function misterini_reset() {
	cp "${ini_file}".sam "$ini_file" &>/dev/null
}

function sv_yt360() {
	
	declare -g yt360=""
	if [ ! -s /tmp/.SAM_List/samvideo_list.txt ]; then
		cp "${sv_youtube_hdmilist}" "/tmp/.SAM_List/samvideo_list.txt"
	fi
	echo "Please wait... downloading file"
	declare -g url="$(shuf -n1 /tmp/.SAM_List/samvideo_list.txt)"
	#declare -g yt360=$("${mrsampath}/ytdl" --list-formats "$url" | grep 360p | grep mp4 | grep -v "video only")
	url=""

	while [ -z "$url" ]; do
		url=$(shuf -n1 /tmp/.SAM_List/samvideo_list.txt)
		"${mrsampath}/ytdl" --format "best[height=360][ext=mp4]" --no-continue -o "$tmpvideo" "$url"
		exit_code=$?

		if [ $exit_code -eq 0 ]; then
			echo "Download successful!"
			break  # Exit the loop if the download was successful
		else
			echo "Invalid URL or download error. Retrying with another URL..."
			awk -vLine="$url" '!index($0,Line)' "${sv_youtube_hdmilist}" >${tmpfile} && cp -f ${tmpfile} "${sv_youtube_hdmilist}"
			cp "${sv_youtube_hdmilist}" "/tmp/.SAM_List/samvideo_list.txt"
			url=""  # Clear the URL variable to repeat the loop
		fi
	done
	res="$(LD_LIBRARY_PATH=/media/fat/Scripts/.MiSTer_SAM /media/fat/Scripts/.MiSTer_SAM/mplayer -vo null -ao null -identify -frames 0 "$tmpvideo" 2>/dev/null | grep "VIDEO:" | awk '{print $3}')"
	awk -vLine="$url" '!index($0,Line)' /tmp/.SAM_List/samvideo_list.txt >${tmpfile} && cp -f ${tmpfile} /tmp/.SAM_List/samvideo_list.txt

	#"${mrsampath}"/ytdl -f $ytid --no-continue -o "$tmpvideo" "$url"
	#declare -g ytid="$(echo "$yt360" | awk '{print $1}')"
	#declare -g ytres="$(echo "$yt360" | awk '{print $3}')"
	#res_comma=$(echo "$ytres" | tr 'x' ',')
	res_space=$(echo "$res" | tr 'x' ' ')

}

function sv_yt240() {
	
	declare -g yt240=""
	if [ ! -s /tmp/.SAM_List/samvideo_list.txt ]; then
		cp "${sv_youtube_crtlist}" "/tmp/.SAM_List/samvideo_list.txt"
	fi
	echo "Please wait... downloading file"
	declare -g url="$(shuf -n1 /tmp/.SAM_List/samvideo_list.txt)"
	#declare -g yt360=$("${mrsampath}/ytdl" --list-formats "$url" | grep 360p | grep mp4 | grep -v "video only")
	url=""

	while [ -z "$url" ]; do
		url=$(shuf -n1 /tmp/.SAM_List/samvideo_list.txt)
		"${mrsampath}/ytdl" --format "best[height=240][ext=mp4]" --no-continue -o "$tmpvideo" "$url"
		exit_code=$?

		if [ $exit_code -eq 0 ]; then
			echo "Download successful!"
			break  # Exit the loop if the download was successful
		else
			echo "Invalid URL or download error. Retrying with another URL..."
			awk -vLine="$url" '!index($0,Line)' "${sv_youtube_crtlist}" >${tmpfile} && cp -f ${tmpfile} "${sv_youtube_crtlist}"
			cp "${sv_youtube_crtlist}" "/tmp/.SAM_List/samvideo_list.txt"
			url=""  # Clear the URL variable to repeat the loop
		fi
	done
	awk -vLine="$url" '!index($0,Line)' /tmp/.SAM_List/samvideo_list.txt >${tmpfile} && cp -f ${tmpfile} /tmp/.SAM_List/samvideo_list.txt
	res_space="640 240"
}

function sv_local() {
	if [ ! -s /tmp/.SAM_List/sv_local_list.txt ]; then
		find "$samvideo_path" -type f > /tmp/.SAM_List/sv_local_list.txt
	fi
	tmpvideo=$(cat /tmp/.SAM_List/sv_local_list.txt | shuf -n1)
	awk -vLine="$tmpvideo" '!index($0,Line)' /tmp/.SAM_List/sv_local_list.txt >${tmpfile} && cp -f ${tmpfile} /tmp/.SAM_List/sv_local_list.txt
}

function sv_ar480() {
	http_archive=${sv_archive_hdmilist//https/http}
	if [ ! -s /tmp/.SAM_List/sv_archive_hdmilist.txt ]; then
		curl_download /tmp/SAMvideos.xml  "${http_archive}"
		grep -o '<file name="[^"]\+\.avi"' /tmp/SAMvideos.xml | sed 's/<file name="//;s/"$//' > /tmp/.SAM_List/sv_archive_hdmilist.txt
	fi
	sv_selected="$(shuf -n1 /tmp/.SAM_List/sv_archive_hdmilist.txt)"
	sv_selected_url="${http_archive%/*}/${sv_selected}"
	tmpvideo="/tmp/SAMvideo.avi"
	echo "Preloading ${sv_selected} from archive.org for smooth playback"
	wget --progress=dot:2 "$tmpvideo" "${sv_selected_url}"
	awk -vLine="$sv_selected" '!index($0,Line)' /tmp/.SAM_List/sv_archive_hdmilist.txt >${tmpfile} && cp -f ${tmpfile} /tmp/.SAM_List/sv_archive_hdmilist.txt

}

function sv_ar240() {
	http_archive=${sv_archive_crtlist//https/http}
	if [ ! -s /tmp/.SAM_List/sv_archive_crtlist.txt ]; then
		curl_download /tmp/SAMvideos.xml  "${http_archive}"
		grep -o '<file name="[^"]\+\.avi"' /tmp/SAMvideos.xml | sed 's/<file name="//;s/"$//' > /tmp/.SAM_List/sv_archive_crtlist.txt
	fi
	sv_selected="$(shuf -n1 /tmp/.SAM_List/sv_archive_crtlist.txt)"
	sv_selected_url="${http_archive%/*}/${sv_selected}"
	tmpvideo="/tmp/SAMvideo.avi"
	echo "Preloading ${sv_selected} from archive.org for smooth playback"
	wget -q --progress=dot -O "$tmpvideo" "${sv_selected_url}"  
	awk -vLine="$sv_selected" '!index($0,Line)' /tmp/.SAM_List/sv_archive_crtlist.txt >${tmpfile} && cp -f ${tmpfile} /tmp/.SAM_List/sv_archive_crtlist.txt
	res_space="640 240"
}

## Play video
function samvideo_play() {
	if [ "${samvideo_source}" == "youtube" ] && [ "$samvideo_output" == "hdmi" ]; then
		sv_yt360
	elif [ "${samvideo_source}" == "youtube" ] && [ "$samvideo_output" == "crt" ]; then
		sv_yt240
	elif [ "${samvideo_source}" == "archive" ] && [ "$samvideo_output" == "hdmi" ]; then
		sv_ar480
	elif [ "${samvideo_source}" == "archive" ] && [ "$samvideo_output" == "crt" ]; then
		sv_ar240
	elif [ "${samvideo_source}" == "local" ]; then
		sv_local
	fi
	
	if [ ! -s "$tmpvideo" ]; then
		echo "No video was downloaded. Skipping video playback.."
		next_core
		return
	fi
	sv_gametimer="$(LD_LIBRARY_PATH=/media/fat/Scripts/.MiSTer_SAM /media/fat/Scripts/.MiSTer_SAM/mplayer -vo null -ao null -identify -frames 0 "$tmpvideo" 2>/dev/null | grep "ID_LENGTH" | sed 's/[^0-9.]//g' | awk -F '.' '{print $1}')"

	#Show tty2oled splash
	if [ "${ttyenable}" == "yes" ]; then
		tty_currentinfo=(
			[core_pretty]="SAM Video Player"
			[name]="Video Playback"
			[core]=SAM_splash
			[date]=$EPOCHSECONDS
			[counter]=${sv_gametimer}
			[name_scroll]="Video Playback"
			[name_scroll_position]=0
			[name_scroll_direction]=1
			[update_pause]=${ttyupdate_pause}
		)
	
		declare -p tty_currentinfo | sed 's/declare -A/declare -gA/' >"${tty_currentinfo_file}"
		tty_displayswitch=$(($gametimer / $ttycoresleep - 1))
		write_to_TTY_cmd_pipe "display_info" &		
		local elapsed=$((EPOCHSECONDS - tty_currentinfo[date]))
		SECONDS=${elapsed}
	fi
	
	if [ "$bgm" == "yes" ]; then
		options="-nosound"
	fi
	
	if [ -s "$tmpvideo" ]; then
		echo load_core /media/fat/menu.rbf > /dev/MiSTer_cmd
		sleep "${samvideo_displaywait}"
		# TODO delete blinking cursor
		#chvt 2
		#echo "\033[?25l" > /dev/tty2
		echo $(("$sv_gametimer" + 2)) > /tmp/sv_gametimer
		/media/fat/Scripts/.MiSTer_SAM/mbc raw_seq :43
		vmode -r ${res_space} rgb32
		echo -e "\nPlaying video now."
		echo -e "Length: ${sv_gametimer} seconds\n"
		nice -n -20 env LD_LIBRARY_PATH=/media/fat/Scripts/.MiSTer_SAM /media/fat/Scripts/.MiSTer_SAM/mplayer -msglevel all=0:statusline=5 "${options}" "$tmpvideo" 2>/dev/null 
		rm /tmp/sv_gametimer 2>/dev/null
	fi
	#echo load_core /media/fat/menu.rbf > /dev/MiSTer_cmd
	#next_core
}



# ======== SAM UPDATE ========


function curl_download() { # curl_download ${filepath} ${URL}

	curl \
		--connect-timeout 15 --max-time 600 --retry 3 --retry-delay 5 --silent --show-error \
		--insecure \
		--fail \
		--location \
		-o "${1}" \
		"${2}"
}

function get_samstuff() { #get_samstuff file (path)
	
	if [ -z "${1}" ]; then
		return 1
	fi

	filepath="${2}"
	if [ -z "${filepath}" ]; then
		filepath="${mrsampath}"
	fi

	echo -n " Downloading from ${repository_url}/blob/${branch}/${1} to ${filepath}/..."
	curl_download "/tmp/${1##*/}" "${repository_url}/blob/${branch}/${1}?raw=true"

	if [ ! "${filepath}" == "/tmp" ]; then
		mv --force "/tmp/${1##*/}" "${filepath}/${1##*/}"
	fi

	if [ "${1##*.}" == "sh" ]; then
		chmod +x "${filepath}/${1##*/}"
	fi

	echo " Done."
}

function get_partun() {
	REPOSITORY_URL="https://github.com/woelper/partun"
	echo " Downloading partun - needed for unzipping roms from big archives..."
	echo " Created for MiSTer by woelper - Talk to him at this year's PartunCon"
	echo " ${REPOSITORY_URL}"
	latest=$(curl -s -L --insecure https://api.github.com/repos/woelper/partun/releases/latest | jq -r ".assets[] | select(.name | contains(\"armv7\")) | .browser_download_url")
	curl_download "/tmp/partun" "${latest}"
	mv --force "/tmp/partun" "${mrsampath}/partun"
	echo " Done."
}

function get_samindex() {
	echo " Downloading samindex - needed for creating gamelists..."
	echo " Created for MiSTer by wizzo"
	echo " https://github.com/wizzomafizzo/mrext"
	latest="${repository_url}/blob/${branch}/.MiSTer_SAM/samindex.zip?raw=true"
	curl_download "/tmp/samindex.zip" "${latest}"
	unzip -ojq /tmp/samindex.zip -d "${mrsampath}" # &>/dev/null
	echo " Done."
}

function get_samvideo() {
	echo " Downloading wizzo's mplayer for SAM..."
	echo " Created for MiSTer by wizzo"
	echo " https://github.com/wizzomafizzo/mrext"
	latest="${repository_url}/blob/${branch}/.MiSTer_SAM/mplayer.zip?raw=true"
	curl_download "/tmp/mplayer.zip" "${latest}"
	unzip -ojq /tmp/mplayer.zip -d "${mrsampath}" # &>/dev/null
	curl_download "${mrsampath}"/ytdl "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux_armv7l"
	get_samstuff .MiSTer_SAM/sv_yt360_list.txt /media/fat/Scripts/.MiSTer_SAM >/dev/null
	get_samstuff .MiSTer_SAM/sv_yt240_list.txt /media/fat/Scripts/.MiSTer_SAM >/dev/null
	echo " Done."
}

function get_mbc() {
	echo " Downloading mbc - Control MiSTer from cmd..."
	echo " Created for MiSTer by pocomane"
	get_samstuff .MiSTer_SAM/mbc
}

function get_inputmap() {
	echo -n " Downloading input maps - needed to skip past BIOS for some systems..."
	[ ! -d "/media/fat/Config/inputs" ] && mkdir -p "/media/fat/Config/inputs"
	get_samstuff .MiSTer_SAM/inputs/GBA_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	get_samstuff .MiSTer_SAM/inputs/MegaCD_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	get_samstuff .MiSTer_SAM/inputs/NES_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	get_samstuff .MiSTer_SAM/inputs/TGFX16_input_1234_5678_v3.map /media/fat/Config/inputs >/dev/null
	echo " Done."
}

function get_blacklist() {
	echo -n " Downloading blacklist files - SAM can auto-detect games with static screens and filter them out..."
	get_samstuff .MiSTer_SAM/SAM_Gamelists/amiga_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/arcade_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/fds_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/gba_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/genesis_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/megacd_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/nes_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/neogeo_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/psx_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/s32x_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/sms_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/snes_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/tgfx16_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	get_samstuff .MiSTer_SAM/SAM_Gamelists/tgfx16cd_blacklist.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Gamelists >/dev/null
	echo " Done."
}

function get_ratedlist() {
	if [ "${kids_safe}" == "yes" ]; then 
		echo -n " Downloading lists with kids friendly games..."
		get_samstuff .MiSTer_SAM/SAM_Rated/arcade_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/amiga_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/ao486_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/fds_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/gb_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/gbc_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/gba_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/gg_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/genesis_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/megacd_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/nes_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/neogeo_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/psx_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/sms_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/snes_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/tgfx16_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		get_samstuff .MiSTer_SAM/SAM_Rated/tgfx16cd_rated.txt /media/fat/Scripts/.MiSTer_SAM/SAM_Rated >/dev/null
		echo " Done."
	fi
}


function sam_update() { # sam_update (next command)

	if ping -4 -q -w 1 -c 1 github.com > /dev/null; then 
		echo " Connection established"
	else
		echo "No connection to Github. Please use offline install."
		sleep 5
		#exit 1
	fi
	
	# Ensure the MiSTer SAM data directory exists
	mkdir --parents "${mrsampath}" &>/dev/null
	mkdir --parents "${mrsampath}/SAM_Rated" &>/dev/null
	mkdir --parents "${gamelistpath}" &>/dev/null

	if [ ! "$(dirname -- "${0}")" == "/tmp" ]; then
		# Warn if using non-default branch for updates
		if [ ! "${branch}" == "main" ]; then
			echo ""
			echo "*******************************"
			echo " Updating from ${branch}"
			echo "*******************************"
			echo ""
		fi

		# Download the newest MiSTer_SAM_on.sh to /tmp
		get_samstuff MiSTer_SAM_on.sh /tmp
		if [ -f /tmp/MiSTer_SAM_on.sh ]; then
			if [ "${1}" ]; then
				echo " Continuing setup with latest MiSTer_SAM_on.sh..."
				/tmp/MiSTer_SAM_on.sh "${1}"
				exit 0
			else
				echo " Launching latest"
				echo " MiSTer_SAM_on.sh..."
				/tmp/MiSTer_SAM_on.sh update
				exit 0
			fi
		else
			# /tmp/MiSTer_SAM_on.sh isn't there!
			echo " SAM update FAILED"
			echo " No Internet?"
			exit 1
		fi
	else # We're running from /tmp - download dependencies and proceed
		cp --force "/tmp/MiSTer_SAM_on.sh" "/media/fat/Scripts/MiSTer_SAM_on.sh"

		get_partun
		get_samindex
		get_mbc
		get_samstuff .MiSTer_SAM/MiSTer_SAM_init
		get_samstuff .MiSTer_SAM/MiSTer_SAM_MCP
		get_samstuff .MiSTer_SAM/MiSTer_SAM_tty2oled
		get_samstuff .MiSTer_SAM/MiSTer_SAM_joy.py
		if [ ! -f "/media/fat/Scripts/.MiSTer_SAM/sam_controllers.json" ]; then
			get_samstuff .MiSTer_SAM/sam_controllers.json
		fi
		if [ "${samvideo}" == "yes" ]; then
			get_samvideo
		fi
		get_samstuff .MiSTer_SAM/MiSTer_SAM_keyboard.py
		get_samstuff .MiSTer_SAM/MiSTer_SAM_mouse.py
		get_inputmap
		get_blacklist
		get_ratedlist
		get_samstuff MiSTer_SAM_off.sh /media/fat/Scripts

		if [ -f /media/fat/Scripts/MiSTer_SAM.ini ]; then
			echo " MiSTer SAM INI already exists... Merging with new ini."
			get_samstuff MiSTer_SAM.ini /tmp
			echo " Backing up MiSTer_SAM.ini to MiSTer_SAM.ini.bak"
			cp /media/fat/Scripts/MiSTer_SAM.ini /media/fat/Scripts/MiSTer_SAM.ini.bak
			echo -n " Merging ini values.."
			# In order for the following awk script to replace variable values, we need to change our ASCII art from "=" to "-"
			sed -i 's/==/--/g' /media/fat/Scripts/MiSTer_SAM.ini
			sed -i 's/-=/--/g' /media/fat/Scripts/MiSTer_SAM.ini
			awk -F= 'NR==FNR{a[$1]=$0;next}($1 in a){$0=a[$1]}1' /media/fat/Scripts/MiSTer_SAM.ini /tmp/MiSTer_SAM.ini >/tmp/MiSTer_SAM.tmp && cp -f --force /tmp/MiSTer_SAM.tmp /media/fat/Scripts/MiSTer_SAM.ini
			echo "Done."

		else
			get_samstuff MiSTer_SAM.ini /media/fat/Scripts
		fi
		
	fi

	echo " Update complete!"
	return
	
	mcp_start

	if [ ${inmenu} -eq 1 ]; then
		sleep 1
		sam_menu
	fi

}


# ======== SAM MENU ========
function sam_premenu() {
	echo "+---------------------------+"
	echo "| MiSTer Super Attract Mode |"
	echo "+---------------------------+"
	echo " SAM Configuration:"
	if [ "$(grep -ic "mister_sam" "${userstartup}")" != "0" ]; then
		echo " -SAM autoplay ENABLED"
	else
		echo " -SAM autoplay DISABLED"
	fi
	echo " -Start after ${samtimeout} sec. idle"
	echo " -Start only on the menu: ${menuonly^}"
	echo " -Show each game for ${gametimer} sec."
	echo ""
	echo " Press UP to open menu"
	echo " Press DOWN to start SAM"
	echo ""
	echo " Or wait for"
	echo " auto-configuration"
	echo ""

	for i in {10..1}; do
		echo -ne " Updating SAM in ${i} secs...\033[0K\r"
		premenu="Default"
		read -r -s -N 1 -t 1 key
		if [[ "${key}" == "A" ]]; then
			premenu="Menu"
			break
		elif [[ "${key}" == "B" ]]; then
			premenu="Start"
			break
		elif [[ "${key}" == "C" ]]; then
			premenu="Default"
			break
		fi
	done
	parse_cmd ${premenu}
}

function sam_menu() {
	inmenu=1
	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Exit" \
		--backtitle "Super Attract Mode" --title "[ Main Menu ]" \
		--menu "Use the arrow keys and enter \nor the d-pad and A button" 0 0 0 \
		Start "Start SAM now" \
		Startmonitor "Start SAM now And Monitor (SSH)" \
		Skip "Skip Game" \
		Ignore "Ignore current game and exclude from SAM" \
		Stop "Stop SAM" \
		Update "Update SAM to latest" \
		Settings "Settings" \
		----- "-----------------------------" \
		sam_coreconfig "Configure Core List" \
		sam_exittask "Configure Exit Behavior" \
		sam_filters "Filters (by Orientation or Category)" \
		sam_bgm "Add-ons: SAMVIDEO, BGM, TTY2OLED" \
		Gamemode "Game Roulette" \
		Favorite "Copy current game to _Favorites folder" \
		Reset "Reset or uninstall SAM" 2>"/tmp/.SAMmenu"
	
	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear
	
	if [ "$opt" != "0" ]; then
		exit
	elif [[ "${menuresponse,,}" == "sam_coreconfig" ]]; then
		sam_coreconfig
	elif [[ "${menuresponse,,}" == "-----" ]]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "sam_exittask" ]]; then
		sam_exittask
	elif [[ "${menuresponse,,}" == "sam_bgm" ]]; then
		sam_bgmmenu	
	elif [[ "${menuresponse,,}" == "sam_filters" ]]; then
		sam_filters
	else 
		parse_cmd "${menuresponse}"
	fi

}


function changes_saved () {
	dialog --clear --ascii-lines --no-cancel \
	--backtitle "Super Attract Mode" --title "[ Settings ]" \
	--msgbox "Changes saved!" 0 0
}

function sam_settings() {
	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Back" \
		--backtitle "Super Attract Mode" --title "[ Settings ]" \
		--menu "Use the arrow keys and enter \nor the d-pad and A button" 0 0 0 \
		sam_timer "Select Timers - When SAM should start" \
		sam_mute "Mute Cores while SAM is on" \
		autoplay "Autoplay Configuration" \
		enablekidssafe "Enable Kids Safe Filter" \
		disablekidssafe "Disable Kids Safe Filter" \
		sam_misc "Advanced Settings" \
		config "Manual Settings Editor (MiSTer_SAM.ini)" 2>"/tmp/.SAMmenu"
	
	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear
	
	if [ "$opt" != "0" ]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "sam_timer" ]]; then
		sam_timer
	elif [[ "${menuresponse,,}" == "sam_mute" ]]; then
		sam_mute
	elif [[ "${menuresponse,,}" == "sam_misc" ]]; then
		sam_misc	
	elif [[ "${menuresponse,,}" == "arcade_orient" ]]; then
		arcade_orient
	elif [[ "${menuresponse,,}" == "enablekidssafe" ]]; then
		if [[ "$shown" == "0" ]]; then
		dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ KIDS SAFE FILTER ]" \
			--msgbox "Good to use if you have young children. Limits rom selection to ESRB rated games with the 'All Ages' label\n\nOn first boot, SAM will download the ESRB game whitelists. \n\nAlso 'Alternative Core Selection Mode' will be enabled. " 0 0
		fi
		sed -i '/kids_safe=/c\kids_safe="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
		sed -i '/coreweight=/c\coreweight="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
		changes_saved
		sam_settings
	elif [[ "${menuresponse,,}" == "disablekidssafe" ]]; then
		sed -i '/kids_safe=/c\kids_safe="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
		sed -i '/coreweight=/c\coreweight="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
		changes_saved
		sam_settings
	else 
		parse_cmd "${menuresponse}"
	fi

}

function sam_filters() {
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ MISCELLANEOUS OPTIONS ]" \
		--menu "Select from the following options?" 0 0 0 \
		Include "Select Single Category/Genre" \
		exclude "Exclude Categories/Genres" \
		arcadehoriz "Only show Horizontal Arcade Games" \
		arcadevert "Only show Vertical Arcade Games" \
		arcadedisable "Show all Arcade Games" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	if [ "$opt" != "0" ]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "arcadehoriz" ]]; then
		#sed -i '/arcadepathfilter=/c\arcadepathfilter="'"_Horizontal"'"' /media/fat/Scripts/MiSTer_SAM.ini
		sed -i '/arcadeorient=/c\arcadeorient="'"horizontal"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "arcadevert" ]]; then
		sed -i '/arcadeorient=/c\arcadeorient="'"vertical"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "arcadedisable" ]]; then
		sed -i '/arcadeorient=/c\arcadeorient="'""'"' /media/fat/Scripts/MiSTer_SAM.ini
	else 
		parse_cmd "${menuresponse}"
	fi
	changes_saved
	sam_filters
}


function sam_misc() {
	if [[ "$shown" == "0" ]]; then
		dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ CONTROLLER SETUP ]" \
			--msgbox "Alternative Core Mode will prefer cores with larger libraries so you don't have many game repeats.\n\nPlease set up controller in main menu instead of using Play Current Game if possible." 0 0
	fi
	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Back" \
		--backtitle "Super Attract Mode" --title "[ MISCELLANEOUS OPTIONS ]" \
		--menu "Select from the following options?" 0 0 0 \
		enablemenuonly "Start SAM only in MiSTer Menu" \
		disablemenuonly "Start SAM outside of MiSTer Menu" \
		----- "-----------------------------" \
		enablealtcore "Enable Alternative Core Selection Mode" \
		disablealtcore "Disable Alternative Core Selection Mode" \
		----- "-----------------------------" \
		enablelistenjoy "Enable Joystick detection" \
		disablelistenjoy "Disable Joystick detection" \
		enablelistenkey "Enable Keyboard detection" \
		disablelistenkey "Disable Keyboard detection" \
		enablelistenmouse "Enable Mouse detection" \
		disablelistenmouse "Disable Mouse detection" \
		----- "-----------------------------" \
		enabledebug "Enable Debug" \
		disabledebug  "Disable Debug" \
		enabledebuglog "Enable Debug Log File" \
		disabledebuglog  "Disable Debug Log File" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	if [ "$opt" != "0" ]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "enablemenuonly" ]]; then
		sed -i '/menuonly=/c\menuonly="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "-----" ]]; then
		shown=1	
		sam_misc
	elif [[ "${menuresponse,,}" == "disablemenuonly" ]]; then
		sed -i '/menuonly=/c\menuonly="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "enablealtcore" ]]; then
		sed -i '/coreweight=/c\coreweight="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disablealtcore" ]]; then
		sed -i '/coreweight=/c\coreweight="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "enablelistenjoy" ]]; then
		sed -i '/listenjoy=/c\listenjoy="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disablelistenjoy" ]]; then
		sed -i '/listenjoy=/c\listenjoy="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "enablelistenkey" ]]; then
		sed -i '/listenkeyboard=/c\listenkeyboard="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disablelistenkey" ]]; then
		sed -i '/listenkeyboard=/c\listenkeyboard="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "enablelistenmouse" ]]; then
		sed -i '/listenmouse=/c\listenmouse="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disablelistenmouse" ]]; then
		sed -i '/listenmouse=/c\listenmouse="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "enabledebug" ]]; then
		sed -i '/samdebug=/c\samdebug="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disabledebug" ]]; then
		sed -i '/samdebug=/c\samdebug="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini	
	elif [[ "${menuresponse,,}" == "enabledebuglog" ]]; then
		sed -i '/samdebuglog=/c\samdebuglog="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disabledebuglog" ]]; then
		sed -i '/samdebuglog=/c\samdebuglog="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	fi
	dialog --clear --ascii-lines --no-cancel \
	--backtitle "Super Attract Mode" --title "[ Settings ]" \
	--msgbox "Changes saved!" 0 0
	shown=1	
	sam_misc
}



function sam_mute() {
	dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ CONTROLLER SETUP ]" \
		--msgbox "SAM uses the core mute feature of MiSTer which will turn the volume low.\n\nYou might still hear a bit of the core's sounds.\n\nYou can also use global mute but it's not as well supported with SAM." 0 0

	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ BACKGROUND MUSIC ENABLER ]" \
		--menu "Select from the following options?" 0 0 0 \
		enablemute "Mute Volume for all Cores" \
		disablemute "Unmute Volume fore all Cores" \
		globalmute "Mute Global Volume (not recommended)" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	if [ "$opt" != "0" ]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "enablemute" ]]; then
		sed -i '/mute=/c\mute="'"Core"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "disablemute" ]]; then
		sed -i '/mute=/c\mute="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
	elif [[ "${menuresponse,,}" == "globalmute" ]]; then
		sed -i '/mute=/c\mute="'"Global"'"' /media/fat/Scripts/MiSTer_SAM.ini
	fi
	dialog --clear --ascii-lines --no-cancel \
	--backtitle "Super Attract Mode" --title "[ Settings ]" \
	--msgbox "Changes saved!" 0 0
	sam_settings
			
}

function sam_exittask() {
	if [[ "$shown" == "0" ]]; then
		if [[ "${playcurrentgame}" == "yes" ]]; then
			dialog --clear --no-cancel --ascii-lines \
				--backtitle "Super Attract Mode" --title "[ SAM EXIT ]" \
				--msgbox "Currently, SAM will play the current game when you push a button." 0 0
		else
			dialog --clear --no-cancel --ascii-lines \
				--backtitle "Super Attract Mode" --title "[ SAM EXIT ]" \
				--msgbox "Currently, SAM will exit back to the MiSTer menu when you push a button.\n\nIf you configured your controller, SAM will still play the current game if you push the Start button." 0 0
		fi
	shown=1
	fi
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ SAM EXIT ]" \
		--menu "Select from the following options?" 0 0 0 \
		enableplaycurrent "On Exit, Play current Game" \
		disableplaycurrent "On Exit, Return to Menu (Except Start Button)" \
		sam_controller "Setup Controller - Configure Start button" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	if [ "$opt" != "0" ]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "enableplaycurrent" ]]; then
		sed -i '/playcurrentgame=/c\playcurrentgame="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
		changes_saved
	elif [[ "${menuresponse,,}" == "disableplaycurrent" ]]; then
		sed -i '/playcurrentgame=/c\playcurrentgame="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
		changes_saved
	elif [[ "${menuresponse,,}" == "sam_controller" ]]; then
		sam_controller
	elif [[ "${menuresponse,,}" == "globalmute" ]]; then
		sed -i '/mute=/c\mute="'"Global"'"' /media/fat/Scripts/MiSTer_SAM.ini
	fi
	dialog --clear --ascii-lines --no-cancel \
	--backtitle "Super Attract Mode" --title "[ SAM EXIT ]" \
	--msgbox "Changes saved!" 0 0
	sam_exittask		
}

function sam_controller() {
	dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ CONTROLLER SETUP ]" \
		--msgbox "Configure your controller so that pushing the start button will play the current game.\nAny other button will exit SAM. " 0 0
	dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ CONTROLLER SETUP ]" \
		--msgbox "Connect one controller at a time.\n\nPush start button when ready!" 0 0
		c_json="/media/fat/Scripts/.MiSTer_SAM/sam_controllers.json"
		id="$(/media/fat/Scripts/.MiSTer_SAM/MiSTer_SAM_joy.py /dev/input/js0 id)"
		name="$(grep -iwns "js0" /proc/bus/input/devices -B 4 | grep Name | awk -F'"' '{print $2}')"	
		startbutton="$(/media/fat/Scripts/.MiSTer_SAM/MiSTer_SAM_joy.py /dev/input/js0 start)"
		echo start button: "$startbutton"
		echo controller id: "$id"

		if [[ "$startbutton" == *"not exist"* ]]; then
			dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ CONTROLLER SETUP ]" \
			--msgbox "No joysticks connected. " 0 0
			sam_exittask
		else
			jq --arg name "$name" --arg id "$id" --argjson start "$startbutton" '. + {($id): {"name": $name, "button": {"start": $start}, "axis": {}}}' ${c_json} > /tmp/temp.json && mv /tmp/temp.json ${c_json}
			dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ CONTROLLER SETUP ]" \
			--msgbox "Added $name. \n\nPlease reboot MiSTer or reconnect controller for changes to take effect. " 0 0		
			sam_exittask
		fi
}

function sam_timer() {
	if [[ "$shown" == "0" ]]; then
		dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ GAME TIMER ]" \
			--msgbox "Super Attract Mode starts after you haven't used your controller for a certain amount of time\n\n\nConfigure when SAM should start showing games and how long SAM shows games for." 0 0
	fi
	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Back" \
		--backtitle "Super Attract Mode" --title "[ GAME TIMER ]" \
		--menu "Select an option" 0 0 0 \
		samtimeout1 "Wait 1 minute before showing games" \
		samtimeout2 "Wait 2 minutes before showing games" \
		samtimeout3 "Wait 3 minutes before showing games" \
		samtimeout5 "Wait 5 minutes before showing games" \
		gametimer1 "Show Games for 1 minute" \
		gametimer2 "Show Games for 2 minutes" \
		gametimer3 "Show Games for 3 minutes" \
		gametimer5 "Show Games for 5 minutes" \
		gametimer10 "Show Games for 10 minutes" \
		gametimer15 "Show Games for 15 minutes" 2>"/tmp/.SAMmenu"	
	
		opt=$?
		menuresponse=$(<"/tmp/.SAMmenu")
		
		if [ "$opt" != "0" ]; then
			sam_menu
		elif [[ "${menuresponse}" == *"samtimeout"* ]]; then
			timemin=${menuresponse//samtimeout/}
			samtimeout=$((timemin*60))
			sed -i '/samtimeout=/c\samtimeout="'"$samtimeout"'"' /media/fat/Scripts/MiSTer_SAM.ini
			dialog --clear --ascii-lines --no-cancel \
			--backtitle "Super Attract Mode" --title "[ GAME TIMER ]" \
			--msgbox "Changes saved. Wait now for $samtimeout seconds" 0 0
			shown=1
			sam_timer
		elif [[ "${menuresponse}" == *"gametimer"* ]]; then
			timemin=${menuresponse//gametimer/}
			gametimer=$((timemin*60))
			sed -i '/gametimer=/c\gametimer="'"$gametimer"'"' /media/fat/Scripts/MiSTer_SAM.ini
			dialog --clear --ascii-lines --no-cancel \
			--backtitle "Super Attract Mode" --title "[ GAME TIMER ]" \
			--msgbox "Changes saved. Show games now for $gametimer seconds" 0 0
			shown=1
			sam_timer
		fi
}


function sam_coreconfig() {
	if [[ "$shown" == "0" ]]; then
		dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ CORE CONFIG ]" \
			--msgbox "Current corelist:\n\n${corelist[*]}" 0 0
	fi
	shown=1
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ CORE CONFIG ]" \
		--menu "Select from the following options?" 0 0 0 \
		sam_corelist_preset "Presets for Core List" \
		sam_corelist "Enable/Disable cores (Keyboard support only)" \
		single "Only play Games from one Core" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	if [ "$opt" != "0" ]; then
		sam_menu
	elif [[ "${menuresponse,,}" == "sam_corelist_preset" ]]; then
		sam_corelist_preset
	elif [[ "${menuresponse,,}" == "sam_corelist" ]]; then
		sam_corelist
	else 
		parse_cmd "${menuresponse}"
	fi
	sam_menu
			
}

function sam_corelist() {
	dialog --clear --no-cancel --ascii-lines \
	--backtitle "Super Attract Mode" --title "[ CORE CONFIGURATION]" \
	--msgbox "Joystick is currently not supported to select cores. You need a keyboard and can enable/disable cores with space key.\n\nPlease exit this menu if you are using a joystick." 0 0
	declare -a corelistmenu=()
	for core in "${corelistall[@]}"; do
		corelistmenu+=("${core}")
		corelistmenu+=("Show ${CORE_PRETTY[${core}]} Games")
		if [[ "${corelist[*]}" == *"$core"* ]]; then
			corelistmenu+=("ON")
		else
			corelistmenu+=("OFF")
		fi
	done

	dialog --ok-label "Select" --cancel-label "Back" \
	--separate-output --checklist "Corelist Config:" 0 0 0 \
	"${corelistmenu[@]}" 2>"/tmp/.SAMmenu"
	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear
	
	if [ "$opt" != "0" ]; then
		sam_menu
	else 
		declare -a corelistnew=()
		for choice in ${menuresponse}; do
			case $choice in
				"$choice")
					corelistnew+=("$choice")
					;;															
			esac
		done
	fi
	if [[ "${corelistnew[*]}" ]]; then
		unset corelist
		corelistmod="$(echo "${corelistnew[@]}" | tr ' ' ',' | tr -s ' ')"
		sed -i '/corelist=/c\corelist="'"$corelistmod"'"' /media/fat/Scripts/MiSTer_SAM.ini
		dialog --clear --ascii-lines --no-cancel \
		--backtitle "Super Attract Mode" --title "[ Settings ]" \
		--msgbox "Changes saved. Core list is now: $corelistmod" 0 0
	fi
	sam_menu
}

function sam_corelist_preset() {
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ CORELIST PRESET ]" \
		--menu "Select an option" 0 0 0 \
		2 "Only Arcade & Console Cores" \
		1 "Only Arcade and NeoGeo games" \
		6 "Only Arcade and NeoGeo games from the 1990s" \
		3 "Only Handheld Cores" \
		4 "Only Computer Cores" \
		5 "Only Cores from the 1990s (no handheld)" \
		7 "mrchrisster's Selection of favorite cores" 2>"/tmp/.SAMmenu"	
	
		opt=$?
		menuresponse=$(<"/tmp/.SAMmenu")
		
		if [ "$opt" != "0" ]; then
			sam_menu
		elif [[ "${menuresponse}" == "1" ]]; then
			sed -i '/corelist=/c\corelist="'"arcade,neogeo"'"' /media/fat/Scripts/MiSTer_SAM.ini
		elif [[ "${menuresponse}" == "2" ]]; then
			sed -i '/corelist=/c\corelist="'"arcade,atari2600,atari5200,atari7800,fds,genesis,megacd,neogeo,nes,s32x,sms,snes,tgfx16,tgfx16cd,psx"'"' /media/fat/Scripts/MiSTer_SAM.ini
		elif [[ "${menuresponse}" == "3" ]]; then
			sed -i '/corelist=/c\corelist="'"gb,gbc,gba,gg,atarilynx"'"' /media/fat/Scripts/MiSTer_SAM.ini
		elif [[ "${menuresponse}" == "4" ]]; then
			sed -i '/corelist=/c\corelist="'"amiga,c64"'"' /media/fat/Scripts/MiSTer_SAM.ini
		elif [ "${menuresponse}" -eq "5" ]; then
			dialog --clear --ascii-lines --no-cancel \
			--backtitle "Super Attract Mode" --title "[ CORELIST PRESET ]" \
			--yesno "This will set Arcade Path Filter to 1990's\nYou can remove the filter later by clicking No here." 0 0
			response=$?
			case $response in
			   0) sed -i '/arcadepathfilter=/c\arcadepathfilter="'"_The 1990s"'"' /media/fat/Scripts/MiSTer_SAM.ini	   
				;;
			   1) sed -i '/arcadepathfilter=/c\arcadepathfilter="'""'"' /media/fat/Scripts/MiSTer_SAM.ini
				;;
			   255) exit;;
			esac
			sed -i '/corelist=/c\corelist="'"arcade,genesis,megacd,neogeo,s32x,snes,tgfx16,tgfx16cd,psx"'"' /media/fat/Scripts/MiSTer_SAM.ini
		elif [ "${menuresponse}" -eq "6" ]; then
			dialog --clear --ascii-lines --no-cancel \
			--backtitle "Super Attract Mode" --title "[ CORELIST PRESET ]" \
			--yesno "This will set Arcade Path Filter to 1990's\nYou can remove the filter later by clicking No here." 0 0
			response=$?
			case $response in
			   0) sed -i '/arcadepathfilter=/c\arcadepathfilter="'"_The 1990s"'"' /media/fat/Scripts/MiSTer_SAM.ini
				;;
			   1) sed -i '/arcadepathfilter=/c\arcadepathfilter="'""'"' /media/fat/Scripts/MiSTer_SAM.ini
				;;
			   255) exit;;
			esac
			sed -i '/corelist=/c\corelist="'"arcade,neogeo"'"' /media/fat/Scripts/MiSTer_SAM.ini
		elif [[ "${menuresponse}" == "7" ]]; then
			sed -i '/corelist=/c\corelist="'"amiga,arcade,fds,genesis,megacd,neogeo,nes,s32x,sms,snes,tgfx16,tgfx16cd,psx"'"' /media/fat/Scripts/MiSTer_SAM.ini
		fi
		dialog --clear --ascii-lines --no-cancel \
		--backtitle "Super Attract Mode" --title "[ CORELIST PRESET ]" \
		--msgbox "Changes saved!" 0 0
		sam_menu
}


function sam_singlemenu() {
	declare -a menulist=()
	for core in "${corelistall[@]}"; do
		menulist+=("${core^^}")
		menulist+=("${CORE_PRETTY[${core}]} games only")
	done

	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ Single System Select ]" \
		--menu "Which system?" 0 0 0 \
		"${menulist[@]}" 2>"/tmp/.SAMmenu"
	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear
	
	if [ "$opt" != "0" ]; then
		sam_menu
	else 
		parse_cmd "${menuresponse}"
	fi

}

function sam_resetmenu() {
	inmenu=1
	dialog --clear --no-cancel --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ Reset ]" \
		--menu "Select an option" 0 0 0 \
		Deleteall "Reset/Delete all files" \
		Gamelists "Create/Delete only Game Lists" \
		Default "Reinstall SAM and enable Autostart" \
		Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	samdebug "menuresponse: ${menuresponse}"
	parse_cmd "${menuresponse}"
}

function sam_gamelistmenu() {
	inmenu=1
	dialog --clear --no-cancel --ascii-lines --colors \
		--backtitle "Super Attract Mode" --title "[ GAMELIST MENU ]" \
		--msgbox "Game Lists contain filenames that SAM can play for each core. \n\nThey get created automatically when SAM plays games. Here you can create or delete those lists." 0 0
	dialog --clear --no-cancel --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ GAMELIST MENU ]" \
		--menu "Select an option" 0 0 0 \
		CreateGL "Create all Game Lists" \
		DeleteGL "Delete all Game Lists" \
		Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	samdebug  "menuresponse: ${menuresponse}"
	parse_cmd "${menuresponse}"
}

function sam_autoplaymenu() {
	dialog --clear --no-cancel --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ Configure Autoplay ]" \
		--menu "Select an option" 0 0 0 \
		Enable "Enable Autoplay" \
		Disable "Disable Autoplay" \
		Back 'Previous menu' 2>"/tmp/.SAMmenu"
	menuresponse=$(<"/tmp/.SAMmenu")

	clear
	samdebug  "menuresponse: ${menuresponse}"
	parse_cmd "${menuresponse}"
}

function sam_configmenu() {
	dialog --clear --ascii-lines --no-cancel \
		--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
		--msgbox "Here you can configure the INI settings for SAM.\n\nUse TAB to switch between editing, the OK and Cancel buttons." 0 0

	dialog --clear --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
		--editbox "${misterpath}/Scripts/MiSTer_SAM.ini" 0 0 2>"/tmp/.SAMmenu"

	if [ -s "/tmp/.SAMmenu" ] && [ "$(diff -wq "/tmp/.SAMmenu" "${misterpath}/Scripts/MiSTer_SAM.ini")" ]; then
		cp -f "/tmp/.SAMmenu" "${misterpath}/Scripts/MiSTer_SAM.ini"
		dialog --clear --ascii-lines --no-cancel \
			--backtitle "Super Attract Mode" --title "[ INI Settings ]" \
			--msgbox "Changes saved!" 0 0
	fi

	parse_cmd menu
}

function sam_gamemodemenu() {
	dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ GAME ROULETTE ]" \
		--msgbox "In Game Roulette mode SAM selects games for you. \n\nYou have a pre-defined amount of time to play this game, then SAM will move on to play the next game. \n\nPlease do a cold reboot when done playing." 0 0
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ GAME ROULETTE ]" \
		--menu "Select an option" 0 0 0 \
		Roulette2 "Play a random game for 2 minutes. " \
		Roulette5 "Play a random game for 5 minutes. " \
		Roulette10 "Play a random game for 10 minutes. " \
		Roulette15 "Play a random game for 15 minutes. " \
		Roulette20 "Play a random game for 20 minutes. " \
		Roulette25 "Play a random game for 25 minutes. " \
		Roulette30 "Play a random game for 30 minutes. " \
		Roulettetimer "Play a random game for ${roulettetimer} secs (roulettetimer in MiSTer_SAM.ini). " 2>"/tmp/.SAMmenu"	
	
		opt=$?
		menuresponse=$(<"/tmp/.SAMmenu")
		
		if [ "$opt" != "0" ]; then
			sam_menu
		elif [ "${menuresponse}" == "Roulettetimer" ]; then
			{
			echo "gametimer=${roulettetimer}"
			echo "mute=no"
			echo "listenmouse=No"
			echo "listenkeyboard=No"
			echo "listenjoy=No"
			} >/tmp/.SAM_tmp/gameroulette.ini
		else
			timemin=${menuresponse//Roulette/}
			{		
			echo "gametimer=$((timemin*60))"
			echo "mute=no"
			echo "listenmouse=No"
			echo "listenkeyboard=No"
			echo "listenjoy=No"
			} >/tmp/.SAM_tmp/gameroulette.ini
		fi
		sam_start
}

function samedit_include() {
	dialog --clear --no-cancel --ascii-lines --colors \
		--backtitle "Super Attract Mode" --title "[ CATEGORY SELECTION ]" \
		--msgbox "Play games from only one category.\n\n\Z1Please use Everdrive packs for this mode. \Zn \n\nSome categories (like country selection) will probably work with some other rompacks as well. \n\nMake sure you have game lists created for this mode." 0 0
	dialog --clear --ascii-lines --no-tags \
		--backtitle "Super Attract Mode" --title "[ CATEGORY SELECTION ]" \
		--menu "Only play games from the following categories" 0 0 0 \
		''"("'usa'")"'' "Only USA Games" \
		''"("'japan'")"'' "Only Japanese Games" \
		''"("'europe'")"'' "Only Europe games" \
		'shoot '"'"'em' "Only Shoot 'Em Ups" \
		'beat '"'"'em' "Only Beat 'Em Ups" \
		'role playing' "Only Role Playing Games" \
		pinball "Only Pinball Games" \
		platformers "Only Platformers" \
		'genre/fight' "Only Fighting Games" \
		trivia "Only Trivia Games" \
		sports "Only Sport Games" \
		racing "Only Racing Games" \
		hacks "Only Hacks" \
		kiosk "Only Kiosk mode games" \
		translations "Only Translated Games" \
		homebrew "Only Homebrew" 2>"/tmp/.SAMmenu"

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	clear

	if [ "$opt" != "0" ]; then
		sam_menu
	else
		echo "Please wait... getting things ready."
		declare -a corelist=()
		declare -a gamelists=()
		categ="${menuresponse}"
		# echo "${menuresponse}"
		# Delete all temporary Game lists
		find ${gamelistpathtmp} -type f -name "*_gamelist.txt" -exec rm {} \;
		readarray -t gamelists <<< "$(find "${gamelistpath}" -name "*_gamelist.txt")"

		# echo ${gamelists[@]}
		for list in "${gamelists[@]}"; do
			listfile=$(basename "${list}")
			# awk -v category="$categ" 'tolower($0) ~ category' "${list}" > "${gamelistpathtmp}/${listfile}"
			fgrep -i "${categ}" "${list}" >"${tmpfile}"
			if [ $? -eq 0 ]; then
				awk -F'/' '!seen[$NF]++' "${tmpfile}" >"${gamelistpathtmp}/${listfile}"
			fi
		done

		#corelist=$(find "${gamelistpathtmp}" -name "*_gamelist.txt" -exec basename \{} \; | cut -d '_' -f 1)
		readarray -t corelist <<< "$(find "${gamelistpathtmp}" -name "*_gamelist.txt" -exec basename \{} \; | cut -d '_' -f 1)"
		dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ CATEGORY SELECTION ]" \
			--msgbox "SAM will start now and only play games from the '${categ^^}' category.\n\nOn cold reboot, SAM will get reset automatically to play all games again. " 0 0
		printf "%s\n" "${corelist[@]}" > "${corelistfile}"
		sam_start

	fi

}

function samedit_excltags() {
	excludetags="${gamelistpath}/.excludetags"
	
	function process_tag() {
		for core in "${corelist[@]}"; do
			[[ -f "${gamelistpathtmp}/${core}_gamelist.txt" ]] && rm "${gamelistpathtmp}/${core}_gamelist.txt"
			if [[ -e "${gamelistpath}/${core}_gamelist.txt" ]]; then
				grep -i "$categ" "${gamelistpath}/${core}_gamelist.txt" >>"${gamelistpath}/${core}_gamelist_exclude.txt"
			else
				grep -i "$categ" "${gamelistpath}/${core}_gamelist.txt" >"${gamelistpath}/${core}_gamelist_exclude.txt"
			fi
		done
	}
	
	if [ -f "${excludetags}" ]; then
		dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
		--msgbox "Currently excluded tags: \n\n$(cat "${excludetags}")" 0 0
	else
		dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
		--msgbox "Exclude hacks, prototypes, homebrew or other game categories you don't want SAM to show.\n\n" 0 0
	fi 

	dialog --clear --ascii-lines --no-tags --ok-label "Select" --cancel-label "Done" \
		--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
		--menu "Which tags do you want to exclude?" 0 0 0 \
		Beta "Beta Games" \
		Hack "Hacks" \
		Homebrew "Homebrew" \
		Prototype "Prototypes"  \
		Unlicensed "Unlicensed Games" \
		Translations "Translated Games" \
		USA "USA" \
		Japan "Japan" \
		Europe "Europe" \
		'' "Reset Exclusion Lists" 2>"/tmp/.SAMmenu" 

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")
	
	categ="${menuresponse}"
	
	if [ "$opt" != "0" ]; then
		sam_menu
	else
		echo " Please wait... creating exclusion lists."
		if [ -n "${categ}" ]; then
			if [ ! -s "${excludetags}" ]; then
				echo "${categ} " > "${excludetags}"
				process_tag
			else
				# Check if tag is already excluded
				if grep -qi "${categ}" "${excludetags}"; then
					dialog --clear --no-cancel --ascii-lines \
					--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
					--msgbox "${categ} has already been excluded. \n\n" 0 0
				else
					echo "${categ} " >> "${excludetags}"
					# TO DO: What if we don't have gamelists
					process_tag
				fi
			fi
		else
			for core in "${corelist[@]}"; do
				rm "${gamelistpath}/${core}_gamelist_exclude.txt" 2>/dev/null
				rm "${excludetags}" 2>/dev/null
			done
			dialog --clear --no-cancel --ascii-lines \
			--backtitle "Super Attract Mode" --title "[ EXCLUDE CATEGORY SELECTION ]" \
			--msgbox "All exclusion filters have been removed. \n\n" 0 0
			sam_menu
		fi
		find "${gamelistpath}" -name "*_gamelist_exclude.txt" -size 0 -print0 | xargs -0 rm
		samedit_excltags
	fi
	
}

function samedit_excltags_old() {
	# Looks better but doesn't work with gamepad
	dialog --title "[ EXCLUDE CATEGORY SELECTION ]" --ascii-lines --checklist \
		"Which tags do you want to exclude?" 0 0 0 \
		"Beta" "" OFF \
		"Hack" "" OFF \
		"Homebrew" "" OFF \
		"Prototypes" "" OFF \
		"Unlicensed" "" OFF \
		"Translations" "" OFF \
		"USA" "" OFF \
		"Japan" "" OFF \
		"Europe" "" OFF \
		"Australia" "" OFF \
		"Brazil" "" OFF \
		"China" "" OFF \
		"France" "" OFF \
		"Germany" "" OFF "Italy" "" OFF \
		"Korea" "" OFF \
		"Spain" "" OFF \
		"Sweden" "" OFF 2>"/tmp/.SAMmenu"

	opt=$?
	menuresponse=$(<"/tmp/.SAMmenu")

	if [ "$opt" != "0" ]; then
		sam_menu
	else
		echo " Please wait... creating exclusion lists."
		categ="$(echo "${menuresponse}" | tr ' ' '|')"
		if [ -n "${categ}" ]; then
			# TO DO: What if we don't have gamelists
			for core in "${corelist[@]}"; do
				[[ -f "${gamelistpathtmp}/${core}_gamelist.txt" ]] && rm "${gamelistpathtmp}/${core}_gamelist.txt"
				# Find out how to do this with grep, might be faster
				awk -v category="$categ" 'BEGIN {IGNORECASE = 1}  $0 ~ category' "${gamelistpath}/${core}_gamelist.txt" >"${gamelistpath}/${core}_gamelist_exclude.txt"
			done
		else
			for core in "${corelist[@]}"; do
				rm "${gamelistpath}/${core}_gamelist_exclude.txt"
			done
		fi
		find "${gamelistpath}" -name "*_excludelist.txt" -size 0 -exec rm '{}' \;
		samedit_taginfo
	fi

}

function sam_bgmmenu() {
	if [ "$sam_bgmmenu" == "0" ]; then
		dialog --clear --no-cancel --ascii-lines \
		--backtitle "Super Attract Mode" --title "[ SAMVIDEO, BGM & TTY2OLED ]" \
		--msgbox "SAMVIDEO\n----------------\nSAM can play back video on the MiSTer\nBy default, playback alternates with other cores. You can change more settings in MiSTer_SAM.ini\n\n\nBGM\n----------------\nWhile SAM is shuffling games, play some music.\nThis installs wizzomafizzo's BGM script to play music in SAM.\n\nWe'll drop one playlist in the music folder (80s.pls) as a default playlist. You can customize this later or to your liking by dropping mp3's or pls files in /media/fat/music folder.\n\n\nTTY2OLED\n----------------\nTTY2OLED is a hardware display for the MiSTer. ONLY ENABLE THIS IF YOU HAVE A TTY2OLED DISPLAY, or else SAM might not work correctly." 0 0
		sam_bgmmenu=1
		sam_bgmmenu
	else
		dialog --clear --ascii-lines --no-tags \
			--backtitle "Super Attract Mode" --title "[ SAMVIDEO, BGM & TTY2OLED ]" \
			--menu "Select from the following options?" 0 0 0 \
			enablesv "SAMVIDEO: Enable Video Playback for SAM" \
			disablesv "SAMVIDEO: Disable Video Playback for SAM" \
			enablecrt "SAMVIDEO: CRT output" \
			enablehdmi "SAMVIDEO: HDMI output" \
			enableyt "SAMVIDEO: Youtube Playback" \
			enablear "SAMVIDEO: Archive Playback" \
			enablebgm "BGM: Enable BGM for SAM" \
			disableplay "BGM: Disable BGM Play (in case songs play twice)" \
			disablebgm "BGM: Disable BGM for SAM" \
			enabletty "TTY2OLED: Enable TTY2OLED support for SAM" \
			disabletty "TTY2OLED: Disable TTY2OLED support for SAM" 2>"/tmp/.SAMmenu" 

		opt=$?
		menuresponse=$(<"/tmp/.SAMmenu")
		
		if [ "$opt" != "0" ]; then
			sam_menu
		else
			if [ -f /media/fat/Scripts/MiSTer_SAM.ini ]; then
				if [[ "${menuresponse,,}" == "enablebgm" ]]; then
					if [ ! -f "/media/fat/Scripts/bgm.sh" ]; then
						echo " Installing BGM to Scripts folder"
						repository_url="https://github.com/wizzomafizzo/MiSTer_BGM"
						get_samstuff bgm.sh /tmp
						mv --force /tmp/bgm.sh /media/fat/Scripts/
					else
						echo " BGM script is installed already. Updating just in case..."
						echo -n "stop" | socat - UNIX-CONNECT:/tmp/bgm.sock 2>/dev/null
						kill -9 "$(ps -o pid,args | grep '[b]gm.sh' | awk '{print $1}' | head -1)" 2>/dev/null
						rm /tmp/bgm.sock 2>/dev/null
						repository_url="https://github.com/wizzomafizzo/MiSTer_BGM"
						get_samstuff bgm.sh /tmp
						mv --force /tmp/bgm.sh /media/fat/Scripts/
						echo " Resetting BGM now."
					fi
					echo " Updating MiSTer_SAM.ini to use Mute=Core"
					sed -i '/mute=/c\mute="'"Core"'"' /media/fat/Scripts/MiSTer_SAM.ini
					/media/fat/Scripts/bgm.sh
					sync
					repository_url="https://github.com/mrchrisster/MiSTer_SAM"
					get_samstuff Media/80s.pls /media/fat/music
					[[ ! $(grep -i "bgm" /media/fat/Scripts/MiSTer_SAM.ini) ]] && echo "bgm=Yes" >> /media/fat/Scripts/MiSTer_SAM.ini
					sed -i '/bgm=/c\bgm="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
					#echo " All Done. Starting SAM now."
					#/media/fat/Scripts/MiSTer_SAM_on.sh start
				elif [[ "${menuresponse,,}" == "disableplay" ]]; then
					sed -i '/bgmplay=/c\bgmplay="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini

				elif [[ "${menuresponse,,}" == "disablebgm" ]]; then
					echo " Uninstalling BGM, please wait..."
					echo -n "stop" | socat - UNIX-CONNECT:/tmp/bgm.sock 2>/dev/null
					[[ -e /media/fat/Scripts/bgm.sh ]] && /media/fat/Scripts/bgm.sh stop
					[[ -e /media/fat/Scripts/bgm.sh ]] && rm /media/fat/Scripts/bgm.sh
					[[ -e /media/fat/music/bgm.ini ]] && rm /media/fat/music/bgm.ini
					rm /tmp/bgm.sock 2>/dev/null
					sed -i '/bgm.sh/d' ${userstartup}
					sed -i '/Startup BGM/d' ${userstartup}
					sed -i '/bgm=/c\bgm="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
					sed -i '/mute=/c\mute="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
					#echo " Done."
				elif [[ "${menuresponse,,}" == "enabletty" ]]; then
					sed -i '/ttyenable=/c\ttyenable="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "disabletty" ]]; then
					sed -i '/ttyenable=/c\ttyenable="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "enablesv" ]]; then
					sed -i '/samvideo=/c\samvideo="'"Yes"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "disablesv" ]]; then
					sed -i '/samvideo=/c\samvideo="'"No"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "enableyt" ]]; then
					sed -i '/samvideo_source=/c\samvideo_source="'"Youtube"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "enablear" ]]; then
					sed -i '/samvideo_source=/c\samvideo_source="'"Archive"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "enablehdmi" ]]; then
					sed -i '/samvideo_output=/c\samvideo_output="'"HDMI"'"' /media/fat/Scripts/MiSTer_SAM.ini
				elif [[ "${menuresponse,,}" == "enablecrt" ]]; then
					sed -i '/samvideo_output=/c\samvideo_output="'"CRT"'"' /media/fat/Scripts/MiSTer_SAM.ini
				fi
				dialog --clear --ascii-lines --no-cancel \
				--backtitle "Super Attract Mode" --title "[ BACKGROUND MUSIC PLAYER ]" \
				--msgbox "Changes saved!" 0 0
				sam_bgmmenu
			else
				echo "Error: MiSTer_SAM.ini not found. Please update SAM first"
			fi
		fi
	fi
}






# ========= MAIN =========

init_vars

read_samini

init_paths

init_data

if [ "${1,,}" != "--source-only" ]; then
	parse_cmd "${@}" # Parse command line parameters for input
fi
