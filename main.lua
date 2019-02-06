-- Made by who is he
-- Risk of Rain mod to display some player stats
-- Calculates: Armor, AS, AD, Crit, Speed, Experience, Remaining Enemies, and DPS

json = require("json")
Display = require("display")
Combat = require("combat")

combat = Combat()
display = Display(combat)

registercallback("onGameStart", function()
    combat = Combat()
    display.combat = combat
end)

registercallback("onStep", function()
    combat:update()
    display:update()
end)

registercallback("onPlayerHUDDraw", function(player, x, y)
    display:draw(player)
end)

registercallback("onHit", function(damager, hit, x, y)
    combat:onHit(damager, hit, x, y)
end)

print("Rainy Stats v1.3.0 loaded")
