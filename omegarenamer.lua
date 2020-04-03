--[[
Copyright © 2020, Sjshovan (LoTekkie)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Omega Renamer nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (LoTekkie) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

_addon.name = "Omega Renamer"
_addon.author = "Sjshovan (LoTekkie) sjshovan@gmail.com"
_addon.description = 'Official Omega private server addon that fixes npc names through automatic updates.'
_addon.version = '0.9.0'
_addon.commands = {'/omegarenamer', '/orenamer', '/oren'}

local http = require("socket.http")
local ltn12 = require("ltn12")

require("common")
require("constants")
require("helpers")

local help = {
    commands = {
        buildHelpSeperator('=', 28),
        buildHelpTitle('Commands'),
        buildHelpSeperator('=', 28),
        buildHelpCommandEntry('reload', 'Reload Omega Renamer.'),
        buildHelpCommandEntry('about', 'Display information about Omega Renamer.'),
        buildHelpCommandEntry('help', 'Display Omega Renamer commands.'),
        buildHelpSeperator('=', 28),
    },
    about = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('About'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry('Name', _addon.name),
        buildHelpTypeEntry('Description', _addon.description),
        buildHelpTypeEntry('Author', _addon.author),
        buildHelpTypeEntry('Version', _addon.version),
        buildHelpSeperator('=', 23),
    },
}

function display_help(table_help)
    for index, command in pairs(table_help) do
        displayResponse(command)
    end
end

ashita.register_event('load', function()
    local d = string.format('%s/addons/OmegaRenamer/%s/', AshitaCore:GetAshitaInstallPath(), 'data');
    if (not ashita.file.dir_exists(d)) then
        ashita.file.create_dir(d);
    end
    local response = {}
    http.request{
        method = "GET",
        url = "https://omega-renamer.s3.amazonaws.com/omega.lua",
        sink = ltn12.sink.table(response)
    }
    local remoteMap = table.concat(response)
    local f = io.open(string.format('%s/%s', d, "map.lua"), 'w+');
    if (f ~= nil) then
        f:write(remoteMap);
        f:close();
    end
    require("data.map")
end)

ashita.register_event('command', function(command, ntype)

    local command_args = command:lower():args()
        
    if not tableContains(_addon.commands, command_args[1]) then
        return false
    end 
    
    if command_args[2] == 'reload' or command_args[2] == 'r' then
        AshitaCore:GetChatManager():QueueCommand('/addon reload omegarenamer', 1)
    
    elseif command_args[2] == 'about' or command_args[2] == 'a' then
        display_help(help.about)
        
    elseif command_args[2] == 'help' or command_args[2] == 'h' then
        display_help(help.commands)

    else
        display_help(help.commands)
    end

    return false
end)

ashita.register_event('prerender', function()
    local zoneId = AshitaCore:GetDataManager():GetParty():GetMemberZone(0);
    local npcs = map[zoneId];
    if (npcs ~= nil) then
        for _, data in pairs(npcs) do
            local npcIndex = bit.band(data[1], 0x0FFF);
            AshitaCore:GetDataManager():GetEntity():SetName(npcIndex, data[2]);
        end
    end
end)