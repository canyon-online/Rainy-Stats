-- meter.lua
-- Creates a display for combat.lua
require("displayhelper")

local Display, DisplayMT = newtype("Display")
DisplayMT.__index = {}

function DisplayMT:__init(combat)
    self.settings = {
        active = true,
        draggable = true,
        position = {x = 20, y = 100},
        oldPosition = {x = 20, y = 100},
        size = {x = 0, y = 0},
        fontSize = {x = 0, y = 0},
        fontIndex = 3,
        headerHeight = 0,
        backgroundColor = {color = Color.BLACK, alpha = 2 / 10},
        headerColor = {color = Color.fromHex(0x737495), alpha = 10 / 10},
        padding = 2,
        headerFix = 3,
        keybind = "j"
    }

    self.stats = {
        totalAllyDamage = 0,
        totalAllyDPS = 0,
        allyCount = 0,
        secondsInCombat = 0,
        secondsOutOfCombat = 0
    }

    self.mouse = {
        clickedMouse = {x = 0, y = 0},
        position = {x = 0, y = 0},
        dragging = false
    }

    self.combat = combat
    self.settings.headerHeight = graphics.textHeight(header_text, fonts[self.settings.fontIndex])
    self.settings.fontSize.x = graphics.textWidth(text_string, fonts[self.settings.fontIndex])
    self.settings.fontSize.y = graphics.textHeight(text_string, fonts[self.settings.fontIndex])
    self.settings.size.x = self.settings.fontSize.x + 2 * self.settings.padding
    self.settings.size.y = self.settings.headerHeight + self.settings.fontSize.y + 2 * self.settings.padding
end

function DisplayMT.__index:draw(player)
    local playerAccessor = player:getAccessor()
    -- We don't care to draw or evaluate anything if we aren't even active
    if not self.settings.active then return end

    -- Header --
    drawHeader(self)

    -- Body --
    drawBody(self, playerAccessor)
end

function DisplayMT.__index:update()
    -- Dragable window boundries
    local boundries = {
        start = {
            x = self.settings.position.x,
            y = self.settings.position.y
        },
        ending = {
            x = self.settings.position.x + self.settings.size.x,
            y = self.settings.position.y + self.settings.size.y
        }
    }

    -- Check toggle of display size
    if input.checkKeyboard(self.settings.keybind) == input.PRESSED then
        self.settings.fontIndex = (self.settings.fontIndex % #fonts) + 1

        if self.settings.fontIndex == 1 then
            self.settings.active = false
        else
            self:updateSize(text_string)
            self.settings.active = true
        end
    end

    -- Set some stats to be updated
    self.mouse.position.x, self.mouse.position.y = input.getMousePos(true)
    self.stats.totalAllyDamage = 0
    self.stats.totalAllyDPS = 0
    self.stats.allyCount = 0
    self.stats.secondsInCombat = 0
    self.stats.secondsOutOfCombat = 0

    -- Count the number of ally players and update dps, time in combat, etc.
    for i, player in ipairs(self.combat.teams.allies) do
        self.stats.allyCount = self.stats.allyCount + 1
        self.stats.totalAllyDamage = self.stats.totalAllyDamage + player.combat.damage
        self.stats.totalAllyDPS = self.stats.totalAllyDPS + player.combat.DPS

        if player.combat.secondsInCombat > self.stats.secondsInCombat then
            self.stats.secondsInCombat = player.combat.secondsInCombat
        end

        if player.combat.secondsOutOfCombat > self.stats.secondsOutOfCombat then
            self.stats.secondsOutOfCombat = player.combat.secondsOutOfCombat
        end
    end

    -- Check to see if the window is being dragged
    if self.settings.active then
        self:drag(boundries)
    end
end

function DisplayMT.__index:drag(boundries)
    drag(self, boundries)
end

function DisplayMT.__index:updateSize()
    updateSize(self)
end


return Display
