local L = {

	["Alterac Valley"] = true,
	["Arathi Basin"] = true,
	["Warsong Gulch"] = true,
	["Eye of the Storm"] = true,
	["Wintergrasp"] = true,
	["Isle of Conquest"] = true,

	["Auto Quest Turnins"] = true,
	["Bar"] = "Timer Bar",
	["Width"] = true,
	["Height"] = true,
	["Texture"] = true,
	["Map Scale"] = true,
	["Hide Border"] = true,
	["Port Timer"] = true,
	["Wait Timer"] = true,
	["Show/Hide Anchor"] = true,
	["Narrow Map Mode"] = true,
	["Narrow Anchor Left"] = true,
	["Test"] = true,
	["Flip Growth"] = "Flip Bar Stack",
	["Single Group"] = true,
	["Move Scoreboard"] = true,
	["Spacing"] = true,
	["Request Sync"] = true,
	["Fill Grow"] = true,
	["Fill Right"] = true,
	["Font"] = true,
	["Time Position"] = true,
	["Border Width"] = true,
	["Send to BG"] = true,
	["Send to SAY"] = true,
	["Cancel Timer"] = true,
	["Move Capture Bar"] = true,
	["Move Vehicle Seat"] = true,

	["Port: %s"] = true,
	["Queue: %s"] = true,
	["Battle Begins"] = true,
	["1 minute"] = true,
	["60 seconds"] = true,
	["30 seconds"] = true,
	["15 seconds"] = true,
	["One minute until"] = true,
	["Forty five seconds"] = true,
	["Thirty seconds until"] = true,
	["Fifteen seconds until"] = true,
	["has begun"] = true,
	["%s: %s - %d:%02d"] = true,

	["Bases: (%d+)  Resources: (%d+)/(%d+)"] = true,
	["has assaulted"] = true,
	["claims the"] = true,
	["has taken the"] = true,
	["has defended the"] = true,
	["Final: %d - %d"] = true,
	["wins %d-%d"] = true,

	["was picked up by (.+)!"] = true,
	["was picked up by (.+)!2"] = true,
	["dropped"] = true,
	["captured the"] = true,
	["Flag respawns"] = true,
	["%s's flag carrier: %s (%s)"] = true,

	["Smith Regzar"] = true,
	["Murgot Deepforge"] = true,
	["Primalist Thurloga"] = true,
	["Arch Druid Renferal"] = true,
	["Stormpike Ram Rider Commander"] = true,
	["Frostwolf Wolf Rider Commander"] = true,

	["Upgrade to"] = true,
	["Wicked, wicked, mortals!"] = true,
	["Ivus begins moving"] = true,
	["WHO DARES SUMMON LOKHOLAR"] = true,
	["The Ice Lord has arrived!"] = true,
	["Lokholar begins moving"] = true,

	["^(.+) has taken the flag!"] = true,
	["Bases: (%d+)  Victory Points: (%d+)/(%d+)"] = true,

	["Alliance Keep"] = true,
	["Horde Keep"] = true,

	["Goblin"] = true,
	["seaforium bombs"] = true,
	["It's broken"] = true,
	["halfway"] = true,
}

CappingLocale = L
function L:CreateLocaleTable(t)
	for k, v in pairs(t) do
		self[k] = (v == true and k) or v
	end
end

L:CreateLocaleTable(L)
