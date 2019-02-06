local enemyObjectGroup = ObjectGroup.find("enemies")
fonts = {nil, graphics.FONT_SMALL, graphics.FONT_DEFAULT, graphics.FONT_LARGE}

header_text = "Rainy Stats"
text_string = 
[[&lt&Armor&!&: %d
&lt&Attack Speed&!&: %.2f
&lt&Attack Damage&!&: %d
&lt&Critical Strike Chance&!&: %d

&lt&Speed&!&: %.2f
&lt&Experience&!&: %s / %s
&lt&Remaining Enemies&!&: %d

&lt&DPS&!&: %s (%d | %d)]]

function drag(self, boundries)
    -- If draggable, mouse pressed, and bounded
    if isDragging(self, boundries) then
        -- Toggle dragging and set old mouse and window position for calculation
        self.mouse.dragging = true
        self.mouse.clickedMouse.x = self.mouse.position.x
        self.mouse.clickedMouse.y = self.mouse.position.y
        self.settings.oldPosition.x = self.settings.position.x
        self.settings.oldPosition.y = self.settings.position.y
    -- If dragging and mouse held down
    elseif self.mouse.dragging and input.checkMouse("left") == input.HELD then
        -- Update window position
        self.settings.position.x = (
            self.mouse.position.x - (self.mouse.clickedMouse.x - self.settings.oldPosition.x)
        ) 
        self.settings.position.y = (
            self.mouse.position.y - (self.mouse.clickedMouse.y - self.settings.oldPosition.y)
        )
    -- Mostly if the mouse isn't pressed or held, toggle dragging
    else
        self.mouse.dragging = false
    end
end

function updateSize(self)
    -- If visible
    if self.settings.fontIndex ~= 1 then
        -- There is a slight offset between font_small and font_medium which
        -- is different between medium and large. It's weird idek..
        self.settings.headerFix = 3
        if self.settings.fontIndex == 2 then
            -- The smaller font should go up a little more
            self.settings.headerFix = 1
        end
        -- Set header height, get font size, adjust size of window.
        self.settings.headerHeight = graphics.textHeight(header_text, fonts[self.settings.fontIndex])
        self.settings.fontSize.x = graphics.textWidth(text_string, fonts[self.settings.fontIndex])
        self.settings.fontSize.y = graphics.textHeight(text_string, fonts[self.settings.fontIndex])
        self.settings.size.x = self.settings.fontSize.x + 2 * self.settings.padding
        self.settings.size.y = self.settings.headerHeight + self.settings.fontSize.y + 2 * self.settings.padding
    end
end

function drawHeader(self)
    -- Bar
    setColor(self.settings.headerColor)
    graphics.rectangle(
        self.settings.position.x - 1, self.settings.position.y, 
        self.settings.position.x + self.settings.size.x + 1, 
        self.settings.position.y + self.settings.headerHeight
    )

    -- Top Text
    graphics.color(Color.WHITE)
    graphics.print(header_text,
        self.settings.position.x + self.settings.size.x / 2, 
        self.settings.position.y + self.settings.headerFix,
        fonts[self.settings.fontIndex],
        graphics.ALIGN_MIDDLE, graphics.ALIGN_TOP
    )
end

function drawBody(self, playerAccessor)
    local enemyCount = #enemyObjectGroup:findAll()

    -- Background
    setColor(self.settings.backgroundColor)
    graphics.rectangle(
        self.settings.position.x, 
        self.settings.position.y + self.settings.headerHeight, 

        self.settings.position.x + self.settings.size.x, 
        self.settings.position.y + self.settings.size.y
    )

    -- Print our stats
    setColor({color = Color.WHITE, alpha = 1})
    graphics.printColor(
        string.format(text_string,
            playerAccessor.armor, -- Armor
            playerAccessor.attack_speed, -- Attack Speed
            playerAccessor.damage, -- Attack Damage
            playerAccessor.critical_chance, -- Critical Strike Chance
            playerAccessor.pHspeed, -- Speed
            formatNumber(playerAccessor.expr), formatNumber(playerAccessor.maxexp), -- Experience
            enemyCount, -- Remaining Enemies
            shortNumber(self.stats.totalAllyDPS), 
            self.stats.secondsInCombat, self.stats.secondsOutOfCombat), 
            -- DPS (In Combat | Out Combat)
        self.settings.position.x + 2 * self.settings.padding, 
        self.settings.position.y + 2 * self.settings.padding + self.settings.headerHeight, 
        fonts[self.settings.fontIndex]
    )
end

function isDragging(self, boundries)
    return (
        self.settings.draggable 
        and input.checkMouse("left") == input.PRESSED 
        and isBounded(self.mouse.position, boundries)
    )
end

function isBounded(coordinates, boundries)
    if coordinates.x >= boundries.start.x and coordinates.x <= boundries.ending.x then
        if coordinates.y >= boundries.start.y and coordinates.y <= boundries.ending.y then
            return true
        end
    end

    return false
end

-- Just so I don't have to type out alpha and color :p
function setColor(colorThing)
    graphics.alpha(colorThing.alpha)
    graphics.color(colorThing.color)
end

-- Format time as seconds into minutes and seconds
function secondsToClock(s)
    local minutes = math.floor(s / 60)
    local seconds = s % 60

    return string.format("%dm %ds", minutes, seconds)
end

-- Format numbers for display
-- 0.0k / 0.0m
function shortNumber(n)
    if n >= 10^6 then
        return string.format("%.1fm", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.1fk", n / 10^3)
    else
        return string.format("%.1f", n)
    end
end

-- 000,000,000,000,000,000,000,000,000
function formatNumber(amount)
    local formatted = math.floor(amount)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
end
